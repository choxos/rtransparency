# Identify mentions of lack of registration

Extract the index of mentions such as: "This trial and its protocol were
not registered on a publicly accessible registry."

## Usage

``` r
.which_not_registered_1(article, dict)
```

## Arguments

- article:

  A string or a list of strings.

- dict:

  A list of regular expressions for each concept.

## Value

Index of element with phrase of interest
