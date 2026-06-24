test_that(".classify_license maps URLs and prose to canonical identifiers", {
  cl <- rtransparency:::.classify_license
  expect_equal(cl("http://creativecommons.org/licenses/by/4.0/"), "CC-BY-4.0")
  expect_equal(cl("https://creativecommons.org/licenses/by-nc-nd/4.0/"), "CC-BY-NC-ND-4.0")
  expect_equal(cl("Creative Commons Attribution-NonCommercial 4.0 License"), "CC-BY-NC-4.0")
  expect_equal(cl("https://creativecommons.org/publicdomain/zero/1.0/"), "CC0-1.0")
  # A CC-BY article that also carries a CC0 data-waiver boilerplate stays CC-BY.
  expect_equal(
    cl(c("creativecommons.org/licenses/by/4.0/",
         "The Creative Commons public domain dedication waiver",
         "creativecommons.org/publicdomain/zero/1.0/ applies to the data")),
    "CC-BY-4.0"
  )
  # Retained copyright is not an open license.
  expect_equal(cl("(c) 2020 The Authors. All rights reserved."), "")
  expect_equal(cl(character(0)), "")
})

test_that("rt_oa_pmc reads the license from the example PMC XML", {
  xml <- system.file("extdata", "PMID32171256-PMC7071725.xml", package = "rtransparency")
  skip_if(xml == "")
  r <- rt_oa_pmc(xml, remove_ns = TRUE)
  expect_true(r$is_success)
  expect_true(r$is_open_access)
  expect_equal(r$oa_license, "CC-BY-4.0")
})

test_that("rt_oa detects an open-access license in plain text", {
  f <- tempfile(fileext = ".txt")
  on.exit(unlink(f), add = TRUE)
  writeLines(paste("This is an open access article distributed under the terms of the",
                   "Creative Commons Attribution 4.0 International License",
                   "(http://creativecommons.org/licenses/by/4.0/)."), f)
  r <- rt_oa(f)
  expect_true(r$is_open_access)
  expect_equal(r$oa_license, "CC-BY-4.0")

  g <- tempfile(fileext = ".txt")
  on.exit(unlink(g), add = TRUE)
  writeLines("All rights reserved. Reproduction requires permission from the publisher.", g)
  expect_false(rt_oa(g)$is_open_access)
})

test_that("rt_all_pmc includes the open-access columns", {
  xml <- system.file("extdata", "PMID32171256-PMC7071725.xml", package = "rtransparency")
  skip_if(xml == "")
  a <- rt_all_pmc(xml, remove_ns = TRUE)
  expect_true(all(c("is_open_access", "oa_license", "oa_text") %in% names(a)))
  expect_true(a$is_open_access)
})
