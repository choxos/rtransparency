# Identify generic mentions of registration

Extract the index of mentions such as: "This study was approved by the
local Scientific and Ethics Committees of IRCCS \\Saverio de Bellis\\,
Castellana Grotte (Ba), Italy, and it was part of a registered research
on https://www.clinicaltrials.gov, reg. number: NCT01244945."

## Usage

``` r
get_registered_1(article)
```

## Arguments

- article:

  A string or a list of strings.

## Value

Index of element with phrase of interest
