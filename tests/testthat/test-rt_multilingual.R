# Non-English (multilingual) conflict-of-interest and funding detection. The
# helpers run on transliterated, accent-stripped text; the tokens are
# language-distinctive and must not fire on English.

test_that(".which_spanish_coi_1 detects non-English COI phrases", {
  expect_length(rtransparency:::.which_spanish_coi_1("conflicto de interes"), 1)     # ES
  expect_length(rtransparency:::.which_spanish_coi_1("conflictos de intereses"), 1)  # ES
  expect_length(rtransparency:::.which_spanish_coi_1("conflito de interesse"), 1)    # PT
  expect_length(rtransparency:::.which_spanish_coi_1("conflitto di interessi"), 1)   # IT
  expect_length(rtransparency:::.which_spanish_coi_1("conflit d'interets"), 1)       # FR
  expect_length(rtransparency:::.which_spanish_coi_1("declaration de liens d'interets"), 1)  # FR
  expect_length(rtransparency:::.which_spanish_coi_1("kein Interessenkonflikt besteht"), 1)  # DE
})

test_that(".which_spanish_coi_1 does not fire on English COI text", {
  expect_length(rtransparency:::.which_spanish_coi_1(
    "the authors declare a conflict of interest"), 0)
  expect_length(rtransparency:::.which_spanish_coi_1(
    "no competing interests were declared"), 0)
})

test_that(".which_multilingual_fund_1 detects non-English funding", {
  expect_length(rtransparency:::.which_multilingual_fund_1("financiado por la beca de salud"), 1)  # ES
  expect_length(rtransparency:::.which_multilingual_fund_1("foi financiado pelo CNPq"), 1)         # PT
  expect_length(rtransparency:::.which_multilingual_fund_1("finance par l'agence nationale"), 1)   # FR
  expect_length(rtransparency:::.which_multilingual_fund_1("gefordert von der DFG"), 1)            # DE
  expect_length(rtransparency:::.which_multilingual_fund_1("finanziato dal ministero"), 1)         # IT
})

test_that(".which_multilingual_fund_1 does not fire on English funding text", {
  expect_length(rtransparency:::.which_multilingual_fund_1(
    "this study was funded by the NIH"), 0)
  expect_length(rtransparency:::.which_multilingual_fund_1(
    "supported by a grant from the Wellcome Trust"), 0)
})

test_that("negate_absence_1 treats non-English no-funding as absence", {
  expect_true(rtransparency:::negate_absence_1("no hubo fuentes de financiacion externas"))  # ES
  expect_true(rtransparency:::negate_absence_1("cette etude a ete effectuee sans subvention externe"))  # FR
  expect_true(rtransparency:::negate_absence_1("es bestand keine finanzielle unterstutzung"))  # DE
  expect_true(rtransparency:::negate_absence_1("non ha ricevuto alcun finanziamento"))  # IT
})

test_that("transliteration is platform independent", {
  x <- "Die Autoren erkl\u00e4ren, dass kein Interessenkonflikt besteht. Financiaci\u00f3n"
  expect_identical(rtransparency:::.to_ascii(x),
                   "Die Autoren erklaren, dass kein Interessenkonflikt besteht. Financiacion")
  expect_identical(rtransparency:::.to_ascii(c("\u00e9t\u00e9", NA)), c("ete", NA))
})

test_that("non-English COI section titles are recognized", {
  d <- rtransparency:::.create_synonyms()
  titles <- rtransparency:::.encase(unlist(d[c("conflict_title", "disclosure_coi_title")]))
  for (h in c("Liens d'intérêts", "LIENS D'INTÉRÊTS",
              "Conflits d’intérêts", "Conflito de interesses",
              "Conflitto di interessi", "Interessenkonflikt", "Conflicto de intereses")) {
    expect_true(grepl(titles, h, ignore.case = TRUE, perl = TRUE), info = h)
  }
  expect_false(grepl(titles, "Linked data", ignore.case = TRUE, perl = TRUE))
})
