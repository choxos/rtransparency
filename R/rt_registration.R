# Trial registration identifiers and registration timing.
#
# Registration detection says whether an article reports a registration. For
# trials registered at ClinicalTrials.gov, the registry itself records when the
# trial was registered and when it started, so whether the registration was
# prospective can be checked rather than inferred from text.


# Registry identifier patterns: canonical registry name -> regex.
.trial_id_patterns <- function() {
  c(
    ClinicalTrials.gov = "\\bNCT[0-9]{8}\\b",
    ISRCTN = "\\bISRCTN[0-9]{8}\\b",
    PROSPERO = "\\bCRD[0-9]{11}\\b",
    ChiCTR = "\\bChiCTR[-A-Z]*[0-9]{6,}\\b",
    DRKS = "\\bDRKS[0-9]{8}\\b",
    ANZCTR = "\\bACTRN[0-9]{14}\\b",
    IRCT = "\\bIRCT[0-9]+N[0-9]+\\b",
    UMIN = "\\bUMIN[0-9]{9}\\b",
    jRCT = "\\bjRCT[a-z]?[0-9]{9,10}\\b",
    CTRI = "\\bCTRI/[0-9]{4}/[0-9]{2,3}/[0-9]{5,6}\\b",
    PACTR = "\\bPACTR[0-9]{15,16}\\b",
    KCT = "\\bKCT[0-9]{7}\\b",
    # Not the first part of a CTIS number (2022-500024-30-00).
    EudraCT = "(?<![0-9-])(19|20)[0-9]{2}-[0-9]{6}-[0-9]{2}(?!-?[0-9])",
    CTIS = "\\b20[0-9]{2}-5[0-9]{5}-[0-9]{2}-[0-9]{2}\\b",
    INPLASY = "\\bINPLASY[0-9]{6,}\\b"
  )
}


#' Extract trial and review registration identifiers from text
#'
#' Finds registry identifiers (ClinicalTrials.gov NCT numbers, ISRCTN,
#' PROSPERO, ChiCTR, DRKS, ANZCTR, IRCT, UMIN, jRCT, CTRI, PACTR, KCT, EudraCT,
#' CTIS and INPLASY) in text, typically the `register_text` returned by
#' [rt_all_pmc()] or [rt_register()].
#'
#' @param text A character vector.
#' @return A tibble with one row per identifier found: the position in `text`
#'   (`element`), the `registry` and the `trial_id` (upper-cased, with spaces
#'   removed). Identifiers repeated within an element are listed once.
#' @seealso [rt_registration_timing()]
#' @examples
#' rt_trial_ids(c(
#'   "Registered at ClinicalTrials.gov (NCT04368728) and ISRCTN12345678.",
#'   "PROSPERO CRD42020123456",
#'   "No registration."
#' ))
#' @export
rt_trial_ids <- function(text) {
  text <- as.character(text)
  pats <- .trial_id_patterns()
  rows <- list()
  for (i in seq_along(text)) {
    if (is.na(text[i]) || !nzchar(text[i])) next
    for (reg in names(pats)) {
      hits <- regmatches(text[i], gregexpr(pats[[reg]], text[i], perl = TRUE,
                                           ignore.case = TRUE))[[1]]
      if (length(hits)) {
        hits <- unique(toupper(gsub("\\s", "", hits)))
        if (reg == "jRCT") hits <- sub("^JRCT", "jRCT", hits)
        if (reg == "ChiCTR") hits <- sub("^CHICTR", "ChiCTR", hits)
        rows[[length(rows) + 1]] <- tibble::tibble(element = i, registry = reg,
                                                  trial_id = hits)
      }
    }
  }
  if (!length(rows)) {
    return(tibble::tibble(element = integer(0), registry = character(0),
                          trial_id = character(0)))
  }
  dplyr::bind_rows(rows)
}


#' Check whether ClinicalTrials.gov registrations were prospective
#'
#' Looks up trials in the ClinicalTrials.gov registry (API version 2) and
#' compares the date the registration was first submitted with the study start
#' date. A registration is prospective when it was submitted no later than the
#' start date (plus an optional grace period).
#'
#' When the registry gives the start date to the month only, a registration
#' submitted within that month cannot be classified and `is_prospective` is
#' `NA`; one submitted before the month is prospective and one after it is
#' retrospective. The start date the registry holds may be an estimate for
#' trials not yet started (`start_date_type`).
#'
#' @param nct_ids A character vector of NCT numbers, for example from
#'   [rt_trial_ids()]. Other identifiers are returned with `NA` dates.
#' @param grace_days Days after the start date within which a registration
#'   still counts as prospective (default `0`). Some studies allow 30 days.
#' @return A tibble with one row per unique identifier: `nct_id`,
#'   `first_submitted` and `first_posted` (the registration dates),
#'   `start_date`, `start_date_precision` (`"day"` or `"month"`),
#'   `start_date_type` (`"ACTUAL"` or `"ESTIMATED"`), `days_after_start`
#'   (submission date minus start date; negative when registered before the
#'   start) and `is_prospective`. Trials the registry does not know have `NA`
#'   dates.
#' @seealso [rt_trial_ids()], [rt_register_pmc()]
#' @examples
#' \donttest{
#' # Needs internet access and the jsonlite package.
#' if (requireNamespace("jsonlite", quietly = TRUE)) {
#'   try(rt_registration_timing(c("NCT04368728", "NCT00000102")))
#' }
#' }
#' @export
rt_registration_timing <- function(nct_ids, grace_days = 0) {
  rlang::check_installed("jsonlite", reason = "to read ClinicalTrials.gov records")
  ids <- unique(toupper(trimws(as.character(nct_ids))))
  ids <- ids[!is.na(ids) & nzchar(ids)]
  valid <- ids[grepl("^NCT[0-9]{8}$", ids)]

  recs <- list()
  for (chunk in split(valid, ceiling(seq_along(valid) / 100))) {
    uri <- paste0(
      "https://clinicaltrials.gov/api/v2/studies?format=json&pageSize=100",
      "&fields=NCTId,StudyFirstSubmitDate,StudyFirstPostDate,StartDate,StartDateType",
      "&filter.ids=", paste(chunk, collapse = ",")
    )
    js <- .read_json_retry(uri)
    recs <- c(recs, js$studies)
  }
  .registration_timing_table(ids, recs, grace_days)
}


# Read JSON from a URL with a few retries.
.read_json_retry <- function(uri, tries = 3L, pause = 1) {
  for (attempt in seq_len(tries)) {
    js <- tryCatch(jsonlite::fromJSON(uri, simplifyVector = FALSE),
                   error = function(e) e)
    if (!inherits(js, "error")) return(js)
    if (attempt < tries) Sys.sleep(pause * attempt)
  }
  stop(conditionMessage(js), call. = FALSE)
}


# Build the timing table from parsed ClinicalTrials.gov study records.
.registration_timing_table <- function(ids, recs, grace_days = 0) {
  get <- function(x, ...) {
    for (k in c(...)) {
      if (is.null(x[[k]])) return(NA_character_)
      x <- x[[k]]
    }
    as.character(x)
  }
  by_id <- list()
  for (r in recs) {
    id <- get(r, "protocolSection", "identificationModule", "nctId")
    sm <- r$protocolSection$statusModule
    by_id[[id]] <- list(
      first_submitted = get(sm, "studyFirstSubmitDate"),
      first_posted = get(sm, "studyFirstPostDateStruct", "date"),
      start = get(sm, "startDateStruct", "date"),
      start_type = get(sm, "startDateStruct", "type")
    )
  }
  field <- function(f) vapply(ids, function(i) {
    if (is.null(by_id[[i]])) NA_character_ else by_id[[i]][[f]]
  }, character(1), USE.NAMES = FALSE)

  submitted <- as.Date(field("first_submitted"))
  start_raw <- field("start")
  precision <- ifelse(is.na(start_raw), NA_character_,
                      ifelse(grepl("^[0-9]{4}-[0-9]{2}$", start_raw), "month", "day"))
  start <- as.Date(ifelse(precision %in% "month", paste0(start_raw, "-01"), start_raw))
  # The last day of the start month (start is the 1st for month precision).
  month_end <- as.Date(format(start + 32, "%Y-%m-01")) - 1
  days <- as.integer(submitted - start)
  prospective <- ifelse(is.na(submitted) | is.na(start), NA,
    ifelse(precision %in% "day", days <= grace_days,
      ifelse(submitted < start, TRUE,
        ifelse(submitted > month_end + grace_days, FALSE, NA))))

  tibble::tibble(
    nct_id = ids,
    first_submitted = submitted,
    first_posted = as.Date(field("first_posted")),
    start_date = start,
    start_date_precision = precision,
    start_date_type = field("start_type"),
    days_after_start = days,
    is_prospective = as.logical(prospective)
  )
}

