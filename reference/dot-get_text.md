# Get the desired text from the xml_document

Returns the text desired according to xpath.

## Usage

``` r
.get_text(article_xml, xpath, find_first)
```

## Arguments

- article_xml:

  An xml_document from \`xml2::read_xml\`.

- xpath:

  The XPath as a character, e.g. "id_info/nct_id".

- find_first:

  TRUE to find first mention, FALSE to find all mentions.

## Value

The desired text as a character; if not found, then \`character()\`
