# Identify whether a study claims novelty in TXT files.

Takes a TXT file and returns data related to the presence of novelty
claims, including whether a novelty claim exists. If a novelty claim
exists, it extracts the relevant text. Novelty is defined as the study
claiming to report something "for the first time."

## Usage

``` r
rt_novelty(filename)
```

## Arguments

- filename:

  The name of the TXT file as a string.

## Value

A tibble of results. It returns the filename, PMID (if it was part of
the file name), whether a novelty claim was found, the text identified,
and whether each pattern-matching function identified relevant text or
not.

## Examples

``` r
if (FALSE) { # \dontrun{
# Path to TXT file.
filepath <- "../inst/extdata/00003-PMID26637448-PMC4737611.txt"

# Identify and extract novelty claims.
results_table <- rt_novelty(filepath)
} # }
```
