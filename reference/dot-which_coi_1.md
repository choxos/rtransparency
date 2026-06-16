# Identify standard mentions of COI statements

Extract mentions of COI statements that contain standard phrases, such
as "Conflicts of Interest".

## Usage

``` r
.which_coi_1(article, dict)
```

## Arguments

- article:

  The text as a vector of strings.

- dict:

  A list of regular expressions for each concept.

## Value

Index of element with phrase of interest
