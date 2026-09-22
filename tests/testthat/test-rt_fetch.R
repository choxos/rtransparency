test_that(".parse_idconv reads converter records, including misses", {
  doc <- xml2::read_xml(paste0(
    '<pmcids status="ok"><request/>',
    '<record requested-id="32171256" pmcid="PMC7071725" pmid="32171256" ',
    'doi="10.1186/s12874-020-0914-6"></record>',
    '<record requested-id="31452104" pmid="31452104" status="error" ',
    'errmsg="Identifier not found in PMC"></record></pmcids>'
  ))
  rec <- rtransparency:::.parse_idconv(doc)
  expect_equal(nrow(rec), 2L)
  expect_identical(rec$pmcid, c("PMC7071725", NA))
  expect_identical(rec$pmid, c("32171256", "31452104"))
})

test_that(".normalize_pmcid is vectorized", {
  expect_identical(rtransparency:::.normalize_pmcid(c("123", "PMC45", " pmc6 ")),
                   c("PMC123", "PMC45", "PMC6"))
})

test_that(".xml_has_body distinguishes full text from front matter", {
  xml <- system.file("extdata", "PMID32171256-PMC7071725.xml",
                     package = "rtransparency")
  skip_if(xml == "")
  expect_true(rtransparency:::.xml_has_body(xml))
  front <- tempfile(fileext = ".xml")
  writeLines("<pmc-articleset><article><front/></article></pmc-articleset>", front)
  expect_false(rtransparency:::.xml_has_body(front))
})

test_that("rt_convert_ids and rt_fetch_pmc work against NCBI", {
  skip_on_cran()
  skip_if_offline("pmc.ncbi.nlm.nih.gov")

  ids <- rt_convert_ids(c("32171256", "PMC7071725", "not-an-id"))
  expect_identical(ids$pmcid[1:2], c("PMC7071725", "PMC7071725"))
  expect_true(is.na(ids$pmcid[3]))

  d <- tempfile("pmc_")
  got <- rt_fetch_pmc(c("PMC7071725", "not-an-id"), d, progress = FALSE)
  expect_identical(got$is_success, c(TRUE, FALSE))
  expect_true(got$has_body[1])
  expect_true(rt_all_pmc(got$file[1])$is_success)
})

test_that("rt_fetch_pmc can download from Europe PMC", {
  skip_on_cran()
  skip_if_offline("www.ebi.ac.uk")
  got <- rt_fetch_pmc("PMC7071725", tempfile("epmc_"), source = "europepmc",
                      progress = FALSE)
  expect_true(got$is_success)
  res <- rt_all_pmc(got$file)
  expect_identical(res$pmcid_pmc, "PMC7071725")
  expect_true(res$is_coi_pred)
})
