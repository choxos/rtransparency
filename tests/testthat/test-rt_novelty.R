test_that(".which_novelty_first_time_1 detects 'for the first time'", {
  article_positive <- c(
    "We demonstrate for the first time that this pathway is activated.",
    "Blood pressure was measured at baseline."
  )
  article_negative <- c(
    "The results were consistent with prior reports.",
    "No significant differences were observed."
  )

  idx_pos <- rtransparent:::.which_novelty_first_time_1(article_positive)
  expect_true(length(idx_pos) > 0, info = "Should detect 'for the first time'")

  idx_neg <- rtransparent:::.which_novelty_first_time_1(article_negative)
  expect_equal(length(idx_neg), 0, info = "Should not flag non-novelty text")
})


test_that(".which_novelty_first_to_1 detects 'first to show/demonstrate'", {
  article_positive <- c(
    "This study is the first to demonstrate a causal relationship.",
    "We are the first to report this association in humans."
  )
  article_negative <- c(
    "Prior work has shown similar results.",
    "These findings extend previous observations."
  )

  idx_pos <- rtransparent:::.which_novelty_first_to_1(article_positive)
  expect_true(length(idx_pos) > 0, info = "Should detect 'first to demonstrate/report'")

  idx_neg <- rtransparent:::.which_novelty_first_to_1(article_negative)
  expect_equal(length(idx_neg), 0, info = "Should not flag non-novelty text")
})


test_that(".which_novelty_previously_1 detects 'previously unknown/unreported'", {
  article_positive <- c(
    "We identified a previously unknown mechanism of drug resistance.",
    "This previously unreported variant was found in 5% of patients."
  )
  article_negative <- c(
    "Previous studies have reported similar findings.",
    "Earlier work demonstrated the same effect."
  )

  idx_pos <- rtransparent:::.which_novelty_previously_1(article_positive)
  expect_true(length(idx_pos) > 0, info = "Should detect 'previously unknown/unreported'")

  idx_neg <- rtransparent:::.which_novelty_previously_1(article_negative)
  expect_equal(length(idx_neg), 0, info = "Should not flag 'previous studies' as novelty")
})


test_that(".which_novelty_novel_1 detects 'novel finding/approach'", {
  article_positive <- c(
    "This novel finding suggests a new therapeutic target.",
    "We present a novel approach to treating drug-resistant infections."
  )
  article_negative <- c(
    "The study included 500 participants.",
    "We used logistic regression for all analyses."
  )

  idx_pos <- rtransparent:::.which_novelty_novel_1(article_positive)
  expect_true(length(idx_pos) > 0, info = "Should detect 'novel finding/approach'")

  idx_neg <- rtransparent:::.which_novelty_novel_1(article_negative)
  expect_equal(length(idx_neg), 0, info = "Should not flag non-novelty text")
})


test_that(".which_novelty_knowledge_1 detects 'to our knowledge'", {
  article_positive <- c(
    "To our knowledge, this is the first study to examine this outcome.",
    "To the best of our knowledge, no prior work has addressed this question."
  )
  article_negative <- c(
    "Previous studies have reported similar findings.",
    "The results were replicated in an independent cohort."
  )

  idx_pos <- rtransparent:::.which_novelty_knowledge_1(article_positive)
  expect_true(length(idx_pos) > 0, info = "Should detect 'to our knowledge'")

  idx_neg <- rtransparent:::.which_novelty_knowledge_1(article_negative)
  expect_equal(length(idx_neg), 0, info = "Should not flag non-novelty text")
})


test_that("novelty functions return integer(0) for empty input", {
  empty <- character(0)
  expect_equal(rtransparent:::.which_novelty_first_time_1(empty), integer(0))
  expect_equal(rtransparent:::.which_novelty_first_time_2(empty), integer(0))
  expect_equal(rtransparent:::.which_novelty_first_to_1(empty), integer(0))
  expect_equal(rtransparent:::.which_novelty_previously_1(empty), integer(0))
  expect_equal(rtransparent:::.which_novelty_novel_1(empty), integer(0))
  expect_equal(rtransparent:::.which_novelty_knowledge_1(empty), integer(0))
})
