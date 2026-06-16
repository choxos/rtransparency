# Identify generic mentions of registration

Extract the index of mentions such as: "Trial registration number is
TCTR20151021001."

## Usage

``` r
.which_registration_1(article, dict)
```

## Arguments

- article:

  A string or a list of strings.

- dict:

  A list of regular expressions for each concept.

## Value

Index of element with phrase of interest
