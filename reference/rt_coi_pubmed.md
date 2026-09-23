# Fetch conflict-of-interest statements recorded in PubMed

Retrieves the \`\<CoiStatement\>\` that PubMed records for an article,
which holds the conflict-of-interest disclosure also when it is absent
from the full-text XML (the main source of missed disclosures in the XML
detector).

## Usage

``` r
rt_coi_pubmed(pmids, api_key = Sys.getenv("ENTREZ_KEY"))
```

## Arguments

- pmids:

  A character or numeric vector of PubMed IDs.

- api_key:

  An NCBI API key; defaults to the \`ENTREZ_KEY\` environment variable.

## Value

A tibble with one row per unique PubMed ID: \`pmid\`,
\`has_coi_statement\` and \`coi_statement\` (\`""\` when PubMed has
none).

## See also

\[rt_fill_coi_pubmed()\], \[rt_coi_pmc()\]

## Examples

``` r
# \donttest{
# Needs internet access.
try(rt_coi_pubmed(c("32171256", "36696006")))
#> # A tibble: 2 × 3
#>   pmid     has_coi_statement coi_statement                                      
#>   <chr>    <lgl>             <chr>                                              
#> 1 32171256 TRUE              In the past 36 months, J.D.W. received research su…
#> 2 36696006 TRUE              The authors have no competing interests to declare…
# }
```
