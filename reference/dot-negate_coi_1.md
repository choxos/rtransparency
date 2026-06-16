# Negate statements that mention conflict but are not COI

Keep statements such as "No conficts of interest reported", but do not
keep statements such as "The conflicts of interest are becoming
commoner."

## Usage

``` r
.negate_coi_1(article, dict)
```

## Arguments

- article:

  The text as a vector of strings.

- dict:

  A list of regular expressions for each concept.

## Value

A boolean indicating whether a disclosure should be retained.
