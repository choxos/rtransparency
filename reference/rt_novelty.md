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
# \donttest{
# Write a short example article to a temporary text file.
filepath <- file.path(tempdir(), "PMID00000000-PMC0000000.txt")
writeLines(c(
  "To our knowledge, this is the first study of its kind.",
  "Conflicts of interest: none declared.",
  "This work was supported by the National Institutes of Health (R01-000000).",
  "The protocol was registered at ClinicalTrials.gov (NCT00000000).",
  "All data and code are available at https://github.com/example/repo.",
  "We independently replicated the original analysis."
), filepath)

# Identify and extract novelty claims.
results_table <- rt_novelty(filepath)
# }
```
