#' Identify and extract Conflicts of Interest (COI) statements in TXT files.
#'
#' Takes a TXT file and returns data related to the presence of a COI
#'     statement, including whether a COI statement exists. If a COI statement
#'     exists, it extracts it. Detection runs through the same text helpers as
#'     [rt_coi_pmc()], so a plain-text article is scored with the same logic as
#'     a PMC XML one (only the XML-structural routes, which need tags a TXT file
#'     does not have, are unavailable).
#'
#' @param filename The path to a TXT file as a string.
#' @param text Alternatively, the article text itself as a character vector
#'     (for example the output of [rt_read_pdf()]). Supply `filename` or `text`.
#' @return A tibble with the file name (`article`), the PMID (the digits after
#'     "PMID" in the file name, `NA` if absent or for `text`), whether a COI
#'     statement was found (`is_coi_pred`) and the text identified (`coi_text`).
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
#' # Identify and extract the COI statement.
#' results_table <- rt_coi(filepath)
#' }
#' @export
rt_coi <- function(filename = NULL, text = NULL) {
  input <- .txt_input(filename, text)
  .txt_row(input, .rt_coi_txt(input$text))
}


# COI detection on plain text. A TXT file carries no XML structure, so all text
# goes to the body and the XML-structural route is disabled (pmc_coi_ls reports
# nothing found); detection then runs through the same text-regex helpers as
# rt_coi_pmc().
.rt_coi_txt <- function(paper_text) {
  dict <- .create_synonyms()
  paragraphs <- strsplit(paper_text, "\n")[[1]]
  paragraphs <- paragraphs[nzchar(trimws(paragraphs))]
  article_ls <- list(ack = character(0), body = paragraphs,
                     footnotes = character(0))
  pmc_coi_ls <- list(is_coi_pred = FALSE, coi_text = "")
  res <- .rt_coi_pmc(article_ls, pmc_coi_ls, dict)
  list(is_coi_pred = res$is_coi_pred, coi_text = res$coi_text)
}
