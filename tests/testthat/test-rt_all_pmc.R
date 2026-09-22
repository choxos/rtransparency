test_that("rt_all_pmc returns all ten indicators", {
  xml <- system.file("extdata", "PMID32171256-PMC7071725.xml",
                     package = "rtransparency")
  skip_if(xml == "")

  res <- rtransparency::rt_all_pmc(xml, remove_ns = TRUE)

  indicator_cols <- c(
    "is_coi_pred", "is_fund_pred", "is_register_pred", "is_novelty_pred",
    "is_replication_pred", "is_open_data", "is_open_code", "is_ai_pred",
    "is_open_access", "is_reporting_pred"
  )
  expect_true(all(indicator_cols %in% names(res)))
  # Statement-text columns for data/code come along too.
  expect_true(all(c("open_data_statements", "open_code_statements",
                    "oa_license", "reporting_guideline", "ai_used",
                    "has_das") %in% names(res)))
  # rt_summary() recognizes every indicator column.
  expect_setequal(rt_summary(res, adjust = FALSE)$indicator, indicator_cols)
  expect_true(isTRUE(res$is_success))
})

test_that("rt_all_pmc data/code agree with rt_data_code_pmc", {
  xml <- system.file("extdata", "PMID32171256-PMC7071725.xml",
                     package = "rtransparency")
  skip_if(xml == "")

  all_res <- rtransparency::rt_all_pmc(xml, remove_ns = TRUE)
  dc_res  <- rtransparency::rt_data_code_pmc(xml, remove_ns = TRUE)

  expect_identical(all_res$is_open_data, dc_res$is_open_data)
  expect_identical(all_res$is_open_code, dc_res$is_open_code)
  expect_identical(all_res$open_data_statements, dc_res$open_data_statements)
  expect_identical(all_res$open_code_statements, dc_res$open_code_statements)
})

test_that("a default XML namespace does not silently blank the results", {
  xml <- system.file("extdata", "PMID32171256-PMC7071725.xml",
                     package = "rtransparency")
  skip_if(xml == "")

  lines <- readLines(xml, warn = FALSE)
  i <- grep("<article ", lines)[1]
  lines[i] <- sub("<article ",
                  "<article xmlns=\"https://jats.nlm.nih.gov/ns/archiving/1.3/\" ",
                  lines[i])
  namespaced <- tempfile(fileext = ".xml")
  writeLines(lines, namespaced)

  plain <- rtransparency::rt_all_pmc(xml)
  ns <- rtransparency::rt_all_pmc(namespaced)
  ns$filename <- plain$filename
  expect_identical(ns, plain)
  expect_identical(ns$pmid, "32171256")
})
