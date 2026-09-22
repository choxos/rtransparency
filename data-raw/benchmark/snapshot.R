# Prediction snapshots: a regression harness for detector changes.
#
# Runs rt_all_pmc() over every cached PMC XML and stores the full output, so a
# detector change can be diffed article by article against a previous snapshot
# instead of only through aggregate metrics. A behavior-preserving change
# (refactor, speedup, dead-code removal) must produce an identical snapshot; a
# detection change must explain every row it flips.
#
# Usage, from the repo root (or with RT_PKG_DIR pointing at another checkout):
#
#   Rscript data-raw/benchmark/snapshot.R run out.rds [xml_dir ...]
#   Rscript data-raw/benchmark/snapshot.R compare before.rds after.rds
#   Rscript data-raw/benchmark/snapshot.R export snapshot.rds out.csv
#   Rscript data-raw/benchmark/snapshot.R check predictions_snapshot.csv [xml_dir]
#
# `run` defaults to data-raw/benchmark/.cache and the committed test fixtures.
# Set RT_CORES to control parallelism (forked workers; default: cores - 1).
# `export` writes the compact per-article prediction table committed as
# data-raw/benchmark/predictions_snapshot.csv. `check` re-runs the detectors on
# the articles in such a table (XML from xml_dir, default the benchmark cache)
# and exits with an error if any decision changed: the regression gate the
# benchmark workflow runs. Regenerate the table deliberately (run + export)
# when a detection change is intended, and explain the flips in the commit.

args <- commandArgs(trailingOnly = TRUE)
if (!length(args)) stop("usage: snapshot.R run|compare|export ...", call. = FALSE)

# Columns that carry a detector decision (the compact, committed view).
key_cols <- c(
  "is_coi_pred", "is_fund_pred", "is_register_pred", "is_novelty_pred",
  "is_replication_pred", "is_open_data", "is_open_code", "is_ai_pred",
  "is_open_access", "oa_license", "is_reporting_pred", "reporting_guideline"
)

if (args[1] == "run") {
  out <- args[2]
  dirs <- if (length(args) > 2) args[-(1:2)] else
    c("data-raw/benchmark/.cache", "tests/testthat/fixtures/benchmark")
  files <- unlist(lapply(normalizePath(dirs), list.files,
                         pattern = "^PMC[0-9]+\\.xml$", full.names = TRUE))
  pkg <- Sys.getenv("RT_PKG_DIR", ".")
  suppressMessages(pkgload::load_all(pkg, quiet = TRUE))
  files <- files[!duplicated(basename(files))]
  files <- files[file.info(files)$size > 0]
  cores <- as.integer(Sys.getenv("RT_CORES", max(1, parallel::detectCores() - 1)))
  message(sprintf("snapshot: %d files, %d cores, package at %s",
                  length(files), cores, normalizePath(pkg)))
  t0 <- Sys.time()
  rows <- parallel::mclapply(files, function(f) {
    r <- tryCatch(rt_all_pmc(f, remove_ns = TRUE), error = function(e)
      tibble::tibble(is_success = FALSE, error = conditionMessage(e)))
    r <- dplyr::mutate(r, dplyr::across(dplyr::everything(), as.character))
    r$pmcid <- sub("\\.xml$", "", basename(f))
    r$filename <- NULL
    r
  }, mc.cores = cores, mc.preschedule = FALSE)
  snap <- dplyr::bind_rows(rows)
  snap <- snap[order(snap$pmcid), c("pmcid", setdiff(names(snap), "pmcid"))]
  saveRDS(snap, out)
  message(sprintf("snapshot: wrote %s (%d rows, %d columns) in %.1f min",
                  out, nrow(snap), ncol(snap),
                  as.numeric(difftime(Sys.time(), t0, units = "mins"))))

} else if (args[1] == "compare") {
  a <- readRDS(args[2])
  b <- readRDS(args[3])
  ids <- intersect(a$pmcid, b$pmcid)
  message(sprintf("compare: %d shared articles (%d only before, %d only after)",
                  length(ids), length(setdiff(a$pmcid, ids)),
                  length(setdiff(b$pmcid, ids))))
  a <- a[match(ids, a$pmcid), ]
  b <- b[match(ids, b$pmcid), ]
  gone <- setdiff(names(a), names(b))
  new <- setdiff(names(b), names(a))
  if (length(gone)) message("columns removed: ", paste(gone, collapse = ", "))
  if (length(new)) message("columns added: ", paste(new, collapse = ", "))
  same <- TRUE
  for (col in intersect(names(a), names(b))) {
    x <- a[[col]]
    y <- b[[col]]
    diff <- !((is.na(x) & is.na(y)) | (!is.na(x) & !is.na(y) & x == y))
    if (any(diff)) {
      same <- FALSE
      flag <- if (col %in% key_cols) " [decision]" else ""
      cat(sprintf("%-28s %5d changed%s\n", col, sum(diff), flag))
      if (col %in% key_cols) {
        tab <- table(before = x[diff], after = y[diff], useNA = "ifany")
        print(tab)
        cat("  e.g. ", paste(utils::head(ids[diff], 8), collapse = " "), "\n")
      }
    }
  }
  if (same && !length(gone) && !length(new)) cat("IDENTICAL\n")

} else if (args[1] == "export") {
  s <- readRDS(args[2])
  s <- s[, intersect(c("pmcid", key_cols), names(s))]
  utils::write.csv(s, args[3], row.names = FALSE, na = "")
  message("export: wrote ", args[3])

} else if (args[1] == "check") {
  ref <- utils::read.csv(args[2], colClasses = "character", na.strings = "")
  dir <- if (length(args) > 2) args[3] else "data-raw/benchmark/.cache"
  suppressMessages(pkgload::load_all(Sys.getenv("RT_PKG_DIR", "."), quiet = TRUE))
  files <- file.path(dir, paste0(ref$pmcid, ".xml"))
  if (!all(file.exists(files))) {
    stop(sum(!file.exists(files)), " articles have no XML in ", dir, call. = FALSE)
  }
  cores <- as.integer(Sys.getenv("RT_CORES", max(1, parallel::detectCores() - 1)))
  now <- dplyr::bind_rows(parallel::mclapply(files, function(f) {
    r <- rt_all_pmc(f)
    r <- dplyr::mutate(r, dplyr::across(dplyr::everything(), as.character))
    r[intersect(key_cols, names(r))]
  }, mc.cores = cores))
  bad <- 0L
  for (col in intersect(key_cols, names(ref))) {
    x <- ref[[col]]
    y <- now[[col]]
    x[is.na(x)] <- ""
    y[is.na(y)] <- ""
    d <- which(x != y)
    if (length(d)) {
      bad <- bad + length(d)
      cat(sprintf("%s: %d changed, e.g. %s\n", col, length(d),
                  paste(utils::head(ref$pmcid[d], 5), collapse = " ")))
    }
  }
  if (bad) stop(bad, " prediction(s) differ from ", args[2], call. = FALSE)
  cat("No prediction changed on", nrow(ref), "articles.\n")

} else {
  stop("unknown mode: ", args[1], call. = FALSE)
}
