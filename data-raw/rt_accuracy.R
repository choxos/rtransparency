# Builds data/rt_accuracy.rda and data/rt_accuracy_2021.rda: detector accuracy
# used by rt_summary() to correct apparent prevalence.
#
# rt_accuracy holds the current detectors' accuracy with the validation counts
# behind each estimate (tp, fn, tn, fp), read from
# inst/benchmark/results_all_sets.csv, which data-raw/benchmark/evaluate.R
# writes from a prediction snapshot of the release code. Sources:
#
# * Conflicts of interest, funding, registration: the held-out, independently
#   labeled test set of Serghiou et al. (2021), scored with the current
#   detectors (not the paper's published values, which describe the 2021
#   detectors).
# * Data and code sharing: the same held-out set's data/code labels. The
#   native detector was developed against this set, so these are regression
#   estimates, not untouched validation.
# * Novelty: the maintainer's hand-labeled novelty/replication gold set.
# * Replication: sensitivity from the replication-enriched sample (111
#   positives), specificity from the representative 2023 sample.
# * Reporting guideline: the 1000-article 2023 sample, hand-labeled.
#
# Open-access licensing (structured metadata; specificity not estimable) and
# AI-use disclosure (9 positives) are deliberately absent, so rt_summary()
# reports them uncorrected.
#
# rt_accuracy_2021 keeps the published, importance-weighted estimates of
# Serghiou et al. (2021) for conflicts of interest, funding and registration,
# for comparability with that paper.
#
# Run from the repo root after regenerating results_all_sets.csv:
#   Rscript data-raw/rt_accuracy.R

res <- utils::read.csv("inst/benchmark/results_all_sets.csv", stringsAsFactors = FALSE)
cnt <- function(set, indicator) {
  r <- res[res$set == set & res$indicator == indicator, ]
  if (nrow(r) != 1) stop("missing ", set, "/", indicator, " in results_all_sets.csv")
  r
}
row <- function(variable, label, sens_from, spec_from, source) {
  s <- cnt(sens_from[1], sens_from[2])
  p <- cnt(spec_from[1], spec_from[2])
  tibble::tibble(
    variable = variable, label = label,
    sensitivity = round(s$TP / (s$TP + s$FN), 3),
    specificity = round(p$TN / (p$TN + p$FP), 3),
    tp = s$TP, fn = s$FN, tn = p$TN, fp = p$FP,
    source = source
  )
}
heldout <- "Serghiou et al. (2021) held-out test labels, current detector (inst/benchmark/results.md)"

rt_accuracy <- rbind(
  row("is_coi_pred", "Conflicts of interest", c("heldout", "coi"), c("heldout", "coi"), heldout),
  row("is_fund_pred", "Funding disclosure", c("heldout", "fund"), c("heldout", "fund"), heldout),
  row("is_register_pred", "Protocol registration", c("heldout", "register"), c("heldout", "register"), heldout),
  row("is_open_data", "Data sharing", c("heldout", "data"), c("heldout", "data"),
      "Serghiou et al. (2021) held-out data labels; regression estimate for the native detector (inst/benchmark/results_data_code.md)"),
  row("is_open_code", "Code sharing", c("heldout", "code"), c("heldout", "code"),
      "Serghiou et al. (2021) held-out code labels; regression estimate for the native detector (inst/benchmark/results_data_code.md)"),
  row("is_novelty_pred", "Novelty", c("novrep", "nov"), c("novrep", "nov"),
      "rtransparency novelty/replication hand-labeled gold set (inst/benchmark/results_novelty_replication.md)"),
  row("is_replication_pred", "Replication", c("repenr", "rep"), c("s2023", "rep"),
      "sensitivity: replication-enriched sample (inst/benchmark/results_replication_enriched.md); specificity: 2023 1000-article sample"),
  row("is_reporting_pred", "Reporting guideline", c("oarep", "reporting"), c("oarep", "reporting"),
      "rtransparency hand-labeled 2023 1000-article sample (inst/benchmark/results_oa_reporting.md)")
)

rt_accuracy_2021 <- tibble::tibble(
  variable = c("is_coi_pred", "is_fund_pred", "is_register_pred"),
  label = c("Conflicts of interest", "Funding disclosure", "Protocol registration"),
  sensitivity = c(0.992, 0.997, 0.955),
  specificity = c(0.995, 0.981, 0.997),
  source = "Serghiou et al. 2021, PLOS Biology (doi:10.1371/journal.pbio.3001107), importance-weighted"
)

print(rt_accuracy[, 1:8])
save(rt_accuracy, file = "data/rt_accuracy.rda", version = 2)
save(rt_accuracy_2021, file = "data/rt_accuracy_2021.rda", version = 2)
