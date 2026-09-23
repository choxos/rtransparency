# Funders, funder identifiers and award numbers from a PMC XML file.

Reads the structured funding metadata of an article (the JATS
\`\<funding-group\>\`): each funding source with its name, its Crossref
Open Funder Registry DOI and ROR identifier when the publisher tagged
them, and the award (grant) numbers of its award group. This complements
\[rt_fund_pmc()\], which detects whether a funding statement exists,
with identifiers that can be linked to funder databases.

## Usage

``` r
rt_funders_pmc(filename, remove_ns = TRUE)
```

## Arguments

- filename:

  The name of the PMC XML as a string.

- remove_ns:

  Ignored since version 1.2.0 and kept for backward compatibility.
  Default XML namespaces are now always removed, so a namespaced PMC XML
  file gives the same result as a plain one.

## Value

A tibble with one row per funding source: the article IDs, \`funder\`
(the name as tagged), \`funder_doi\` (a Crossref Funder Registry DOI
such as \`10.13039/100000002\`), \`funder_ror\` (a ROR URL),
\`award_id\` (the award numbers of the source's award group, \`";
"\`-separated) and \`is_success\`. An article without a
\`\<funding-group\>\` gives one row with \`NA\` funder fields, so every
file is represented.

## See also

\[rt_fund_pmc()\], \[rt_authors_pmc()\]

## Examples

``` r
# \donttest{
filepath <- system.file(
  "extdata", "PMID32171256-PMC7071725.xml", package = "rtransparency"
)
rt_funders_pmc(filepath)
#> # A tibble: 1 × 10
#>   pmid  pmcid_pmc pmcid_uid doi   filename funder funder_doi funder_ror award_id
#>   <chr> <chr>     <chr>     <chr> <chr>    <chr>  <chr>      <chr>      <chr>   
#> 1 3217… PMC70717… 7071725   10.1… /home/r… NA     NA         NA         NA      
#> # ℹ 1 more variable: is_success <lgl>
# }
```
