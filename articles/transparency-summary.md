# Summarizing transparency across a corpus

The detector functions
([`rt_all_pmc()`](https://choxos.github.io/rtransparency/reference/rt_all_pmc.md),
[`rt_data_code_pmc()`](https://choxos.github.io/rtransparency/reference/rt_data_code_pmc.md))
describe **one article at a time**. Most studies of research
transparency instead ask corpus-level questions: across thousands of
articles, how often is each practice present? Is it improving over time?
Does it differ by journal or article type?

This vignette shows how to go from per-article detector output to that
kind of summary, using
[`rt_summary()`](https://choxos.github.io/rtransparency/reference/rt_summary.md),
[`rt_score()`](https://choxos.github.io/rtransparency/reference/rt_score.md)
and
[`rt_plot()`](https://choxos.github.io/rtransparency/reference/rt_plot.md).

## From one article to many

Running a detector on a single article returns a one-row table of
indicators:

``` r

library(rtransparency)
#> rtransparency 1.2.0: identify indicators of transparency (conflicts of interest, funding,
#> protocol registration, novelty, replication, data and code sharing, AI-use disclosure,
#> open-access licensing and reporting-guideline use) in biomedical articles. GitHub: https://github.com/choxos/rtransparency | vignette("rtransparency")

xml <- system.file(
  "extdata", "PMID32171256-PMC7071725.xml", package = "rtransparency"
)
one <- rt_all_pmc(xml)
one[, c("pmid", "is_coi_pred", "is_fund_pred", "is_register_pred")]
#> # A tibble: 1 × 4
#>   pmid     is_coi_pred is_fund_pred is_register_pred
#>   <chr>    <lgl>       <lgl>        <lgl>           
#> 1 32171256 TRUE        FALSE        FALSE
```

To study a corpus you run a detector over many files and stack the rows;
`purrr::map_dfr(files, rt_all_pmc)` returns all ten indicators per
article in one pass. The result is one row per article with the
indicator columns `is_coi_pred`, `is_fund_pred`, `is_register_pred`,
`is_open_data`, `is_open_code`, `is_novelty_pred`,
`is_replication_pred`, `is_ai_pred`, `is_open_access` and
`is_reporting_pred`. `is_ai_pred` is `NA` for articles published before
2023, and
[`rt_summary()`](https://choxos.github.io/rtransparency/reference/rt_summary.md)
drops those `NA`s, so the AI-disclosure prevalence is computed only over
the articles where the indicator applies. `is_open_access` and
`is_reporting_pred` are summarized by
[`rt_summary()`](https://choxos.github.io/rtransparency/reference/rt_summary.md)
too, but are not part of the five openness practices counted by
[`rt_score()`](https://choxos.github.io/rtransparency/reference/rt_score.md).

This package ships a small **simulated** table of that shape, `rt_demo`,
so the rest of the vignette runs without downloading anything:

``` r

data(rt_demo)
head(rt_demo)
#> # A tibble: 6 × 13
#>   pmid      year type     is_coi_pred is_fund_pred is_register_pred is_open_data
#>   <chr>    <int> <chr>    <lgl>       <lgl>        <lgl>            <lgl>       
#> 1 28143943  2011 review-… FALSE       TRUE         TRUE             FALSE       
#> 2 31314758  2014 systema… FALSE       TRUE         TRUE             FALSE       
#> 3 30397608  2022 systema… TRUE        TRUE         FALSE            TRUE        
#> 4 37703615  2026 researc… TRUE        TRUE         TRUE             TRUE        
#> 5 26030375  2022 researc… TRUE        TRUE         FALSE            FALSE       
#> 6 21738034  2018 researc… TRUE        TRUE         FALSE            FALSE       
#> # ℹ 6 more variables: is_open_code <lgl>, is_novelty_pred <lgl>,
#> #   is_replication_pred <lgl>, is_ai_pred <lgl>, is_open_access <lgl>,
#> #   is_reporting_pred <lgl>
```

## Prevalence of each indicator

[`rt_summary()`](https://choxos.github.io/rtransparency/reference/rt_summary.md)
reports, for each indicator, how many articles were assessed, how many
were positive, the apparent prevalence and its 95% confidence interval:

``` r

s <- rt_summary(rt_demo)
knitr::kable(
  s[, c("label", "n_articles", "n_detected", "percent", "conf_low", "conf_high")],
  digits = 1,
  col.names = c("Indicator", "Assessed", "Detected", "%", "CI low", "CI high")
)
```

| Indicator             | Assessed | Detected |    % | CI low | CI high |
|:----------------------|---------:|---------:|-----:|-------:|--------:|
| Conflicts of interest |     1200 |      845 | 70.4 |   67.8 |    72.9 |
| Funding disclosure    |     1200 |      955 | 79.6 |   77.2 |    81.8 |
| Protocol registration |     1200 |      356 | 29.7 |   27.2 |    32.3 |
| Data sharing          |     1200 |      245 | 20.4 |   18.2 |    22.8 |
| Code sharing          |     1200 |      102 |  8.5 |    7.1 |    10.2 |
| Novelty               |     1200 |      653 | 54.4 |   51.6 |    57.2 |
| Replication           |     1200 |      113 |  9.4 |    7.9 |    11.2 |
| AI disclosure         |      282 |       71 | 25.2 |   20.5 |    30.6 |
| Open-access license   |     1200 |      986 | 82.2 |   79.9 |    84.2 |
| Reporting guideline   |     1200 |      167 | 13.9 |   12.1 |    16.0 |

### Correcting for detector error

A text-mining detector is not perfect, so the **observed** prevalence is
a biased estimate of the **true** prevalence.
[`rt_summary()`](https://choxos.github.io/rtransparency/reference/rt_summary.md)
corrects for this using each detector’s sensitivity and specificity
estimates (the Rogan-Gladen estimator). The correction is on by default
and adds `adj_percent`, `adj_low` and `adj_high`:

``` r

knitr::kable(
  s[, c("label", "percent", "adj_percent", "adj_low", "adj_high")],
  digits = 1,
  col.names = c("Indicator", "Apparent %", "Corrected %", "CI low", "CI high")
)
```

| Indicator             | Apparent % | Corrected % | CI low | CI high |
|:----------------------|-----------:|------------:|-------:|--------:|
| Conflicts of interest |       70.4 |        74.9 |   70.6 |    81.1 |
| Funding disclosure    |       79.6 |        86.1 |   80.7 |    95.2 |
| Protocol registration |       29.7 |        24.6 |   18.2 |    29.1 |
| Data sharing          |       20.4 |        25.7 |   20.8 |    30.3 |
| Code sharing          |        8.5 |         9.1 |    6.7 |    11.2 |
| Novelty               |       54.4 |        62.8 |   56.7 |    71.1 |
| Replication           |        9.4 |         8.2 |    6.4 |    10.3 |
| AI disclosure         |       25.2 |          NA |     NA |      NA |
| Open-access license   |       82.2 |          NA |     NA |      NA |
| Reporting guideline   |       13.9 |        13.7 |   11.6 |    16.2 |

The accuracy values come from
[`rt_accuracy`](https://choxos.github.io/rtransparency/reference/rt_accuracy.md):

``` r

rt_accuracy
#> # A tibble: 8 × 9
#>   variable          label sensitivity specificity    tp    fn    tn    fp source
#>   <chr>             <chr>       <dbl>       <dbl> <int> <int> <int> <int> <chr> 
#> 1 is_coi_pred       Conf…       0.94        1        79     5    69     0 Sergh…
#> 2 is_fund_pred      Fund…       0.917       0.957    66     6   111     5 Sergh…
#> 3 is_register_pred  Prot…       0.983       0.927   116     2    89     7 Sergh…
#> 4 is_open_data      Data…       0.765       0.99     88    27   100     1 Sergh…
#> 5 is_open_code      Code…       0.881       0.995    96    13   214     1 Sergh…
#> 6 is_novelty_pred   Nove…       0.838       0.952    83    16   258    13 rtran…
#> 7 is_replication_p… Repl…       0.964       0.984   107     4   967    16 sensi…
#> 8 is_reporting_pred Repo…       0.954       0.99     62     3   926     9 rtran…
```

AI-use disclosure and open-access licensing have no bundled accuracy
estimate, so their corrected values are `NA`. Each row of `rt_accuracy`
records where its estimate comes from (`source`) and the validation
counts behind it (`tp`, `fn`, `tn`, `fp`).

**The corrected interval carries the validation’s uncertainty.** A
detector’s sensitivity and specificity are themselves estimates from a
finite hand-labeled sample. By default (`adj_interval = "simulation"`)
[`rt_summary()`](https://choxos.github.io/rtransparency/reference/rt_summary.md)
draws the apparent prevalence, the sensitivity and the specificity from
their Jeffreys posteriors, corrects each draw and reports the percentile
interval, so the corrected interval widens when the validation sample is
small. For rare indicators (registration, code sharing, replication)
this matters most: their correction subtracts the false-positive rate
`1 - specificity`, which is only known to within a percentage point or
so. `adj_interval = "fixed"` gives the narrower interval that treats the
accuracy as known.

**Registration is summarized over the articles its detector assesses.**
When the data carry `is_research` (as
[`rt_all_pmc()`](https://choxos.github.io/rtransparency/reference/rt_all_pmc.md)
output does), the registration denominator is restricted to research
articles and reviews, the types the detector assesses; set
`register_assessed_only = FALSE` to count every article.

To use your own validation (or the published `oddpub` values for data
and code), pass any table with `variable`, `sensitivity` and
`specificity` columns:

``` r

# Keep only the point estimates: the bundled validation counts would no longer
# match an edited sensitivity (rt_summary() warns when they disagree).
my_acc <- rt_accuracy[, c("variable", "sensitivity", "specificity")]
my_acc$sensitivity[my_acc$variable == "is_open_data"] <- 0.758
rt_summary(rt_demo, indicators = "is_open_data", accuracy = my_acc)[,
  c("label", "percent", "adj_percent")]
#> # A tibble: 1 × 3
#>   label        percent adj_percent
#>   <chr>          <dbl>       <dbl>
#> 1 Data sharing    20.4        26.0
```

## How many practices per article

[`rt_score()`](https://choxos.github.io/rtransparency/reference/rt_score.md)
adds a per-article count of the openness practices met (conflicts of
interest, funding, registration, data and code). Tabulating it shows how
many articles meet zero, one, two … of the five practices:

``` r

scored <- rt_score(rt_demo)
knitr::kable(
  as.data.frame(table(`Practices met` = scored$n_indicators)),
  col.names = c("Practices met", "Articles")
)
```

| Practices met | Articles |
|:--------------|---------:|
| 0             |       52 |
| 1             |      288 |
| 2             |      467 |
| 3             |      305 |
| 4             |       74 |
| 5             |       14 |

## Subgroups

Pass `by` to summarize within a grouping column, such as article type:

``` r

by_type <- rt_summary(rt_demo, by = "type", adjust = FALSE)
knitr::kable(
  by_type[by_type$indicator == "is_open_data",
          c("type", "label", "n_articles", "percent")],
  digits = 1,
  col.names = c("Type", "Indicator", "Assessed", "%")
)
```

| Type              | Indicator    | Assessed |    % |
|:------------------|:-------------|---------:|-----:|
| review-article    | Data sharing |      241 | 19.5 |
| systematic-review | Data sharing |      132 | 23.5 |
| research-article  | Data sharing |      827 | 20.2 |

## Plots

[`rt_plot()`](https://choxos.github.io/rtransparency/reference/rt_plot.md)
returns a `ggplot`, so it composes with the usual ggplot2 layers. The
default is a prevalence bar chart:

``` r

library(ggplot2)
rt_plot(rt_demo) + ggtitle("Transparency indicators in rt_demo")
```

![Bar chart of the prevalence of each transparency
indicator](transparency-summary_files/figure-html/unnamed-chunk-10-1.png)

Use `type = "trend"` with a year column to see prevalence over time:

``` r

rt_plot(rt_demo, type = "trend", year = "year")
#> Warning: Removed 13 rows containing missing values or values outside the scale range
#> (`geom_line()`).
#> Warning: Removed 13 rows containing missing values or values outside the scale range
#> (`geom_point()`).
```

![Line chart of each transparency indicator's prevalence by
year](transparency-summary_files/figure-html/unnamed-chunk-11-1.png)

The AI-disclosure line begins only in 2023, because the indicator is
`NA` before then; the rising data-sharing and AI lines illustrate the
kind of trend these summaries are meant to surface. Restrict a plot to
particular indicators with `indicators =`, for example to follow AI-use
disclosure on its own:

``` r

rt_plot(rt_demo, type = "trend", year = "year", indicators = "is_ai_pred") +
  ggtitle("Disclosure of generative-AI use, 2023 onward")
#> Warning: Removed 13 rows containing missing values or values outside the scale range
#> (`geom_line()`).
#> Warning: Removed 13 rows containing missing values or values outside the scale range
#> (`geom_point()`).
```

![Line chart of AI-use disclosure prevalence by year from
2023](transparency-summary_files/figure-html/unnamed-chunk-12-1.png)

Set `adjusted = TRUE` in either plot to show the error-corrected
prevalence instead of the apparent prevalence.

## Putting it together

A typical analysis is therefore: run a detector over your corpus, stack
the rows, then

``` r

results <- purrr::map_dfr(xml_files, rt_all_pmc)
rt_summary(results)                       # prevalence + corrected prevalence
rt_score(results)                         # per-article practice count
rt_plot(results, type = "trend", year = "year")
```

For the per-indicator detection methodology, see
[`vignette("rtransparency")`](https://choxos.github.io/rtransparency/articles/rtransparency.md).
