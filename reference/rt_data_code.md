# Identify and extract Data and Code statements in TXT files.

Takes a TXT file and returns data related to the presence of Data and/or
Code statements, including whether Data and/or Code statements exist. If
such statements exist, it extracts them.

## Usage

``` r
rt_data_code(filename)
```

## Arguments

- filename:

  The name of the TXT file as a string.

## Value

A dataframe of results. It returns whether text suggesting the presence
of data or code was found, and if so, what this text was.

## Examples

``` r
if (FALSE) { # \dontrun{
# Path to PMC XML.
filepath <- "../inst/extdata/00003-PMID26637448-PMC4737611.txt"

# Identify and extract meta-data and indicators of transparency.
results_table <- rt_data(filepath)
} # }
```
