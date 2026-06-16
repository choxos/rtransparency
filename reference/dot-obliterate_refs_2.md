# Remove mentions of previously reported registered studies

Removes mentions such as: "An active o \<- servational cohort study was
conducted as previously reported (ClinicalTrials.gov identifier
NCT01280162) \[16\]."

## Usage

``` r
.obliterate_refs_2(article)
```

## Arguments

- article:

  A List with paragraphs of interest.

## Value

The list of paragraphs without mentions of financial COIs.
