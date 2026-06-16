# Remove irrelevat mentions of honoraria

Remove mentions of honoraria such as "Patients received honoraria".

## Usage

``` r
.obliterate_honoraria_1(article, dict)
```

## Arguments

- article:

  The text as a vector of strings.

- dict:

  A list of regular expressions for each concept.

## Value

A boolean indicating whether a disclosure should be retained.
