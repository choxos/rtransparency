# Read an XML file into an xml_document

Returns the file as an xml_document.

## Usage

``` r
.get_xml(filename, remove_ns = F)
```

## Arguments

- filename:

  The filepath to the PMC XML file of interest.

- remove_ns:

  Whether to remove the XML namespace or not (default = F).

## Value

The PMC XML as an xml_document.
