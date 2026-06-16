# Remove references

Removes mentions such as: "An active observational cohort study was
conducted as previously reported (ClinicalTrials.gov identifier
NCT01280162) \[16\]."

## Usage

``` r
.obliterate_references_1(article)
```

## Arguments

- article:

  A List with paragraphs of interest.

## Value

The list of paragraphs without mentions of financial COIs.
