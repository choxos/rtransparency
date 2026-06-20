test_that("rt_coi detects COI statements in text", {
  # Simulate paragraph matching
  article_with_coi <- c(
    "The study was conducted in a tertiary care hospital.",
    "Conflicts of Interest: The authors declare no conflicts of interest.",
    "All participants provided written consent."
  )
  article_no_coi <- c(
    "The study was conducted in a tertiary care hospital.",
    "All participants provided written consent.",
    "Data were collected from January to December."
  )

  # Test the internal helper functions directly
  dict <- rtransparency:::.create_synonyms()

  # COI detection with standard phrase
  idx_coi <- rtransparency:::.which_coi_1(article_with_coi, dict)
  expect_true(length(idx_coi) > 0, info = "Should detect 'Conflicts of Interest'")

  # No COI in clean text
  idx_no_coi <- rtransparency:::.which_coi_1(article_no_coi, dict)
  expect_equal(length(idx_no_coi), 0, info = "Should not flag non-COI text")
})


test_that("rt_coi detects 'no competing interests' statements", {
  dict <- rtransparency:::.create_synonyms()

  article <- c(
    "The authors have no competing interests to declare.",
    "Data analysis was performed using R version 4.0."
  )

  idx <- rtransparency:::.which_coi_2(article, dict)
  expect_true(length(idx) > 0, info = "Should detect 'no competing interests'")
})


test_that("rt_coi detects Spanish conflict-of-interest headings", {
  article <- c(
    "Conflicto de interesesLos autores declaran no tener conflictos de interes.",
    "Conflictos de intereses: Ninguno declarado."
  )

  idx <- rtransparency:::.which_spanish_coi_1(article)
  expect_equal(idx, 1:2)
})


test_that(".rt_coi_pmc ignores AI-only disclosure sections", {
  dict <- rtransparency:::.create_synonyms()
  pmc_coi_ls <- list(is_coi_pred = FALSE, coi_text = "")

  ai_only <- list(
    ack = character(),
    body = "Declaration of generative AI and AI-assisted technologies in the writing process: During preparation the authors used ChatGPT to improve grammar and the manuscript was proofread by native English speakers.",
    footnotes = character()
  )
  out_ai <- rtransparency:::.rt_coi_pmc(ai_only, pmc_coi_ls, dict)
  expect_false(isTRUE(out_ai$is_coi_pred))
  expect_equal(out_ai$coi_text, "")

  coi <- list(
    ack = character(),
    body = "Conflicts of Interest: The authors declare no competing interests.",
    footnotes = character()
  )
  out_coi <- rtransparency:::.rt_coi_pmc(coi, pmc_coi_ls, dict)
  expect_true(isTRUE(out_coi$is_coi_pred))
})


test_that("rt_read_pdf -> writeLines -> text detector workflow works end to end", {
  pdf <- system.file("extdata", "PMID32171256-PMC7071725.pdf",
                     package = "rtransparency")
  skip_if(pdf == "", "Example PDF not available")
  skip_if(unname(Sys.which("pdftotext")) == "", "pdftotext (poppler) not on PATH")

  # rt_read_pdf() returns the extracted text as a character string, NOT a path.
  article_txt <- rt_read_pdf(pdf)
  expect_type(article_txt, "character")
  expect_length(article_txt, 1L)
  expect_gt(nchar(article_txt), 1000L)

  # The README/vignette workflow: write the text to a .txt file, then run the
  # text detectors against that file path.
  txt <- tempfile(pattern = "PMID32171256-PMC7071725-", fileext = ".txt")
  on.exit(unlink(txt), add = TRUE)
  writeLines(article_txt, txt)
  expect_true(file.exists(txt))

  # No path-length warning, and the reported article is the file's basename
  # (not the article text mistaken for a filename).
  coi <- expect_no_warning(rt_coi(txt))
  expect_s3_class(coi, "data.frame")
  expect_true("is_coi_pred" %in% names(coi))
  expect_equal(coi$article, basename(txt))
  expect_lt(nchar(coi$article), 100L)

  ai <- rt_ai(txt)
  expect_true("is_ai_pred" %in% names(ai))
  expect_equal(ai$article, basename(txt))
  expect_false(is.na(ai$is_ai_pred))
})
