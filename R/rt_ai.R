# Detect disclosure of generative-AI / large-language-model use.
#
# Since 2023, journals and publishers (ICMJE, COPE, Elsevier, Springer Nature,
# Frontiers, ...) ask authors to disclose whether generative AI or AI-assisted
# tools were used in preparing a manuscript. This indicator detects the presence
# of such a disclosure (positive "we used ChatGPT ..." or negative "no
# generative AI was used ..."). Because the practice did not exist before 2023,
# the indicator is only evaluated for articles published in 2023 or later;
# earlier articles return NA.


# Generative-AI tools and an AI-disclosure / manuscript-preparation context, in
# the same sentence; an abbreviation-list / method veto removes papers that
# merely study or use AI as their method.
.detect_ai_disclosure <- function(text) {

  out <- list(is_ai_disclosed = FALSE, ai_text = "")
  if (!length(text)) return(out)

  s <- .dc_split(text)
  s <- s[nchar(trimws(s)) > 0]
  if (!length(s)) return(out)

  ai_term <- paste(
    "generative (ai|artificial intelligence)", "\\bgen-?ai\\b",
    "chatgpt", "\\bgpt\\s?[-\u2013]?\\s?[0-9]", "gpt-4o", "\\bllms?\\b",
    "large language models?",
    "ai-(assisted|generated|based) (tool|technolog|writ|languag|imag|content)",
    "ai-assisted technolog", "dall-?e", "midjourney", "stable diffusion",
    "deepseek", "mixtral", "\\bqwen", "\\bllm-?[0-9]", "\\bpalm 2\\b",
    "pathways language model", "ernie bot", "\\bdeepl\\b", "paperpal",
    "quillbot", "writefull", "wordtune", "jasper ai", "writesonic", "openai",
    "anthropic",
    # Product names that are also ordinary names or words (Claude Martin, the
    # Gemini Observatory, a llama facility, Bard College, perplexity) count only
    # with a version, vendor or AI qualifier beside them.
    "\\bclaude[ -]?([0-9]|ai\\b|\\(anthropic|by anthropic|sonnet|opus|haiku|instant)",
    "\\b(google )?gemini[ -]?([0-9]|pro\\b|ultra|flash|advanced|ai\\b|model|\\(google)",
    "google gemini", "google bard", "\\bbard \\(google",
    "\\bllama[ -]?[0-9]", "\\bllama (model|ai\\b)", "meta llama", "\\bmeta ai\\b",
    "\\bmistral (ai|large|medium|small|[0-9])", "\\bperplexity(\\.ai| ai\\b)",
    "\\bgemma[ -]?[0-9]", "\\bgrok[ -]?[0-9]", "\\bgrok \\(x", "\\bxai\\b",
    "(github|microsoft|bing) copilot", "\\bcopilot \\(microsoft",
    "\\bsora \\(openai",
    # ... or when the name itself is what was used: "used Mistral to", "Grok
    # was used", "the Gemini large language model". A following capitalized
    # word ("Claude Martin", "Gemini Observatory") marks a person or place.
    paste0("\\b(used|using|utili[sz](ed|ing)|employ(ed|ing)|with the (help|aid|",
           "assistance|use) of|assisted by|use of) (the )?(claude|gemini|bard|llama|mistral|perplexity|gemma|grok|sora|copilot)\\b",
           "(?!\\s*(?-i:[A-Z][a-z]))"),
    "\\b(claude|gemini|bard|llama|mistral|perplexity|gemma|grok|sora|copilot)\\b (was|were|is|has been) (used|employed|utili[sz]ed)",
    paste0("\\b(claude|gemini|bard|llama|mistral|perplexity|gemma|grok|sora|copilot)\\b,? (\\()?(a |an |the )?(large language model|llm|",
           "generative|ai (tool|model|assistant|chatbot)|chatbot|language model)"),
    # Bare "AI tool" / "artificial intelligence" only matters here because the
    # extracted text is restricted to declaration / acknowledgment sections,
    # where these refer to manuscript-preparation AI use, not a research method.
    "\\bai tools?\\b", "\\bartificial intelligence\\b", "\\bai\\b (was|were) (not )?used",
    sep = "|"
  )

  ctx <- paste(
    # AI used/using/refined/etc. tied to a manuscript / writing / figure object.
    paste0("(used|using|utiliz(ed|ing)|employ(ed|ing)|adopt(ed|ing)|",
           "assisted by|with the (help|aid|assistance|use) of|",
           "created (with|using)|generated (with|using)|refined|edited|",
           "improved|enhanced|polished|proofread|paraphrased|checked)",
           "[^.]{0,75}",
           "(manuscript|text|language(?!s? ?model)|writing|written|readabilit|",
           "grammar|grammatic|wording|clarity|concise|editing|proofread|english|",
           "paraphras|figure|image|illustration|graphic|abstract|translation|",
           "draft|introduction|discussion)"),
    # explicit declaration / negation forms.
    "declaration of (generative )?ai", "declared that",
    "authors? (used|declare|confirm|did not)",
    "did not use",
    # "use of" only when it introduces the AI tool itself ("the use of
    # ChatGPT"), not any use ("we thank ... for the use of their facility").
    paste0("\\buse of\\b[^.]{0,40}(", ai_term, ")"),
    "(no|not|never) [^.]{0,25}(ai|generative|llm)[^.]{0,25}(used|tool|technolog|declared)",
    "(was|were) (not )?used in[^.]{0,40}(manuscript|writing|preparation|creation|work)",
    "(generative ai|ai-assisted technolog|ai-generated (image|content))[^.]{0,40}(was|were) (not )?used",
    "in the (writing|preparation|creation|production|editing|drafting) of (this|the)",
    "(preparation|creation|production) of (this|the) (manuscript|work|paper)",
    "ai-generated (image|figure|content)",
    sep = "|"
  )

  # Abbreviation lists ("AI, artificial intelligence; LLM, large language
  # model") and similar appear in AI-method papers, not as disclosures.
  veto <- paste(
    "\\bai, artificial intelligence\\b",
    "llm,? large language model",
    ", large language model;",
    "artificial intelligence \\(ai\\),",
    # An AI unit or facility named in an acknowledgment is not a disclosure.
    paste0("artificial intelligence (core|facility|cent(er|re)|institute|lab|",
           "laboratory|department|program|group|unit|initiative|hub|research)"),
    sep = "|"
  )

  hit <- grepl(ai_term, s, ignore.case = TRUE, perl = TRUE) &
    grepl(ctx, s, ignore.case = TRUE, perl = TRUE) &
    !grepl(veto, s, ignore.case = TRUE, perl = TRUE)

  if (any(hit)) {
    out$is_ai_disclosed <- TRUE
    out$ai_text <- paste(unique(trimws(s[hit])), collapse = " | ")
  }
  out
}


# What a disclosure says: whether AI was used, which tools, and for what.
#
# ai_used is TRUE when a disclosure sentence states that AI was used, FALSE when
# every disclosure sentence states that it was not ("No generative AI was used
# ..."), and NA when there is no disclosure sentence to read (for example only
# a section title was found). ai_tools and ai_purpose are read from the
# sentences that state use, as "; "-separated canonical names.
.ai_details <- function(sentences) {
  out <- list(ai_used = NA, ai_tools = "", ai_purpose = "")
  sentences <- sentences[nzchar(trimws(sentences))]
  if (!length(sentences)) return(out)

  negated <- grepl(paste0(
    "\\b(no|not|never|none|without)\\b[^.]{0,60}\\b(ai|generative|llms?|chatgpt|",
    "artificial intelligence|language models?|tools?|technolog\\w*)\\b[^.]{0,40}",
    "\\b(was|were|been|is|are)?\\s?(used|employed|utili[sz]ed|involved|applied)|",
    "\\b(did|do|does|have|has|had|was|were)\\s?n[o']t\\s(use|used|employ|utili[sz]e|",
    "rely|involve)|\\bnot applicable\\b|\\bno (generative )?(ai|artificial intelligence)",
    "\\b[^.]{0,30}\\b(was|were) (used|employed)"
  ), sentences, ignore.case = TRUE, perl = TRUE)
  # "No AI was used except for grammar checks" still reports use.
  exception <- grepl("\\b(except|other than|apart from|besides|only (to|for))\\b",
                     sentences, ignore.case = TRUE, perl = TRUE)
  used <- !negated | exception
  out$ai_used <- any(used)
  if (!out$ai_used) return(out)

  use_text <- paste(sentences[used], collapse = " ")
  has <- function(p) grepl(p, use_text, ignore.case = TRUE, perl = TRUE)

  tools <- c(
    ChatGPT = "chatgpt|\\bgpt-?[0-9]|gpt-4o|\\bopenai\\b",
    Claude = "\\bclaude\\b|\\banthropic\\b",
    Gemini = "\\bgemini\\b",
    Bard = "\\bbard\\b",
    Copilot = "\\bcopilot\\b",
    Llama = "\\bllama\\b",
    Mistral = "\\bmistral\\b|\\bmixtral\\b",
    DeepSeek = "deepseek",
    Grok = "\\bgrok\\b",
    Qwen = "\\bqwen",
    Perplexity = "\\bperplexity\\b",
    DeepL = "\\bdeepl\\b",
    QuillBot = "quillbot",
    Paperpal = "paperpal",
    Writefull = "writefull",
    Wordtune = "wordtune",
    Grammarly = "grammarly",
    Jasper = "jasper ai",
    Writesonic = "writesonic",
    `DALL-E` = "dall-?e",
    Midjourney = "midjourney",
    `Stable Diffusion` = "stable diffusion",
    `ERNIE Bot` = "ernie bot"
  )
  out$ai_tools <- paste(names(tools)[vapply(tools, has, logical(1))], collapse = "; ")

  purposes <- c(
    `language editing` = paste0("grammar|grammatic|proofread|spelling|readabilit|",
                                "wording|clarity|phras|polish|\\bedit|english|",
                                "\\blanguage\\b(?!\\s+models?)|concise|fluency|\\bstyle"),
    translation = "translat",
    drafting = paste0("draft|\\bwrit(e|ing|ten)\\b[^.]{0,20}\\b(text|section|part|",
                      "manuscript|paper|abstract)|generat\\w* (the )?(text|content)|",
                      "summari[sz]"),
    `figures and images` = "figure|image|illustrat|graphic|diagram|visual",
    `code and analysis` = "\\bcode\\b|\\bcoding\\b|\\bscripts?\\b|programm|statistic|data analys",
    `literature search` = "literature|references?\\b|citations?\\b|search"
  )
  out$ai_purpose <- paste(names(purposes)[vapply(purposes, has, logical(1))],
                          collapse = "; ")
  out
}


# Earliest publication year (epub/ppub/collection) as an integer, or NA.
.get_pub_year <- function(article_xml) {
  yrs <- article_xml %>%
    xml2::xml_find_all(".//front/article-meta//pub-date//year | .//front/article-meta//pub-date/year") %>%
    xml2::xml_text() %>%
    as.integer()
  yrs <- yrs[!is.na(yrs) & yrs > 1900 & yrs < 2100]
  if (!length(yrs)) return(NA_integer_)
  min(yrs)
}


# Sections where an AI-use disclosure is found: back matter, footnotes,
# acknowledgments, author notes, custom-meta and declaration/AI sections. The
# main body is deliberately excluded to avoid AI-method articles.
.ai_article_text <- function(article_xml) {
  lc <- function(kw) {
    paste0(".//sec[contains(translate(title,",
           "'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz'),",
           "'", kw, "')]//p")
  }
  # Back matter, footnotes, acknowledgments and any section whose title marks it
  # as a declaration/disclosure of AI use. The main body is excluded so that
  # articles which use AI as their research method are not flagged.
  sec_kw <- c("declaration", "disclosure", "generative",
              "artificial intelligence", "ai-assisted", "ai-generated")
  xp <- paste(
    c(".//back//p", ".//back//fn", ".//fn", ".//author-notes", ".//ack",
      ".//notes", ".//custom-meta", vapply(sec_kw, lc, character(1))),
    collapse = " | "
  )
  nodes <- tryCatch(xml2::xml_find_all(article_xml, xp), error = function(e) NULL)
  if (is.null(nodes) || !length(nodes)) return(character(0))
  xml2::xml_text(nodes)
}


#' Identify disclosure of generative-AI use from a PMC XML file.
#'
#' Detects whether an article discloses the use (or non-use) of generative AI or
#' AI-assisted tools in preparing the manuscript, as required of articles since
#' 2023. The indicator is only evaluated for articles published in 2023 or
#' later; for earlier articles `is_ai_pred` is `NA`.
#'
#' @param filename The filename of the PMC XML file to analyze.
#' @param remove_ns Ignored since version 1.2.0 and kept for backward
#'   compatibility. Default XML namespaces are now always removed, so a
#'   namespaced PMC XML file gives the same result as a plain one.
#' @return A tibble with the article IDs, the publication `year`, whether an AI
#'   disclosure was found (`is_ai_pred`, `NA` before 2023), the matched
#'   statement (`ai_text`), what the disclosure says (`ai_used`, `ai_tools`,
#'   `ai_purpose`; see Details) and `is_success`.
#' @details The year gate uses the earliest publication year the XML records
#'   (electronic, print or collection date), so an article first published
#'   online in December 2022 is gated out even if its issue is dated 2023.
#'
#'   A disclosure can state use or non-use, and `is_ai_pred` counts
#'   both. `ai_used` separates them: `TRUE` when a disclosure states that AI
#'   was used, `FALSE` when it states that no AI was used, and `NA` when there
#'   is no disclosure or the use cannot be read from it (for example when only
#'   a section title was found). `ai_tools` names the tools mentioned in
#'   statements of use (for example `"ChatGPT; DeepL"`) and `ai_purpose` the
#'   stated purposes, from `"language editing"`, `"translation"`,
#'   `"drafting"`, `"figures and images"`, `"code and analysis"` and
#'   `"literature search"`. These are read with the same rules as the
#'   disclosure itself and have not been separately validated.
#' @examples
#' \donttest{
#' filepath <- system.file(
#'   "extdata", "PMID32171256-PMC7071725.xml", package = "rtransparency"
#' )
#' rt_ai_pmc(filepath)
#' }
#' @export
rt_ai_pmc <- function(filename, remove_ns = TRUE) {

  article_xml <- tryCatch(.get_xml(filename, remove_ns), error = function(e) e)
  if (inherits(article_xml, "error")) {
    return(.xml_failure(filename, article_xml))
  }

  id_ls <- .get_ids(article_xml)
  id_ls$filename <- filename
  year <- .get_pub_year(article_xml)

  ai <- .get_ai_pmc(article_xml, year)

  tibble::as_tibble(c(id_ls, ai, list(is_success = TRUE)))
}


#' Identify disclosure of generative-AI use from a TXT file.
#'
#' Detects whether an article discloses the use (or non-use) of generative AI or
#' AI-assisted tools in preparing the manuscript, from a plain-text (typically
#' PDF-derived) file. Unlike [rt_ai_pmc()] it applies **no publication-year
#' gate**: a plain-text file carries no reliable publication date, so `is_ai_pred`
#' is always `TRUE` or `FALSE` (never `NA`). AI-use disclosure became an expected
#' practice only in 2023, so the caller is responsible for restricting analysis
#' to articles from 2023 onward. Plain text also lacks the section structure the
#' PMC detector uses to confine the scan to back matter, acknowledgments and
#' declaration sections, so an article that uses AI purely as a research method
#' is more likely to be flagged than under [rt_ai_pmc()].
#'
#' @inheritParams rt_coi
#' @return A tibble with the file name (`article`), the PMID (`NA` if absent),
#'   whether an AI-use disclosure was found (`is_ai_pred`), the matched
#'   statement (`ai_text`) and what it says (`ai_used`, `ai_tools`,
#'   `ai_purpose`), as described in [rt_ai_pmc()].
#' @examples
#' \donttest{
#' # Write a short example article to a temporary text file.
#' filepath <- file.path(tempdir(), "PMID00000000-PMC0000000.txt")
#' writeLines(
#'   "The authors used ChatGPT to assist with drafting this manuscript.",
#'   filepath
#' )
#'
#' # Identify and extract an AI-use disclosure.
#' rt_ai(filepath)
#' }
#' @seealso [rt_ai_pmc()] for the PMC XML detector, which applies the 2023
#'   publication-year gate.
#' @export
rt_ai <- function(filename = NULL, text = NULL) {
  input <- .txt_input(filename, text)
  .txt_row(input, .rt_ai_txt(input$text))
}


# AI-use disclosure on plain text (no publication-year gate).
.rt_ai_txt <- function(paper_text) {
  # Rejoin words hyphenated across a line break ("Chat-\nGPT" -> "ChatGPT") so a
  # tool name split by the PDF-to-text conversion is still matched; .dc_split
  # collapses the remaining whitespace before sentence-splitting.
  paper_text <- gsub("([A-Za-z0-9])-\\s*\n\\s*([A-Za-z0-9])", "\\1\\2", paper_text)
  found <- .detect_ai_disclosure(paper_text)
  c(list(is_ai_pred = found$is_ai_disclosed, ai_text = found$ai_text),
    .ai_details(strsplit(found$ai_text, " | ", fixed = TRUE)[[1]]))
}


# A section titled as a generative-AI declaration is itself a disclosure, even
# when the body is minimal ("Not applicable", "no AI was used") or garbled.
.ai_declaration_section <- function(article_xml) {
  titles <- article_xml %>%
    xml2::xml_find_all(".//sec/title | .//boxed-text/caption/title") %>%
    xml2::xml_text() %>%
    tolower()
  if (!length(titles)) return("")
  pat <- paste(
    # Unconditional disclosure-section headers.
    "(declaration|disclosure|statement) of (generative )?(ai|artificial intelligence|large language model)",
    # A section explicitly titled as a statement on the use of AI is itself a
    # disclosure ("Statement on the use of artificial intelligence").
    paste0("(statement|declaration|note|section) on (the )?use of (generative )?",
           "(ai|artificial intelligence|large language models?|llms?|chatgpt|ai-assisted)"),
    "generative ai (and|in|use|statement)",
    "ai(-| )assisted (technolog|tool)",
    "ai (use )?(statement|disclosure|declaration)",
    # "use of AI" only when tied to writing / the manuscript (a disclosure),
    # not as an AI-method topic section.
    paste0("(use of|using) (large language models?|llms?|generative ai|",
           "ai|artificial intelligence|chatgpt)[^.]{0,40}",
           "(writ|manuscript|language|preparation|assist|editing|grammar|readabilit)"),
    "(generative )?ai[^.]{0,30}(in (the )?writing|writing process|manuscript preparation)",
    sep = "|"
  )
  hit <- grepl(pat, titles, perl = TRUE)
  if (any(hit)) titles[hit][1] else ""
}


# Internal: compute the AI-disclosure fields, applying the 2023 year gate.
.get_ai_pmc <- function(article_xml, year = NULL) {
  if (is.null(year)) year <- .get_pub_year(article_xml)
  found <- .detect_ai_disclosure(.ai_article_text(article_xml))
  sec_title <- .ai_declaration_section(article_xml)
  is_disclosed <- found$is_ai_disclosed || nchar(sec_title) > 0
  ai_text <- if (nchar(found$ai_text) > 0) found$ai_text else sec_title
  is_ai_pred <- if (is.na(year) || year < 2023) NA else is_disclosed
  details <- if (isTRUE(is_ai_pred)) .ai_details(strsplit(found$ai_text, " | ", fixed = TRUE)[[1]])
             else list(ai_used = NA, ai_tools = "", ai_purpose = "")
  c(list(year = year, is_ai_pred = is_ai_pred, ai_text = ai_text), details)
}
