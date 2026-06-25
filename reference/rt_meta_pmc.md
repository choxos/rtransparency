# Extract article metadata from a PMC XML file.

Reads a PMC XML file and returns its metadata as a one-row data frame:
journal, publisher, article title, authors and affiliations, identifiers
(PMID, PMCID, DOI), publication dates, and figure / table / reference
counts.

## Usage

``` r
rt_meta_pmc(filename, remove_ns = FALSE)
```

## Arguments

- filename:

  The path to the PMC XML file as a string.

- remove_ns:

  TRUE if an XML namespace should be removed, else FALSE (default).

## Value

A one-row tibble of metadata. The column \`is_success\` indicates
whether the file was parsed successfully.

## Examples

``` r
# \donttest{
filepath <- system.file(
  "extdata", "PMID32171256-PMC7071725.xml", package = "rtransparency"
)
rt_meta_pmc(filepath, remove_ns = TRUE)
#> # A tibble: 1 × 29
#>   filename           pmid  pmcid_pmc doi   pii   date_epub date_ppub journal_nlm
#>   <chr>              <chr> <chr>     <chr> <chr> <chr>     <chr>     <chr>      
#> 1 /home/runner/work… 3217… ""        10.1… ""    14-03-20… ""        BMC Med Re…
#> # ℹ 21 more variables: journal_iso <chr>, publisher_id <chr>, issn_ppub <chr>,
#> #   issn_epub <chr>, affiliation_all <chr>, title <chr>, subject <chr>,
#> #   license <chr>, author <chr>, author_aff_id <chr>, affiliation_aff_id <chr>,
#> #   correspondence <chr>, n_auth <int>, n_affiliation <int>, n_ref <int>,
#> #   n_fig_body <int>, n_fig_floats <int>, n_table_body <int>,
#> #   n_table_floats <int>, is_supplement <lgl>, is_success <lgl>
# }
```
