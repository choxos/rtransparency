# Detector accuracy estimates

Sensitivity and specificity of each transparency detector, with the
validation counts behind them, used by \[rt_summary()\] to correct an
apparent prevalence for detector error (the Rogan-Gladen correction) and
to carry the uncertainty of these estimates into the corrected interval.

## Usage

``` r
rt_accuracy
```

## Format

A tibble with 8 rows and 9 columns:

- variable:

  Indicator column name, as returned by \[rt_all_pmc()\].

- label:

  Human-readable indicator name.

- sensitivity:

  Detector sensitivity (true-positive rate), 0-1.

- specificity:

  Detector specificity (true-negative rate), 0-1.

- tp, fn:

  True positives and false negatives behind \`sensitivity\`.

- tn, fp:

  True negatives and false positives behind \`specificity\`.

- source:

  Where the estimate comes from.

## Source

This package's benchmarks (\`inst/benchmark/\`), including the held-out
labels of Serghiou S, Contopoulos-Ioannidis DG, Boyack KW, Riedel N,
Wallach JD, Ioannidis JPA (2021). Assessment of transparency indicators
across the biomedical literature: How open is open? *PLOS Biology*
19(3): e3001107.
[doi:10.1371/journal.pbio.3001107](https://doi.org/10.1371/journal.pbio.3001107)
.

## Details

Every row describes the detectors shipped in this version, scored on
hand-labeled articles (see \`inst/benchmark/results_all_sets.csv\` and
the reports beside it):

\* Conflicts of interest, funding and registration: the held-out,
independently labeled test set of Serghiou et al. (2021). These are not
the paper's published values, which describe the 2021 detectors; those
are kept in \[rt_accuracy_2021\]. \* Data and code sharing: the same
held-out set's data and code labels. The native detector was developed
against this set, so these are regression estimates rather than an
untouched validation. \* Novelty: the maintainer's hand-labeled
novelty/replication gold set. \* Replication: sensitivity from a
replication-enriched sample (111 positives) and specificity from the
representative 2023 sample, so the correction mixes designs. \*
Reporting guideline: the 1000-article 2023 sample, hand-labeled.

Open-access licensing (structured metadata whose specificity cannot be
estimated in the open-access subset) and AI-use disclosure (too few
positives) are not included, so \[rt_summary()\] reports them
uncorrected. Supply your own table to \[rt_summary()\] via its
\`accuracy\` argument when you have study-specific or external
estimates; the \`data-raw/validation/\` scripts produce one in this
format.

## See also

\[rt_summary()\], \[rt_accuracy_2021\]
