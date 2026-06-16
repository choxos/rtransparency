test_that("get_ct_1 detects NCT numbers with registration context", {
  article_with_nct <- c(
    "The study was pre-registered on ClinicalTrials.gov (NCT12345678).",
    "Methods were approved by the IRB."
  )
  article_without_nct <- c(
    "Participants were randomized to two groups.",
    "The outcome was measured at 6 months."
  )

  idx_found <- get_ct_1(article_with_nct)
  expect_true(length(idx_found) > 0, info = "Should detect NCT number with registration context")

  idx_empty <- get_ct_1(article_without_nct)
  expect_equal(length(idx_empty), 0, info = "Should not flag text without NCT")
})


test_that("get_prospero_1 detects PROSPERO registrations", {
  article_with_prospero <- c(
    "This systematic review was registered in PROSPERO (CRD42020123456).",
    "We conducted a comprehensive literature search."
  )
  article_without_prospero <- c(
    "A systematic review was performed.",
    "We searched MEDLINE and Embase."
  )

  idx_found <- get_prospero_1(article_with_prospero)
  expect_true(length(idx_found) > 0, info = "Should detect PROSPERO registration")

  idx_empty <- get_prospero_1(article_without_prospero)
  expect_equal(length(idx_empty), 0, info = "Should not flag text without PROSPERO ID")
})


test_that("get_isrctn_1 detects ISRCTN registrations", {
  article_with_isrctn <- c(
    "The trial was registered at ISRCTN (ISRCTN12345678).",
    "Ethics approval was obtained from the IRB."
  )
  article_without_isrctn <- c(
    "The trial was conducted in London.",
    "All patients signed informed consent."
  )

  idx_found <- get_isrctn_1(article_with_isrctn)
  expect_true(length(idx_found) > 0, info = "Should detect ISRCTN number")

  idx_empty <- get_isrctn_1(article_without_isrctn)
  expect_equal(length(idx_empty), 0, info = "Should not flag text without ISRCTN")
})


test_that("get_anzctr_1 detects ANZCTR registrations", {
  article_with_anzctr <- c(
    "The study was registered with ANZCTR (ACTRN12614001234567).",
    "Written consent was obtained."
  )

  idx_found <- get_anzctr_1(article_with_anzctr)
  expect_true(length(idx_found) > 0, info = "Should detect ACTRN number")
})


test_that("get_drks_1 detects DRKS registrations", {
  article_with_drks <- c(
    "Trial registration: DRKS00012345.",
    "All procedures were approved by the ethics board."
  )

  idx_found <- get_drks_1(article_with_drks)
  expect_true(length(idx_found) > 0, info = "Should detect DRKS number")
})


test_that("get_irct_1 detects IRCT registrations", {
  article_with_irct <- c(
    "This trial was registered at IRCT (IRCT20120526009954N3).",
    "Participants provided written consent."
  )

  idx_found <- get_irct_1(article_with_irct)
  expect_true(length(idx_found) > 0, info = "Should detect IRCT number")
})


test_that("get_umin_1 detects UMIN registrations", {
  article_with_umin <- c(
    "The study was registered at UMIN (UMIN000012345).",
    "Ethical approval was obtained."
  )

  idx_found <- get_umin_1(article_with_umin)
  expect_true(length(idx_found) > 0, info = "Should detect UMIN number")
})


test_that("registry helpers return integer(0) for empty/non-matching input", {
  empty <- character(0)
  non_matching <- c("This study examined lung cancer.", "Results were significant.")

  expect_equal(get_isrctn_1(empty), integer(0))
  expect_equal(get_anzctr_1(empty), integer(0))
  expect_equal(get_drks_1(empty), integer(0))
  expect_equal(get_irct_1(non_matching), integer(0))
  expect_equal(get_umin_1(non_matching), integer(0))
})
