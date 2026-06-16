# Remove negated replication mentions

Removes mentions such as "failed to replicate" or "could not replicate".

## Usage

``` r
.negate_replication_1(article)
```

## Arguments

- article:

  A character vector of matching paragraphs.

## Value

Logical vector; TRUE where the match is a negation (to be excluded).
