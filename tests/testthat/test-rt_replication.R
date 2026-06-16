test_that(".which_replication_replicat_1 detects replication of previous results", {
  article_positive <- c(
    "We replicated previously reported findings in a new cohort.",
    "The replication of earlier results confirmed the association."
  )
  article_negative <- c(
    "The study examined cardiovascular outcomes over 5 years.",
    "A total of 1200 patients were enrolled."
  )

  idx_pos <- rtransparent:::.which_replication_replicat_1(article_positive)
  expect_true(length(idx_pos) > 0, info = "Should detect 'replicated previous findings'")

  idx_neg <- rtransparent:::.which_replication_replicat_1(article_negative)
  expect_equal(length(idx_neg), 0, info = "Should not flag non-replication text")
})


test_that(".which_replication_confirm_1 detects 'confirmed findings from'", {
  article_positive <- c(
    "These results confirmed findings from our earlier study.",
    "The analysis validated results of previous reports."
  )
  article_negative <- c(
    "We performed logistic regression to assess risk factors.",
    "Blood samples were collected at baseline and follow-up."
  )

  idx_pos <- rtransparent:::.which_replication_confirm_1(article_positive)
  expect_true(length(idx_pos) > 0, info = "Should detect 'confirmed findings from'")

  idx_neg <- rtransparent:::.which_replication_confirm_1(article_negative)
  expect_equal(length(idx_neg), 0, info = "Should not flag analysis methods as replication")
})


test_that(".which_replication_independent_1 detects 'independently validated'", {
  article_positive <- c(
    "An independent replication study confirmed the association.",
    "The findings were independently validated in a separate dataset."
  )
  article_negative <- c(
    "Independent living was assessed using the ADL scale.",
    "The two groups were matched on age and sex."
  )

  idx_pos <- rtransparent:::.which_replication_independent_1(article_positive)
  expect_true(length(idx_pos) > 0, info = "Should detect 'independently validated'")

  idx_neg <- rtransparent:::.which_replication_independent_1(article_negative)
  expect_equal(length(idx_neg), 0, info = "Should not flag 'independent living' as replication")
})


test_that(".which_replication_validation_1 detects 'validation cohort'", {
  article_positive <- c(
    "Results were confirmed in a validation cohort of 500 patients.",
    "A replication dataset was used to verify the primary findings."
  )
  article_negative <- c(
    "A cohort study was conducted from 2010 to 2020.",
    "The study population included adults aged 18-65."
  )

  idx_pos <- rtransparent:::.which_replication_validation_1(article_positive)
  expect_true(length(idx_pos) > 0, info = "Should detect 'validation cohort'")

  idx_neg <- rtransparent:::.which_replication_validation_1(article_negative)
  expect_equal(length(idx_neg), 0, info = "Should not flag plain cohort description as replication")
})


test_that(".negate_replication_1 correctly identifies negated replication claims", {
  negated_claims <- c(
    "The study failed to replicate the original findings.",
    "We were unable to replicate previously reported results.",
    "Our results did not replicate those from prior work."
  )
  valid_claims <- c(
    "We independently replicated the findings from the original study.",
    "The results were validated in an external cohort."
  )

  is_negated_pos <- rtransparent:::.negate_replication_1(negated_claims)
  expect_true(all(is_negated_pos), info = "All negated claims should be flagged")

  is_negated_neg <- rtransparent:::.negate_replication_1(valid_claims)
  expect_true(all(!is_negated_neg), info = "Valid replication claims should not be negated")
})


test_that("replication functions return integer(0) for empty input", {
  empty <- character(0)
  expect_equal(rtransparent:::.which_replication_replicat_1(empty), integer(0))
  expect_equal(rtransparent:::.which_replication_confirm_1(empty), integer(0))
  expect_equal(rtransparent:::.which_replication_independent_1(empty), integer(0))
  expect_equal(rtransparent:::.which_replication_reproduced_1(empty), integer(0))
  expect_equal(rtransparent:::.which_replication_validation_1(empty), integer(0))
})
