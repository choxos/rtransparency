# Identify and extract Funding statements in TXT files.

Takes a TXT file and returns data related to the presence of a Funding
statement, including whether a Funding statement exists. If a Funding
statement exists, it extracts it.

## Usage

``` r
rt_fund(filename = NULL, text = NULL)
```

## Arguments

- filename:

  The path to a TXT file as a string.

- text:

  Alternatively, the article text itself as a character vector (for
  example the output of \[rt_read_pdf()\]). Supply \`filename\` or
  \`text\`.

## Value

A tibble with the file name (\`article\`), the PMID (\`NA\` if absent),
whether a statement that funding was received was found
(\`is_fund_pred\`) and the statement (\`fund_text\`). These are the same
column names as \[rt_fund_pmc()\] and \[rt_all_pmc()\]. The former names
\`is_funded_pred\` and \`funding_text\` are still returned, as
deprecated copies, and will be removed in a future release.

## Examples

``` r
# \donttest{
# Write a short example article to a temporary text file.
filepath <- file.path(tempdir(), "PMID00000000-PMC0000000.txt")
writeLines(c(
  "To our knowledge, this is the first study of its kind.",
  "Conflicts of interest: none declared.",
  "This work was supported by the National Institutes of Health (R01-000000).",
  "The protocol was registered at ClinicalTrials.gov (NCT00000000).",
  "All data and code are available at https://github.com/example/repo.",
  "We independently replicated the original analysis."
), filepath)

# Identify and extract the funding statement.
results_table <- rt_fund(filepath)
# }
```
