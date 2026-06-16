# Identify mentions of registration on ClinicalTrials.gov

Extract the index of mentions such as: "The study (EudraCT
2011‐001925‐26; ClinicalTrial.gov NCT01489592) was approved by the
Ethics Committee of Rennes University Hospital."

## Usage

``` r
.which_ct_2(article, dict)
```

## Arguments

- article:

  A string or a list of strings.

- dict:

  A list of regular expressions for each concept.

## Value

Index of element with phrase of interest
