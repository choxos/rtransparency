# Negate disclosures that are neither COI nor funding statements

Remove mentions of disclosures such as "Patient Information Disclosure".

## Usage

``` r
.negate_disclosure_2(article, dict)
```

## Arguments

- article:

  The text as a vector of strings.

- dict:

  A list of regular expressions for each concept.

## Value

A boolean indicating whether a disclosure should be retained.
