xml_file <- function(body) {
  f <- tempfile(fileext = ".xml")
  writeLines(paste0('<article article-type="research-article" ',
                    'xmlns:xlink="http://www.w3.org/1999/xlink"><front><article-meta>',
                    '<article-id pub-id-type="pmcid">PMC123</article-id>',
                    '<article-id pub-id-type="pmid">456</article-id>',
                    body, '</article-meta></front><body><p>Text.</p></body></article>'), f)
  f
}

test_that("rt_authors_pmc counts ORCIDs and CRediT roles", {
  f <- xml_file(paste0(
    '<contrib-group>',
    '<contrib contrib-type="author"><name><surname>A</surname></name>',
    '<contrib-id contrib-id-type="orcid">https://orcid.org/0000-0001-2345-678X</contrib-id>',
    '<role vocab="credit" vocab-term="Conceptualization">Conceptualization</role></contrib>',
    '<contrib contrib-type="author"><name><surname>B</surname></name>',
    '<role>Writing \u2013 original draft</role><role>Surgeon</role></contrib>',
    '</contrib-group>'))
  r <- rt_authors_pmc(f)
  expect_identical(r$pmcid_pmc, "PMC123")
  expect_identical(r$n_authors, 2L)
  expect_identical(r$n_orcid, 1L)
  expect_equal(r$orcid_coverage, 0.5)
  expect_identical(r$orcids, "0000-0001-2345-678X")
  expect_true(r$has_credit)
  expect_identical(r$credit_roles, "conceptualization; writing original draft")
})

test_that("rt_funders_pmc returns funder IDs and awards, one row per source", {
  f <- xml_file(paste0(
    '<funding-group><award-group><funding-source><institution-wrap>',
    '<institution-id institution-id-type="FundRef">http://dx.doi.org/10.13039/100000002</institution-id>',
    '<institution>National Institutes of Health</institution></institution-wrap></funding-source>',
    '<award-id>R01 AB123</award-id></award-group>',
    '<award-group><funding-source><institution-wrap>',
    '<institution-id institution-id-type="ROR">https://ror.org/029chgv08</institution-id>',
    '<institution>Wellcome Trust</institution></institution-wrap></funding-source></award-group>',
    '</funding-group>'))
  r <- rt_funders_pmc(f)
  expect_equal(nrow(r), 2L)
  expect_identical(r$funder, c("National Institutes of Health", "Wellcome Trust"))
  expect_identical(r$funder_doi, c("10.13039/100000002", NA))
  expect_identical(r$funder_ror, c(NA, "https://ror.org/029chgv08"))
  expect_identical(r$award_id, c("R01 AB123", NA))

  none <- rt_funders_pmc(xml_file(""))
  expect_equal(nrow(none), 1L)
  expect_true(is.na(none$funder))
})

test_that("both PMCID tag vintages are read", {
  old <- tempfile(fileext = ".xml")
  writeLines(paste0('<article><front><article-meta>',
                    '<article-id pub-id-type="pmc">7071725</article-id>',
                    '<article-id pub-id-type="pmc-uid">7071725</article-id>',
                    '</article-meta></front></article>'), old)
  ids <- rtransparency:::.get_ids(rtransparency:::.get_xml(old))
  expect_identical(ids$pmcid_pmc, "PMC7071725")
  expect_identical(ids$pmcid_uid, "7071725")
})

test_that("the data-availability section is reported separately from sharing", {
  xml <- system.file("extdata", "PMID32171256-PMC7071725.xml",
                     package = "rtransparency")
  skip_if(xml == "")
  r <- rt_data_code_pmc(xml)
  expect_true(r$has_das)
  expect_match(r$das_text, "^Availability of data and materials Data will be shared")
})


test_that("rt_meta_pmc returns the PMCID in the same form as the detectors", {
  old <- tempfile(fileext = ".xml")
  writeLines(paste0('<article><front><article-meta>',
                    '<article-id pub-id-type="pmc">7071725</article-id>',
                    '</article-meta></front></article>'), old)
  expect_identical(rt_meta_pmc(old)$pmcid_pmc, "PMC7071725")
})
