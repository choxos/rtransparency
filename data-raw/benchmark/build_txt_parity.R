# TXT-parity benchmark.
#
# The plain-text detectors have no gold standard of their own. This script
# derives one from the 1000 hand-labeled 2023 PMC XML articles: it extracts the
# article text the PMC path sees, runs rt_all() on it as plain text, runs
# rt_all_pmc() on the XML, and scores both against the same labels
# (labels_2023_sample.csv for eight indicators, labels_oa_reporting.csv for
# reporting guidelines). The gap between the two columns is what the XML-only
# routes (section titles, funding tags, footnote types) contribute.
#
# Run from the repo root: Rscript data-raw/benchmark/build_txt_parity.R
# Reads data-raw/benchmark/.cache/<pmcid>.xml ($RT_XML_DIR to override).
# Writes inst/benchmark/results_txt_parity.{md,csv}. Set RT_CORES for workers.

suppressMessages(devtools::load_all(".", quiet = TRUE))

xml_dir <- Sys.getenv("RT_XML_DIR", "data-raw/benchmark/.cache")
lab <- read.csv("data-raw/benchmark/labels_2023_sample.csv", colClasses = "character")
rep_lab <- read.csv("data-raw/benchmark/labels_oa_reporting.csv", colClasses = "character")
lab$reporting <- rep_lab$is_reporting_label[match(lab$pmcid, rep_lab$pmcid)]

cols <- c(coi = "is_coi_pred", fund = "is_fund_pred", reg = "is_register_pred",
          nov = "is_novelty_pred", rep = "is_replication_pred",
          data = "is_open_data", code = "is_open_code", ai = "is_ai_pred",
          reporting = "is_reporting_pred")

one <- function(id) {
  f <- file.path(xml_dir, paste0(id, ".xml"))
  x <- tryCatch(.get_xml(f), error = function(e) NULL)
  if (is.null(x)) return(NULL)
  txt <- paste(unlist(.get_article_txt(x)), collapse = "\n")
  t <- rt_all(text = txt)
  p <- rt_all_pmc(f)
  data.frame(pmcid = id, source = c("txt", "pmc"),
             rbind(unlist(t[cols]), unlist(p[cols])), check.names = FALSE)
}
cores <- as.integer(Sys.getenv("RT_CORES", max(1, parallel::detectCores() - 1)))
pred <- do.call(rbind, parallel::mclapply(lab$pmcid, one, mc.cores = cores))

lgl <- function(x) {
  x <- toupper(trimws(as.character(x)))
  ifelse(x %in% c("T", "TRUE"), TRUE, ifelse(x %in% c("F", "FALSE"), FALSE, NA))
}
metric <- function(truth, p) {
  ok <- !is.na(truth) & !is.na(p); truth <- truth[ok]; p <- p[ok]
  tp <- sum(truth & p); fp <- sum(!truth & p); fn <- sum(truth & !p); tn <- sum(!truth & !p)
  c(n = length(truth), pos = tp + fn,
    sens = round(100 * tp / max(tp + fn, 1), 1),
    spec = round(100 * tn / max(tn + fp, 1), 1),
    ppv = round(100 * tp / max(tp + fp, 1), 1))
}
res <- do.call(rbind, lapply(names(cols), function(k) {
  truth <- lgl(lab[[k]])
  get <- function(src) {
    d <- pred[pred$source == src, ]
    as.logical(d[[cols[[k]]]][match(lab$pmcid, d$pmcid)])
  }
  t <- metric(truth, get("txt")); p <- metric(truth, get("pmc"))
  data.frame(indicator = k, n = t[["n"]], pos = t[["pos"]],
             txt_sens = t[["sens"]], txt_spec = t[["spec"]], txt_ppv = t[["ppv"]],
             pmc_sens = p[["sens"]], pmc_spec = p[["spec"]])
}))
print(res)
readr::write_csv(res, "inst/benchmark/results_txt_parity.csv")

md <- c(
  "# TXT-parity benchmark",
  "",
  paste0("Package version ", utils::packageVersion("rtransparency"), ". Derived from ",
         "the ", nrow(lab), " hand-labeled 2023 PMC articles: each article's text is ",
         "extracted and scored with `rt_all()` as plain text, and the XML with ",
         "`rt_all_pmc()`, against the same labels. A plain-text file has no XML ",
         "structure, so the XML-only routes (section titles, funding tags, footnote ",
         "types) are unavailable to it; the gap between the columns is their value. ",
         "Conflict-of-interest, funding, data and AI labels were reconciled against ",
         "the PMC detector's output (see `results_2023_sample.md`), which favors the ",
         "PMC column for those rows."),
  "",
  "| Indicator | n | Positives | TXT sens | TXT spec | TXT PPV | PMC sens | PMC spec |",
  "|---|---:|---:|---:|---:|---:|---:|---:|",
  sprintf("| %s | %d | %d | %.1f | %.1f | %.1f | %.1f | %.1f |", res$indicator,
          as.integer(res$n), as.integer(res$pos), res$txt_sens, res$txt_spec,
          res$txt_ppv, res$pmc_sens, res$pmc_spec),
  ""
)
writeLines(md, "inst/benchmark/results_txt_parity.md")
message("wrote inst/benchmark/results_txt_parity.{csv,md}")
