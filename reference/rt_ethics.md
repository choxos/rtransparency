# Identify ethics approval and informed consent statements in text (experimental)

The plain-text counterpart of \[rt_ethics_pmc()\], with the same rules
and the same caveat: the detector is experimental and not yet validated.

## Usage

``` r
rt_ethics(filename = NULL, text = NULL)
```

## Arguments

- filename:

  The path to a TXT file as a string.

- text:

  Alternatively, the article text itself as a character vector (for
  example the output of \[rt_read_pdf()\]). Supply \`filename\` or
  \`text\`.

## Value

A tibble with the file name (\`article\`), the PMID (\`NA\` if absent),
\`is_ethics_pred\`, \`ethics_text\`, \`ethics_approval_id\`,
\`is_consent_pred\` and \`consent_text\`.

## See also

\[rt_ethics_pmc()\]

## Examples

``` r
rt_ethics(text = c(
  "The study was approved by the Ethics Committee of X (approval no. 2021-045).",
  "Written informed consent was obtained from all participants."
))
#> # A tibble: 1 × 7
#>   article pmid  is_ethics_pred ethics_text    ethics_approval_id is_consent_pred
#>   <chr>   <chr> <lgl>          <chr>          <chr>              <lgl>          
#> 1 NA      NA    TRUE           The study was… 2021-045           TRUE           
#> # ℹ 1 more variable: consent_text <chr>
```
