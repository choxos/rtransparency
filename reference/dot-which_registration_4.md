# Identify generic mentions of registration

Extract the index of mentions such as: "The RAPiD trial's International
Standard Randomised Controlled Trial Number (ISRCTN) registration is
ISRCTN 49204710."

## Usage

``` r
.which_registration_4(article, dict)
```

## Arguments

- article:

  A string or a list of strings.

- dict:

  A list of regular expressions for each concept.

## Value

Index of element with phrase of interest
