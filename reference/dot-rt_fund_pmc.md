# Identify and extract Funding statements in PMC XML files.

Takes a PMC XML file as a list of strings and returns data related to
the presence of a Funding statement, including whether a Funding
statement exists. If a Funding statement exists, it extracts it. This is
a modified version of the \`rt_fund_pmc\` designed for integration with
\`rt_all_pmc\`.

## Usage

``` r
.rt_fund_pmc(article_ls, pmc_fund_ls)
```

## Arguments

- article_ls:

  A PMC XML as a list of strings.

- pmc_fund_ls:

  A list of results from the \`.get_fund_pmc\` function.

## Value

A dataframe of results.
