# Multilingual detection benchmark

Package version 1.2.0. Open-access PubMed Central articles per language (up to 70 each, drawn with a fixed seed from the PMC language filter, 2018-2024; the list is `data-raw/benchmark/multilingual_ids.csv`). The COI detection rate approximates recall, as these clinical articles almost all carry a disclosure. The funding rate is a detection rate, not recall: many of these articles report no funding, which the indicator scores FALSE by design. Many articles are bilingual, so the English detector already catches some statements.

| Language | n | COI detected | Funding detected |
|---|---:|---:|---:|
| Spanish | 68 | 90% | 15% |
| French | 66 | 77% | 2% |
| German | 65 | 77% | 54% |
| Italian | 66 | 83% | 50% |
| Portuguese | 70 | 59% | 39% |

