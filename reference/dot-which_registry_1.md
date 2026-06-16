# Identify mentions of registry

Extract the index of mentions such as: "Here, we describe a
collaboration between an international group of patient organisations
advocating for patients with atypical haemolytic uraemic syndrome
(aHUS), the aHUS Alliance, and an international aHUS patient registry
(ClinicalTrials.gov NCT01522183)."

## Usage

``` r
.which_registry_1(article, dict)
```

## Arguments

- article:

  A string or a list of strings.

- dict:

  A list of regular expressions for each concept.

## Value

Index of element with phrase of interest
