# Fetch PMC full-text XML and convert article identifiers.
#
# The detectors are built for NCBI-flavored PMC JATS XML, so full text is
# fetched from NCBI E-utilities (EFetch) by default, with the PMC OAI-PMH
# service as a fallback. The OAI-PMH fallback is adapted
# from metareadr::mt_read_pmcoa() (Stylianos Serghiou, GPL-3;
# https://github.com/serghiou/metareadr).


#' Download PubMed Central full-text XML
#'
#' Downloads the full-text JATS XML of articles in PubMed Central, ready for
#' [rt_all_pmc()] or [rt_all_pmc_dir()]. Identifiers can be PMCIDs, PubMed IDs
#' or DOIs (mixed freely); PubMed IDs and DOIs are first converted to PMCIDs
#' with [rt_convert_ids()]. Each article is saved as `<PMCID>.xml` in `dir`.
#'
#' Full text comes from NCBI E-utilities (EFetch), with the PMC OAI-PMH service
#' as a fallback. Only articles whose publisher allows XML download (the PMC
#' open-access and author-manuscript collections) have a full text; for others
#' NCBI returns the front matter only, which is saved but flagged with
#' `has_body = FALSE`, because most indicators need the article body.
#'
#' Existing non-empty files are reused, so an interrupted download can simply
#' be re-run. Requests are paced to NCBI's limit of 3 per second, or 10 per
#' second with an API key (set the `ENTREZ_KEY` environment variable or pass
#' `api_key`).
#'
#' @param ids A character vector of PMCIDs ("PMC7071725"), PubMed IDs
#'   ("32171256") or DOIs ("10.1186/s12874-020-0914-6").
#' @param dir The directory to save the XML files in (created if needed).
#' @param overwrite Whether to download again files that already exist.
#' @param source Where to download from: `"ncbi"` (NCBI PMC, the default,
#'   with the OAI-PMH service as fallback) or `"europepmc"` (the Europe PMC
#'   REST API). The detectors give the same results on both in a comparison of
#'   13 benchmark articles (`inst/benchmark/results_europepmc_parity.md`);
#'   Europe PMC omits some license URLs, so `oa_license` is then read from the
#'   license text.
#' @param api_key An NCBI API key; defaults to the `ENTREZ_KEY` environment
#'   variable.
#' @param progress Whether to show a progress bar.
#' @return A tibble with one row per identifier: the input `id`, its `pmcid`,
#'   the saved `file` (`NA` on failure), `is_success`, `has_body` (whether the
#'   XML contains the article body) and the `error` message on failure.
#' @seealso [rt_convert_ids()], [rt_all_pmc_dir()]
#' @examples
#' \donttest{
#' # Needs internet access; failures are reported per identifier.
#' dir <- file.path(tempdir(), "pmc")
#' got <- rt_fetch_pmc("PMC7071725", dir, progress = FALSE)
#' got
#' }
#' @export
rt_fetch_pmc <- function(ids, dir = ".", overwrite = FALSE,
                         source = c("ncbi", "europepmc"),
                         api_key = Sys.getenv("ENTREZ_KEY"), progress = TRUE) {
  source <- match.arg(source)
  if (!is.character(ids) && !is.numeric(ids)) {
    stop("`ids` must be a character vector of identifiers.", call. = FALSE)
  }
  ids <- trimws(as.character(ids))
  dir.create(dir, showWarnings = FALSE, recursive = TRUE)

  pmcid <- rep(NA_character_, length(ids))
  conv_error <- rep("No PMCID found", length(ids))
  is_pmc <- grepl("^PMC[0-9]+$", ids, ignore.case = TRUE)
  pmcid[is_pmc] <- toupper(ids[is_pmc])
  if (any(!is_pmc)) {
    # A converter outage is reported per identifier, not as a failed call, so
    # PMCIDs in the same request are still downloaded.
    conv <- tryCatch(rt_convert_ids(ids[!is_pmc]), error = function(e) e)
    if (inherits(conv, "error")) {
      conv_error[!is_pmc] <- paste("ID conversion failed:", conditionMessage(conv))
    } else {
      pmcid[!is_pmc] <- conv$pmcid
    }
  }

  pause <- if (source == "europepmc" || nzchar(api_key)) 0.11 else 0.34
  out <- tibble::tibble(id = ids, pmcid = pmcid, file = NA_character_,
                        is_success = FALSE, has_body = NA,
                        error = ifelse(is.na(pmcid), conv_error, NA_character_))
  todo <- which(!is.na(pmcid))
  if (progress && length(todo)) {
    pb <- utils::txtProgressBar(min = 0, max = length(todo), style = 3)
    on.exit(close(pb), add = TRUE)
  }
  for (k in seq_along(todo)) {
    i <- todo[k]
    dest <- file.path(dir, paste0(pmcid[i], ".xml"))
    cached <- !overwrite && file.exists(dest) && file.info(dest)$size > 0
    res <- tryCatch({
      if (!cached) {
        doc <- if (source == "ncbi") .fetch_pmc_doc(pmcid[i], api_key = api_key)
               else .fetch_europepmc_doc(pmcid[i])
        xml2::write_xml(doc, dest)
        Sys.sleep(pause)
      }
      dest
    }, error = function(e) e)
    if (inherits(res, "error")) {
      out$error[i] <- conditionMessage(res)
    } else {
      out$file[i] <- dest
      out$is_success[i] <- TRUE
      out$has_body[i] <- .xml_has_body(dest)
    }
    if (progress) utils::setTxtProgressBar(pb, k)
  }
  out
}


#' Convert article identifiers with the PMC ID Converter
#'
#' Maps PubMed IDs, PMCIDs and DOIs to one another with the NCBI PMC ID
#' Converter API. Only articles in PubMed Central have a PMCID.
#'
#' @param ids A character vector of PubMed IDs, PMCIDs or DOIs (mixed freely).
#'   Bare numbers are treated as PubMed IDs.
#' @param email An optional contact email passed to NCBI, as its usage
#'   guidelines request for heavy use.
#' @return A tibble with one row per input: the input `id`, and its `pmcid`,
#'   `pmid` and `doi` (`NA` where not found).
#' @seealso [rt_fetch_pmc()]
#' @examples
#' \donttest{
#' # Needs internet access.
#' try(rt_convert_ids(c("32171256", "10.1186/s12874-020-0914-6", "PMC7071725")))
#' }
#' @export
rt_convert_ids <- function(ids, email = NULL) {
  ids <- trimws(as.character(ids))
  type <- ifelse(grepl("^PMC[0-9]+$", ids, ignore.case = TRUE), "pmcid",
                 ifelse(grepl("^[0-9]+$", ids), "pmid",
                        ifelse(grepl("^10\\.", ids), "doi", NA_character_)))
  out <- tibble::tibble(id = ids, pmcid = NA_character_, pmid = NA_character_,
                        doi = NA_character_)
  for (t in unique(stats::na.omit(type))) {
    idx <- which(type == t)
    for (chunk in split(idx, ceiling(seq_along(idx) / 200))) {
      uri <- paste0(
        "https://pmc.ncbi.nlm.nih.gov/tools/idconv/api/v1/articles/",
        "?format=xml&tool=rtransparency&idtype=", t,
        "&ids=", paste(utils::URLencode(ids[chunk], reserved = TRUE), collapse = ","),
        if (!is.null(email)) paste0("&email=", utils::URLencode(email, reserved = TRUE))
      )
      rec <- .parse_idconv(.read_xml_retry(uri))
      m <- match(tolower(ids[chunk]), tolower(rec$requested))
      out$pmcid[chunk] <- rec$pmcid[m]
      out$pmid[chunk] <- rec$pmid[m]
      out$doi[chunk] <- rec$doi[m]
    }
  }
  out
}


# Parse a PMC ID Converter XML response into one row per record.
.parse_idconv <- function(doc) {
  recs <- xml2::xml_find_all(doc, "//record")
  att <- function(a) {
    v <- xml2::xml_attr(recs, a)
    v[!is.na(v) & !nzchar(v)] <- NA_character_
    v
  }
  tibble::tibble(requested = att("requested-id"), pmcid = att("pmcid"),
                 pmid = att("pmid"), doi = att("doi"))
}


# Whether a saved PMC XML file contains the article body.
.xml_has_body <- function(file) {
  doc <- tryCatch(xml2::xml_ns_strip(xml2::read_xml(file)), error = function(e) NULL)
  !is.null(doc) &&
    !inherits(xml2::xml_find_first(doc, "//article/body"), "xml_missing")
}


# Normalize PMCIDs to the "PMC#######" form (accepts "PMC123", "123", 123).
.normalize_pmcid <- function(pmcid) {
  p <- gsub("\\s", "", as.character(pmcid))
  ifelse(grepl("^PMC", p, ignore.case = TRUE), toupper(p), paste0("PMC", p))
}


# Read XML from a URL with a few retries to ride out transient errors such as
# the NCBI 429 rate-limit response. Pauses (increasingly) between attempts.
.read_xml_retry <- function(uri, tries = 3L, pause = 1) {
  doc <- NULL
  for (attempt in seq_len(tries)) {
    doc <- tryCatch(suppressWarnings(xml2::read_xml(uri)), error = function(e) e)
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
# xml_document rooted at <pmc-articleset>. An NCBI API key raises the rate
# limit from 3 to 10 requests per second. EFetch answers an unavailable PMCID
# with an <error> element instead of an article, which is turned into an error
# here so it is never saved as if it were the article.
.fetch_pmc_doc_efetch <- function(pmcid, api_key = Sys.getenv("ENTREZ_KEY")) {
  numeric_id <- sub("^PMC", "", pmcid)
  uri <- paste0(
    "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi",
    "?db=pmc&id=", numeric_id, "&rettype=xml"
  )
  if (nzchar(api_key)) {
    uri <- paste0(uri, "&api_key=", api_key)
  }
  doc <- .read_xml_retry(uri)
  if (inherits(xml2::xml_find_first(doc, "//article"), "xml_missing")) {
    err <- xml2::xml_text(xml2::xml_find_first(doc, "//error"))
    stop("EFetch returned no article for ", pmcid,
         if (!is.na(err)) paste0(": ", err), call. = FALSE)
  }
  doc
}


# Retrieve full-text XML via the PMC OAI-PMH service, returning an xml_document.
# Adapted from metareadr::mt_read_pmcoa() (Stylianos Serghiou, GPL-3).
.fetch_pmc_doc_oai <- function(pmcid) {
  numeric_id <- sub("^PMC", "", pmcid)
  uri <- paste0(
    "https://pmc.ncbi.nlm.nih.gov/api/oai/v1/mh/?verb=GetRecord",
    "&identifier=oai:pubmedcentral.nih.gov:", numeric_id,
    "&metadataPrefix=pmc"
  )
  record <- .read_xml_retry(uri)
  err <- xml2::xml_text(xml2::xml_find_all(record, "//*[local-name()='error']"))
  if (length(err)) {
    stop("OAI service error for ", pmcid, ": ", paste(err, collapse = "; "),
         call. = FALSE)
  }
  record
}


# Retrieve full-text XML from the Europe PMC REST API.
.fetch_europepmc_doc <- function(pmcid) {
  .read_xml_retry(paste0("https://www.ebi.ac.uk/europepmc/webservices/rest/",
                         pmcid, "/fullTextXML"))
}


# Retrieve the parsed full-text XML for a PMCID, trying the preferred backend
# first and the other as a fallback. Returns an xml_document or throws.
.fetch_pmc_doc <- function(pmcid, backend = c("efetch", "oai"),
                           api_key = Sys.getenv("ENTREZ_KEY")) {
  backend <- match.arg(backend)
  order <- if (backend == "efetch") c("efetch", "oai") else c("oai", "efetch")

  errors <- character(0)
  for (b in order) {
    doc <- tryCatch(
      if (b == "efetch") .fetch_pmc_doc_efetch(pmcid, api_key) else .fetch_pmc_doc_oai(pmcid),
      error = function(e) {
        errors[[b]] <<- conditionMessage(e)
        NULL
      }
    )
    if (!is.null(doc)) {
      return(doc)
    }
  }
  stop(paste0(names(errors), ": ", errors, collapse = "; "), call. = FALSE)
}


# Fetch the full-text XML for a PMCID and write it to dest. Returns dest on
# success, or NULL (with a warning) on failure so callers can skip and log.
# Used by the benchmark scripts.
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
