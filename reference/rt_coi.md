# Identify and extract Conflicts of Interest (COI) statements in TXT files.

Takes a TXT file and returns data related to the presence of a COI
statement, including whether a COI statement exists. If a COI statement
exists, it extracts it.

## Usage

``` r
rt_coi(filename)
```

## Arguments

- filename:

  The name of the TXT file as a string.

## Value

A dataframe of results. It returns the filename, PMID (if it was part of
the file name), whether a COI was found and the text identified.

## Examples

``` r
if (FALSE) { # \dontrun{
# Path to PMC XML.
filepath <- "../inst/extdata/00003-PMID26637448-PMC4737611.txt"

# Identify and extract meta-data and indicators of transparency.
results_table <- rt_coi(filepath)
} # }
```
