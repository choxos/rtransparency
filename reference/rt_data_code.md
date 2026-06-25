# Identify and extract Data and Code statements in TXT files.

Takes a TXT file and returns data related to the presence of Data and/or
Code statements, including whether Data and/or Code statements exist. If
such statements exist, it extracts them.

## Usage

``` r
rt_data_code(filename)
```

## Arguments

- filename:

  The name of the TXT file as a string.

## Value

A dataframe of results. It returns whether text suggesting the presence
of data or code was found, and if so, what this text was.

## Examples

``` r
# \donttest{
# Write a short example article to a temporary text file.
filepath <- file.path(tempdir(), "PMID00000000-PMC0000000.txt")
writeLines(c(
  "To our knowledge, this is the first study of its kind.",
  "Conflicts of interest: none declared.",
  "This work was supported by the National Institutes of Health (R01-000000).",
  "The protocol was registered at ClinicalTrials.gov (NCT00000000).",
  "All data and code are available at https://github.com/example/repo.",
  "We independently replicated the original analysis."
), filepath)

# Identify and extract data and code availability.
results_table <- rt_data_code(filepath)
# }
```
