#' Identify and extract Funding statements in TXT files.
#'
#' Takes a TXT file and returns data related to the presence of a Funding
#'     statement, including whether a Funding statement exists. If a Funding
#'     statement exists, it extracts it.
#'
#' @inheritParams rt_coi
#' @return A tibble with the file name (`article`), the PMID (`NA` if absent),
#'     whether a statement that funding was received was found
#'     (`is_fund_pred`) and the statement (`fund_text`). These are the same
#'     column names as [rt_fund_pmc()] and [rt_all_pmc()]. The former names
#'     `is_funded_pred` and `funding_text` are still returned, as deprecated
#'     copies, and will be removed in a future release.
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
#' # Identify and extract the funding statement.
#' results_table <- rt_fund(filepath)
#' }
#' @export
rt_fund <- function(filename = NULL, text = NULL) {
  input <- .txt_input(filename, text)
  res <- .rt_fund_txt(input$text)
  # is_funded_pred / funding_text are deprecated copies kept for one release.
  .txt_row(input, c(res, list(is_funded_pred = res$is_fund_pred,
                              funding_text = res$fund_text)))
}


# Funding detection on plain text. A TXT file carries no XML structure: all text
# goes to the body and the XML-structural route is disabled (pmc_fund_ls reports
# nothing found). Detection then runs through the same text helpers as
# rt_fund_pmc(), which also applies its own conflict/disclosure obliteration.
.rt_fund_txt <- function(paper_text) {

  # Fix common PDF-to-text artifacts (hyphenation and mid-word line breaks),
  # then split into paragraphs.
  broken_1 <- "([a-z]+)-\n+([a-z]+)"
  broken_2 <- "([a-z]+)(|,|;)\n+([a-z]+)"
  paragraphs <-
    paper_text %>%
    purrr::map(gsub, pattern = broken_1, replacement = "\\1\\2") %>%
    purrr::map(gsub, pattern = broken_2, replacement = "\\1\\3") %>%
    purrr::map(strsplit, "\n| \\*") %>%
    unlist() %>%
    .clean_txt()
  paragraphs <- paragraphs[nzchar(trimws(paragraphs))]

  article_ls <- list(ack = character(0), body = paragraphs,
                     footnotes = character(0))
  pmc_fund_ls <- list(is_fund_pred = FALSE, fund_text = "",
                      is_fund_pmc_title = NA)

  res <- .rt_fund_pmc(article_ls, pmc_fund_ls)
  list(is_fund_pred = res$is_fund_pred, fund_text = res$fund_text)
}
