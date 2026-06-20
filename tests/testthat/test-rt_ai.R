test_that(".detect_ai_disclosure detects positive and negative AI disclosures", {
  pos <- list(
    "Acknowledgments The authors used ChatGPT (OpenAI) to support the manuscript writing process.",
    "During the preparation of this manuscript, the authors used Microsoft Copilot to assist with language refinement and readability.",
    "The authors declare that no generative artificial intelligence or AI-assisted tools were used in the writing, editing or preparation of this manuscript.",
    "Generative AI and AI-assisted technologies were not used in the preparation of this work.",
    "Portions of this manuscript's text were refined for clarity using ChatGPT (GPT-5, OpenAI).",
    "We acknowledge the use of the Gemini large language model (LLM) to improve the readability of the manuscript.",
    "No AI tool was used to produce this article."
  )
  for (s in pos) {
    expect_true(rtransparency:::.detect_ai_disclosure(s)$is_ai_disclosed,
                info = paste("should detect:", s))
  }
})

test_that(".detect_ai_disclosure does not flag AI used as a research method", {
  neg <- list(
    "We used a large language model to classify the clinical notes into diagnostic categories.",
    "An artificial intelligence model achieved an AUC of 0.92 for tumor detection.",
    "AI, artificial intelligence; LLM, large language model; NLP, natural language processing.",
    "ChatGPT was evaluated as a tool for answering patient questions about diabetes.",
    "The authors thank the reviewers for their helpful comments."
  )
  for (s in neg) {
    expect_false(rtransparency:::.detect_ai_disclosure(s)$is_ai_disclosed,
                 info = paste("should NOT detect:", s))
  }
})

test_that("rt_ai_pmc applies the 2023 year gate", {
  xml <- system.file("extdata", "PMID32171256-PMC7071725.xml", package = "rtransparency")
  skip_if(xml == "")
  r <- rt_ai_pmc(xml, remove_ns = TRUE)
  expect_true(r$is_success)
  # The bundled example article predates 2023, so AI disclosure is not evaluated.
  expect_lt(r$year, 2023)
  expect_true(is.na(r$is_ai_pred))
})

test_that("rt_all_pmc includes the AI indicator", {
  xml <- system.file("extdata", "PMID32171256-PMC7071725.xml", package = "rtransparency")
  skip_if(xml == "")
  a <- rt_all_pmc(xml, remove_ns = TRUE)
  expect_true("is_ai_pred" %in% names(a))
  expect_true("year" %in% names(a))
})

test_that(".ai_declaration_section recognizes 'Statement on the use of AI' titles", {
  xml <- xml2::read_xml(paste0(
    "<article><body>",
    "<sec><title>Statement on the use of artificial intelligence</title>",
    "<p>The authors declare that no generative AI was used.</p></sec>",
    "</body></article>"))
  expect_gt(nchar(rtransparency:::.ai_declaration_section(xml)), 0)

  xml2 <- xml2::read_xml(
    "<article><body><sec><title>Statistical analysis</title><p>We used R.</p></sec></body></article>")
  expect_equal(nchar(rtransparency:::.ai_declaration_section(xml2)), 0)
})

test_that(".detect_ai_disclosure recognizes a broad range of generative-AI tools", {
  pos <- list(
    "During the preparation of this work the authors used Claude (Anthropic) to improve the wording of the manuscript.",
    "The authors used Google Gemini to refine the language of this manuscript.",
    "Grok was used to polish the grammar of the manuscript text.",
    "We used DeepSeek to improve the readability of the manuscript.",
    "The manuscript text was edited for clarity using DeepL Write.",
    "Paperpal was used to language-edit this manuscript.",
    "The authors used Mistral to improve the phrasing of the manuscript."
  )
  for (s in pos) {
    expect_true(rtransparency:::.detect_ai_disclosure(s)$is_ai_disclosed,
                info = paste("should detect:", s))
  }
})

test_that(".detect_ai_disclosure ignores named models used as research objects", {
  neg <- list(
    "We benchmarked Grok, DeepSeek and LLaMA on a medical question-answering task.",
    "A Mistral-based classifier was trained to detect sepsis from clinical notes.",
    "We compared the diagnostic accuracy of Gemini and Claude on radiology cases."
  )
  for (s in neg) {
    expect_false(rtransparency:::.detect_ai_disclosure(s)$is_ai_disclosed,
                 info = paste("should NOT detect:", s))
  }
})

# Write `text` to a temp .txt whose name carries `pmid`, run rt_ai(), return row.
.run_rt_ai_txt <- function(text, pmid = "12345678") {
  f <- tempfile(pattern = paste0("PMID", pmid, "-"), fileext = ".txt")
  writeLines(text, f)
  on.exit(unlink(f), add = TRUE)
  rt_ai(f)
}

test_that("rt_ai flags positive and negative AI disclosures in TXT", {
  pos <- list(
    "Declaration of generative AI. During the preparation of this work the authors used ChatGPT to improve the readability of the manuscript.",
    "No generative AI or AI-assisted technologies were used in the preparation of this manuscript.",
    "We acknowledge the use of the Gemini large language model to refine the language of this manuscript."
  )
  for (s in pos) {
    expect_true(.run_rt_ai_txt(s)$is_ai_pred, info = paste("should detect:", s))
  }
})

test_that("rt_ai does not flag AI used as a research method or articles with no AI", {
  neg <- list(
    "We trained a large language model on clinical notes to predict hospital readmission.",
    "This randomized trial enrolled 200 patients with hypertension across three centers."
  )
  for (s in neg) {
    expect_false(.run_rt_ai_txt(s)$is_ai_pred, info = paste("should NOT detect:", s))
  }
})

test_that("rt_ai rejoins a tool name hyphenated across a line break", {
  r <- .run_rt_ai_txt("The authors used Chat-\nGPT to polish the language of the manuscript.")
  expect_true(r$is_ai_pred)
})

test_that("rt_ai returns the documented schema, the PMID and never NA (no year gate)", {
  r <- .run_rt_ai_txt("The authors used ChatGPT to improve the manuscript wording.", pmid = "99887766")
  expect_identical(names(r), c("article", "pmid", "is_ai_pred", "ai_text"))
  expect_equal(r$pmid, "99887766")
  expect_false(is.na(r$is_ai_pred))            # TXT applies no 2023 year gate
  expect_gt(nchar(r$ai_text), 0)
})
