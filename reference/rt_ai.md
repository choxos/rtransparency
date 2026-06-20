# Identify disclosure of generative-AI use from a TXT file.

Detects whether an article discloses the use (or non-use) of generative
AI or AI-assisted tools in preparing the manuscript, from a plain-text
(typically PDF-derived) file. Unlike \[rt_ai_pmc()\] it applies \*\*no
publication-year gate\*\*: a plain-text file carries no reliable
publication date, so \`is_ai_pred\` is always \`TRUE\` or \`FALSE\`
(never \`NA\`). AI-use disclosure became an expected practice only in
2023, so the caller is responsible for restricting analysis to articles
from 2023 onward. Plain text also lacks the section structure the PMC
detector uses to confine the scan to back matter, acknowledgments and
declaration sections, so an article that uses AI purely as a research
method is more likely to be flagged than under \[rt_ai_pmc()\].

## Usage

``` r
rt_ai(filename)
```

## Arguments

- filename:

  The name of the TXT file as a string.

## Value

A tibble with the filename, the PMID (if present in the file name),
whether an AI-use disclosure was found (\`is_ai_pred\`) and the matched
statement (\`ai_text\`).

## See also

\[rt_ai_pmc()\] for the PMC XML detector, which applies the 2023
publication-year gate.

## Examples

``` r
if (FALSE) { # \dontrun{
# Path to a TXT file.
filepath <- "../inst/extdata/00003-PMID26637448-PMC4737611.txt"

# Identify and extract an AI-use disclosure.
rt_ai(filepath)
} # }
```
