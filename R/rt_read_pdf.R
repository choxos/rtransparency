#' Convert a PDF file to text.
#'
#' Takes a path to a PDF file and returns its text content as a single
#'     character string, extracted with the poppler `pdftotext` utility (the
#'     same extractor the original `oddpub` package relied on, implemented here
#'     as a standard system call). Different extractors format text differently;
#'     the detectors in this package were tuned to the layout `pdftotext`
#'     produces. To analyze the result with the plain-text detectors, write it
#'     to a `.txt` file first (see Examples).
#'
#' @param filepath The path to the PDF file as a string (must end in `.pdf`).
#' @return A character string with the extracted text.
#' @examples
#' \dontrun{
#' # Path to a PDF file.
#' pdf_path <- system.file(
#'   "extdata", "PMID32171256-PMC7071725.pdf", package = "rtransparency"
#' )
#'
#' # Extract the text, write it to a TXT file, then run the detectors.
#' article_txt <- rt_read_pdf(pdf_path)
#' writeLines(article_txt, "article.txt")
#' rt_coi("article.txt")
#' }
#' @export
rt_read_pdf <- function(filepath){

  if (!file.exists(filepath)) {
    stop("The provided filepath does not exist.")
  }

  if (!grepl("\\.pdf$", filepath, ignore.case = TRUE)) {
    stop("The filepath of a PDF file should end in '.pdf'.")
  }

  if (Sys.which("pdftotext") == "") {
    stop("The 'pdftotext' utility (from poppler) was not found on the PATH.")
  }

  # Convert PDF to TXT; pdftotext writes to stdout when the output path is "-".
  txt_as_vector <- tryCatch(
    system2("pdftotext", args = c(shQuote(filepath), "-"), stdout = TRUE),
    error = function(e) stop("Could not convert PDF to text.")
  )

  # Collapse into appropriate format
  txt_as_string <- paste(txt_as_vector, collapse = "\n")

  # Convert character vector into ASCII to ease text processing
  txt <- iconv(txt_as_string, from = 'UTF-8', to = 'ASCII//TRANSLIT', sub = "")
  return(txt)
}
