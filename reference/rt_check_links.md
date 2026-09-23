# Check whether extracted data and code links resolve

Takes the links extracted by the data and code detectors (the
\`open_data_links\` and \`open_code_links\` columns of
\[rt_data_code_pmc()\], \[rt_all_pmc()\] or \[rt_data_code()\]) and
checks whether each one resolves, following redirects. A shared-data
statement whose link is dead is weaker evidence of sharing than one
whose link works, which availability-statement indicators alone cannot
tell apart.

## Usage

``` r
rt_check_links(links, timeout = 10)
```

## Arguments

- links:

  A character vector of links; elements holding several links separated
  by \`" ; "\` (as the detectors return them) are split.

- timeout:

  Seconds to wait for each server.

## Value

A tibble with one row per unique link: the \`link\`, the \`url\`
checked, the HTTP \`status\` (\`NA\` when the server could not be
reached), \`is_ok\` (a status below 400) and the \`error\` message when
unreachable.

## Details

DOIs are checked through \`https://doi.org/\`, and database accessions
in identifiers.org \`prefix:accession\` form through
\`https://identifiers.org/\`. Only the response headers are requested.
Some servers refuse automated requests (status 403) or header-only
requests (405) although the page exists, so a failing status is a prompt
to look, not proof of a dead link.

## See also

\[rt_data_code_pmc()\]

## Examples

``` r
# \donttest{
# Needs internet access; unreachable links are reported, not errors.
res <- rt_data_code_pmc(system.file(
  "extdata", "PMID32171256-PMC7071725.xml", package = "rtransparency"
))
if (capabilities("libcurl")) rt_check_links(res$open_data_links)
#> # A tibble: 1 × 5
#>   link                  url                   status is_ok error
#>   <chr>                 <chr>                  <int> <lgl> <chr>
#> 1 https://osf.io/zrdx7/ https://osf.io/zrdx7/    200 TRUE  NA   
# }
```
