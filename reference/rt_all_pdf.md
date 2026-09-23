# Identify and extract all transparency indicators from a PDF file.

Converts a PDF to text with \[rt_read_pdf()\] and runs \[rt_all()\] on
it, so a PDF can be scored in one call without writing an intermediate
text file. Requires the poppler \`pdftotext\` utility.

## Usage

``` r
rt_all_pdf(filepath)
```

## Arguments

- filepath:

  The path to the PDF file as a string.

## Value

The same one-row tibble as \[rt_all()\], with \`article\` and \`pmid\`
taken from the PDF file name.

## See also

\[rt_all()\], \[rt_read_pdf()\], \[rt_all_txt_dir()\]

## Examples

``` r
if (FALSE) { # \dontrun{
pdf_path <- system.file(
  "extdata", "PMID32171256-PMC7071725.pdf", package = "rtransparency"
)
rt_all_pdf(pdf_path)
} # }
```
