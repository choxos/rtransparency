# Identify and extract Data and Code sharing from a list of PMC XML files.

Takes a list of PMC XML files and returns data related to the presence
of Data or Code, including whether Data or Code have been shared. If
Data or Code exist, it will extract the relevant text for each.

## Usage

``` r
rt_data_code_pmc_list(filenames, remove_ns = TRUE, specificity = NULL)
```

## Arguments

- filenames:

  A list of the PMC XML filenames as strings.

- remove_ns:

  Ignored since version 1.2.0 and kept for backward compatibility.
  Default XML namespaces are now always removed, so a namespaced PMC XML
  file gives the same result as a plain one.

- specificity:

  Retained for backward compatibility; see
  [`rt_data_code_pmc`](https://choxos.github.io/rtransparency/reference/rt_data_code_pmc.md).

## Value

A dataframe of results, one row per file.

## Examples

``` r
# \donttest{
# Paths to PMC XML files
filepath <- system.file(
  "extdata", "PMID32171256-PMC7071725.xml", package = "rtransparency"
)
filepaths <- list(filepath)

# Identify and extract indicators of data and code sharing
results_table <- rt_data_code_pmc_list(filepaths)
# }
```
