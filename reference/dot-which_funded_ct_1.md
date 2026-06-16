# Identify mentions of funding followed by NCT

Extract the index of mentions such as: "Funded by: the National Heart,
Lung, and Blood Institute, the National Institute of Diabetes and
Digestive and Kidney Disease, and others; SPECS ClinicalTrials.gov
number, NCT00443599; Nutrition and Obesity Center at Harvard; NIH
5P30DK040561-17"

## Usage

``` r
.which_funded_ct_1(article, dict)
```

## Arguments

- article:

  A string or a list of strings.

- dict:

  A list of regular expressions for each concept.

## Value

Index of element with phrase of interest
