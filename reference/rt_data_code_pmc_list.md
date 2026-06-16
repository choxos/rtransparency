# Identify and extract Data and Code sharing from PMC XML files.

Takes a list of PMC XML files and returns data related to the presence
of Data or Code, including whether Data or Code have been shared. If
Data or Code exist, it will extract the relevant text for each.

## Usage

``` r
rt_data_code_pmc_list(filenames, remove_ns = T, specificity = "low")
```

## Arguments

- filenames:

  A list of the PMC XML filenames as strings.

- remove_ns:

  TRUE if an XML namespace exists, else FALSE (default).

- specificity:

  How specific should the extraction of text from the XML be? If "low"
  then this is a as sensitive as possible (it extracts all text). If
  "moderate", then it extracts all paragraphs. If "high", then it only
  extracts text from specific locations (footnotes, methods,
  supplements).

## Value

A dataframe of results. Takes a median of 200ms per article.

## Examples

``` r
if (FALSE) { # \dontrun{
# Paths to PMC XML files
filepath <- system.file(
  "extdata", "PMID32171256-PMC7071725.xml", package = "rtransparent"
)
filepaths <- list(filepath)

# Identify and extract indicators of data and code sharing
results_table <- rt_data_code_pmc_list(filepaths, remove_ns = TRUE)
} # }
```
