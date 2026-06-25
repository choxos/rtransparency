# Identify use of a reporting guideline from a TXT file.

The plain-text counterpart of \[rt_reporting_pmc()\]. Detects whether an
article states that it followed a reporting guideline and which one,
using the same precision-first rules.

## Usage

``` r
rt_reporting(filename)
```

## Arguments

- filename:

  The name of the TXT file as a string.

## Value

A tibble with the filename, the PMID (if present in the file name),
whether a reporting-guideline statement was found
(\`is_reporting_pred\`), the guideline(s) named
(\`reporting_guideline\`) and the matched statement
(\`reporting_text\`).

## See also

\[rt_reporting_pmc()\] for the PMC XML detector.

## Examples

``` r
# \donttest{
# Write a short example article to a temporary text file.
filepath <- file.path(tempdir(), "PMID00000000-PMC0000000.txt")
writeLines(
  "This systematic review was reported following the PRISMA 2020 guideline.",
  filepath
)
rt_reporting(filepath)
#> # A tibble: 1 × 5
#>   article             pmid  is_reporting_pred reporting_guideline reporting_text
#>   <chr>               <chr> <lgl>             <chr>               <chr>         
#> 1 PMID00000000-PMC00… 0000… TRUE              PRISMA              This systemat…
# }
```
