# Identify and extract replication components in PMC XML files.

Takes a PMC XML file and returns data related to the presence of a
replication or validation component, including whether such a component
exists and the relevant text. Replication is defined as the study
independently confirming findings from a prior study in a new sample.

## Usage

``` r
rt_replication_pmc(filename, remove_ns = FALSE)
```

## Arguments

- filename:

  The name of the PMC XML as a string.

- remove_ns:

  TRUE if an XML namespace exists, else FALSE (default).

## Value

A tibble of results. It returns the unique identifiers of the article,
whether a replication component was found, the relevant text and whether
each pattern-matching function identified relevant text.

## Examples

``` r
if (FALSE) { # \dontrun{
# Path to PMC XML.
filepath <- "../inst/extdata/00003-PMID26637448-PMC4737611.xml"

# Identify and extract replication components.
results_table <- rt_replication_pmc(filepath, remove_ns = TRUE)
} # }
```
