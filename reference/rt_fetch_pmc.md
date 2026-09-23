# Download PubMed Central full-text XML

Downloads the full-text JATS XML of articles in PubMed Central, ready
for \[rt_all_pmc()\] or \[rt_all_pmc_dir()\]. Identifiers can be PMCIDs,
PubMed IDs or DOIs (mixed freely); PubMed IDs and DOIs are first
converted to PMCIDs with \[rt_convert_ids()\]. Each article is saved as
\`\<PMCID\>.xml\` in \`dir\`.

## Usage

``` r
rt_fetch_pmc(
  ids,
  dir = ".",
  overwrite = FALSE,
  source = c("ncbi", "europepmc"),
  api_key = Sys.getenv("ENTREZ_KEY"),
  progress = TRUE
)
```

## Arguments

- ids:

  A character vector of PMCIDs ("PMC7071725"), PubMed IDs ("32171256")
  or DOIs ("10.1186/s12874-020-0914-6").

- dir:

  The directory to save the XML files in (created if needed).

- overwrite:

  Whether to download again files that already exist.

- source:

  Where to download from: \`"ncbi"\` (NCBI PMC, the default, with the
  OAI-PMH service as fallback) or \`"europepmc"\` (the Europe PMC REST
  API). The detectors give the same results on both in a comparison of
  13 benchmark articles
  (\`inst/benchmark/results_europepmc_parity.md\`); Europe PMC omits
  some license URLs, so \`oa_license\` is then read from the license
  text.

- api_key:

  An NCBI API key; defaults to the \`ENTREZ_KEY\` environment variable.

- progress:

  Whether to show a progress bar.

## Value

A tibble with one row per identifier: the input \`id\`, its \`pmcid\`,
the saved \`file\` (\`NA\` on failure), \`is_success\`, \`has_body\`
(whether the XML contains the article body) and the \`error\` message on
failure.

## Details

Full text comes from NCBI E-utilities (EFetch), with the PMC OAI-PMH
service as a fallback. Only articles whose publisher allows XML download
(the PMC open-access and author-manuscript collections) have a full
text; for others NCBI returns the front matter only, which is saved but
flagged with \`has_body = FALSE\`, because most indicators need the
article body.

Existing non-empty files are reused, so an interrupted download can
simply be re-run. Requests are paced to NCBI's limit of 3 per second, or
10 per second with an API key (set the \`ENTREZ_KEY\` environment
variable or pass \`api_key\`).

## See also

\[rt_convert_ids()\], \[rt_all_pmc_dir()\]

## Examples

``` r
# \donttest{
# Needs internet access; failures are reported per identifier.
dir <- file.path(tempdir(), "pmc")
got <- rt_fetch_pmc("PMC7071725", dir, progress = FALSE)
got
#> # A tibble: 1 × 6
#>   id         pmcid      file                           is_success has_body error
#>   <chr>      <chr>      <chr>                          <lgl>      <lgl>    <chr>
#> 1 PMC7071725 PMC7071725 /tmp/Rtmp18vWoU/pmc/PMC707172… TRUE       TRUE     NA   
# }
```
