# Score a prediction snapshot against every labeled set in one pass.
#
# Usage, from the repo root:
#
#   Rscript data-raw/benchmark/evaluate.R snapshot.rds [out.csv]
#
# The snapshot comes from snapshot.R (rt_all_pmc() over the cached XML). Each
# labeled set is scored on the articles it shares with the snapshot:
#
#   heldout  Serghiou et al. (2021) held-out test labels (COI, funding,
#            registration; data and code from the data/code spreadsheets).
#            Needs the OSF data under paper/ and the readxl package; skipped
#            when absent.
#   s2023    The 1000-article 2023 sample (labels_2023_sample.csv).
#   novrep   The novelty/replication gold set (labels_novelty_replication.csv).
#   repenr   The replication-enriched sample (labels_replication_enriched.csv).
#   oarep    Open-access and reporting-guideline labels (labels_oa_reporting.csv).
#
# This is the fast development loop: take a snapshot before and after a
# detector change and compare the two tables. The per-indicator scripts
# (run_all.R, run_data_code.R, ...) regenerate the published inst/benchmark
# reports.

args <- commandArgs(trailingOnly = TRUE)
if (!length(args)) stop("usage: evaluate.R snapshot.rds [out.csv]", call. = FALSE)
snap <- readRDS(args[1])

lgl <- function(x) {
  x <- toupper(trimws(as.character(x)))
  ifelse(x %in% c("T", "TRUE", "1"), TRUE, ifelse(x %in% c("F", "FALSE", "0"), FALSE, NA))
}

score <- function(set, indicator, pmcid, label, pred_col) {
  i <- match(pmcid, snap$pmcid)
  pred <- lgl(snap[[pred_col]][i])
  ok <- !is.na(i) & !is.na(label) & !is.na(pred)
  g <- label[ok]
  p <- pred[ok]
  tp <- sum(g & p); fp <- sum(!g & p); fn <- sum(g & !p); tn <- sum(!g & !p)
  pct <- function(a, b) if (b > 0) round(100 * a / b, 1) else NA_real_
  data.frame(set = set, indicator = indicator, n = sum(ok), pos = tp + fn,
             TP = tp, FP = fp, FN = fn, TN = tn,
             sens = pct(tp, tp + fn), spec = pct(tn, tn + fp),
             ppv = pct(tp, tp + fp), acc = pct(tp + tn, sum(ok)))
}

rows <- list()
add <- function(...) rows[[length(rows) + 1]] <<- score(...)

s <- read.csv("data-raw/benchmark/labels_2023_sample.csv", colClasses = "character")
map <- c(coi = "is_coi_pred", fund = "is_fund_pred", reg = "is_register_pred",
         nov = "is_novelty_pred", rep = "is_replication_pred",
         data = "is_open_data", code = "is_open_code", ai = "is_ai_pred")
for (k in names(map)) add("s2023", k, s$pmcid, lgl(s[[k]]), map[[k]])

nr <- read.csv("data-raw/benchmark/labels_novelty_replication.csv")
add("novrep", "nov", nr$pmcid, lgl(nr$is_novelty), "is_novelty_pred")
add("novrep", "rep", nr$pmcid, lgl(nr$is_replication), "is_replication_pred")

re <- read.csv("data-raw/benchmark/labels_replication_enriched.csv")
add("repenr", "rep", re$pmcid, lgl(re$is_replication), "is_replication_pred")

oa <- read.csv("data-raw/benchmark/labels_oa_reporting.csv")
add("oarep", "oa", oa$pmcid, lgl(oa$is_open_access_label), "is_open_access")
add("oarep", "reporting", oa$pmcid, lgl(oa$is_reporting_label), "is_reporting_pred")

tidy <- "paper/osf_data/3_algorithm-validation/data/tidy_data"
if (dir.exists(tidy) && requireNamespace("readxl", quietly = TRUE)) {
  rd <- function(f, label) {
    d <- as.data.frame(readxl::read_excel(file.path(tidy, f)))
    keep <- lgl(d$is_test) %in% TRUE & (if ("is_xml" %in% names(d)) lgl(d$is_xml) %in% TRUE else TRUE)
    pm <- ifelse(grepl("PMC[0-9]+", d$article),
                 sub(".*(PMC[0-9]+).*", "\\1", d$article), NA)
    out <- data.frame(pmcid = pm, label = lgl(d[[label]]), stringsAsFactors = FALSE)
    out[keep & !is.na(out$pmcid), ]
  }
  for (x in list(c("coi", "isCOI"), c("fund", "isFunding"), c("register", "is_register"))) {
    d <- rbind(rd(paste0(x[1], "_true.xlsx"), x[2]), rd(paste0(x[1], "_false.xlsx"), x[2]))
    d <- d[!is.na(d$label), ]
    col <- c(coi = "is_coi_pred", fund = "is_fund_pred", register = "is_register_pred")[[x[1]]]
    add("heldout", x[1], d$pmcid, d$label, col)
  }
  # Data and code: an article is positive if any of its labeled rows is.
  rdc <- function(f) {
    d <- as.data.frame(readxl::read_excel(file.path(tidy, f)))
    pm <- ifelse(grepl("PMC[0-9]+", d$article), sub(".*(PMC[0-9]+).*", "\\1", d$article), NA)
    data.frame(pmcid = pm,
               isData = if ("isData" %in% names(d)) lgl(d$isData) else NA,
               isCode = if ("isCode" %in% names(d)) lgl(d$isCode) else NA,
               is_test = lgl(d$is_test))
  }
  d <- rbind(rdc("data_true.xlsx"), rdc("data_false.xlsx"), rdc("code_true.xlsx"))
  d <- d[d$is_test %in% TRUE & !is.na(d$pmcid), ]
  agg <- function(x) if (all(is.na(x))) NA else any(x, na.rm = TRUE)
  ids <- unique(d$pmcid)
  add("heldout", "data", ids, vapply(ids, function(p) agg(d$isData[d$pmcid == p]), NA), "is_open_data")
  add("heldout", "code", ids, vapply(ids, function(p) agg(d$isCode[d$pmcid == p]), NA), "is_open_code")
}

res <- do.call(rbind, rows)
print(res, row.names = FALSE)
if (length(args) > 1) utils::write.csv(res, args[2], row.names = FALSE)
