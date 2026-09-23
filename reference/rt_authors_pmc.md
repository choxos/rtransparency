# Author identifiers and contribution roles from a PMC XML file.

Reads the article's author list and reports how many authors carry an
ORCID identifier and whether contributions are described with the CRediT
(Contributor Roles Taxonomy) vocabulary. Both are structured JATS
elements (\`\<contrib-id contrib-id-type="orcid"\>\` and \`\<role\>\`),
so they are read, not inferred from text.

## Usage

``` r
rt_authors_pmc(filename, remove_ns = TRUE)
```

## Arguments

- filename:

  The name of the PMC XML as a string.

- remove_ns:

  Ignored since version 1.2.0 and kept for backward compatibility.
  Default XML namespaces are now always removed, so a namespaced PMC XML
  file gives the same result as a plain one.

## Value

A one-row tibble with the article IDs, \`n_authors\` (contributors of
type author), \`n_orcid\` (authors with an ORCID), \`orcid_coverage\`
(\`n_orcid / n_authors\`), \`orcids\` (the ORCID iDs, \`";
"\`-separated), \`has_credit\` (whether any author has a CRediT role),
\`credit_roles\` (the distinct CRediT roles used) and \`is_success\`.

## Details

A role counts as CRediT when it is tagged with the CRediT vocabulary
(\`vocab="credit"\`) or its text is one of the 14 CRediT roles.

## See also

\[rt_funders_pmc()\], \[rt_all_pmc()\]

## Examples

``` r
# \donttest{
filepath <- system.file(
  "extdata", "PMID32171256-PMC7071725.xml", package = "rtransparency"
)
rt_authors_pmc(filepath)
#> # A tibble: 1 × 12
#>   pmid     pmcid_pmc  pmcid_uid doi    filename n_authors n_orcid orcid_coverage
#>   <chr>    <chr>      <chr>     <chr>  <chr>        <int>   <int>          <dbl>
#> 1 32171256 PMC7071725 7071725   10.11… /home/r…         7       1          0.143
#> # ℹ 4 more variables: orcids <chr>, has_credit <lgl>, credit_roles <chr>,
#> #   is_success <lgl>
# }
```
