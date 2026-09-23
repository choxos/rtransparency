# Package index

## Package

- [`rtransparency`](https://choxos.github.io/rtransparency/reference/rtransparency-package.md)
  [`rtransparency-package`](https://choxos.github.io/rtransparency/reference/rtransparency-package.md)
  : rtransparency: Identify indicators of transparency in the biomedical
  literature

## Run all detectors

Detect every indicator in one pass, for one file or a whole corpus.

- [`rt_all()`](https://choxos.github.io/rtransparency/reference/rt_all.md)
  : Identify and extract all transparency indicators from a TXT file.
- [`rt_all_pdf()`](https://choxos.github.io/rtransparency/reference/rt_all_pdf.md)
  : Identify and extract all transparency indicators from a PDF file.
- [`rt_all_pmc()`](https://choxos.github.io/rtransparency/reference/rt_all_pmc.md)
  : Identify and extract all transparency indicators from a PMC XML.
- [`rt_all_pmc_dir()`](https://choxos.github.io/rtransparency/reference/rt_all_pmc_dir.md)
  : Identify transparency indicators across many PMC XML files.
- [`rt_all_txt_dir()`](https://choxos.github.io/rtransparency/reference/rt_all_txt_dir.md)
  : Identify transparency indicators across many TXT or PDF files.

## Individual indicators (PMC XML)

One detector per indicator, for PMC JATS XML files.

- [`rt_coi_pmc()`](https://choxos.github.io/rtransparency/reference/rt_coi_pmc.md)
  : Identify and extract Conflicts of Interest (COI) statements in PMC
  XML files.
- [`rt_fund_pmc()`](https://choxos.github.io/rtransparency/reference/rt_fund_pmc.md)
  : Identify and extract Funding statements in PMC XML files.
- [`rt_register_pmc()`](https://choxos.github.io/rtransparency/reference/rt_register_pmc.md)
  : Identify and extract Conflicts of Interest statements in PMC XML
  files.
- [`rt_novelty_pmc()`](https://choxos.github.io/rtransparency/reference/rt_novelty_pmc.md)
  : Identify and extract novelty claims in PMC XML files.
- [`rt_replication_pmc()`](https://choxos.github.io/rtransparency/reference/rt_replication_pmc.md)
  : Identify and extract replication components in PMC XML files.
- [`rt_data_code_pmc()`](https://choxos.github.io/rtransparency/reference/rt_data_code_pmc.md)
  : Identify and extract Data and Code sharing from PMC XML files.
- [`rt_data_code_pmc_list()`](https://choxos.github.io/rtransparency/reference/rt_data_code_pmc_list.md)
  : Identify and extract Data and Code sharing from a list of PMC XML
  files.
- [`rt_ai_pmc()`](https://choxos.github.io/rtransparency/reference/rt_ai_pmc.md)
  : Identify disclosure of generative-AI use from a PMC XML file.
- [`rt_oa_pmc()`](https://choxos.github.io/rtransparency/reference/rt_oa_pmc.md)
  : Identify the open-access status and reuse license of a PMC XML file.
- [`rt_reporting_pmc()`](https://choxos.github.io/rtransparency/reference/rt_reporting_pmc.md)
  : Identify use of a reporting guideline from a PMC XML file.

## Individual indicators (text)

One detector per indicator, for plain-text (PDF-derived) files.

- [`rt_coi()`](https://choxos.github.io/rtransparency/reference/rt_coi.md)
  : Identify and extract Conflicts of Interest (COI) statements in TXT
  files.
- [`rt_fund()`](https://choxos.github.io/rtransparency/reference/rt_fund.md)
  : Identify and extract Funding statements in TXT files.
- [`rt_register()`](https://choxos.github.io/rtransparency/reference/rt_register.md)
  : Identify and extract Registration statements in TXT files.
- [`rt_novelty()`](https://choxos.github.io/rtransparency/reference/rt_novelty.md)
  : Identify whether a study claims novelty in TXT files.
- [`rt_replication()`](https://choxos.github.io/rtransparency/reference/rt_replication.md)
  : Identify whether a study includes a replication component in TXT
  files.
- [`rt_data_code()`](https://choxos.github.io/rtransparency/reference/rt_data_code.md)
  : Identify and extract Data and Code statements in TXT files.
- [`rt_ai()`](https://choxos.github.io/rtransparency/reference/rt_ai.md)
  : Identify disclosure of generative-AI use from a TXT file.
- [`rt_oa()`](https://choxos.github.io/rtransparency/reference/rt_oa.md)
  : Identify the open-access status and reuse license from a TXT file.
- [`rt_reporting()`](https://choxos.github.io/rtransparency/reference/rt_reporting.md)
  : Identify use of a reporting guideline from a TXT file.

## Get articles

Download PMC full text, convert identifiers and read PDFs.

- [`rt_fetch_pmc()`](https://choxos.github.io/rtransparency/reference/rt_fetch_pmc.md)
  : Download PubMed Central full-text XML
- [`rt_convert_ids()`](https://choxos.github.io/rtransparency/reference/rt_convert_ids.md)
  : Convert article identifiers with the PMC ID Converter
- [`rt_read_pdf()`](https://choxos.github.io/rtransparency/reference/rt_read_pdf.md)
  : Convert a PDF file to text.

## Structured metadata (PMC XML)

Tagged JATS metadata read directly, not detected from prose.

- [`rt_meta_pmc()`](https://choxos.github.io/rtransparency/reference/rt_meta_pmc.md)
  : Extract article metadata from a PMC XML file.
- [`rt_authors_pmc()`](https://choxos.github.io/rtransparency/reference/rt_authors_pmc.md)
  : Author identifiers and contribution roles from a PMC XML file.
- [`rt_funders_pmc()`](https://choxos.github.io/rtransparency/reference/rt_funders_pmc.md)
  : Funders, funder identifiers and award numbers from a PMC XML file.

## Follow-up checks

Go beyond presence of a statement, using registries, PubMed and the web.

- [`rt_trial_ids()`](https://choxos.github.io/rtransparency/reference/rt_trial_ids.md)
  : Extract trial and review registration identifiers from text
- [`rt_registration_timing()`](https://choxos.github.io/rtransparency/reference/rt_registration_timing.md)
  : Check whether ClinicalTrials.gov registrations were prospective
- [`rt_coi_pubmed()`](https://choxos.github.io/rtransparency/reference/rt_coi_pubmed.md)
  : Fetch conflict-of-interest statements recorded in PubMed
- [`rt_fill_coi_pubmed()`](https://choxos.github.io/rtransparency/reference/rt_fill_coi_pubmed.md)
  : Fill missed conflict-of-interest disclosures from PubMed
- [`rt_check_links()`](https://choxos.github.io/rtransparency/reference/rt_check_links.md)
  : Check whether extracted data and code links resolve

## Experimental

Detectors not yet validated against hand labels; not part of
rt_all_pmc().

- [`rt_ethics_pmc()`](https://choxos.github.io/rtransparency/reference/rt_ethics_pmc.md)
  : Identify ethics approval and informed consent statements
  (experimental)
- [`rt_ethics()`](https://choxos.github.io/rtransparency/reference/rt_ethics.md)
  : Identify ethics approval and informed consent statements in text
  (experimental)

## Summarize and visualize

Corpus-level prevalence, per-article scores and plots.

- [`rt_summary()`](https://choxos.github.io/rtransparency/reference/rt_summary.md)
  : Summarize transparency indicators across a corpus of articles
- [`rt_score()`](https://choxos.github.io/rtransparency/reference/rt_score.md)
  : Count the transparency indicators met by each article
- [`rt_plot()`](https://choxos.github.io/rtransparency/reference/rt_plot.md)
  : Plot transparency indicators

## Datasets

- [`rt_accuracy`](https://choxos.github.io/rtransparency/reference/rt_accuracy.md)
  : Detector accuracy estimates
- [`rt_accuracy_2021`](https://choxos.github.io/rtransparency/reference/rt_accuracy_2021.md)
  : Published 2021 detector accuracy estimates
- [`rt_demo`](https://choxos.github.io/rtransparency/reference/rt_demo.md)
  : Simulated transparency indicators for a corpus of articles
