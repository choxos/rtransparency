# Identify mentions of receiving benefits

Extract mentions of benefits, e.g. "SS has received benefits of
commercial nature from GSK."

## Usage

``` r
.which_benefit_1(article, dict)
```

## Arguments

- article:

  The text as a vector of strings.

- dict:

  A list of regular expressions for each concept.

## Value

Index of elements with phrase of interest
