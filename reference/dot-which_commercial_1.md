# Identify less explicit mentions of commercial interest

Extract mentions of COI statements that are less standard and mention
commercial interests, e.g. "The authors of this study declare a
financial relationship with GSK."

## Usage

``` r
.which_commercial_1(article, dict)
```

## Arguments

- article:

  The text as a vector of strings.

- dict:

  A list of regular expressions for each concept.

## Value

Index of elements with phrase of interest
