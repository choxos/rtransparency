# Builds data/rt_accuracy.rda: the validated sensitivity and specificity of
# each detector, used by rt_summary() to correct apparent prevalence.
#
# For conflicts of interest, funding and protocol registration the published,
# importance-weighted validation values of Serghiou et al. (2021) are used; the
# detectors for these indicators are essentially those validated in the paper.
#
# For data and code sharing the detector is now native (it no longer wraps
# oddpub), so the package's own held-out validation estimates are used instead
# (see inst/benchmark/results_data_code.md). Users who prefer the paper's oddpub
# values, or their own, can pass any data frame with `variable`, `sensitivity`
# and `specificity` columns to rt_summary(accuracy = ).

rt_accuracy <- tibble::tibble(
  variable = c(
    "is_coi_pred", "is_fund_pred", "is_register_pred",
    "is_open_data", "is_open_code"
  ),
  label = c(
    "Conflicts of interest", "Funding disclosure",
    "Protocol registration", "Data sharing", "Code sharing"
  ),
  sensitivity = c(0.992, 0.997, 0.955, 0.643, 0.679),
  specificity = c(0.995, 0.981, 0.997, 0.950, 0.940),
  source = c(
    rep("Serghiou et al. 2021, PLOS Biology (doi:10.1371/journal.pbio.3001107)", 3),
    rep("rtransparent native detector, held-out validation (inst/benchmark)", 2)
  )
)

save(rt_accuracy, file = "data/rt_accuracy.rda", version = 2)
