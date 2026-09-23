#' Extract article metadata from a PMC XML file.
#'
#' Reads a PMC XML file and returns its metadata as a one-row data frame:
#'     journal, publisher, article title, authors and affiliations, identifiers
#'     (PMID, PMCID, DOI), publication dates, and figure / table / reference
#'     counts.
#'
#' @param filename The path to the PMC XML file as a string.
#' @param remove_ns Ignored since version 1.2.0 and kept for backward
#'   compatibility. Default XML namespaces are now always removed, so a
#'   namespaced PMC XML file gives the same result as a plain one.
#' @return A one-row tibble of metadata. The column `is_success` indicates
#'     whether the file was parsed successfully.
#' @examples
#' \donttest{
#' filepath <- system.file(
#'   "extdata", "PMID32171256-PMC7071725.xml", package = "rtransparency"
#' )
#' rt_meta_pmc(filepath)
#' }
#' @export
rt_meta_pmc <- function(filename, remove_ns = TRUE) {

  # A lot of the PMC XML files are malformed
  article_xml <- tryCatch(.get_xml(filename, remove_ns), error = function(e) e)

  if (inherits(article_xml, "error")) {

    return(.xml_failure(filename, article_xml))

  }

  id_ls <- list(filename = filename)
  meta_ls <- .xml_metadata_c(article_xml, as_list = TRUE)
  # One normalization rule for the PMCID everywhere ("PMC<number>").
  meta_ls$pmcid_pmc <- .get_ids(article_xml)$pmcid_pmc

  status_ls <- list(is_success = TRUE)
  tibble::as_tibble(c(id_ls, meta_ls, status_ls))
}
