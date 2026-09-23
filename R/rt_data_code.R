#' Identify and extract Data and Code statements in TXT files.
#'
#' Takes a TXT file and returns data related to the presence of Data and/or Code
#'     statements, including whether Data and/or Code statements exist. If such
#'     statements exist, it extracts them.
#'
#' @inheritParams rt_coi
#' @return A tibble with the file name (`article`), the PMID (`NA` if absent),
#'     whether data or code sharing was found (`is_open_data`, `is_open_code`),
#'     the statements that triggered each (`open_data_statements`,
#'     `open_code_statements`) and the identifiers extracted from them
#'     (`open_data_links`, `open_code_links`), with the same columns and
#'     meaning as [rt_data_code_pmc()].
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
#' # Identify and extract data and code availability.
#' results_table <- rt_data_code(filepath)
#' }
#' @export
rt_data_code <- function(filename = NULL, text = NULL) {
  input <- .txt_input(filename, text)
  .txt_row(input, .rt_data_code_txt(input$text))
}


# Data and code sharing detection on plain text: the native detector over the
# paragraphs, plus the identifiers extracted from the matched statements.
.rt_data_code_txt <- function(paper_text) {
  paragraphs <- unlist(strsplit(paper_text, "\n+"))
  found <- .detect_data_code(paragraphs)
  data_links <- if (isTRUE(found$is_open_data))
    .extract_data_code_links(found$data_text) else character(0)
  code_links <- if (isTRUE(found$is_open_code))
    .extract_data_code_links(found$code_text) else character(0)
  list(
    is_open_data = found$is_open_data,
    open_data_statements = found$data_text,
    open_data_links = paste(data_links, collapse = " ; "),
    is_open_code = found$is_open_code,
    open_code_statements = found$code_text,
    open_code_links = paste(code_links, collapse = " ; ")
  )
}
