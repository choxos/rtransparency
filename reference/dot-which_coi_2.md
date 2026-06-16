# Identify less explicit mentions of COI statements.

Extract mentions of COI statements that are less standard, e.g. "We
declare that we have no financial or other conflicts of interest."

## Usage

``` r
.which_coi_2(article, dict)
```

## Arguments

- article:

  The text as a vector of strings.

- dict:

  A list of regular expressions for each concept.

## Value

Index of elements with phrase of interest
