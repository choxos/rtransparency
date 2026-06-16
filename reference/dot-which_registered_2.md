# Identify generic mentions of registration

Extract the index of mentions such as: " EPGP is registered with
clinicaltrials.gov (NCT00552045)."

## Usage

``` r
.which_registered_2(article, dict)
```

## Arguments

- article:

  A string or a list of strings.

- dict:

  A list of regular expressions for each concept.

## Value

Index of element with phrase of interest
