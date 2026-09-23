test_that("rt_trial_ids finds registry identifiers", {
  ids <- rt_trial_ids(c(
    "Registered at ClinicalTrials.gov (NCT04368728) and ISRCTN12345678; NCT04368728.",
    "PROSPERO CRD42020123456; ChiCTR2000029308; ACTRN12620000123456",
    "No registration.", NA
  ))
  expect_identical(ids$element, c(1L, 1L, 2L, 2L, 2L))
  expect_identical(ids$registry, c("ClinicalTrials.gov", "ISRCTN", "PROSPERO",
                                   "ChiCTR", "ANZCTR"))
  expect_identical(ids$trial_id[1], "NCT04368728")
  expect_equal(nrow(rt_trial_ids("nothing here")), 0L)
})

test_that("registration timing classifies day- and month-precision start dates", {
  rec <- function(id, sub, start, type = "ACTUAL") list(protocolSection = list(
    identificationModule = list(nctId = id),
    statusModule = list(studyFirstSubmitDate = sub,
                        startDateStruct = list(date = start, type = type))))
  recs <- list(
    rec("NCT00000001", "2020-04-27", "2020-04-29"),   # before start: prospective
    rec("NCT00000002", "2020-06-10", "2020-04-29"),   # 42 days late
    rec("NCT00000003", "2020-04-15", "2020-04"),      # within start month: unknown
    rec("NCT00000004", "2020-03-31", "2020-04"),      # before start month
    rec("NCT00000005", "2020-05-02", "2020-04")       # after start month
  )
  ids <- c(paste0("NCT0000000", 1:5), "NCT99999999")
  t <- rtransparency:::.registration_timing_table(ids, recs)
  expect_identical(t$is_prospective, c(TRUE, FALSE, NA, TRUE, FALSE, NA))
  expect_identical(t$days_after_start[1:2], c(-2L, 42L))
  expect_identical(t$start_date_precision[2:3], c("day", "month"))
  late <- rtransparency:::.registration_timing_table(ids[2], recs, grace_days = 60)
  expect_true(late$is_prospective)
})

test_that("rt_registration_timing queries ClinicalTrials.gov", {
  skip_on_cran()
  skip_if_not_installed("jsonlite")
  skip_if_offline("clinicaltrials.gov")
  t <- rt_registration_timing(c("NCT04368728", "not-an-id"))
  expect_identical(t$nct_id, c("NCT04368728", "NOT-AN-ID"))
  expect_identical(t$first_submitted[1], as.Date("2020-04-27"))
  expect_true(t$is_prospective[1])
  expect_true(is.na(t$is_prospective[2]))
})


test_that("a CTIS number is not also read as a truncated EudraCT number", {
  ids <- rt_trial_ids("EU CT 2022-500024-30-00; EudraCT 2011-001925-26")
  expect_identical(ids$registry, c("EudraCT", "CTIS"))
  expect_identical(ids$trial_id, c("2011-001925-26", "2022-500024-30-00"))
})
