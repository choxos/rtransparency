# Identify and extract transparency statements from a TXT file.

Takes a TXT file and examines whether any statements of Conflicts of
Interest (COI), Funding, Protocol Registration, Novelty or Replication
exist. If any such statements are found, it also extracts the relevant
text.

## Usage

``` r
rt_all(filename)
```

## Arguments

- filename:

  The name of the TXT file as a string.

## Value

A dataframe of results. It returns the PMID of the article (if this was
included in the filename and preceded by "PMID"), whether each of the
five indicators of transparency (COI, Funding, Registration, Novelty and
Replication) was identified, the relevant text identified, and whether
each labelling function identified relevant text or not. The labelling
functions are returned to add flexibility in how this package is used;
for example, future definitions of Registration may differ from the one
we used. If a labelling function returns NA it means that it was not
run.

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

# Identify and extract indicators of transparency.
results_table <- rt_all(filepath)
# }
```
