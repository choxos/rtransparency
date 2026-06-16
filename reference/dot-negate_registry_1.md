# Negate unwanted mentions of registry

Negate mentions of registry such as: "Ethics approval and consent to
participate This study was approved by the Institutional Review Board of
Chang Gung Memorial Hospital under registry number 201601023B0."

## Usage

``` r
.negate_registry_1(article, dict)
```

## Arguments

- article:

  A string or a list of strings.

- dict:

  A list of regular expressions for each concept.

## Value

Index of element with phrase of interest
