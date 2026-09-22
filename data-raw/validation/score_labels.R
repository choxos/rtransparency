# Score blind labels against detector predictions.
#
# Usage: Rscript score_labels.R <round_dir> <rater1.csv> [rater2.csv]
#
# Rater 1's labels are the reference standard. When a second rater's sheet is
# given, Cohen's kappa is computed on the double-coded rows. Writes
# <round_dir>/results.csv and results.md.

args <- commandArgs(trailingOnly = TRUE)
if (length(args) < 2) stop("usage: score_labels.R <round_dir> <rater1.csv> [rater2.csv]")
dir <- args[1]
pred <- utils::read.csv(file.path(dir, "predictions.csv"), stringsAsFactors = FALSE)
r1 <- utils::read.csv(args[2], stringsAsFactors = FALSE, colClasses = "character")
r2 <- if (length(args) > 2) utils::read.csv(args[3], stringsAsFactors = FALSE,
                                            colClasses = "character") else NULL
lgl <- function(x) {
  x <- toupper(trimws(as.character(x)))
  ifelse(x %in% c("TRUE", "T", "1"), TRUE, ifelse(x %in% c("FALSE", "F", "0"), FALSE, NA))
}
wilson <- function(x, n) {
  if (n == 0) return(c(NA, NA))
  z <- stats::qnorm(0.975); p <- x / n; d <- 1 + z^2 / n
  c(p + z^2 / (2 * n) - z * sqrt(p * (1 - p) / n + z^2 / (4 * n^2)),
    p + z^2 / (2 * n) + z * sqrt(p * (1 - p) / n + z^2 / (4 * n^2))) / d
}
kappa <- function(a, b) {
  ok <- !is.na(a) & !is.na(b); a <- a[ok]; b <- b[ok]
  if (length(a) < 2) return(NA_real_)
  po <- mean(a == b); pe <- mean(a) * mean(b) + mean(!a) * mean(!b)
  if (pe == 1) return(NA_real_)
  (po - pe) / (1 - pe)
}

cols <- setdiff(intersect(names(pred), names(r1)), "pmcid")
rows <- lapply(cols, function(k) {
  g <- lgl(r1[[k]][match(pred$pmcid, r1$pmcid)])
  p <- as.logical(pred[[k]])
  ok <- !is.na(g) & !is.na(p); g <- g[ok]; p <- p[ok]
  tp <- sum(g & p); fn <- sum(g & !p); tn <- sum(!g & !p); fp <- sum(!g & p)
  se <- wilson(tp, tp + fn); sp <- wilson(tn, tn + fp)
  kap <- if (!is.null(r2)) kappa(lgl(r1[[k]][match(r2$pmcid, r1$pmcid)]), lgl(r2[[k]])) else NA
  data.frame(indicator = k, n = sum(ok), tp = tp, fn = fn, tn = tn, fp = fp,
             sensitivity = if (tp + fn) tp / (tp + fn) else NA,
             sens_low = se[1], sens_high = se[2],
             specificity = if (tn + fp) tn / (tn + fp) else NA,
             spec_low = sp[1], spec_high = sp[2],
             ppv = if (tp + fp) tp / (tp + fp) else NA, kappa = kap)
})
res <- do.call(rbind, rows)
utils::write.csv(res, file.path(dir, "results.csv"), row.names = FALSE)
pc <- function(x) ifelse(is.na(x), "NA", sprintf("%.1f", 100 * x))
md <- c("# Blind validation results", "",
        sprintf("Reference: %s. Predictions: %s.", basename(args[2]),
                file.path(dir, "predictions.csv")), "",
        "| Indicator | n | Positives | Sensitivity [95% CI] | Specificity [95% CI] | PPV | Kappa |",
        "|---|---:|---:|---|---|---:|---:|",
        sprintf("| %s | %d | %d | %s [%s, %s] | %s [%s, %s] | %s | %s |",
                res$indicator, res$n, res$tp + res$fn,
                pc(res$sensitivity), pc(res$sens_low), pc(res$sens_high),
                pc(res$specificity), pc(res$spec_low), pc(res$spec_high),
                pc(res$ppv), ifelse(is.na(res$kappa), "", sprintf("%.2f", res$kappa))))
writeLines(md, file.path(dir, "results.md"))
print(res[, c("indicator", "n", "tp", "fn", "tn", "fp", "sensitivity", "specificity", "kappa")])
