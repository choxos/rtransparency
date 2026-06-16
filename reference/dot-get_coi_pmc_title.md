# Identify COI titles using XML labels

Extract XML titles related to COI statements and all text children.

## Usage

``` r
.get_coi_pmc_title(article_xml, dict)
```

## Arguments

- article_xml:

  The text as an xml_document.

- dict:

  A list of regular expressions for each concept.

## Value

The title and its related text as a string.
