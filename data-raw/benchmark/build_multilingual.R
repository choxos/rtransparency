# Multilingual detection benchmark.
#
# Measures conflict-of-interest and funding detection on per-language
# open-access corpora (Spanish, French, German, Italian, Portuguese) from
# PubMed Central. Because these clinical articles almost all carry a COI
# disclosure, the COI detection rate approximates recall; the funding rate is a
# detection rate (funded vs no-funding is not labeled here, and many of these
# articles report no funding).
#
# The corpus is defined by data-raw/benchmark/multilingual_ids.csv (70 articles
# per language, drawn with a fixed seed from PMC's language filter, 2018-2024).
# The first run creates that file if it is absent; later runs reuse it so the
# numbers are comparable across releases. XML is cached under
# data-raw/benchmark/.cache/multilingual/.
#
# Run from the repo root: Rscript data-raw/benchmark/build_multilingual.R
# Writes inst/benchmark/results_multilingual.{csv,md}.

suppressMessages(devtools::load_all(".", quiet = TRUE))

langs <- c(es = "Spanish", fr = "French", de = "German", it = "Italian",
           pt = "Portuguese")
ids_file <- "data-raw/benchmark/multilingual_ids.csv"
cache <- "data-raw/benchmark/.cache/multilingual"

if (!file.exists(ids_file)) {
  draw <- function(code) {
    term <- paste0(tolower(langs[[code]]), '[la] AND "open access"[filter] AND 2018:2024[pdat]')
    uri <- paste0("https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esearch.fcgi?db=pmc",
                  "&retmax=5000&term=", utils::URLencode(term, reserved = TRUE))
    ids <- xml2::xml_text(xml2::xml_find_all(xml2::read_xml(uri), "//Id"))
    Sys.sleep(0.4)
    set.seed(2018)
    data.frame(language = code, pmcid = paste0("PMC", sample(ids, min(70, length(ids)))))
  }
  write.csv(do.call(rbind, lapply(names(langs), draw)), ids_file, row.names = FALSE)
}
ids <- read.csv(ids_file, stringsAsFactors = FALSE)

dict <- .create_synonyms()
detect <- function(f) {
  x <- tryCatch(.get_xml(f), error = function(e) NULL)
  if (is.null(x)) return(c(coi = NA, fund = NA))
  # The XML routes first, on the untouched document, as rt_all_pmc() does:
  # .get_article_txt() removes citation markers and tables in place.
  pmc_coi  <- .get_coi_pmc(x, dict)
  pmc_fund <- .get_fund_pmc(x, dict)
  als  <- .get_article_txt(x)
  coi  <- .rt_coi_pmc(als, pmc_coi, dict)$is_coi_pred
  fund <- .rt_fund_pmc(als, pmc_fund)$is_fund_pred
  c(coi = isTRUE(coi), fund = isTRUE(fund))
}

rows <- list()
for (code in names(langs)) {
  sub <- ids[ids$language == code, ]
  got <- rt_fetch_pmc(sub$pmcid, file.path(cache, code), progress = FALSE)
  files <- got$file[got$is_success & got$has_body %in% TRUE]
  r <- t(vapply(files, detect, logical(2)))
  rows[[code]] <- data.frame(language = langs[[code]], n = nrow(r),
                             coi = round(100 * mean(r[, 1], na.rm = TRUE)),
                             fund = round(100 * mean(r[, 2], na.rm = TRUE)))
}
res <- do.call(rbind, rows)
rownames(res) <- NULL
print(res)
readr::write_csv(res, "inst/benchmark/results_multilingual.csv")

md <- c(
  "# Multilingual detection benchmark",
  "",
  paste0("Package version ", utils::packageVersion("rtransparency"), ". ",
         "Open-access PubMed Central articles per language (up to 70 each, drawn ",
         "with a fixed seed from the PMC language filter, 2018-2024; the list is ",
         "`data-raw/benchmark/multilingual_ids.csv`). The COI detection rate ",
         "approximates recall, as these clinical articles almost all carry a ",
         "disclosure. The funding rate is a detection rate, not recall: many of ",
         "these articles report no funding, which the indicator scores FALSE by ",
         "design. Many articles are bilingual, so the English detector already ",
         "catches some statements."),
  "",
  "| Language | n | COI detected | Funding detected |",
  "|---|---:|---:|---:|",
  sprintf("| %s | %d | %d%% | %d%% |", res$language, res$n, as.integer(res$coi),
          as.integer(res$fund)),
  "")
writeLines(md, "inst/benchmark/results_multilingual.md")
cat("wrote inst/benchmark/results_multilingual.{csv,md}\n")
