# Covert PDF files into TXT files.

Takes a path to a PDF file and returns a TXT file. Note that there are a
number of such converters and different converters return TXT files
formatted differently. The functions within this package were created to
work well with the converter used within this function (poppler). This
function was taken from the package \`oddpub\` by Nico Riedel and hereby
modified for the purposes of this package.

## Usage

``` r
rt_read_pdf(filepath)
```

## Arguments

- filepath:

  The path to the TXT file as a string.

## Value

A character object.

## Examples

``` r
if (FALSE) { # \dontrun{
# Path to PDF file
filepath <- "../inst/extdata/PMID30457984-PMC6245499.txt"

# Convert into string
article_txt <- rt_read_pdf(filepath)
} # }
```
