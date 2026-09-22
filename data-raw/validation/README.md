# Fresh, blind validation samples

The accuracy estimates in `rt_accuracy` come from several labeled sets, some
of which were used while tuning the detectors, and for conflicts of interest,
funding, data and AI disclosure the 2023 labels were reconciled against the
detector's own output. These scripts build a **new, untouched** validation
sample and label it **blind** to the detector, so the next accuracy estimates
are independent.

1. **Draw a sample** of open-access PMC articles (optionally enriched with a
   query, for rare indicators such as AI-use disclosure):

   ```sh
   Rscript data-raw/validation/draw_sample.R 2025 400 2026 data-raw/validation/sample_2025.csv
   # enriched, for AI-use disclosure:
   Rscript data-raw/validation/draw_sample.R 2025 200 2026 data-raw/validation/sample_ai.csv \
     '"generative AI" AND (manuscript OR writing)'
   ```

2. **Build the blind labeling sheets.** This downloads the XML, runs the
   detectors, and writes the predictions to a separate file the raters must
   not open. A random 20% of articles are marked for double coding.

   ```sh
   Rscript data-raw/validation/make_label_sheet.R data-raw/validation/sample_2025.csv \
     data-raw/validation/round_2025
   ```

   Each rater fills in a copy of `label_sheet.csv` (`TRUE`/`FALSE`, blank when
   not assessable) using the definitions in `codebook.md`, reading the article
   at the `pmc_url`. The second rater codes only the rows with
   `double_code = TRUE`.

3. **Score** the labels against the predictions, with Wilson intervals and
   Cohen's kappa for inter-rater agreement:

   ```sh
   Rscript data-raw/validation/score_labels.R data-raw/validation/round_2025 \
     rater1.csv [rater2.csv]
   ```

   This writes `results.csv` (with the TP/FN/TN/FP counts `rt_accuracy`
   stores) and `results.md` in the round directory. Update
   `data-raw/rt_accuracy.R` from `results.csv` only after the labels are final.

Never adjust a detector using a round's labels and then report that round's
accuracy: draw a new round for the next estimate.
