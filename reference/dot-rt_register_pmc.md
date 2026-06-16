# Identify and extract Registration statements in PMC XML files.

Takes a PMC XML file as a list of strings and returns data related to
the presence of a Registration statement, including whether such a
statement exists. If a Registration statement exists, it extracts it.
This is a modified version of the \`rt_register_pmc\` designed for
integration with \`rt_all_pmc\`.

## Usage

``` r
.rt_register_pmc(article_ls, pmc_reg_ls, dict)
```

## Arguments

- article_ls:

  A PMC XML as a list of strings.

- pmc_reg_ls:

  A list of results from the \`.get_register_pmc\` function.

- dict:

  A list of regular expressions for each concept.

## Value

A dataframe of results.
