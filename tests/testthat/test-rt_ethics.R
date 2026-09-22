test_that("rt_ethics detects approval, waiver and exemption statements", {
  e <- function(x) rt_ethics(text = x)
  r <- e("The study was approved by the Ethics Committee of X (approval no. 2021-045).")
  expect_true(r$is_ethics_pred)
  expect_identical(r$ethics_approval_id, "2021-045")
  expect_identical(e("Approved by the IRB of Y (IRB #2000031234).")$ethics_approval_id,
                   "2000031234")
  expect_true(e("Ethical approval was not required as this study used public data.")$is_ethics_pred)
  expect_true(e("All procedures were approved by the Institutional Animal Care and Use Committee.")$is_ethics_pred)
  expect_true(e("El estudio fue aprobado por el Comit\u00e9 de \u00c9tica del Hospital.")$is_ethics_pred)
})

test_that("rt_ethics detects consent statements", {
  e <- function(x) rt_ethics(text = x)
  expect_true(e("Written informed consent was obtained from all participants.")$is_consent_pred)
  expect_true(e("The requirement for informed consent was waived by the IRB.")$is_consent_pred)
})

test_that("headings, 'not applicable' and discussion are not statements", {
  e <- function(x) rt_ethics(text = x)
  na <- e(c("Ethics approval and consent to participate", "Not applicable."))
  expect_false(na$is_ethics_pred)
  expect_false(na$is_consent_pred)
  expect_false(e("Ethics approval and consent to participate: Not applicable.")$is_ethics_pred)
  expect_false(e("The study was conducted in accordance with the Declaration of Helsinki.")$is_ethics_pred)
  expect_false(e("We assessed whether the included studies reported ethics approval.")$is_ethics_pred)
  expect_false(e("The ethics of AI are debated.")$is_ethics_pred)
})

test_that("rt_ethics_pmc returns the documented columns", {
  xml <- system.file("extdata", "PMID32171256-PMC7071725.xml",
                     package = "rtransparency")
  skip_if(xml == "")
  r <- rt_ethics_pmc(xml)
  expect_true(all(c("is_ethics_pred", "ethics_text", "ethics_approval_id",
                    "is_consent_pred", "consent_text", "is_success") %in% names(r)))
})
