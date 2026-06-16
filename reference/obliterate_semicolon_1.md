# Remove semicolons when within parentheses

Removes mentions such as: "guidelines for diagnostic studies (trial
registered at www.clinicaltrial.gov; NCT01697930)."

## Usage

``` r
obliterate_semicolon_1(article)
```

## Arguments

- article:

  A List with paragraphs of interest.

## Value

The list of paragraphs without mentions of financial COIs.
