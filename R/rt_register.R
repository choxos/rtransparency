

#' Exclude registration-like statements that are not study registration.
#'
#' @param article A string or a list of strings.
#' @return Logical vector; TRUE where the candidate should be excluded.
#' @noRd
.is_false_register_statement <- function(article) {

  pattern <- paste(
    "not registered",
    "protocol was not registered",
    "clinical trial number\\s*(not applicable|n/?a)",
    "\\bnot applicable\\b",
    "irb registration no",
    "institutional review board.{0,80}registration no",
    "review board.{0,80}registration no",
    "ethical approval.{0,80}registration number",
    "ethics approval.{0,80}registration number",
    "ethical review authority",
    "institutional ethics committee.{0,80}registration number",
    "ecr/[0-9]+/inst",
    "\\brio\\b.{0,80}(university|registration|research & innovation)",
    "research & innovation organisation",
    "research and innovation organisation",
    "\\bsisgen\\b",
    "genetic heritage",
    "permanent authorization to access",
    "\\bcnil\\b.{0,80}(decision|authorization)",
    "registration id:\\s*mr-",
    "medical research registration and filing information system",
    "protocol described by",
    "according to the protocol described by",
    sep = "|"
  )

  grepl(pattern, article, perl = TRUE, ignore.case = TRUE)

}


#' Identify and extract Registration statements in TXT files.
#'
#' Takes a TXT file and returns data related to the presence of a Registration
#'     statement, including whether a Registration statement exists. If a
#'     Registration statement exists, it extracts it.
#'
#' @inheritParams rt_coi
#' @return A tibble. It returns the file name (`article`), the PMID (`NA` if
#'     absent), whether a registration statement was
#'     found, the identified statement, whether the text was deemed relevant
#'     (e.g. contained the word registration), whether a Methods section was
#'     identified, whether an NCT number was identified, whether a registration
#'     was explicitly identified (defunct) and whether each labeling function
#'     identified a relevant text or not. The labeling functions are returned to
#'     add flexibility in how this package is used; for example, future
#'     definitions of Registration may differ from the one we used.
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
#' # Identify and extract the registration statement.
#' results_table <- rt_register(filepath)
#' }
#' @export
rt_register <- function(filename = NULL, text = NULL) {
  input <- .txt_input(filename, text)
  .txt_row(input, .rt_register_txt(input$text))
}


# Registration detection on plain text.
.rt_register_txt <- function(paper_text) {

  dict <- .create_synonyms()

  # Fix common PDF-to-text artifacts (hyphenation and mid-word/number line
  # breaks), then split into paragraphs.
  broken_1 <- "([a-z]+)-\n+([a-z]+)"
  broken_2 <- "([a-z]+)(|,|;)\n+([a-z]+)"
  broken_3 <- "([0-9]+)-\n+([0-9]+)"
  paragraphs <-
    paper_text %>%
    purrr::map(gsub, pattern = broken_1, replacement = "\\1\\2") %>%
    purrr::map(gsub, pattern = broken_2, replacement = "\\1\\3") %>%
    purrr::map(gsub, pattern = broken_3, replacement = "\\1\\2") %>%
    purrr::map(strsplit, "\n| \\*") %>%
    unlist() %>%
    .clean_txt()
  paragraphs <- paragraphs[nzchar(trimws(paragraphs))]

  # A TXT file carries no XML structure. Route all text through the Methods slot
  # so the shared core's is_method gate passes, and disable the XML-structural
  # route. Detection then runs through the same helpers as rt_register_pmc().
  # Without an article-type tag we cannot exclude reviews, so every TXT article
  # is treated as research (is_research = TRUE).
  article_ls <- list(ack = character(0), methods = paragraphs,
                     abstract = character(0), footnotes = character(0))
  pmc_reg_ls <- list(is_research = TRUE, is_review = FALSE,
                     is_register_pred = FALSE, register_text = "",
                     type = "", is_reg_pmc_title = FALSE)

  res <- .rt_register_pmc(article_ls, pmc_reg_ls, dict)

  list(
    is_register_pred = res$is_register_pred,
    register_text = res$register_text,
    is_relevant = res$is_relevant_reg,
    is_method = res$is_method,
    is_NCT = res$is_NCT,
    is_explicit = res$is_explicit_reg
  )
}
