# Identify replication components in PMC XML files.

Takes a PMC XML file as a list of article sections and returns data
related to the presence of a replication or validation component. This
is the internal version designed for integration with `rt_all_pmc`.

## Usage

``` r
.rt_replication_pmc(article_ls)
```

## Arguments

- article_ls:

  A PMC XML as a list of strings (from `.get_article_txt`).

## Value

A named list of results.
