# Identify and extract novelty claims in PMC XML files.

Takes a PMC XML file and returns data related to the presence of novelty
claims, including whether such claims exist and the relevant text.
Novelty is defined as the study claiming to report something "for the
first time."

## Usage

``` r
rt_novelty_pmc(filename, remove_ns = FALSE)
```

## Arguments

- filename:

  The name of the PMC XML as a string.

- remove_ns:

  TRUE if an XML namespace exists, else FALSE (default).

## Value

A tibble of results. It returns the unique identifiers of the article,
whether a novelty claim was found, the relevant text and whether each
pattern-matching function identified relevant text.

## Examples

``` r
# \donttest{
# Path to a bundled example PMC XML file.
filepath <- system.file(
  "extdata", "PMID32171256-PMC7071725.xml", package = "rtransparency"
)

# Identify and extract novelty claims.
results_table <- rt_novelty_pmc(filepath, remove_ns = TRUE)
# }
```
