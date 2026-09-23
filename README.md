# rtransparency

<!-- badges: start -->
[![CRAN status](https://www.r-pkg.org/badges/version/rtransparency)](https://CRAN.R-project.org/package=rtransparency)
[![R-CMD-check](https://github.com/choxos/rtransparency/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/choxos/rtransparency/actions/workflows/R-CMD-check.yaml)
[![pkgdown](https://github.com/choxos/rtransparency/actions/workflows/pkgdown.yaml/badge.svg)](https://choxos.github.io/rtransparency/)
[![Lifecycle: stable](https://img.shields.io/badge/lifecycle-stable-brightgreen.svg)](https://lifecycle.r-lib.org/articles/stages.html#stable)
[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)
[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.20775089.svg)](https://doi.org/10.5281/zenodo.20775089)
<!-- badges: end -->

<div align="justify">

`rtransparency` automatically identifies and extracts **indicators of research
transparency** from the full text of biomedical articles, in both PubMed Central
(PMC) JATS XML and plain-text (PDF-derived) form. Every prediction comes with the
exact statement that triggered it, so results are auditable rather than a black
box. Detection is rule-based (curated regular expressions over the relevant
article sections), self-contained (no GitHub-only or AGPL dependencies), and
ships with reproducible accuracy benchmarks.

## The ten indicators

| Indicator | Detects | XML function | Text function |
|---|---|---|---|
| **Conflicts of interest** | A COI disclosure is present (including "no competing interests") | `rt_coi_pmc` | `rt_coi` |
| **Funding** | A statement that funding was received | `rt_fund_pmc` | `rt_fund` |
| **Protocol registration** | A trial/protocol registration identifier or statement (NCT, ISRCTN, PROSPERO, OSF, CHiCTR, DRKS, ANZCTR, IRCT, UMIN, ...) | `rt_register_pmc` | `rt_register` |
| **Novelty** | The article claims its own work is novel or first | `rt_novelty_pmc` | `rt_novelty` |
| **Replication** | A replication or external/independent validation was performed | `rt_replication_pmc` | `rt_replication` |
| **Data sharing** | The authors' own data are made available (repository, accession, or in-article) | `rt_data_code_pmc` | `rt_data_code` |
| **Code sharing** | The authors' own analysis code is shared | `rt_data_code_pmc` | `rt_data_code` |
| **AI disclosure** | A statement discloses generative-AI use in manuscript preparation (2023+) | `rt_ai_pmc` | `rt_ai` |
| **Open-access license** | The article is openly licensed, and which license (CC-BY, CC-BY-NC-ND, CC0, ...) | `rt_oa_pmc` | `rt_oa` |
| **Reporting guideline** | The authors followed a reporting guideline, and which (CONSORT, PRISMA, STROBE, ARRIVE, ...) | `rt_reporting_pmc` | `rt_reporting` |

Conflicts of interest and AI disclosure are **disclosure-based**: a statement on
the topic counts whether the disclosure is positive or negative. Conflict-of-
interest and funding statements are detected not only in English but also in
**Spanish, Portuguese, French, German and Italian**.

## Installation

```r
# From CRAN
install.packages("rtransparency")

# Development version from GitHub
# install.packages("remotes")
remotes::install_github("choxos/rtransparency", build_vignettes = TRUE)
```

No GitHub-only or AGPL dependencies are required; data and code detection is
native (it no longer wraps `oddpub`). `rt_read_pdf()` (PDF to text) additionally
needs the poppler `pdftotext` utility on your system (or the optional `pdftools`
package). The optional `furrr` and `future` packages enable parallel corpus
processing, `ggplot2` plotting, and `jsonlite` the ClinicalTrials.gov lookup.

## Quick start: all ten indicators in one call

```r
library(rtransparency)

xml <- system.file("extdata", "PMID32171256-PMC7071725.xml", package = "rtransparency")

res <- rt_all_pmc(xml)

# The predictions, one column per indicator:
res[, c("is_coi_pred", "is_fund_pred", "is_register_pred", "is_novelty_pred",
        "is_replication_pred", "is_open_data", "is_open_code", "is_ai_pred",
        "is_open_access", "is_reporting_pred")]

# Each prediction is paired with the text/value that triggered it, e.g.:
res$coi_text
res$open_data_statements
res$oa_license            # e.g. "CC-BY-4.0"
res$reporting_guideline   # e.g. "PRISMA"
```

`rt_all_pmc()` returns one row with the ten predictions, the extracted statement
for each, article identifiers and metadata, the year, and `is_success`.
`is_ai_pred` is `NA` for articles published before 2023; `ai_used`, `ai_tools`
and `ai_purpose` say whether a disclosure reports use, of which tools, and for
what. `has_das` records whether the article has a data-availability section.

## Getting articles

`rt_fetch_pmc()` downloads PMC full-text XML for PMCIDs, PubMed IDs or DOIs
(from NCBI by default, or from Europe PMC), reusing files already downloaded:

```r
got <- rt_fetch_pmc(c("PMC7071725", "32171256", "10.1186/s12874-020-0914-6"),
                    dir = "xml")
res <- rt_all_pmc_dir("xml")
```

`rt_convert_ids()` maps PubMed IDs, PMCIDs and DOIs to one another. Set the
`ENTREZ_KEY` environment variable to an NCBI API key to raise the rate limit.

## Per-indicator functions

Each indicator can be run on its own, for a PMC XML file or a plain-text file:

```r
rt_coi_pmc(xml)          # conflicts of interest
rt_fund_pmc(xml)         # funding
rt_register_pmc(xml)     # protocol registration
rt_novelty_pmc(xml)      # novelty claims
rt_replication_pmc(xml)  # replication / external validation
rt_data_code_pmc(xml)    # data AND code sharing (+ extracted links, data-availability section)
rt_ai_pmc(xml)           # generative-AI-use disclosure (2023+), with use, tools and purpose
rt_oa_pmc(xml)           # open-access status + license
rt_reporting_pmc(xml)    # reporting-guideline use + which one
rt_meta_pmc(xml)         # article metadata
```

Default XML namespaces are always removed, so the former `remove_ns` argument
is no longer needed (it is accepted and ignored).

## Structured metadata and follow-up checks

Some transparency signals are tagged in the JATS XML rather than written in
prose, and some can be checked against outside sources:

```r
rt_authors_pmc(xml)      # ORCID coverage of authors, CRediT contribution roles
rt_funders_pmc(xml)      # funders with Crossref Funder IDs, ROR IDs and award numbers

ids <- rt_trial_ids(res$register_text)            # NCT, ISRCTN, PROSPERO, ... numbers
rt_registration_timing(ids$trial_id)              # prospective or retrospective (ClinicalTrials.gov)

rt_fill_coi_pubmed(res)                           # COI statements recorded only in PubMed
rt_check_links(res$open_data_links)               # do the shared-data links resolve?
```

`rt_ethics_pmc()` and `rt_ethics()` detect ethics approval and informed consent
statements. They are **experimental**: not yet validated against hand labels,
so they are not part of `rt_all_pmc()`.
## Corpus-scale processing

`rt_all_pmc_dir()` runs all ten indicators over an entire directory (or a
vector of paths). It is built for large corpora:

```r
res <- rt_all_pmc_dir(
  "path/to/xml",          # a directory, or a character vector of file paths
  output    = "results.csv",  # resumable: re-running skips files already recorded
  parallel  = TRUE,           # via furrr + an active future::plan()
  progress  = TRUE
)
```

- **Resumable**: with `output`, results are written to a CSV in chunks; a re-run
  skips files already recorded and appends only the new ones.
- **Failure-isolated**: a malformed file yields an `is_success = FALSE` row, with
  the reason in `error`, instead of aborting the run.
- **Parallel**: set `future::plan("multisession")` and `parallel = TRUE`.

## Plain-text input

The same detectors run on plain-text (PDF-derived) articles, given either a file
path or the text itself, and return the same column names as the XML detectors:

```r
rt_all_pdf("article.pdf")                   # all ten indicators from a PDF (needs pdftotext)
rt_all("article.txt")                       # all ten indicators from a text file
rt_all(text = rt_read_pdf("article.pdf"))   # or from text already in memory
rt_coi(text = my_text)                      # one indicator at a time

rt_all_txt_dir("path/to/txt_and_pdf")       # a whole directory, resumable and parallel
```

`rt_ai()` is the plain-text counterpart of `rt_ai_pmc()`. Because a text file
carries no reliable publication date, it applies **no 2023 year gate** (it
returns `TRUE`/`FALSE`, never `NA`) and cannot confine the scan to back-matter
sections, so restrict its use to 2023-or-later articles and expect a slightly
higher false-positive rate on papers that use AI as a research method.

## Summarizing a corpus

Once you have one row per article, summarize the corpus:

```r
data(rt_demo)            # a small simulated example shipped with the package

rt_summary(rt_demo)      # per-indicator prevalence with a Wilson confidence
                         # interval and a sensitivity/specificity-corrected
                         # (Rogan-Gladen) prevalence whose interval carries the
                         # uncertainty of the detector's validation

rt_summary(rt_demo, by = "year")   # subgroup summaries

rt_score(rt_demo)        # add a per-article count of openness practices met

rt_plot(rt_demo)                                  # prevalence bar chart
rt_plot(rt_demo, type = "trend", year = "year")   # prevalence over time
```

The accuracy correction uses the bundled `rt_accuracy` table (detector
sensitivity and specificity for eight indicators; open-access licensing and
AI-use disclosure are reported uncorrected). Supply your own estimates:

```r
rt_accuracy                              # the bundled estimates
my_acc <- data.frame(variable = "is_open_data", sensitivity = 0.84, specificity = 0.97)
rt_summary(rt_demo, accuracy = my_acc)   # correct with your own values
```

## Linking to FAIR assessment

The data- and code-availability links the detector extracts (`open_data_links`,
`open_code_links`) can be passed to FAIR-assessment tooling such as
[`rfair`](https://github.com/choxos/rfair) to score the findability and
accessibility of the shared resources.

## Validation

Every indicator is benchmarked against hand labels; the reports and the scripts
that reproduce them are in `inst/benchmark/` and `data-raw/benchmark/`. On the
held-out, independently labeled test set of Serghiou et al. (2021):

| Indicator | Sensitivity | Specificity |
|---|---|---|
| Conflicts of interest | 94.0% | 100% |
| Funding | 91.7% | 95.7% |
| Protocol registration | 98.3% | 92.7% |
| Data sharing | 76.5% | 99.0% |
| Code sharing | 88.1% | 99.5% |

Data sharing is deliberately precision-favoring, and the native data/code
detector was developed against this set, so its figures are regression
estimates rather than an untouched validation. The newer indicators are
validated against maintainer-built, hand-labeled benchmarks:

| Indicator | Sensitivity | Specificity | Basis |
|---|---|---|---|
| Novelty | 83.8% | 95.2% | hand-labeled novelty/replication gold set |
| Replication | 96.4% | 98.4% | sensitivity from a replication-enriched sample (111 positives), specificity from the 2023 sample |
| AI-use disclosure | 100% | 100% | 2023 sample, only 9 positives and detector-adjudicated labels; not accuracy-corrected |
| Open-access license | 100% | not estimable | structured `<license>` extraction; license-type exact match 99.8%; one negative in the OA subset |
| Reporting guideline | 95.4% | 99.0% | 1000-article 2023 sample, hand-labeled (65 positives) |

These estimates, with the validation counts behind them, form the
`rt_accuracy` table that `rt_summary()` uses to correct prevalence, and the
corrected intervals carry their uncertainty. Further reports cover a
five-language sample for multilingual COI and funding, plain-text parity, and
Europe PMC parity. Fresh, blind validation rounds for 2025 are prepared in
`data-raw/validation/`.

See `vignette("rtransparency")` for the methodology and `vignette("scope-and-limitations")`
for what each indicator does and does not capture.

## Documentation

- `vignette("rtransparency")`: introduction and methodology
- `vignette("transparency-summary")`: corpus prevalence, scoring and plotting
- `vignette("ai-disclosure")`: the AI-use disclosure indicator in depth
- `vignette("scope-and-limitations")`: indicator semantics, limitations, output schema
- Package website: <https://choxos.github.io/rtransparency/>

## Lineage and citation

This package builds on the original **`rtransparent`** tool of Stylianos
(Stelios) Serghiou, an enhanced, renamed fork maintained by Ahmad Sofi-Mahmudi
([ORCID 0000-0001-6829-0823](https://orcid.org/0000-0001-6829-0823), GitHub
[@choxos](https://github.com/choxos)). It adds four indicators (novelty,
replication, AI disclosure, and a natively re-implemented data/code detector),
multilingual COI and funding detection, plain-text parity, and corpus-scale
batch processing. Serghiou is credited as an author.

The foundational paper: Serghiou et al., *Assessment of transparency indicators
across the biomedical literature: How open is open?* PLOS Biology, 2021,
[doi:10.1371/journal.pbio.3001107](https://doi.org/10.1371/journal.pbio.3001107).
Run `citation("rtransparency")` for both references.

## Use of AI

Parts of this package were developed with the assistance of generative AI
(Anthropic's Claude, via Claude Code), including code, tests, documentation, and
benchmark tooling. All AI-assisted output was reviewed, run, and validated by the
maintainer, who is responsible for the final content. This mirrors the kind of
disclosure the package itself is built to detect.

## Getting help

Please file bugs or questions as issues at
<https://github.com/choxos/rtransparency/issues> with a minimal reproducible
example.

</div>
