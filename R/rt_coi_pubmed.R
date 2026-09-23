# Conflict-of-interest statements recorded in PubMed.
#
# Some journals print the conflict-of-interest disclosure only in the PDF or on
# the publisher site, not in the PMC XML, so the XML detector cannot see it.
# PubMed records many of these disclosures in the <CoiStatement> element,
# which these helpers fetch.


#' Fetch conflict-of-interest statements recorded in PubMed
#'
#' Retrieves the `<CoiStatement>` that PubMed records for an article, which
#' holds the conflict-of-interest disclosure also when it is absent from the
#' full-text XML (the main source of missed disclosures in the XML detector).
#'
#' @param pmids A character or numeric vector of PubMed IDs.
#' @param api_key An NCBI API key; defaults to the `ENTREZ_KEY` environment
#'   variable.
#' @return A tibble with one row per unique PubMed ID: `pmid`,
#'   `has_coi_statement` and `coi_statement` (`""` when PubMed has none).
#' @seealso [rt_fill_coi_pubmed()], [rt_coi_pmc()]
#' @examples
#' \donttest{
#' # Needs internet access.
#' try(rt_coi_pubmed(c("32171256", "36696006")))
#' }
#' @export
rt_coi_pubmed <- function(pmids, api_key = Sys.getenv("ENTREZ_KEY")) {
  pmids <- unique(trimws(as.character(pmids)))
  pmids <- pmids[!is.na(pmids) & grepl("^[0-9]+$", pmids)]
  out <- tibble::tibble(pmid = pmids, has_coi_statement = FALSE,
                        coi_statement = "")
  for (chunk in split(seq_along(pmids), ceiling(seq_along(pmids) / 200))) {
    uri <- paste0(
      "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi",
      "?db=pubmed&retmode=xml&id=", paste(pmids[chunk], collapse = ","),
      if (nzchar(api_key)) paste0("&api_key=", api_key)
    )
    got <- .parse_pubmed_coi(.read_xml_retry(uri))
    m <- match(pmids[chunk], got$pmid)
    found <- !is.na(m) & nzchar(ifelse(is.na(m), "", got$coi_statement[m]))
    out$coi_statement[chunk[found]] <- got$coi_statement[m[found]]
    out$has_coi_statement[chunk[found]] <- TRUE
    if (length(chunk) == 200) Sys.sleep(if (nzchar(api_key)) 0.11 else 0.34)
  }
  out
}


#' Fill missed conflict-of-interest disclosures from PubMed
#'
#' For rows of detector output where no conflict-of-interest statement was
#' found (`is_coi_pred` is `FALSE`) but a PubMed ID is known, looks the
#' article up with [rt_coi_pubmed()] and, when PubMed records a statement,
#' sets `is_coi_pred` to `TRUE` and `coi_text` to that statement. A new
#' `coi_source` column records where each disclosure came from.
#'
#' Note that the accuracy estimates in [rt_accuracy] describe the full-text
#' detector alone; with this fallback the sensitivity is higher.
#'
#' @param data A data frame with `pmid`, `is_coi_pred` and `coi_text` columns,
#'   such as the output of [rt_all_pmc()] or [rt_coi_pmc()].
#' @inheritParams rt_coi_pubmed
#' @return `data` as a tibble with `is_coi_pred` and `coi_text` filled where
#'   PubMed has a statement, and `coi_source`: `"article"` (found in the full
#'   text), `"pubmed"` (filled from PubMed) or `NA` (none found).
#' @seealso [rt_coi_pubmed()]
#' @examples
#' \donttest{
#' # Needs internet access.
#' res <- rt_all_pmc(system.file(
#'   "extdata", "PMID32171256-PMC7071725.xml", package = "rtransparency"
#' ))
#' res <- try(rt_fill_coi_pubmed(res))
#' }
#' @export
rt_fill_coi_pubmed <- function(data, api_key = Sys.getenv("ENTREZ_KEY")) {
  need <- c("pmid", "is_coi_pred", "coi_text")
  if (!is.data.frame(data) || !all(need %in% names(data))) {
    stop("`data` must be a data frame with columns ",
         paste(need, collapse = ", "), ".", call. = FALSE)
  }
  data <- tibble::as_tibble(data)
  data$coi_source <- ifelse(data$is_coi_pred %in% TRUE, "article", NA_character_)
  todo <- which(!(data$is_coi_pred %in% TRUE) & !is.na(data$pmid) &
                  grepl("^[0-9]+$", data$pmid))
  if (!length(todo)) return(data)
  pm <- rt_coi_pubmed(data$pmid[todo], api_key = api_key)
  m <- match(as.character(data$pmid[todo]), pm$pmid)
  hit <- !is.na(m) & pm$has_coi_statement[m] %in% TRUE
  rows <- todo[hit]
  data$is_coi_pred[rows] <- TRUE
  data$coi_text[rows] <- pm$coi_statement[m[hit]]
  data$coi_source[rows] <- "pubmed"
  data
}


# Parse PubMed EFetch XML into PMID and CoiStatement text.
.parse_pubmed_coi <- function(doc) {
  arts <- xml2::xml_find_all(doc, "//PubmedArticle")
  pmid <- xml2::xml_text(xml2::xml_find_first(arts, "./MedlineCitation/PMID"))
  coi <- xml2::xml_text(xml2::xml_find_first(arts, ".//CoiStatement"))
  coi[is.na(coi)] <- ""
  tibble::tibble(pmid = pmid, coi_statement = trimws(coi))
}
