# Identify and extract Conflicts of Interest (COI) statements in PMC XML files.

Takes a PMC XML file and returns data related to the presence of a COI
statement, including whether a COI statement exists. If a COI statement
exists, it extracts it.

## Usage

``` r
rt_coi_pmc(filename, remove_ns = F)
```

## Arguments

- filename:

  The name of the PMC XML as a string.

- remove_ns:

  TRUE if an XML namespace exists, else FALSE (default).

## Value

A dataframe of results. It returns unique article identifiers, whether
this article was deemed relevant to COI, whether a COI was found, the
text that suggested the presence of COI and the name of the function
that identified this text. The functions are returned to add flexibility
in how this package is used, such as future definitions of COI that may
differ from the one we used.

## Examples

``` r
if (FALSE) { # \dontrun{
# Path to PMC XML.
filepath <- "../inst/extdata/00003-PMID26637448-PMC4737611.xml"

# Identify and extract meta-data and indicators of transparency.
results_table <- rt_coi_pmc(filepath, remove_ns = T)
} # }
```
