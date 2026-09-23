# Identify and extract Conflicts of Interest (COI) statements in TXT files.

Takes a TXT file and returns data related to the presence of a COI
statement, including whether a COI statement exists. If a COI statement
exists, it extracts it. Detection runs through the same text helpers as
\[rt_coi_pmc()\], so a plain-text article is scored with the same logic
as a PMC XML one (only the XML-structural routes, which need tags a TXT
file does not have, are unavailable).

## Usage

``` r
rt_coi(filename = NULL, text = NULL)
```

## Arguments

- filename:

  The path to a TXT file as a string.

- text:

  Alternatively, the article text itself as a character vector (for
  example the output of \[rt_read_pdf()\]). Supply \`filename\` or
  \`text\`.

## Value

A tibble with the file name (\`article\`), the PMID (the digits after
"PMID" in the file name, \`NA\` if absent or for \`text\`), whether a
COI statement was found (\`is_coi_pred\`) and the text identified
(\`coi_text\`).

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

# Identify and extract the COI statement.
results_table <- rt_coi(filepath)
# }
```
