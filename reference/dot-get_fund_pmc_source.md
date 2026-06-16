# Identify funding source elements in NLM XML files

Identify and return the text found in funding source elements of NLM XML
files. Some funding sources are not included in the funding-group
elements - these are the sources that this function attempts to capture.
It seems that all articles with such elements also have a Funding
statement on PubMed.

## Usage

``` r
.get_fund_pmc_source(article_xml)
```

## Arguments

- article_xml:

  An NLM XML as an xml_document.

## Value

The text of interest as a string.
