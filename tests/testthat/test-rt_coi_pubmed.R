test_that(".parse_pubmed_coi reads CoiStatement, empty when absent", {
  doc <- xml2::read_xml(paste0(
    "<PubmedArticleSet>",
    "<PubmedArticle><MedlineCitation><PMID>1</PMID>",
    "<CoiStatement>The authors declare no competing interests.</CoiStatement>",
    "</MedlineCitation></PubmedArticle>",
    "<PubmedArticle><MedlineCitation><PMID>2</PMID></MedlineCitation></PubmedArticle>",
    "</PubmedArticleSet>"))
  got <- rtransparency:::.parse_pubmed_coi(doc)
  expect_identical(got$pmid, c("1", "2"))
  expect_identical(got$coi_statement,
                   c("The authors declare no competing interests.", ""))
})

test_that("rt_fill_coi_pubmed only looks up rows without a statement", {
  data <- data.frame(pmid = c("1", NA), is_coi_pred = c(TRUE, FALSE),
                     coi_text = c("None.", ""))
  # Nothing to look up: no network call is made.
  out <- rt_fill_coi_pubmed(data)
  expect_identical(out$coi_source, c("article", NA))
  expect_error(rt_fill_coi_pubmed(data.frame(x = 1)), "columns")
})

test_that("rt_coi_pubmed and rt_fill_coi_pubmed work against PubMed", {
  skip_on_cran()
  skip_if_offline("eutils.ncbi.nlm.nih.gov")
  got <- rt_coi_pubmed(c("36696006", "36696006"))
  expect_equal(nrow(got), 1L)
  expect_true(got$has_coi_statement)
  out <- rt_fill_coi_pubmed(data.frame(pmid = "36696006", is_coi_pred = FALSE,
                                       coi_text = ""))
  expect_true(out$is_coi_pred)
  expect_identical(out$coi_source, "pubmed")
})
