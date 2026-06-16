#' Identify whether a study claims novelty in TXT files.
#'
#' Takes a TXT file and returns data related to the presence of novelty claims,
#'     including whether a novelty claim exists. If a novelty claim exists, it
#'     extracts the relevant text. Novelty is defined as the study claiming to
#'     report something "for the first time."
#'
#' @param filename The name of the TXT file as a string.
#' @return A tibble of results. It returns the filename, PMID (if it was part
#'     of the file name), whether a novelty claim was found, the text
#'     identified, and whether each pattern-matching function identified
#'     relevant text or not.
#' @examples
#' \dontrun{
#' # Path to TXT file.
#' filepath <- "../inst/extdata/00003-PMID26637448-PMC4737611.txt"
#'
#' # Identify and extract novelty claims.
#' results_table <- rt_novelty(filepath)
#' }
#' @export
rt_novelty <- function(filename) {

  article <- basename(filename)
  pmid <- gsub("^.*PMID([0-9]+).*$", "\\1", filename)

  is_novelty_pred <- FALSE
  novelty_text <- ""

  index_any <- list(
    novelty_first_time_1 = NA,
    novelty_first_time_2 = NA,
    novelty_first_to_1 = NA,
    novelty_previously_1 = NA,
    novelty_novel_1 = NA,
    novelty_knowledge_1 = NA
  )

  paper_text <- readr::read_file(filename)

  # Quick relevance check
  rel_regex <- "first time|first study|first to |first report|novel finding|previously unknown|previously unreported|previously uncharacterized|previously undescribed|to our knowledge|to the best of our knowledge"
  is_relevant <- grepl(rel_regex, paper_text, ignore.case = TRUE)

  if (!is_relevant) {
    return(tibble::as_tibble(c(
      list(article = article, pmid = pmid,
           is_novelty_pred = is_novelty_pred,
           novelty_text = novelty_text),
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

  # Scan first ~30 paragraphs (abstract + intro zone) + last few (discussion)
  n_para <- length(splitted)
  scan_idx <- unique(c(seq_len(min(30, n_para)), seq(max(1, n_para - 15), n_para)))
  article_scan <- splitted[scan_idx]

  index_any$novelty_first_time_1 <- .which_novelty_first_time_1(article_scan)
  index_any$novelty_first_time_2 <- .which_novelty_first_time_2(article_scan)
  index_any$novelty_first_to_1   <- .which_novelty_first_to_1(article_scan)
  index_any$novelty_previously_1 <- .which_novelty_previously_1(article_scan)
  index_any$novelty_novel_1       <- .which_novelty_novel_1(article_scan)
  index_any$novelty_knowledge_1   <- .which_novelty_knowledge_1(article_scan)

  index <- unlist(index_any) %>% unique() %>% sort()

  is_novelty_pred <- !!length(index)
  novelty_text <- article_scan[index] %>% paste(collapse = " ")

  index_any %<>% purrr::map(function(x) !!length(x))

  tibble::as_tibble(c(
    list(article = article, pmid = pmid,
         is_novelty_pred = is_novelty_pred,
         novelty_text = novelty_text),
    index_any
  ))
}


#' Identify "for the first time" claims
#'
#' @param article A character vector of paragraphs.
#' @return Integer index of matching elements.
.which_novelty_first_time_1 <- function(article) {

  grep("\\bfor the first time\\b", article, ignore.case = TRUE, perl = TRUE)

}


#' Identify "first time that" claims
#'
#' @param article A character vector of paragraphs.
#' @return Integer index of matching elements.
.which_novelty_first_time_2 <- function(article) {

  grep("\\bfirst time (that|to|we|this)\\b", article, ignore.case = TRUE, perl = TRUE)

}


#' Identify "first to show/report/demonstrate" claims
#'
#' @param article A character vector of paragraphs.
#' @return Integer index of matching elements.
.which_novelty_first_to_1 <- function(article) {

  verbs <- "(show|report|demonstrate|identify|describe|establish|characterize|reveal|document|observe|detect)"
  pattern <- paste0("\\b(first (study|report|trial|analysis|investigation|paper|work|time)? to ",
                    verbs, "|first to ", verbs, ")")

  grep(pattern, article, ignore.case = TRUE, perl = TRUE)

}


#' Identify "previously unknown/unreported" claims
#'
#' @param article A character vector of paragraphs.
#' @return Integer index of matching elements.
.which_novelty_previously_1 <- function(article) {

  grep("\\bpreviously (unknown|unreported|uncharacterized|undescribed|unidentified|unrecognized|unappreciated)\\b",
       article, ignore.case = TRUE, perl = TRUE)

}


#' Identify "novel finding/approach" claims
#'
#' @param article A character vector of paragraphs.
#' @return Integer index of matching elements.
.which_novelty_novel_1 <- function(article) {

  grep("\\bnovel (finding|observation|approach|method|technique|insight|evidence|aspect|role|mechanism|target|treatment|therapy|association|result)\\b",
       article, ignore.case = TRUE, perl = TRUE)

}


#' Identify "to our knowledge" novelty claims
#'
#' @param article A character vector of paragraphs.
#' @return Integer index of matching elements.
.which_novelty_knowledge_1 <- function(article) {

  grep("\\bto (our|the best of our|the best of my) knowledge\\b",
       article, ignore.case = TRUE, perl = TRUE)

}
