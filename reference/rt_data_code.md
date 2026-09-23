# Identify and extract Data and Code statements in TXT files.

Takes a TXT file and returns data related to the presence of Data and/or
Code statements, including whether Data and/or Code statements exist. If
such statements exist, it extracts them.

## Usage

``` r
rt_data_code(filename = NULL, text = NULL)
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
whether data or code sharing was found (\`is_open_data\`,
\`is_open_code\`), the statements that triggered each
(\`open_data_statements\`, \`open_code_statements\`) and the identifiers
extracted from them (\`open_data_links\`, \`open_code_links\`), with the
same columns and meaning as \[rt_data_code_pmc()\].

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

# Identify and extract data and code availability.
results_table <- rt_data_code(filepath)
# }
```
