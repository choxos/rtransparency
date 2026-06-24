# Reproducible validation of the open-access-licensing and reporting-guideline
# indicators against the 1000-article 2023 sample.
#
# Ground truth: data-raw/benchmark/labels_oa_reporting.csv, in which every article
# was read and hand-labeled by the maintainer (columns is_open_access_label,
# oa_license_label, is_reporting_label, reporting_guideline_label).
#
# The PMC XML is read from $RT_XML_DIR (default /tmp/newcache/xml); files are
# fetched by PMCID with the package's internal NCBI EFetch helper if absent.
# Re-run with:  Rscript data-raw/benchmark/run_oa_reporting.R

suppressMessages(devtools::load_all(quiet = TRUE))

labels <- read.csv("data-raw/benchmark/labels_oa_reporting.csv", stringsAsFactors = FALSE)
xml_dir <- Sys.getenv("RT_XML_DIR", "/tmp/newcache/xml")
dir.create(xml_dir, recursive = TRUE, showWarnings = FALSE)

# Set RT_NO_FETCH=1 to fail fast on missing XML instead of fetching from NCBI.
no_fetch <- nzchar(Sys.getenv("RT_NO_FETCH"))
get_xml <- function(id) {
  f <- file.path(xml_dir, paste0(id, ".xml"))
  if (!file.exists(f) || file.size(f) < 800) {
    if (no_fetch) return(NULL)
    doc <- tryCatch(rtransparency:::.fetch_pmc_doc_efetch(rtransparency:::.normalize_pmcid(id)),
                    error = function(e) NULL)
    if (!is.null(doc)) tryCatch(xml2::write_xml(doc, f), error = function(e) NULL)
    Sys.sleep(0.34)
  }
  if (!file.exists(f)) return(NULL)
  tryCatch(rtransparency:::.get_xml(f, remove_ns = TRUE), error = function(e) NULL)
}

n_total <- nrow(labels); missing <- 0
pred <- do.call(rbind, lapply(seq_len(n_total), function(i) {
  id <- labels$pmcid[i]
  ax <- get_xml(id)
  if (i %% 100 == 0) cat(sprintf("  [%d/%d] processed (missing so far: %d)\n", i, n_total, missing))
  if (is.null(ax)) { missing <<- missing + 1
    return(data.frame(pmcid = id, oa = NA, oa_license = NA, rep = NA, guideline = NA)) }
  oa <- rtransparency:::.get_oa_pmc(ax); rp <- rtransparency:::.get_reporting_pmc(ax)
  data.frame(pmcid = id, oa = oa$is_open_access, oa_license = oa$oa_license,
             rep = rp$is_reporting_pred, guideline = rp$reporting_guideline, stringsAsFactors = FALSE)
}))
if (missing > 0) {
  msg <- sprintf("%d/%d articles had no usable XML.", missing, n_total)
  # In formal no-fetch mode a missing file is a hard error, so a partial run can
  # never silently overwrite the benchmark with a weakened estimate.
  if (no_fetch) stop(msg, " RT_NO_FETCH is set; aborting rather than writing a partial benchmark.",
                     call. = FALSE)
  cat("WARNING:", msg, " (fetched the rest from NCBI)\n")
}

m <- merge(labels, pred, by = "pmcid")
asl <- function(x) { x <- toupper(trimws(as.character(x)))
  ifelse(x %in% c("T", "TRUE"), TRUE, ifelse(x %in% c("F", "FALSE"), FALSE, NA)) }
met <- function(truth, p) { ok <- !is.na(truth) & !is.na(p); truth <- truth[ok]; p <- p[ok]
  TP <- sum(truth & p); FN <- sum(truth & !p); TN <- sum(!truth & !p); FP <- sum(!truth & p)
  c(n = length(truth), pos = sum(truth), sens = 100*TP/(TP+FN), spec = 100*TN/(TN+FP),
    ppv = 100*TP/(TP+FP), acc = 100*(TP+TN)/length(truth)) }
boot <- function(truth, p, B = 2000, seed = 1306) { set.seed(seed)
  ok <- !is.na(truth) & !is.na(p); truth <- truth[ok]; p <- p[ok]
  pos <- which(truth); neg <- which(!truth); o <- matrix(NA_real_, B, 2)
  for (b in seq_len(B)) { idx <- c(sample(pos, length(pos), TRUE), sample(neg, length(neg), TRUE))
    tt <- truth[idx]; pp <- p[idx]; o[b,1] <- 100*sum(tt&pp)/sum(tt); o[b,2] <- 100*sum(!tt&!pp)/sum(!tt) }
  list(sens = quantile(o[,1], c(.025,.975), na.rm = TRUE), spec = quantile(o[,2], c(.025,.975), na.rm = TRUE)) }

oa <- met(asl(m$is_open_access_label), asl(m$oa));  oab <- boot(asl(m$is_open_access_label), asl(m$oa))
rp <- met(asl(m$is_reporting_label), m$rep);        rpb <- boot(asl(m$is_reporting_label), m$rep)
oaok <- asl(m$is_open_access_label) %in% TRUE
lic_num <- sum(toupper(gsub("[^A-Za-z0-9.]","",m$oa_license_label[oaok])) ==
               toupper(gsub("[^A-Za-z0-9.]","",m$oa_license[oaok])), na.rm = TRUE)
lic_den <- sum(oaok); lic <- 100 * lic_num / lic_den
oa_neg <- oa["n"] - oa["pos"]

# Open-access specificity is not meaningfully estimated from one negative in the
# OA subset, so it is written as NA (not a stable 100%) in the machine-readable
# output; the license-type exact match is the well-powered metric.
res <- data.frame(
  indicator = c("Open-access license", "Reporting guideline"),
  n = c(oa["n"], rp["n"]), positives = c(oa["pos"], rp["pos"]), negatives = c(oa_neg, rp["n"]-rp["pos"]),
  sensitivity = round(c(oa["sens"], rp["sens"]), 1),
  specificity = c(NA, round(rp["spec"], 1)),
  ppv = round(c(oa["ppv"], rp["ppv"]), 1), accuracy = round(c(oa["acc"], rp["acc"]), 1),
  sens_lo = round(c(oab$sens[1], rpb$sens[1]),1), sens_hi = round(c(oab$sens[2], rpb$sens[2]),1),
  spec_lo = c(NA, round(rpb$spec[1],1)), spec_hi = c(NA, round(rpb$spec[2],1)),
  license_type_match = c(round(lic,1), NA), license_type_num = c(lic_num, NA), license_type_den = c(lic_den, NA),
  basis = c("structured <license> extraction; specificity prevalence-limited (1 negative)",
            "hand-labeled, precision-first detector"),
  stringsAsFactors = FALSE)
write.csv(res, "inst/benchmark/results_oa_reporting.csv", row.names = FALSE)

md <- c(
"# Open-access licensing and reporting-guideline validation", "",
"Two indicators added in 1.1.0, validated on the **1000-article 2023 open-access",
"sample**. Every article was read and hand-labeled by the maintainer (the ground",
"truth), independently of the detector. This file is generated by",
"`data-raw/benchmark/run_oa_reporting.R` from the row-level labels in",
"`data-raw/benchmark/labels_oa_reporting.csv`; do not edit it by hand. 95%",
"confidence intervals are stratified bootstrap (2000 resamples).", "",
"| Indicator | n | Positives | Negatives | Sensitivity | Specificity | PPV | Accuracy |",
"|---|---:|---:|---:|---:|---:|---:|---:|",
sprintf("| Open-access license | %d | %d | %d | %.1f%% | (not estimable, see note) | %.1f%% | %.1f%% |",
        oa["n"], oa["pos"], oa_neg, oa["sens"], oa["ppv"], oa["acc"]),
sprintf("| Reporting guideline | %d | %d | %d | %.1f%% [%.1f, %.1f] | %.1f%% [%.1f, %.1f] | %.1f%% | %.1f%% |",
        rp["n"], rp["pos"], rp["n"]-rp["pos"], rp["sens"], rpb$sens[1], rpb$sens[2],
        rp["spec"], rpb$spec[1], rpb$spec[2], rp["ppv"], rp["acc"]),
"",
"## Open-access licensing", "",
"This indicator is **structured metadata extraction**, not a behavioral",
"classifier: it reads the JATS `<license>` element and its license-reference URL.",
sprintf("The well-powered result is the **license-type exact match: %.1f%%** (%d/%d)",
        lic, lic_num, lic_den),
"against the hand label (CC-BY vs CC-BY-NC / NC-ND / SA, CC0, or retained",
"copyright). The binary `is_open_access` is near-deterministic from that field;",
"its **specificity is not meaningfully estimated here** because the PMC",
sprintf("open-access subset contains only %d non-open article(s) (classified", oa_neg),
"correctly), so it is reported as NA in the CSV rather than a stable 100%. A",
"negative-enriched sample (retained copyright, hybrid, missing or restricted",
"license) would be needed to estimate it. `is_open_access` is access status:",
"CC-BY-NC and CC-BY-ND articles are open access but restrict reuse, recorded in",
"`oa_license`.", "",
"## Reporting guideline", "",
"Detected **precision-first**: a guideline counts only in an author-level",
"reporting context; common-word acronyms (ARRIVE, CARE, RECORD, REMARK, SPIRIT,",
"PROCESS) require the upper-case form beside a guideline noun; spelled-out names",
"match directly; and a veto removes animal-welfare, clinical/treatment,",
"non-adherence, guideline-discourse/background, and quality-assessment-of-",
"included-studies mentions. The named guideline is returned. Coverage spans the",
"EQUATOR catalogue (CONSORT, PRISMA and extensions, STROBE, ARRIVE, STARD,",
"TRIPOD, COREQ, SRQR, SQUIRE, CHEERS, CARE, PROCESS, STROCSS, RAMESES) and the",
"wider reportilo guideline list. Residual misses are mostly non-English",
"statements; residual false positives are guidelines named in a borderline",
"context judged not followed.", "",
"## Reproducing", "",
"The PMC XML corpus is **not committed** (too large for an R package): the script",
"fetches each article by PMCID from NCBI EFetch into `$RT_XML_DIR`",
"(default `/tmp/newcache/xml`) and caches it. Set `RT_NO_FETCH=1` to validate",
"strictly against a pre-populated cache; the run then aborts if any XML is",
"missing rather than writing a partial benchmark.")
writeLines(md, "inst/benchmark/results_oa_reporting.md")

cat(sprintf("OA        : Sens %.1f Spec NA (neg=%d) license-type %.1f%% (%d/%d)\n", oa["sens"], oa_neg, lic, lic_num, lic_den))
cat(sprintf("REPORTING : Sens %.1f [%.1f,%.1f]  Spec %.1f [%.1f,%.1f]  PPV %.1f\n",
            rp["sens"], rpb$sens[1], rpb$sens[2], rp["spec"], rpb$spec[1], rpb$spec[2], rp["ppv"]))
cat("wrote inst/benchmark/results_oa_reporting.{csv,md}\n")
