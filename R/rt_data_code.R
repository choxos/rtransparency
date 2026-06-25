#' Identify and extract Data and Code statements in TXT files.
#'
#' Takes a TXT file and returns data related to the presence of Data and/or Code
#'     statements, including whether Data and/or Code statements exist. If such
#'     statements exist, it extracts them.
#'
#' @param filename The name of the TXT file as a string.
#' @return A dataframe of results. It returns whether text suggesting the
#'     presence of data or code was found, and if so, what this text was.
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
rt_data_code <- function(filename) {

  article <- .read_txt(filename)
  paragraphs <- unlist(strsplit(article, "\n+"))

  found <- .detect_data_code(paragraphs)

  tibble::tibble(
    article = filename,
    is_open_data = found$is_open_data,
    open_data_statements = found$data_text,
    is_open_code = found$is_open_code,
    open_code_statements = found$code_text
  )
}