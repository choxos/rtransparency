# Convert article identifiers with the PMC ID Converter

Maps PubMed IDs, PMCIDs and DOIs to one another with the NCBI PMC ID
Converter API. Only articles in PubMed Central have a PMCID.

## Usage

``` r
rt_convert_ids(ids, email = NULL)
```

## Arguments

- ids:

  A character vector of PubMed IDs, PMCIDs or DOIs (mixed freely). Bare
  numbers are treated as PubMed IDs.

- email:

  An optional contact email passed to NCBI, as its usage guidelines
  request for heavy use.

## Value

A tibble with one row per input: the input \`id\`, and its \`pmcid\`,
\`pmid\` and \`doi\` (\`NA\` where not found).

## See also

\[rt_fetch_pmc()\]

## Examples

``` r
# \donttest{
# Needs internet access.
try(rt_convert_ids(c("32171256", "10.1186/s12874-020-0914-6", "PMC7071725")))
#> # A tibble: 3 × 4
#>   id                        pmcid      pmid     doi                      
#>   <chr>                     <chr>      <chr>    <chr>                    
#> 1 32171256                  PMC7071725 32171256 10.1186/s12874-020-0914-6
#> 2 10.1186/s12874-020-0914-6 PMC7071725 32171256 10.1186/s12874-020-0914-6
#> 3 PMC7071725                PMC7071725 32171256 10.1186/s12874-020-0914-6
# }
```
