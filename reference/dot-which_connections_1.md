# Identify mentions of financial connections

Identify mentions such as: "SS has a financial relationship with GSK."

## Usage

``` r
.which_connections_1(article, dict)
```

## Arguments

- article:

  The text as a vector of strings.

- dict:

  A list of regular expressions for each concept.

## Value

Index of elements with phrase of interest
