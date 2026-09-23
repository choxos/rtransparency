#' Convert a PDF file to text.
#'
#' Takes a path to a PDF file and returns its text content as a single
#'     character string, extracted by default with the poppler `pdftotext`
#'     utility (the same extractor the original `oddpub` package relied on,
#'     called as a system command). Different extractors format text
#'     differently; the detectors were tuned to the reading-order layout
#'     `pdftotext` produces. The result can be passed straight to the
#'     plain-text detectors through their `text` argument, or scored in one
#'     call with [rt_all_pdf()].
#'
#' @param filepath The path to the PDF file as a string (must end in `.pdf`).
#' @param engine `"pdftotext"` (default) calls the poppler command-line
#'     utility, which must be on the PATH. `"pdftools"` uses the \pkg{pdftools}
#'     package instead, which bundles poppler (convenient on Windows) but
#'     keeps the physical page layout, so text in two-column articles can be
#'     interleaved and some statements missed; prefer `"pdftotext"` when it is
#'     available.
#' @return A character string with the extracted text, transliterated to
#'     ASCII.
#' @examples
#' \dontrun{
#' # Path to a PDF file.
#' pdf_path <- system.file(
#'   "extdata", "PMID32171256-PMC7071725.pdf", package = "rtransparency"
#' )
#'
#' # Extract the text and run a detector on it, or score all indicators at once.
#' article_txt <- rt_read_pdf(pdf_path)
#' rt_coi(text = article_txt)
#' rt_all_pdf(pdf_path)
#' }
#' @export
rt_read_pdf <- function(filepath, engine = c("pdftotext", "pdftools")) {

  engine <- match.arg(engine)

  if (!file.exists(filepath)) {
    stop("The provided filepath does not exist.", call. = FALSE)
  }

  if (!grepl("\\.pdf$", filepath, ignore.case = TRUE)) {
    stop("The filepath of a PDF file should end in '.pdf'.", call. = FALSE)
  }

  if (engine == "pdftools") {
    rlang::check_installed("pdftools", reason = "to read PDFs with engine = \"pdftools\"")
    pages <- pdftools::pdf_text(filepath)
    return(.to_ascii(paste(pages, collapse = "\n")))
  }

  if (Sys.which("pdftotext") == "") {
    stop("The 'pdftotext' utility (from poppler) was not found on the PATH. ",
         "Install poppler, or use engine = \"pdftools\".", call. = FALSE)
  }

  # pdftotext writes to stdout when the output path is "-". system2() does not
  # fail on a non-zero exit status, so check it explicitly.
  txt_as_vector <- suppressWarnings(
    system2("pdftotext", args = c(shQuote(filepath), "-"), stdout = TRUE,
            stderr = FALSE)
  )
  status <- attr(txt_as_vector, "status")
  if (!is.null(status) && status != 0) {
    stop("pdftotext could not convert the PDF (exit status ", status, ").",
         call. = FALSE)
  }

  .to_ascii(paste(txt_as_vector, collapse = "\n"))
}
