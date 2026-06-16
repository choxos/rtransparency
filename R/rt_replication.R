#' Identify whether a study includes a replication component in TXT files.
#'
#' Takes a TXT file and returns data related to the presence of a replication
#'     or validation component, including whether such a component exists.
#'     Replication is defined as the study independently confirming findings
#'     from a prior study in a new sample.
#'
#' @param filename The name of the TXT file as a string.
#' @return A tibble of results. It returns the filename, PMID (if it was part
#'     of the file name), whether a replication component was found, the text
#'     identified, and whether each pattern-matching function identified
#'     relevant text or not.
#' @examples
#' \dontrun{
#' # Path to TXT file.
#' filepath <- "../inst/extdata/00003-PMID26637448-PMC4737611.txt"
#'
#' # Identify and extract replication components.
#' results_table <- rt_replication(filepath)
#' }
#' @export
rt_replication <- function(filename) {

  article <- basename(filename)
  pmid <- gsub("^.*PMID([0-9]+).*$", "\\1", filename)

  is_replication_pred <- FALSE
  replication_text <- ""

  index_any <- list(
    replication_replicat_1    = NA,
    replication_confirm_1     = NA,
    replication_independent_1 = NA,
    replication_reproduced_1  = NA,
    replication_validation_1  = NA
  )

  paper_text <- readr::read_file(filename)

  # Quick relevance check
  rel_regex <- "replicat|independent(ly)? (confirm|validat|reproduc)|external validation|reproduced (the|our|their|these) (findings|results)"
  is_relevant <- grepl(rel_regex, paper_text, ignore.case = TRUE)

  if (!is_relevant) {
    return(tibble::as_tibble(c(
      list(article = article, pmid = pmid,
           is_replication_pred = is_replication_pred,
           replication_text = replication_text),
      index_any
    )))
  }

  # Split into paragraphs
  broken_1 <- "([a-z]+)-\n+([a-z]+)"
  broken_2 <- "([a-z]+)(|,|;)\n+([a-z]+)"
  splitted <-
    paper_text %>%
    purrr::map(gsub, pattern = broken_1, replacement = "\\1\\2") %>%
    purrr::map(gsub, pattern = broken_2, replacement = "\\1\\3") %>%
    purrr::map(strsplit, "\n| \\*") %>%
    unlist() %>%
    utf8::utf8_encode()

  index_any$replication_replicat_1    <- .which_replication_replicat_1(splitted)
  index_any$replication_confirm_1     <- .which_replication_confirm_1(splitted)
  index_any$replication_independent_1 <- .which_replication_independent_1(splitted)
  index_any$replication_reproduced_1  <- .which_replication_reproduced_1(splitted)
  index_any$replication_validation_1  <- .which_replication_validation_1(splitted)

  index <- unlist(index_any) %>% unique() %>% sort()

  # Remove negations
  if (!!length(index)) {
    is_negated <- .negate_replication_1(splitted[index])
    index <- index[!is_negated]
  }

  is_replication_pred <- !!length(index)
  replication_text <- splitted[index] %>% paste(collapse = " ")

  index_any %<>% purrr::map(function(x) !!length(x))

  tibble::as_tibble(c(
    list(article = article, pmid = pmid,
         is_replication_pred = is_replication_pred,
         replication_text = replication_text),
    index_any
  ))
}


#' Identify replication claims using "replicate" terms
#'
#' @param article A character vector of paragraphs.
#' @return Integer index of matching elements.
.which_replication_replicat_1 <- function(article) {

  # "replicat" root to cover replicate/replicated/replicating/replication
  # Require context: "previous/prior/earlier findings/results/study"
  pattern <- paste0(
    "\\breplicat(e|es|ed|ing|ion)\\b.{0,80}",
    "(previous|prior|earlier|original|published|reported|known|established)",
    "|",
    "(previous|prior|earlier|original|published|reported|known|established).{0,80}",
    "\\breplicat(e|es|ed|ing|ion)\\b"
  )

  grep(pattern, article, ignore.case = TRUE, perl = TRUE)

}


#' Identify "confirm findings" replication claims
#'
#' @param article A character vector of paragraphs.
#' @return Integer index of matching elements.
.which_replication_confirm_1 <- function(article) {

  confirm_verbs <- "(confirm(s|ed|ing)?|corroborate(s|d|ing)?|validate(s|d|ing)?)"
  findings <- "(finding(s)?|result(s)?|observation(s)?|association(s)?|effect(s)?)"
  context  <- "(from|of|in|reported in|by)"

  pattern <- paste0("\\b", confirm_verbs, "\\b.{0,60}\\b", findings, "\\b.{0,40}\\b", context, "\\b")

  grep(pattern, article, ignore.case = TRUE, perl = TRUE)

}


#' Identify "independently replicated/validated" claims
#'
#' @param article A character vector of paragraphs.
#' @return Integer index of matching elements.
.which_replication_independent_1 <- function(article) {

  pattern <- paste0(
    "\\bindependent(ly)?\\b.{0,40}",
    "\\b(replicat|validat|reproduc|confirm)(e|es|ed|ing|ion)?\\b",
    "|",
    "\\b(independent|external)\\b.{0,10}\\b(replication|validation|reproduction|cohort|sample|dataset)\\b"
  )

  grep(pattern, article, ignore.case = TRUE, perl = TRUE)

}


#' Identify "reproduced the/our findings" claims
#'
#' @param article A character vector of paragraphs.
#' @return Integer index of matching elements.
.which_replication_reproduced_1 <- function(article) {

  pattern <- paste0(
    "\\breproduced? (the |our |their |these )?(findings|results|observations|associations)\\b",
    "|",
    "\\b(findings|results|observations)\\b.{0,40}\\breproduced?\\b"
  )

  grep(pattern, article, ignore.case = TRUE, perl = TRUE)

}


#' Identify "validation cohort/sample" claims
#'
#' @param article A character vector of paragraphs.
#' @return Integer index of matching elements.
.which_replication_validation_1 <- function(article) {

  pattern <- paste0(
    "\\b(validation|replication|confirmatory)\\b.{0,20}",
    "\\b(cohort|sample|dataset|set|population|study|analysis|group|trial)\\b",
    "|",
    "\\b(cohort|sample|dataset|set|population|study|group|trial)\\b.{0,20}",
    "\\b(validation|replication|confirmatory)\\b"
  )

  grep(pattern, article, ignore.case = TRUE, perl = TRUE)

}


#' Remove negated replication mentions
#'
#' Removes mentions such as "failed to replicate" or "could not replicate".
#'
#' @param article A character vector of matching paragraphs.
#' @return Logical vector; TRUE where the match is a negation (to be excluded).
.negate_replication_1 <- function(article) {

  pattern <- "(not replicated|failed to replicate|unable to replicate|could not replicate|fail(ed|s|ing) to replicate|did not replicate)"

  grepl(pattern, article, ignore.case = TRUE, perl = TRUE)

}
