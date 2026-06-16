# Fetch PMC Open Access full-text XML by PMCID.
#
# Internal helpers used by the accuracy benchmark to obtain NCBI PMC full-text
# JATS XML for the detectors. The detectors are built for NCBI-flavored PMC XML,
# so we fetch from NCBI E-utilities (EFetch) by default, with the PMC OAI-PMH
# service as a fallback. (Europe PMC serves a different JATS flavor that the
# detectors do not parse, so it is not used here.) The OAI-PMH fallback is
# adapted from metareadr::mt_read_pmcoa() (Stylianos Serghiou, GPL-3;
# https://github.com/serghiou/metareadr).
#
# Results are cached on disk: if dest exists and is non-empty, the download is
# skipped unless overwrite = TRUE.


# Normalize a PMCID to the "PMC#######" form (accepts "PMC123", "123", 123).
.normalize_pmcid <- function(pmcid) {
  p <- gsub("\\s", "", as.character(pmcid))
  if (!grepl("^PMC", p)) {
    p <- paste0("PMC", p)
  }
  p
}


# Read XML from a URL with a few retries to ride out transient errors such as
# the NCBI 429 rate-limit response. Pauses (increasingly) between attempts.
.read_xml_retry <- function(uri, tries = 3L, pause = 1) {
  doc <- NULL
  for (attempt in seq_len(tries)) {
    doc <- tryCatch(xml2::read_xml(uri), error = function(e) e)
    if (!inherits(doc, "error")) {
      return(doc)
    }
    if (attempt < tries) {
      Sys.sleep(pause * attempt)
    }
  }
  stop(conditionMessage(doc), call. = FALSE)
}


# Retrieve full-text XML via NCBI E-utilities EFetch (db = pmc). Returns an
# xml_document rooted at <pmc-articleset>. An NCBI API key (ENTREZ_KEY env var)
# raises the rate limit from 3 to 10 requests per second.
.fetch_pmc_doc_efetch <- function(pmcid, api_key = Sys.getenv("ENTREZ_KEY")) {
  numeric_id <- sub("^PMC", "", pmcid)
  uri <- paste0(
    "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi",
    "?db=pmc&id=", numeric_id, "&rettype=xml"
  )
  if (nzchar(api_key)) {
    uri <- paste0(uri, "&api_key=", api_key)
  }
  .read_xml_retry(uri)
}


# Retrieve full-text XML via the PMC OAI-PMH service, returning an xml_document.
# Adapted from metareadr::mt_read_pmcoa() (Stylianos Serghiou, GPL-3).
.fetch_pmc_doc_oai <- function(pmcid) {
  numeric_id <- sub("^PMC", "", pmcid)
  uri <- paste0(
    "https://www.ncbi.nlm.nih.gov/pmc/oai/oai.cgi?verb=GetRecord",
    "&identifier=oai:pubmedcentral.nih.gov:", numeric_id,
    "&metadataPrefix=pmc"
  )
  record <- .read_xml_retry(uri)
  err <- xml2::xml_text(xml2::xml_find_all(record, "d1:error"))
  if (length(err)) {
    stop("OAI service error for ", pmcid, ": ", paste(err, collapse = "; "),
         call. = FALSE)
  }
  record
}


# Retrieve the parsed full-text XML for a PMCID, trying the preferred backend
# first and the other as a fallback. Returns an xml_document or throws.
.fetch_pmc_doc <- function(pmcid, backend = c("efetch", "oai")) {
  backend <- match.arg(backend)
  order <- if (backend == "efetch") c("efetch", "oai") else c("oai", "efetch")

  last_err <- NULL
  for (b in order) {
    doc <- tryCatch(
      if (b == "efetch") .fetch_pmc_doc_efetch(pmcid) else .fetch_pmc_doc_oai(pmcid),
      error = function(e) {
        last_err <<- e
        NULL
      }
    )
    if (!is.null(doc)) {
      return(doc)
    }
  }
  if (!is.null(last_err)) {
    stop(last_err)
  }
  stop("No working fetch backend for ", pmcid, call. = FALSE)
}


# Fetch the full-text XML for a PMCID and write it to dest. Returns dest on
# success, or NULL (with a warning) on failure so callers can skip and log.
.fetch_pmc_xml <- function(pmcid, dest, backend = c("efetch", "oai"),
                           overwrite = FALSE) {
  backend <- match.arg(backend)
  pmcid <- .normalize_pmcid(pmcid)

  if (!overwrite && file.exists(dest) && file.info(dest)$size > 0) {
    return(dest)
  }
  dir.create(dirname(dest), showWarnings = FALSE, recursive = TRUE)

  doc <- tryCatch(
    .fetch_pmc_doc(pmcid, backend),
    error = function(e) {
      warning("Failed to fetch ", pmcid, ": ", conditionMessage(e), call. = FALSE)
      NULL
    }
  )
  if (is.null(doc)) {
    return(NULL)
  }
  xml2::write_xml(doc, dest)
  dest
}
