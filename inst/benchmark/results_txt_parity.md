# TXT-parity benchmark

Package version 1.2.0. Derived from the 1000 hand-labeled 2023 PMC articles: each article's text is extracted and scored with `rt_all()` as plain text, and the XML with `rt_all_pmc()`, against the same labels. A plain-text file has no XML structure, so the XML-only routes (section titles, funding tags, footnote types) are unavailable to it; the gap between the columns is their value. Conflict-of-interest, funding, data and AI labels were reconciled against the PMC detector's output (see `results_2023_sample.md`), which favors the PMC column for those rows: several articles whose plain text carries a conflict-of-interest heading and statement ("Declaration of competing interest: None.") are labeled FALSE, which lowers the TXT COI specificity shown here.

| Indicator | n | Positives | TXT sens | TXT spec | TXT PPV | PMC sens | PMC spec |
|---|---:|---:|---:|---:|---:|---:|---:|
| coi | 1000 | 927 | 94.4 | 84.9 | 98.8 | 100.0 | 90.4 |
| fund | 1000 | 537 | 79.9 | 90.3 | 90.5 | 95.0 | 95.2 |
| reg | 1000 | 52 | 90.4 | 98.4 | 75.8 | 84.6 | 99.2 |
| nov | 1000 | 205 | 89.3 | 93.5 | 77.9 | 90.2 | 93.3 |
| rep | 1000 | 17 | 82.4 | 98.3 | 45.2 | 82.4 | 98.4 |
| data | 1000 | 123 | 72.4 | 98.3 | 85.6 | 91.9 | 98.1 |
| code | 1000 | 33 | 78.8 | 99.1 | 74.3 | 93.9 | 99.0 |
| ai | 996 | 9 | 77.8 | 99.1 | 43.8 | 100.0 | 100.0 |
| reporting | 1000 | 65 | 95.4 | 99.3 | 89.9 | 95.4 | 99.0 |

