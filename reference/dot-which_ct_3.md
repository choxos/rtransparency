# Identify mentions of registration on ClinicalTrials.gov

Extract the index of mentions such as: "Registered on ClinicalTrials.gov
(NCT12345678)."

## Usage

``` r
.which_ct_3(article, dict)
```

## Arguments

- article:

  A string or a list of strings.

- dict:

  A list of regular expressions for each concept.

## Value

Index of element with phrase of interest
