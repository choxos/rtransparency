# Identify whether a study includes a replication component in TXT files.

Takes a TXT file and returns data related to the presence of a
replication or validation component, including whether such a component
exists. Replication is defined as the study independently confirming
findings from a prior study in a new sample.

## Usage

``` r
rt_replication(filename)
```

## Arguments

- filename:

  The name of the TXT file as a string.

## Value

A tibble of results. It returns the filename, PMID (if it was part of
the file name), whether a replication component was found, the text
identified, and whether each pattern-matching function identified
relevant text or not.

## Examples

``` r
if (FALSE) { # \dontrun{
# Path to TXT file.
filepath <- "../inst/extdata/00003-PMID26637448-PMC4737611.txt"

# Identify and extract replication components.
results_table <- rt_replication(filepath)
} # }
```
