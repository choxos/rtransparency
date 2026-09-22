# Build blind labeling sheets for a drawn sample.
#
# Usage: Rscript make_label_sheet.R <sample.csv> <round_dir>
#
# Downloads each article's PMC XML into <round_dir>/xml, runs the detectors,
# and writes:
#   <round_dir>/label_sheet.csv   blank sheet for the raters (no predictions)
#   <round_dir>/predictions.csv   detector output, kept away from the raters
# A random 20% of the rows are marked double_code = TRUE for a second rater.

args <- commandArgs(trailingOnly = TRUE)
if (length(args) < 2) stop("usage: make_label_sheet.R <sample.csv> <round_dir>")
suppressMessages(devtools::load_all(".", quiet = TRUE))
smp <- utils::read.csv(args[1], stringsAsFactors = FALSE)
dir <- args[2]
dir.create(file.path(dir, "xml"), recursive = TRUE, showWarnings = FALSE)

got <- rt_fetch_pmc(smp$pmcid, file.path(dir, "xml"))
ok <- got$is_success & got$has_body %in% TRUE
message(sum(ok), " of ", nrow(got), " articles have full text")

pred <- dplyr::bind_rows(lapply(got$file[ok], function(f) {
  a <- rt_all_pmc(f)
  e <- rt_ethics_pmc(f)
  tibble::tibble(
    pmcid = sub("\\.xml$", "", basename(f)),
    coi = a$is_coi_pred, fund = a$is_fund_pred, reg = a$is_register_pred,
    nov = a$is_novelty_pred, rep = a$is_replication_pred,
    data = a$is_open_data, code = a$is_open_code, ai = a$is_ai_pred,
    ai_used = a$ai_used, reporting = a$is_reporting_pred,
    ethics = e$is_ethics_pred, consent = e$is_consent_pred
  )
}))
utils::write.csv(pred, file.path(dir, "predictions.csv"), row.names = FALSE)

set.seed(2026)
cols <- setdiff(names(pred), "pmcid")
sheet <- data.frame(pmcid = pred$pmcid,
                    pmc_url = paste0("https://pmc.ncbi.nlm.nih.gov/articles/", pred$pmcid, "/"),
                    double_code = seq_len(nrow(pred)) %in%
                      sample.int(nrow(pred), ceiling(0.2 * nrow(pred))))
for (k in cols) sheet[[k]] <- ""
sheet$notes <- ""
sheet <- sheet[sample.int(nrow(sheet)), ]  # shuffle, so order carries no signal
utils::write.csv(sheet, file.path(dir, "label_sheet.csv"), row.names = FALSE)
message("wrote ", file.path(dir, "label_sheet.csv"), " and predictions.csv")
