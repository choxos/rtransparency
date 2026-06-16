# Identify mentions of protocol

Extract the index of mentions such as: "The complete study protocol has
been published previously (Supplement 1)"

## Usage

``` r
.which_protocol_1(article, dict)
```

## Arguments

- article:

  A string or a list of strings.

- dict:

  A list of regular expressions for each concept.

## Value

Index of element with phrase of interest
