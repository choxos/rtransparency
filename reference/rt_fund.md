# Identify and extract Funding statements in TXT files.

Takes a TXT file and returns data related to the presence of a Funding
statement, including whether a Funding statement exists. If a Funding
statement exists, it extracts it.

## Usage

``` r
rt_fund(filename)
```

## Arguments

- filename:

  The name of the TXT file as a string.

## Value

A dataframe of results. It returns the PMID (if this was part of the
filename), whether a funding statement was found, what this statement
was and the name of the function that identified this text. The
functions are returned to add flexibility in how this package is used,
such as future definitions of COI that may differ from the one we used.

## Examples

``` r
if (FALSE) { # \dontrun{
# Path to PMC XML.
filepath <- "../inst/extdata/00003-PMID26637448-PMC4737611.txt"

# Identify and extract meta-data and indicators of transparency.
results_table <- rt_fund(filepath)
} # }
```
