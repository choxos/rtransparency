# Identify and extract statements of COI, Funding and Registration.

Takes a PMC XML and returns relevant meta-data, as well as whether any
statements of Conflicts of Interest (COI), Funding or Protocol
Registration. If any such statements are found, it also extracts the
relevant text.

## Usage

``` r
rt_all_pmc(filename, remove_ns = F, all_meta = F)
```

## Arguments

- filename:

  The name of the PMC XML as a string.

- remove_ns:

  TRUE if an XML namespace exists, else FALSE (default).

- all_meta:

  TRUE extracts all meta-data, FALSE extracts some (default).

## Value

A dataframe of results. It returns the unique identifiers of the
article, whether each of 3 indicators of transparency (COI, Funding or
Registration) was identified, the relevant text identified, whether it
was identified through a dedicated XML tag (such variables include "pmc"
in their name, e.g. “fund_pmc_source”) and whether each labelling
function identified relevant text or not. The labeling functions are
returned to add flexibility in how this package is used; for example,
future definitions of Registration may differ from the one we used. If a
labelling function returns NA it means that it was not run.

## Examples

``` r
if (FALSE) { # \dontrun{
# Path to PMC XML.
filepath <- "../inst/extdata/00003-PMID26637448-PMC4737611.xml"

# Identify and extract meta-data and indicators of transparency.
results_table <- rt_all_pmc(filepath, remove_ns = T, all_meta = T)
} # }
```
