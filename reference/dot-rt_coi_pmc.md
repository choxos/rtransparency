# Identify and extract Conflicts of Interest (COI) statements in PMC XML files.

Takes a PMC XML file as a list of strings and returns data related to
the presence of a COI statement, including whether a COI statement
exists. If a Funding statement exists, it extracts it. This is a
modified version of the \`rt_coi_pmc\` designed for integration with
\`rt_all_pmc\`.

## Usage

``` r
.rt_coi_pmc(article_ls, pmc_coi_ls, dict)
```

## Arguments

- article_ls:

  A PMC XML as a list of strings.

- pmc_coi_ls:

  A list of results from the \`.get_coi_pmc\` function.

- dict:

  A list of regular expressions for each concept.

## Value

A dataframe of results.
