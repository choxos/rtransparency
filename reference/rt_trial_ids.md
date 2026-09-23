# Extract trial and review registration identifiers from text

Finds registry identifiers (ClinicalTrials.gov NCT numbers, ISRCTN,
PROSPERO, ChiCTR, DRKS, ANZCTR, IRCT, UMIN, jRCT, CTRI, PACTR, KCT,
EudraCT, CTIS and INPLASY) in text, typically the \`register_text\`
returned by \[rt_all_pmc()\] or \[rt_register()\].

## Usage

``` r
rt_trial_ids(text)
```

## Arguments

- text:

  A character vector.

## Value

A tibble with one row per identifier found: the position in \`text\`
(\`element\`), the \`registry\` and the \`trial_id\` (upper-cased, with
spaces removed). Identifiers repeated within an element are listed once.

## See also

\[rt_registration_timing()\]

## Examples

``` r
rt_trial_ids(c(
  "Registered at ClinicalTrials.gov (NCT04368728) and ISRCTN12345678.",
  "PROSPERO CRD42020123456",
  "No registration."
))
#> # A tibble: 3 × 3
#>   element registry           trial_id      
#>     <int> <chr>              <chr>         
#> 1       1 ClinicalTrials.gov NCT04368728   
#> 2       1 ISRCTN             ISRCTN12345678
#> 3       2 PROSPERO           CRD42020123456
```
