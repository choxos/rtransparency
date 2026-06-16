# Reconfigure the PMC XML so that the top node is "article".

PMC uses different XML top nodes, depending on what service is used to
download an article. This function standardizes the XML files so that
they all start from the same root.

## Usage

``` r
.reroot_xml(article_xml)
```

## Arguments

- article_xml:

  The article as an xml_document.

## Value

The xml_document reconfigure to start with the "article" node.
