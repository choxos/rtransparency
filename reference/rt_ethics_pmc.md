# Identify ethics approval and informed consent statements (experimental)

Detects whether an article reports oversight by an ethics body
(approval, waiver or exemption by an ethics committee or institutional
review board, including a statement that approval was not required) and
whether it reports how participant informed consent was handled
(obtained, waived or not required). The committee's approval number is
extracted when stated. A bare "Not applicable" does not count.

## Usage

``` r
rt_ethics_pmc(filename, remove_ns = TRUE)
```

## Arguments

- filename:

  The name of the PMC XML as a string.

- remove_ns:

  Ignored since version 1.2.0 and kept for backward compatibility.
  Default XML namespaces are now always removed, so a namespaced PMC XML
  file gives the same result as a plain one.

## Value

A one-row tibble with the article IDs, \`is_ethics_pred\`,
\`ethics_text\`, \`ethics_approval_id\`, \`is_consent_pred\`,
\`consent_text\` and \`is_success\`.

## Details

\*\*Experimental.\*\* Unlike the ten main indicators, this detector has
not been validated against hand labels, so it is not part of
\[rt_all_pmc()\], has no row in \[rt_accuracy\], and its output should
be spot-checked before use. The scripts in \`data-raw/validation/\`
build blind labeling sheets for its validation.

## See also

\[rt_ethics()\] for plain text.

## Examples

``` r
# \donttest{
filepath <- system.file(
  "extdata", "PMID32171256-PMC7071725.xml", package = "rtransparency"
)
rt_ethics_pmc(filepath)
#> # A tibble: 1 × 11
#>   pmid     pmcid_pmc  pmcid_uid doi          filename is_ethics_pred ethics_text
#>   <chr>    <chr>      <chr>     <chr>        <chr>    <lgl>          <chr>      
#> 1 32171256 PMC7071725 7071725   10.1186/s12… /home/r… FALSE          ""         
#> # ℹ 4 more variables: ethics_approval_id <chr>, is_consent_pred <lgl>,
#> #   consent_text <chr>, is_success <lgl>
# }
```
