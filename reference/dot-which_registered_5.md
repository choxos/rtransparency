# Identify generic mentions of registration

Extract the index of mentions such as: "The Régression de l'Albuminurie
dans la Néphropathie Drépanocytaire (RAND) study design was approved by
the local ethics committee (Ref: DGRI CCTIRS MG/CP09.503, 9 July 2009)
and registered at ClinicalTrials.gov (NCT01195818)."

## Usage

``` r
.which_registered_5(article, dict)
```

## Arguments

- article:

  A string or a list of strings.

- dict:

  A list of regular expressions for each concept.

## Value

Index of element with phrase of interest
