#' Detector accuracy estimates
#'
#' Sensitivity and specificity of each transparency detector, with the
#' validation counts behind them, used by [rt_summary()] to correct an apparent
#' prevalence for detector error (the Rogan-Gladen correction) and to carry the
#' uncertainty of these estimates into the corrected interval.
#'
#' Every row describes the detectors shipped in this version, scored on
#' hand-labeled articles (see `inst/benchmark/results_all_sets.csv` and the
#' reports beside it):
#'
#' * Conflicts of interest, funding and registration: the held-out, independently
#'   labeled test set of Serghiou et al. (2021). These are not the paper's
#'   published values, which describe the 2021 detectors; those are kept in
#'   [rt_accuracy_2021].
#' * Data and code sharing: the same held-out set's data and code labels. The
#'   native detector was developed against this set, so these are regression
#'   estimates rather than an untouched validation.
#' * Novelty: the maintainer's hand-labeled novelty/replication gold set.
#' * Replication: sensitivity from a replication-enriched sample (111
#'   positives) and specificity from the representative 2023 sample, so the
#'   correction mixes designs.
#' * Reporting guideline: the 1000-article 2023 sample, hand-labeled.
#'
#' Open-access licensing (structured metadata whose specificity cannot be
#' estimated in the open-access subset) and AI-use disclosure (too few
#' positives) are not included, so [rt_summary()] reports them uncorrected.
#' Supply your own table to [rt_summary()] via its `accuracy` argument when you
#' have study-specific or external estimates; the `data-raw/validation/`
#' scripts produce one in this format.
#'
#' @format A tibble with 8 rows and 9 columns:
#' \describe{
#'   \item{variable}{Indicator column name, as returned by [rt_all_pmc()].}
#'   \item{label}{Human-readable indicator name.}
#'   \item{sensitivity}{Detector sensitivity (true-positive rate), 0-1.}
#'   \item{specificity}{Detector specificity (true-negative rate), 0-1.}
#'   \item{tp, fn}{True positives and false negatives behind `sensitivity`.}
#'   \item{tn, fp}{True negatives and false positives behind `specificity`.}
#'   \item{source}{Where the estimate comes from.}
#' }
#' @source This package's benchmarks (`inst/benchmark/`), including the held-out
#'   labels of Serghiou S, Contopoulos-Ioannidis DG, Boyack KW, Riedel N,
#'   Wallach JD, Ioannidis JPA (2021). Assessment of transparency indicators
#'   across the biomedical literature: How open is open? \emph{PLOS Biology}
#'   19(3): e3001107. \doi{10.1371/journal.pbio.3001107}.
#' @seealso [rt_summary()], [rt_accuracy_2021]
"rt_accuracy"


#' Published 2021 detector accuracy estimates
#'
#' The importance-weighted sensitivity and specificity that Serghiou et al.
#' (2021) published for their conflict-of-interest, funding and registration
#' detectors. They describe the 2021 detectors, not the current ones (see
#' [rt_accuracy]), and are kept for comparability with that paper:
#' `rt_summary(data, accuracy = rt_accuracy_2021)`. Without validation counts,
#' [rt_summary()] uses the fixed interval for them.
#'
#' @format A tibble with 3 rows and 5 columns: `variable`, `label`,
#'   `sensitivity`, `specificity` and `source`.
#' @source Serghiou et al. (2021), PLOS Biology 19(3): e3001107.
#'   \doi{10.1371/journal.pbio.3001107}.
#' @seealso [rt_accuracy]
"rt_accuracy_2021"


#' Simulated transparency indicators for a corpus of articles
#'
#' A small, simulated set of detector output, with one row per article, used to
#' illustrate [rt_summary()], [rt_score()] and [rt_plot()]. The values are
#' \strong{simulated}, not real detector output: prevalences and their trends
#' over time are chosen to resemble published findings (frequent conflict-of-
#' interest and funding disclosure, less frequent protocol registration, low but
#' rising data sharing, rare code sharing, and a recent, fast-rising disclosure
#' of generative-AI use) so the illustrations are realistic.
#'
#' @format A tibble with 1200 rows and 13 columns:
#' \describe{
#'   \item{pmid}{A made-up PubMed identifier (character).}
#'   \item{year}{Publication year, 2010-2026.}
#'   \item{type}{Article type (research-article, review-article,
#'     systematic-review).}
#'   \item{is_coi_pred}{Conflict-of-interest statement detected.}
#'   \item{is_fund_pred}{Funding statement detected.}
#'   \item{is_register_pred}{Protocol registration detected.}
#'   \item{is_open_data}{Data sharing detected.}
#'   \item{is_open_code}{Code sharing detected.}
#'   \item{is_novelty_pred}{Novelty claim detected.}
#'   \item{is_replication_pred}{Replication component detected.}
#'   \item{is_ai_pred}{Disclosure of generative-AI use detected. `NA` before
#'     2023, when the practice did not yet exist (see [rt_ai_pmc()]).}
#'   \item{is_open_access}{Open license detected.}
#'   \item{is_reporting_pred}{Reporting-guideline use detected.}
#' }
#' @seealso [rt_summary()], [rt_score()], [rt_plot()]
"rt_demo"
