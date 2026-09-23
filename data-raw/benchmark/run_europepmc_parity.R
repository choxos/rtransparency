# Europe PMC parity: do the detectors give the same results on Europe PMC's
# JATS XML as on NCBI's?
#
# For each committed benchmark fixture (and the bundled example article), the
# same article is downloaded from the Europe PMC REST API and both versions are
# run through rt_all_pmc(). Every indicator decision and key field is compared.
#
# Run from the repo root: Rscript data-raw/benchmark/run_europepmc_parity.R
# Writes inst/benchmark/results_europepmc_parity.{csv,md}.

suppressMessages(devtools::load_all(".", quiet = TRUE))
fx <- list.files("tests/testthat/fixtures/benchmark", pattern = "^PMC.*xml$",
                 full.names = TRUE)
ncbi <- c(fx, system.file("extdata", "PMID32171256-PMC7071725.xml",
                          package = "rtransparency"))
ids <- c(sub("\\.xml$", "", basename(fx)), "PMC7071725")
dir <- file.path(tempdir(), "europepmc")
got <- rt_fetch_pmc(ids, dir, source = "europepmc", progress = FALSE)

key <- c("is_coi_pred", "is_fund_pred", "is_register_pred", "is_novelty_pred",
         "is_replication_pred", "is_open_data", "is_open_code", "is_ai_pred",
         "is_open_access", "oa_license", "is_reporting_pred",
         "reporting_guideline", "has_das", "pmid", "pmcid_pmc", "doi",
         "year_epub")
rows <- list()
for (i in seq_along(ids)) {
  if (!got$is_success[i]) next
  a <- rt_all_pmc(ncbi[i])
  b <- rt_all_pmc(got$file[i])
  for (k in key) {
    rows[[length(rows) + 1]] <- data.frame(
      pmcid = ids[i], field = k, ncbi = as.character(a[[k]]),
      europepmc = as.character(b[[k]]),
      same = identical(as.character(a[[k]]), as.character(b[[k]])))
  }
}
res <- do.call(rbind, rows)
utils::write.csv(res, "inst/benchmark/results_europepmc_parity.csv", row.names = FALSE)

dec <- res[res$field %in% key[1:12], ]
diff <- res[!res$same, ]
md <- c(
  "# Europe PMC parity",
  "",
  sprintf(paste("Package version %s. %d articles (the benchmark fixtures and the",
                "bundled example) were downloaded from both NCBI PMC and the Europe",
                "PMC REST API and run through `rt_all_pmc()`."),
          utils::packageVersion("rtransparency"), length(unique(res$pmcid))),
  "",
  sprintf("Indicator fields (the ten decisions, license and guideline) identical: %d of %d.", sum(dec$same), nrow(dec)),
  "",
  "Differing fields:",
  "",
  "| PMCID | Field | NCBI | Europe PMC |",
  "|---|---|---|---|",
  if (nrow(diff)) sprintf("| %s | %s | %s | %s |", diff$pmcid, diff$field,
                          diff$ncbi, diff$europepmc) else "| (none) | | | |",
  "",
  paste("Europe PMC omits some license URLs; `oa_license` is then read from the",
        "license text, which can disagree with the URL when the publisher's own",
        "metadata disagree (for example text saying CC BY-NC and a URL saying",
        "CC BY-NC-SA). This is a small sample: it shows the detectors parse",
        "Europe PMC XML, not that their accuracy is identical on it.")
)
writeLines(md, "inst/benchmark/results_europepmc_parity.md")
print(diff)
