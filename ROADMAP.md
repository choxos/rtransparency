# rtransparency roadmap

Living plan for improving the package. Update it as items ship.

## Principles

- Improve accuracy iteratively, **one change per commit**, measured
  before and after on every labeled set (`data-raw/benchmark/snapshot.R`
  and `evaluate.R`); sensitivity must not regress, and every flipped
  article is explained. The `benchmark` workflow fails a pull request
  whose predictions differ from the committed
  `data-raw/benchmark/predictions_snapshot.csv` unless the snapshot is
  deliberately regenerated.
- Behavior-preserving changes (refactors, speedups, dead-code removal)
  must give an identical prediction snapshot.
- Never tune a detector on a validation round and then report that
  round’s accuracy; draw a new round (`data-raw/validation/`).
- Be self-contained: no GitHub-only or AGPL dependencies.

## In 1.2.0 (awaiting release)

- Plain-text API unified with the XML one (text input, same column
  names, all ten indicators in
  [`rt_all()`](https://choxos.github.io/rtransparency/reference/rt_all.md),
  [`rt_all_pdf()`](https://choxos.github.io/rtransparency/reference/rt_all_pdf.md),
  [`rt_all_txt_dir()`](https://choxos.github.io/rtransparency/reference/rt_all_txt_dir.md)).
- Correctness fixes: namespaced XML, empty PMCIDs in current PMC XML,
  data statements with a request clause, replication external-validation
  misses, AI product names in acknowledgments, reporting-guideline
  recommendations, plain-text COI headings, platform-dependent
  transliteration.
- 8.6x faster reporting-guideline detector; append-only batch output.
- Downloading
  ([`rt_fetch_pmc()`](https://choxos.github.io/rtransparency/reference/rt_fetch_pmc.md),
  [`rt_convert_ids()`](https://choxos.github.io/rtransparency/reference/rt_convert_ids.md),
  Europe PMC source), structured metadata
  ([`rt_authors_pmc()`](https://choxos.github.io/rtransparency/reference/rt_authors_pmc.md),
  [`rt_funders_pmc()`](https://choxos.github.io/rtransparency/reference/rt_funders_pmc.md),
  `has_das`), follow-up checks
  ([`rt_trial_ids()`](https://choxos.github.io/rtransparency/reference/rt_trial_ids.md),
  [`rt_registration_timing()`](https://choxos.github.io/rtransparency/reference/rt_registration_timing.md),
  [`rt_fill_coi_pubmed()`](https://choxos.github.io/rtransparency/reference/rt_fill_coi_pubmed.md),
  [`rt_check_links()`](https://choxos.github.io/rtransparency/reference/rt_check_links.md)),
  AI-use details, the experimental ethics detector.
- `rt_accuracy` rebuilt from the current detectors with validation
  counts; simulation-based corrected intervals; `rt_accuracy_2021` for
  the paper’s values.

## Next (priority order)

### A. Label the 2025 validation rounds

`data-raw/validation/round_2025/` (400 articles, uniform over 2025
open-access PMC) and `round_2025_ai/` (200 articles enriched for AI-use
disclosures) have blind label sheets. Label them (two raters on the 20%
double-code subset), score with `score_labels.R`, and: - replace the
detector-adjudicated COI, funding, data and AI estimates; - validate the
experimental ethics and consent detector, and the AI
`ai_used`/`ai_tools`/`ai_purpose` fields; - once validated, add
ethics/consent to
[`rt_all_pmc()`](https://choxos.github.io/rtransparency/reference/rt_all_pmc.md)
and `rt_accuracy`.

### B. Replace article-specific data/code patterns with general rules

The data and code detectors contain phrases lifted from individual
benchmark articles (for example `cellchat package`, `\bcomparem\b`).
Rework them into general rules, measured on the new independent round
rather than the set they came from.

### C. Multilingual funding

`build_multilingual.R` now defines a reproducible corpus. Label a subset
for funding received / no funding / no statement in Spanish, French and
Portuguese, where detection rates are lowest, before changing patterns.

### D. Plain-text reference lists

The plain-text path does not exclude reference lists, so a cited title
such as “Conflicts of interest in medicine” can trigger COI. Excluding
references is risky because some journals print declarations after them;
measure with the TXT-parity benchmark first.

### E. Held-out drift since 0.9.0

On the held-out set, funding sensitivity fell from 100% (0.9.0 report)
to 91.7% and registration specificity from 96.9% to 92.7% by 1.1.0.
Snapshot the v0.9.x tags on the held-out articles and bisect with
`snapshot.R compare` to find the responsible changes; keep whichever
gains they bought on other sets.

### F. Registration linkage beyond ClinicalTrials.gov

[`rt_registration_timing()`](https://choxos.github.io/rtransparency/reference/rt_registration_timing.md)
covers NCT numbers. ISRCTN and PROSPERO expose registration dates too.

## Running the benchmarks

``` sh
Rscript data-raw/benchmark/snapshot.R run snap.rds          # predictions for all cached XML
Rscript data-raw/benchmark/evaluate.R snap.rds              # every labeled set at once
Rscript data-raw/benchmark/snapshot.R compare a.rds b.rds   # what changed, article by article
Rscript data-raw/benchmark/run_all.R                        # published held-out report
```

Set `ENTREZ_KEY` to raise the NCBI rate limit. The XML cache lives in
`data-raw/benchmark/.cache/` (git-ignored);
[`rt_fetch_pmc()`](https://choxos.github.io/rtransparency/reference/rt_fetch_pmc.md)
refills it. The Serghiou et al. (2021) labels live under `paper/`
(git-ignored, from the study’s OSF repository).
