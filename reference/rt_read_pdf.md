# Convert a PDF file to text.

Takes a path to a PDF file and returns its text content as a single
character string, extracted by default with the poppler \`pdftotext\`
utility (the same extractor the original \`oddpub\` package relied on,
called as a system command). Different extractors format text
differently; the detectors were tuned to the reading-order layout
\`pdftotext\` produces. The result can be passed straight to the
plain-text detectors through their \`text\` argument, or scored in one
call with \[rt_all_pdf()\].

## Usage

``` r
rt_read_pdf(filepath, engine = c("pdftotext", "pdftools"))
```

## Arguments

- filepath:

  The path to the PDF file as a string (must end in \`.pdf\`).

- engine:

  \`"pdftotext"\` (default) calls the poppler command-line utility,
  which must be on the PATH. \`"pdftools"\` uses the pdftools package
  instead, which bundles poppler (convenient on Windows) but keeps the
  physical page layout, so text in two-column articles can be
  interleaved and some statements missed; prefer \`"pdftotext"\` when it
  is available.

## Value

A character string with the extracted text, transliterated to ASCII.

## Examples

``` r
if (FALSE) { # \dontrun{
# Path to a PDF file.
pdf_path <- system.file(
  "extdata", "PMID32171256-PMC7071725.pdf", package = "rtransparency"
)

# Extract the text and run a detector on it, or score all indicators at once.
article_txt <- rt_read_pdf(pdf_path)
rt_coi(text = article_txt)
rt_all_pdf(pdf_path)
} # }
```
