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
rt_ai(filename = NULL, text = NULL)
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
whether an AI-use disclosure was found (\`is_ai_pred\`), the matched
statement (\`ai_text\`) and what it says (\`ai_used\`, \`ai_tools\`,
\`ai_purpose\`), as described in \[rt_ai_pmc()\].

## See also

\[rt_ai_pmc()\] for the PMC XML detector, which applies the 2023
publication-year gate.

## Examples

``` r
# \donttest{
# Write a short example article to a temporary text file.
filepath <- file.path(tempdir(), "PMID00000000-PMC0000000.txt")
writeLines(
  "The authors used ChatGPT to assist with drafting this manuscript.",
  filepath
)

# Identify and extract an AI-use disclosure.
rt_ai(filepath)
#> # A tibble: 1 × 7
#>   article                   pmid  is_ai_pred ai_text ai_used ai_tools ai_purpose
#>   <chr>                     <chr> <lgl>      <chr>   <lgl>   <chr>    <chr>     
#> 1 PMID00000000-PMC0000000.… 0000… TRUE       The au… TRUE    ChatGPT  drafting  
# }
```
