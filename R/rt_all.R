#' Identify and extract all transparency indicators from a TXT file.
#'
#' Takes a plain-text article (a TXT file, or the text itself) and returns all
#'     ten indicators of transparency the package detects: conflicts of
#'     interest, funding, protocol registration, novelty, replication, data
#'     sharing, code sharing, generative-AI-use disclosure, open-access
#'     licensing and reporting-guideline use. The file is read once and every
#'     detector runs on the same text, with the same logic as the standalone
#'     plain-text functions ([rt_coi()], [rt_fund()], [rt_register()],
#'     [rt_novelty()], [rt_replication()], [rt_data_code()], [rt_ai()],
#'     [rt_oa()], [rt_reporting()]).
#'
#' @inheritParams rt_coi
#' @return A one-row tibble: the file name (`article`) and PMID (`pmid`, the
#'     digits after "PMID" in the file name, `NA` if absent), then each
#'     indicator with the text that triggered it. The indicator columns carry
#'     the same names as in [rt_all_pmc()] (`is_coi_pred`, `is_fund_pred`,
#'     `is_register_pred`, `is_novelty_pred`, `is_replication_pred`,
#'     `is_open_data`, `is_open_code`, `is_ai_pred`, `is_open_access`,
#'     `is_reporting_pred`), so the result can be passed to [rt_summary()].
#'     The pattern-function flags of the novelty and replication detectors are
#'     also returned; if one is `NA` it was not run. Unlike
#'     [rt_all_pmc()], `is_ai_pred` has no publication-year gate (see [rt_ai()]).
#'     `is_funded_pred` and `funding_text` are deprecated copies of the funding
#'     columns, kept for one release.
#' @seealso [rt_all_pdf()] for a PDF, [rt_all_txt_dir()] for many files, and
#'     [rt_all_pmc()] for PMC XML.
#' @examples
#' \donttest{
#' # Write a short example article to a temporary text file.
#' filepath <- file.path(tempdir(), "PMID00000000-PMC0000000.txt")
#' writeLines(c(
#'   "To our knowledge, this is the first study of its kind.",
#'   "Conflicts of interest: none declared.",
#'   "This work was supported by the National Institutes of Health (R01-000000).",
#'   "The protocol was registered at ClinicalTrials.gov (NCT00000000).",
#'   "All data and code are available at https://github.com/example/repo.",
#'   "We independently replicated the original analysis."
#' ), filepath)
#'
#' # Identify and extract indicators of transparency.
#' results_table <- rt_all(filepath)
#'
#' # The same, from text already in memory.
#' results_table <- rt_all(text = readLines(filepath))
#' }
#' @export
rt_all <- function(filename = NULL, text = NULL) {
  input <- .txt_input(filename, text)
  txt <- input$text
  fund <- .rt_fund_txt(txt)
  .txt_row(input, c(
    .rt_coi_txt(txt),
    fund,
    list(is_funded_pred = fund$is_fund_pred, funding_text = fund$fund_text),
    .rt_register_txt(txt),
    .rt_novelty_txt(txt),
    .rt_replication_txt(txt),
    .rt_data_code_txt(txt),
    .rt_ai_txt(txt),
    .rt_oa_txt(txt),
    .rt_reporting_txt(txt)
  ))
}


#' Identify and extract all transparency indicators from a PDF file.
#'
#' Converts a PDF to text with [rt_read_pdf()] and runs [rt_all()] on it, so a
#'     PDF can be scored in one call without writing an intermediate text file.
#'     Requires the poppler `pdftotext` utility.
#'
#' @param filepath The path to the PDF file as a string.
#' @return The same one-row tibble as [rt_all()], with `article` and `pmid`
#'     taken from the PDF file name.
#' @seealso [rt_all()], [rt_read_pdf()], [rt_all_txt_dir()]
#' @examples
#' \dontrun{
#' pdf_path <- system.file(
#'   "extdata", "PMID32171256-PMC7071725.pdf", package = "rtransparency"
#' )
#' rt_all_pdf(pdf_path)
#' }
#' @export
rt_all_pdf <- function(filepath) {
  res <- rt_all(text = rt_read_pdf(filepath))
  res$article <- basename(filepath)
  res$pmid <- .pmid_from_filename(filepath)
  res
}
