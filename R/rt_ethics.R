# Ethics approval and informed consent statements (experimental).
#
# Whether a study reports oversight by an ethics body (approval, waiver or
# exemption) and how participant consent was handled are standard items in
# meta-research audits of reporting. This detector is precision-first and
# rule-based like the others, but it has NOT been validated against hand
# labels yet; data-raw/validation/ builds the blind labeling sheets for that.
# Until then it is exported as experimental and kept out of rt_all_pmc().


# An ethics body.
.ethics_body <- function() {
  paste(
    "ethic(s|al)[- ](review )?(committee|board|commission|council|panel)",
    "research ethics", "ethics (review|approval|clearance|permission)",
    "ethical (review|approval|clearance|permission|board|committee)",
    "institutional review board", "\\birbs?\\b", "\\biec\\b", "\\brec\\b",
    "review board", "helsinki committee", "\\biacuc\\b",
    "animal (care|ethics|welfare)[^.]{0,30}committee",
    # Spanish/Portuguese "comite de etica" and French "comite d'ethique" with accents
    # (R-level \u escapes keep this file ASCII and switch PCRE to UTF mode.)
    "comit[e\u00e9\u00ea] (de |d.|d\u2019)?[e\u00e9\u00c9]ti(c|qu)",
    "ethikkommission", "comitato etico",
    sep = "|"
  )
}

# The body's decision: approval, waiver or exemption.
# The noun "approval" alone does not count, so a heading such as "Ethics
# approval and consent to participate" is not itself a statement.
.ethics_decision <- function() {
  paste(
    "approved", "approving",
    "approval (was|were|has been|had been|is|by|from|of the|number|no\\b|nr\\b|id\\b|code|reference|protocol|#)",
    "granted", "obtained", "waiv", "exempt", "reviewed", "cleared",
    "authori[sz]", "permission", "consent(ed)? (to|for) (the )?(study|protocol)",
    "(was|were|is) not (required|necessary|needed)", "did not require",
    "no (need|requirement) for", "aprob", "genehmig", "approvato",
    sep = "|"
  )
}

# Informed consent handling.
.consent_pattern <- function() {
  paste(
    "informed consent", "written consent", "verbal consent", "oral consent",
    "consent (was|were) (obtained|waived|given|provided|not required)",
    "consent to (participate|publication|publish)", "waiver of (informed )?consent",
    "consentimiento informado", "consentimento informado", "consentement",
    "einwilligung", "consenso informato",
    sep = "|"
  )
}

.consent_decision <- function() {
  paste(
    "obtain", "provid", "given", "gave", "sign", "waiv", "exempt", "signed",
    "(was|were|is) not (required|necessary|needed)", "no (need|requirement)",
    "agreed", "received", "collected",
    sep = "|"
  )
}

# Statements that are not the study's own ethics or consent handling.
.ethics_veto <- function() {
  paste(
    "^\\s*(not applicable|n/?a)\\.?\\s*$",
    "(ethics approval|consent)[^.]{0,40}:\\s*(not applicable|n/?a)\\b",
    "\\bnot applicable\\b\\.?\\s*$",
    "(included|eligible|primary|original|individual|selected|reviewed) (studies|trials|articles)[^.]{0,60}(approv|consent)",
    sep = "|"
  )
}


# Detect ethics and consent statements in text chunks.
.detect_ethics <- function(text) {
  out <- list(is_ethics_pred = FALSE, ethics_text = "", ethics_approval_id = "",
              is_consent_pred = FALSE, consent_text = "")
  if (!length(text)) return(out)
  # Keep "approval no. 2021-045" and "...: Not applicable" in one sentence.
  text <- gsub("\\b(no|nr|No|Nr|NO)\\.\\s+(?=[A-Z0-9])", "\\1 ", text, perl = TRUE)
  text <- gsub(":\\s+(not applicable|n/?a)\\b", ": not applicable", text,
               ignore.case = TRUE, perl = TRUE)
  s <- .dc_split(text)
  s <- s[nchar(trimws(s)) > 0]
  if (!length(s)) return(out)

  has <- function(p) grepl(p, s, ignore.case = TRUE, perl = TRUE)
  veto <- has(.ethics_veto())
  ethics <- has(.ethics_body()) & has(.ethics_decision()) & !veto
  consent <- has(.consent_pattern()) & has(.consent_decision()) & !veto

  if (any(ethics)) {
    out$is_ethics_pred <- TRUE
    out$ethics_text <- paste(unique(trimws(s[ethics])), collapse = " | ")
    id <- regmatches(out$ethics_text, regexpr(paste0(
      "(?i)(approval|reference|protocol|project|permit|registration|decision|",
      "study|irb|ethics)?\\s*(no\\.?|number|nr\\.?|id|code|#)\\s*[:.]?\\s*",
      "([A-Z0-9][A-Za-z0-9./_-]{2,}[0-9][A-Za-z0-9./_-]*)"),
      out$ethics_text, perl = TRUE))
    if (length(id)) {
      out$ethics_approval_id <- sub(paste0(
        "(?i)^.*?(no\\.?|number|nr\\.?|id|code|#)\\s*:?\\s*"), "", id, perl = TRUE)
      out$ethics_approval_id <- sub("[.,;:)]+$", "", out$ethics_approval_id)
    }
  }
  if (any(consent)) {
    out$is_consent_pred <- TRUE
    out$consent_text <- paste(unique(trimws(s[consent])), collapse = " | ")
  }
  out
}


# Ethics fields from a PMC XML: body, back matter, footnotes and declaration
# sections, where these statements are written.
.get_ethics_pmc <- function(article_xml) {
  xp <- paste(".//body//p", ".//back//p", ".//back//title", ".//fn//p",
              ".//notes//p", sep = " | ")
  nodes <- tryCatch(xml2::xml_find_all(article_xml, xp), error = function(e) NULL)
  text <- if (length(nodes)) xml2::xml_text(nodes) else character(0)
  .detect_ethics(text)
}


#' Identify ethics approval and informed consent statements (experimental)
#'
#' Detects whether an article reports oversight by an ethics body (approval,
#' waiver or exemption by an ethics committee or institutional review board,
#' including a statement that approval was not required) and whether it
#' reports how participant informed consent was handled (obtained, waived or
#' not required). The committee's approval number is extracted when stated.
#' A bare "Not applicable" does not count.
#'
#' **Experimental.** Unlike the ten main indicators, this detector has not been
#' validated against hand labels, so it is not part of [rt_all_pmc()], has no
#' row in [rt_accuracy], and its output should be spot-checked before use.
#' The scripts in `data-raw/validation/` build blind labeling sheets for its
#' validation.
#'
#' @inheritParams rt_all_pmc
#' @return A one-row tibble with the article IDs, `is_ethics_pred`,
#'   `ethics_text`, `ethics_approval_id`, `is_consent_pred`, `consent_text`
#'   and `is_success`.
#' @seealso [rt_ethics()] for plain text.
#' @examples
#' \donttest{
#' filepath <- system.file(
#'   "extdata", "PMID32171256-PMC7071725.xml", package = "rtransparency"
#' )
#' rt_ethics_pmc(filepath)
#' }
#' @export
rt_ethics_pmc <- function(filename, remove_ns = TRUE) {
  article_xml <- tryCatch(.get_xml(filename), error = function(e) e)
  if (inherits(article_xml, "error")) {
    return(.xml_failure(filename, article_xml))
  }
  id_ls <- .get_ids(article_xml)
  id_ls$filename <- filename
  tibble::as_tibble(c(id_ls, .get_ethics_pmc(article_xml), list(is_success = TRUE)))
}


#' Identify ethics approval and informed consent statements in text (experimental)
#'
#' The plain-text counterpart of [rt_ethics_pmc()], with the same rules and the
#' same caveat: the detector is experimental and not yet validated.
#'
#' @inheritParams rt_coi
#' @return A tibble with the file name (`article`), the PMID (`NA` if absent),
#'   `is_ethics_pred`, `ethics_text`, `ethics_approval_id`, `is_consent_pred`
#'   and `consent_text`.
#' @seealso [rt_ethics_pmc()]
#' @examples
#' rt_ethics(text = c(
#'   "The study was approved by the Ethics Committee of X (approval no. 2021-045).",
#'   "Written informed consent was obtained from all participants."
#' ))
#' @export
rt_ethics <- function(filename = NULL, text = NULL) {
  input <- .txt_input(filename, text)
  .txt_row(input, .detect_ethics(strsplit(input$text, "\n+")[[1]]))
}
