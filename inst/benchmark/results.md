# rtransparency accuracy benchmark

Package version 1.2.0. Detectors run on NCBI PMC full-text XML for the
human-labeled held-out test articles of Serghiou et al. (2021), compared to
the published Fig 2 (XML subset). Bootstrap: 2000 resamples, unweighted
(see data-raw/benchmark/README.md). Current values are point [95% CI].

## COI
Coverage: 153 / 153 articles fetched and scored (100%).

| Metric | Current [95% CI] | Paper Fig 2 (xml) |
|---|---|---|
| Sensitivity | 94.0 [88.8, 98.8] | 99.6 [99.0, 100.0] |
| Specificity | 100.0 [100.0, 100.0] | 100.0 [100.0, 100.0] |
| PPV | 100.0 [100.0, 100.0] | 100.0 [100.0, 100.0] |
| NPV | 93.2 [88.0, 98.6] | 95.9 [90.6, 100.0] |
| Accuracy | 96.7 [94.1, 99.3] | 99.6 [99.1, 100.0] |

## FUND
Coverage: 188 / 188 articles fetched and scored (100%).

| Metric | Current [95% CI] | Paper Fig 2 (xml) |
|---|---|---|
| Sensitivity | 91.7 [85.3, 97.3] | 99.7 [99.3, 100.0] |
| Specificity | 95.7 [91.7, 99.1] | 100.0 [100.0, 100.0] |
| PPV | 93.0 [87.3, 98.5] | 100.0 [100.0, 100.0] |
| NPV | 94.9 [90.9, 98.3] | 98.3 [95.8, 100.0] |
| Accuracy | 94.1 [91.0, 97.3] | 99.8 [99.4, 100.0] |

## REGISTER
Coverage: 214 / 214 articles fetched and scored (100%).

| Metric | Current [95% CI] | Paper Fig 2 (xml) |
|---|---|---|
| Sensitivity | 98.3 [95.8, 100.0] | 96.9 [93.1, 99.4] |
| Specificity | 92.7 [86.9, 97.7] | 99.7 [99.5, 99.9] |
| PPV | 94.3 [89.7, 98.2] | 93.8 [89.2, 97.4] |
| NPV | 97.8 [94.4, 100.0] | 99.9 [99.7, 100.0] |
| Accuracy | 95.8 [93.0, 98.1] | 99.6 [99.3, 99.8] |

