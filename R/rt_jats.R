# Structured JATS metadata relevant to transparency: author identifiers and
# contributions, funder identifiers and awards, and data-availability sections.
# These are read from tagged elements, not detected from prose, so they carry
# no detector error beyond what the publisher tagged.


# The 14 CRediT (Contributor Roles Taxonomy) roles, normalized to lower case
# with dashes and extra space folded, for matching untagged role text.
.credit_roles <- function() {
  c("conceptualization", "data curation", "formal analysis",
    "funding acquisition", "investigation", "methodology",
    "project administration", "resources", "software", "supervision",
    "validation", "visualization", "writing original draft",
    "writing review editing")
}

.norm_role <- function(x) {
  x <- tolower(.to_ascii(x))
  x <- gsub("[^a-z ]+", " ", x)
  x <- gsub("\\band\\b|&", " ", x)
  trimws(gsub("\\s+", " ", x))
}


#' Author identifiers and contribution roles from a PMC XML file.
#'
#' Reads the article's author list and reports how many authors carry an ORCID
#' identifier and whether contributions are described with the CRediT
#' (Contributor Roles Taxonomy) vocabulary. Both are structured JATS elements
#' (`<contrib-id contrib-id-type="orcid">` and `<role>`), so they are read, not
#' inferred from text.
#'
#' A role counts as CRediT when it is tagged with the CRediT vocabulary
#' (`vocab="credit"`) or its text is one of the 14 CRediT roles.
#'
#' @inheritParams rt_all_pmc
#' @return A one-row tibble with the article IDs, `n_authors` (contributors of
#'   type author), `n_orcid` (authors with an ORCID), `orcid_coverage`
#'   (`n_orcid / n_authors`), `orcids` (the ORCID iDs, `"; "`-separated),
#'   `has_credit` (whether any author has a CRediT role), `credit_roles` (the
#'   distinct CRediT roles used) and `is_success`.
#' @seealso [rt_funders_pmc()], [rt_all_pmc()]
#' @examples
#' \donttest{
#' filepath <- system.file(
#'   "extdata", "PMID32171256-PMC7071725.xml", package = "rtransparency"
#' )
#' rt_authors_pmc(filepath)
#' }
#' @export
rt_authors_pmc <- function(filename, remove_ns = TRUE) {
  article_xml <- tryCatch(.get_xml(filename), error = function(e) e)
  if (inherits(article_xml, "error")) {
    return(.xml_failure(filename, article_xml))
  }
  id_ls <- .get_ids(article_xml)
  id_ls$filename <- filename
  tibble::as_tibble(c(id_ls, .get_authors_pmc(article_xml), list(is_success = TRUE)))
}


.get_authors_pmc <- function(article_xml) {
  authors <- xml2::xml_find_all(
    article_xml,
    ".//front/article-meta/contrib-group/contrib[@contrib-type='author' or not(@contrib-type)]"
  )
  orcid <- vapply(authors, function(a) {
    id <- xml2::xml_find_first(a, ".//contrib-id[translate(@contrib-id-type,'ORCID','orcid')='orcid']")
    if (inherits(id, "xml_missing")) {
      # Some publishers put the ORCID in an ext-link or uri instead.
      id <- xml2::xml_find_first(a, ".//*[self::uri or self::ext-link][contains(., 'orcid.org')]")
    }
    if (inherits(id, "xml_missing")) return(NA_character_)
    m <- regmatches(xml2::xml_text(id),
                    regexpr("[0-9]{4}-[0-9]{4}-[0-9]{4}-[0-9]{3}[0-9X]", xml2::xml_text(id)))
    if (length(m)) m else NA_character_
  }, character(1))

  roles <- xml2::xml_find_all(article_xml, ".//front/article-meta/contrib-group/contrib//role")
  vocab <- tolower(xml2::xml_attr(roles, "vocab"))
  term <- xml2::xml_attr(roles, "vocab-term")
  role_text <- ifelse(!is.na(term) & nzchar(term), term, xml2::xml_text(roles))
  norm <- .norm_role(role_text)
  is_credit <- (!is.na(vocab) & vocab == "credit") | norm %in% .credit_roles()
  credit <- unique(norm[is_credit & norm %in% .credit_roles()])
  credit <- .credit_roles()[.credit_roles() %in% credit]

  n <- length(authors)
  n_orcid <- sum(!is.na(orcid))
  list(
    n_authors = n,
    n_orcid = n_orcid,
    orcid_coverage = if (n > 0) n_orcid / n else NA_real_,
    orcids = paste(unique(stats::na.omit(orcid)), collapse = "; "),
    has_credit = any(is_credit),
    credit_roles = paste(credit, collapse = "; ")
  )
}


#' Funders, funder identifiers and award numbers from a PMC XML file.
#'
#' Reads the structured funding metadata of an article (the JATS
#' `<funding-group>`): each funding source with its name, its Crossref Open
#' Funder Registry DOI and ROR identifier when the publisher tagged them, and
#' the award (grant) numbers of its award group. This complements
#' [rt_fund_pmc()], which detects whether a funding statement exists, with
#' identifiers that can be linked to funder databases.
#'
#' @inheritParams rt_all_pmc
#' @return A tibble with one row per funding source: the article IDs, `funder`
#'   (the name as tagged), `funder_doi` (a Crossref Funder Registry DOI such as
#'   `10.13039/100000002`), `funder_ror` (a ROR URL), `award_id` (the award
#'   numbers of the source's award group, `"; "`-separated) and `is_success`.
#'   An article without a `<funding-group>` gives one row with `NA` funder
#'   fields, so every file is represented.
#' @seealso [rt_fund_pmc()], [rt_authors_pmc()]
#' @examples
#' \donttest{
#' filepath <- system.file(
#'   "extdata", "PMID32171256-PMC7071725.xml", package = "rtransparency"
#' )
#' rt_funders_pmc(filepath)
#' }
#' @export
rt_funders_pmc <- function(filename, remove_ns = TRUE) {
  article_xml <- tryCatch(.get_xml(filename), error = function(e) e)
  if (inherits(article_xml, "error")) {
    return(.xml_failure(filename, article_xml))
  }
  id_ls <- .get_ids(article_xml)
  id_ls$filename <- filename
  funders <- .get_funders_pmc(article_xml)
  if (!nrow(funders)) {
    funders <- tibble::tibble(funder = NA_character_, funder_doi = NA_character_,
                              funder_ror = NA_character_, award_id = NA_character_)
  }
  ids <- tibble::as_tibble(id_ls)[rep(1, nrow(funders)), ]
  dplyr::bind_cols(ids, funders, tibble::tibble(is_success = TRUE))
}


.get_funders_pmc <- function(article_xml) {
  groups <- xml2::xml_find_all(article_xml, ".//front/article-meta/funding-group/award-group")
  rows <- lapply(groups, function(g) {
    awards <- trimws(xml2::xml_text(xml2::xml_find_all(g, ".//award-id")))
    award <- if (length(awards)) paste(unique(awards[nzchar(awards)]), collapse = "; ") else NA_character_
    if (identical(award, "")) award <- NA_character_
    sources <- xml2::xml_find_all(g, ".//funding-source")
    if (!length(sources)) return(NULL)
    do.call(rbind, lapply(sources, function(src) {
      ids <- xml2::xml_find_all(src, ".//institution-id")
      id_txt <- trimws(xml2::xml_text(ids))
      id_type <- tolower(xml2::xml_attr(ids, "institution-id-type"))
      doi <- regmatches(id_txt, regexpr("10\\.13039/[0-9A-Za-z]+", id_txt))
      # Some publishers put the Funder Registry DOI in an attribute or as text.
      if (!length(doi)) {
        all_txt <- paste(xml2::xml_attrs(src), xml2::xml_text(src), collapse = " ")
        doi <- regmatches(all_txt, regexpr("10\\.13039/[0-9A-Za-z]+", all_txt))
      }
      ror <- id_txt[grepl("ror", id_type) | grepl("ror\\.org/", id_txt)]
      ror <- sub("^(https?://)?(www\\.)?ror\\.org/", "", ror)
      name <- xml2::xml_text(xml2::xml_find_first(src, ".//institution"))
      if (is.na(name) || !nzchar(trimws(name))) {
        name <- paste(xml2::xml_text(xml2::xml_contents(src)[
          xml2::xml_type(xml2::xml_contents(src)) == "text"]), collapse = " ")
      }
      name <- trimws(gsub("\\s+", " ", name))
      tibble::tibble(
        funder = if (nzchar(name)) name else NA_character_,
        funder_doi = if (length(doi)) doi[1] else NA_character_,
        funder_ror = if (length(ror)) paste0("https://ror.org/", ror[1]) else NA_character_,
        award_id = award
      )
    }))
  })
  out <- dplyr::bind_rows(rows)
  if (!nrow(out)) {
    return(tibble::tibble(funder = character(0), funder_doi = character(0),
                          funder_ror = character(0), award_id = character(0)))
  }
  out
}


# A data-availability section: a tagged <sec sec-type="data-availability"> or
# a section, notes or footnote whose title names data availability. Returns
# the section text, or "" when there is none. This records whether the article
# carries the statement at all, separately from whether data were shared.
.get_das_pmc <- function(article_xml) {
  lc <- "translate(%s,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')"
  title_hit <- paste0(
    "contains(", sprintf(lc, "title"), ",'data availab') or ",
    "contains(", sprintf(lc, "title"), ",'availability of data') or ",
    "contains(", sprintf(lc, "title"), ",'data sharing') or ",
    "contains(", sprintf(lc, "title"), ",'data access')"
  )
  xp <- paste(
    ".//sec[@sec-type='data-availability']",
    ".//notes[@notes-type='data-availability']",
    ".//fn[@fn-type='data-availability']",
    paste0(".//sec[", title_hit, "]"),
    paste0(".//notes[", title_hit, "]"),
    sep = " | "
  )
  nodes <- tryCatch(xml2::xml_find_all(article_xml, xp), error = function(e) NULL)
  if (is.null(nodes) || !length(nodes)) return("")
  # Join the section's title and paragraphs with spaces (xml_text() of the
  # whole node would run "Data availability" into the first sentence).
  parts <- xml2::xml_text(xml2::xml_find_all(nodes[[1]], ".//title | .//p"))
  if (!length(parts)) parts <- xml2::xml_text(nodes[[1]])
  trimws(gsub("\\s+", " ", paste(parts, collapse = " ")))
}
