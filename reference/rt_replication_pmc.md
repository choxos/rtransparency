# Identify and extract replication components in PMC XML files.

Takes a PMC XML file and returns data related to the presence of a
replication or validation component, including whether such a component
exists and the relevant text. Replication is defined as the study
independently confirming findings from a prior study in a new sample.

## Usage

``` r
rt_replication_pmc(filename, remove_ns = TRUE)
```

## Arguments

- filename:

  The name of the PMC XML as a string.

- remove_ns:

  Ignored since version 1.2.0 and kept for backward compatibility.
  Default XML namespaces are now always removed, so a namespaced PMC XML
  file gives the same result as a plain one.

## Value

A tibble of results. It returns the unique identifiers of the article,
whether a replication component was found, the relevant text and whether
each pattern-matching function identified relevant text.

## Examples

``` r
# \donttest{
# Path to a bundled example PMC XML file.
filepath <- system.file(
  "extdata", "PMID32171256-PMC7071725.xml", package = "rtransparency"
)

# Identify and extract replication components.
results_table <- rt_replication_pmc(filepath)
# }
```
