# Identify generic mentions of registration

Extract the index of mentions such as: "registered with Clinical Trials
(ChiCTR-IOR-14005438)"

## Usage

``` r
.which_registered_3(article, dict)
```

## Arguments

- article:

  A string or a list of strings.

- dict:

  A list of regular expressions for each concept.

## Value

Index of element with phrase of interest
