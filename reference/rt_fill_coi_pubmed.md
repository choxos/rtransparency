# Fill missed conflict-of-interest disclosures from PubMed

For rows of detector output where no conflict-of-interest statement was
found (\`is_coi_pred\` is \`FALSE\`) but a PubMed ID is known, looks the
article up with \[rt_coi_pubmed()\] and, when PubMed records a
statement, sets \`is_coi_pred\` to \`TRUE\` and \`coi_text\` to that
statement. A new \`coi_source\` column records where each disclosure
came from.

## Usage

``` r
rt_fill_coi_pubmed(data, api_key = Sys.getenv("ENTREZ_KEY"))
```

## Arguments

- data:

  A data frame with \`pmid\`, \`is_coi_pred\` and \`coi_text\` columns,
  such as the output of \[rt_all_pmc()\] or \[rt_coi_pmc()\].

- api_key:

  An NCBI API key; defaults to the \`ENTREZ_KEY\` environment variable.

## Value

\`data\` as a tibble with \`is_coi_pred\` and \`coi_text\` filled where
PubMed has a statement, and \`coi_source\`: \`"article"\` (found in the
full text), \`"pubmed"\` (filled from PubMed) or \`NA\` (none found).

## Details

Note that the accuracy estimates in \[rt_accuracy\] describe the
full-text detector alone; with this fallback the sensitivity is higher.

## See also

\[rt_coi_pubmed()\]

## Examples

``` r
# \donttest{
# Needs internet access.
res <- rt_all_pmc(system.file(
  "extdata", "PMID32171256-PMC7071725.xml", package = "rtransparency"
))
res <- try(rt_fill_coi_pubmed(res))
# }
```
