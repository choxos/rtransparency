# Identify funding group elements in NLM XML files

Identify and return the text found in funding group elements of NLM XML
files. Articles with funding-group elements also have a Funding
indication on PubMed.

## Usage

``` r
.get_fund_pmc_group(article_xml)
```

## Arguments

- article_xml:

  An NLM XML as an xml_document.

## Value

The text of interest as a list indicating whether it was found, the
quoated institutes and the actual statement as a string.
