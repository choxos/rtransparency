# Score the detectors against the committed 2023 OA PMC hand-labeled sample
# (eight indicators) and write the accuracy report. Run from the package root
# after editing detectors.
#
# The labels were assigned by reading the article text. For COI, funding and
# data the author's back matter was sometimes truncated in the labelling view
# and the label was reconciled against the detector's extracted statement; those
# three are therefore NOT independent of the detector (their agreement is near
# ceiling by construction). Novelty, replication, registration and code sharing
# were labelled independently and are the meaningful validation.
suppressMessages(devtools::load_all("."))

# The labels are committed; this script only scores the current detectors
# against them (it never rewrites the label file).
xml_dir <- Sys.getenv("RT_XML_DIR", "data-raw/benchmark/.cache")
gold  <- read.csv("data-raw/benchmark/labels_2023_sample.csv",
                  stringsAsFactors = FALSE, colClasses = "character")
inds  <- c("coi", "fund", "reg", "nov", "rep", "data", "code", "ai")
missing <- sum(!file.exists(file.path(xml_dir, paste0(gold$pmcid, ".xml"))))
if (missing) stop(missing, " labeled articles have no XML in ", xml_dir,
                  "; fetch them first (see data-raw/benchmark/README.md).")

# Predictions from the current detectors.
pred <- as.data.frame(matrix(NA, nrow(gold), length(inds),
                             dimnames = list(NULL, inds)))
for (i in seq_len(nrow(gold))) {
  f <- file.path(xml_dir, paste0(gold$pmcid[i], ".xml"))
  if (!file.exists(f)) next
  a <- tryCatch(rt_all_pmc(f), error = function(e) NULL)
  d <- tryCatch(rt_data_code_pmc(f), error = function(e) NULL)
  if (!is.null(a) && isTRUE(a$is_success[1])) {
    pred$coi[i]  <- isTRUE(a$is_coi_pred[1]);  pred$fund[i] <- isTRUE(a$is_fund_pred[1])
    pred$reg[i]  <- isTRUE(a$is_register_pred[1]); pred$nov[i] <- isTRUE(a$is_novelty_pred[1])
    pred$rep[i]  <- isTRUE(a$is_replication_pred[1])
    pred$ai[i]   <- if (is.na(a$is_ai_pred[1])) NA else isTRUE(a$is_ai_pred[1])
  }
  if (!is.null(d)) { pred$data[i] <- isTRUE(d$is_open_data[1]); pred$code[i] <- isTRUE(d$is_open_code[1]) }
}

g2 <- function(v) { v <- toupper(v); ifelse(v == "NA", NA, v == "T") }
metr <- function(g, p) {
  ok <- !is.na(g) & !is.na(p); g <- g[ok]; p <- p[ok]
  TP <- sum(g & p); FP <- sum(!g & p); FN <- sum(g & !p); TN <- sum(!g & !p)
  data.frame(n = TP + FP + FN + TN, pos = TP + FN,
             sens = round(100 * TP / (TP + FN), 1),
             spec = round(100 * TN / (TN + FP), 1),
             ppv  = round(100 * TP / max(TP + FP, 1), 1),
             acc  = round(100 * (TP + TN) / (TP + FP + FN + TN), 1),
             TP = TP, FP = FP, FN = FN, TN = TN)
}
res <- do.call(rbind, lapply(inds, function(i) cbind(indicator = i, metr(g2(gold[[i]]), pred[[i]]))))
independent <- c("nov", "rep", "reg", "code")
res$labels <- ifelse(res$indicator %in% independent, "independent", "detector-adjudicated")
write.csv(res, "inst/benchmark/results_2023_sample.csv", row.names = FALSE)

md <- c(
  "# Independent 2023 OA PMC hand-labeled sample",
  "",
  sprintf("Package version %s. %d open-access PMC articles published in 2023, sampled",
          as.character(utils::packageVersion("rtransparency")), nrow(gold)),
  "and hand-labeled for all eight transparency indicators. This is a modern,",
  "independent companion to the Serghiou et al. (2021) held-out set (which",
  "predates these indicators and the 2023-era reporting conventions).",
  "",
  "**Methods note.** Conflicts of interest, funding and data labels were",
  "reconciled against the detector's extracted statement where the author's back",
  "matter was truncated in the labelling view, so those three are *not*",
  "independent of the detector and their agreement is near ceiling by",
  "construction. Novelty, replication, registration and code sharing were",
  "labelled independently and are the meaningful validation.",
  "",
  "| Indicator | Labels | n | pos | Sens | Spec | PPV | Acc |",
  "|---|---|---|---|---|---|---|---|",
  apply(res, 1, function(r) sprintf("| %s | %s | %s | %s | %s | %s | %s | %s |",
        r["indicator"], r["labels"], r["n"], r["pos"], r["sens"], r["spec"], r["ppv"], r["acc"]))
)
writeLines(md, "inst/benchmark/results_2023_sample.md")
message("wrote inst/benchmark/results_2023_sample.{csv,md}")
print(res[, c("indicator","labels","pos","sens","spec","ppv")])
