# Identify and extract Funding statements in PMC XML files.

Takes a PMC XML file and returns data related to the presence of a
Funding statement, including whether a Funding statement exists. If a
Funding statement exists, it extracts it.

## Usage

``` r
rt_fund_pmc(filename, remove_ns = F)
```

## Arguments

- filename:

  The name of the PMC XML as a string.

- remove_ns:

  TRUE if an XML namespace exists, else FALSE (default).

## Value

A dataframe of results. It returns all unique article identifiers,
whether this article was deemed relevant to funding (e.g. was the word
"fund" found within the text), whether a funding statement was found,
whether a statement within the PMC tags dedicated to funding was found,
the text identified, whether this text is explicit (i.e. whether it
clearly indicated that funding was received) and whether each of the
labeling functions identified the text or not. The functions are
returned to add flexibility in how this package is used; for example,
future definitions of Funding may differ from the one we used.

## Examples

``` r
if (FALSE) { # \dontrun{
# Path to PMC XML.
filepath <- "../inst/extdata/00003-PMID26637448-PMC4737611.xml"

# Identify and extract meta-data and indicators of transparency.
results_table <- rt_fund_pmc(filepath, remove_ns = T)
} # }
```
