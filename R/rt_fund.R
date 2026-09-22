# TODO: First find the paragraphs that contain intersting words and then
#    apply the obliteration and rest of functions and test if this saves
#    time!


# get_fund_acknow_new <- function(article) {
#
#   synonyms <- .create_synonyms()
#   words <- c("acknowledge")
#
#   a <- synonyms %>%
#     magrittr::extract(words) %>%
#     lapply(.bound) %>%
#     lapply(.encase)
#
#   grep(paste0(a, synonyms$txt, "[0-9]{3,10}"), article, perl = TRUE)
#
# }


#' Identify and extract Funding statements in TXT files.
#'
#' Takes a TXT file and returns data related to the presence of a Funding
#'     statement, including whether a Funding statement exists. If a Funding
#'     statement exists, it extracts it.
#'
#' @param filename The name of the TXT file as a string.
#' @return A dataframe of results. It returns the PMID (if this was part of the
#'     filename), whether a funding statement was found, what this statement
#'     was and the name of the function that identified this text. The functions
#'     are returned to add flexibility in how this package is used, such as
#'     future definitions of COI that may differ from the one we used.
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
rt_fund <- function(filename) {

  # Fix common PDF-to-text artifacts (hyphenation and mid-word line breaks),
  # then split into paragraphs.
  broken_1 <- "([a-z]+)-\n*([a-z]+)"
  broken_2 <- "([a-z]+)(|,|;)\n*([a-z]+)"
  paragraphs <-
    .read_txt(filename) %>%
    purrr::map(gsub, pattern = broken_1, replacement = "\\1\\2") %>%
    purrr::map(gsub, pattern = broken_2, replacement = "\\1\\3") %>%
    purrr::map(strsplit, "\n| \\*") %>%
    unlist() %>%
    utf8::utf8_encode()
  paragraphs <- paragraphs[nzchar(trimws(paragraphs))]

  # A TXT file carries no XML structure: all text goes to the body and the
  # XML-structural route is disabled (pmc_fund_ls reports nothing found).
  # Detection then runs through the same text helpers as rt_fund_pmc(), which
  # also applies its own conflict/disclosure obliteration internally.
  article_ls <- list(ack = character(0), body = paragraphs,
                     footnotes = character(0))
  pmc_fund_ls <- list(is_fund_pred = FALSE, fund_text = "",
                      is_fund_pmc_title = NA)

  res <- .rt_fund_pmc(article_ls, pmc_fund_ls)

  article <- basename(filename) %>% stringr::word(sep = "\\.")
  pmid <- gsub("^.*PMID([0-9]+).*$", "\\1", filename)

  tibble::tibble(
    article,
    pmid,
    is_funded_pred = res$is_fund_pred,
    funding_text = res$fund_text
  )
}
