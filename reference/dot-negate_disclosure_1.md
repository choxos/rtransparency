# Negate disclosures that are funding statements

Keep statements such as "No financial disclosures reported.", but do not
keep statements such as "The authors disclose not funding received."

## Usage

``` r
.negate_disclosure_1(article, dict)
```

## Arguments

- article:

  The text as a vector of strings.

- dict:

  A list of regular expressions for each concept.

## Value

A boolean indicating whether a disclosure should be retained.
