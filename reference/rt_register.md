# Identify and extract Registration statements in TXT files.

Takes a TXT file and returns data related to the presence of a
Registration statement, including whether a Registration statement
exists. If a Registration statement exists, it extracts it.

## Usage

``` r
rt_register(filename)
```

## Arguments

- filename:

  The name of the TXT file as a string.

## Value

A dataframe of results. It returns the PMID (if this was part of the
filename and preceded by PMID), whether a registration statement was
found, the identified statement, whether the text was deemed relevant
(e.g. contained the word registration), whether a Methods section was
identified, whether an NCT number was identified, whether a registration
was explicitly identified (defunct) and whether each labeling function
identified a relevant text or not. The labeling functions are returned
to add flexibility in how this package is used; for example, future
definitions of Registration may differ from the one we used.

## Examples

``` r
if (FALSE) { # \dontrun{
# Path to PMC XML.
filepath <- "../inst/extdata/00003-PMID26637448-PMC4737611.txt"

# Identify and extract meta-data and indicators of transparency.
results_table <- rt_register(filepath)
} # }
```
