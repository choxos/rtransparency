# Identify and extract Conflicts of Interest statements in PMC XML files.

Takes a PMC XML file and returns data related to the presence of a
Funding statement, including whether a Funding statement exists. If a
Funding statement exists, it extracts it.

## Usage

``` r
rt_register_pmc(filename, remove_ns = FALSE)
```

## Arguments

- filename:

  The name of the PMC XML as a string.

- remove_ns:

  TRUE if an XML namespace exists, else FALSE (default).

## Value

A dataframe of results. It returns the unique article identifiers,
whether this article was deemed a research, review or systematic review,
whether the text was deemed relevant to registration (e.g. contained the
word registration), whether a Methods section was identified, whether an
NCT number was identified, whether a registration was explicitly
identified (defunct), whether a registration statement was found, what
the registration statement was, whether it the registration was
identified from the PMC XML (i.e. it was found within a dedicated
registration tag) and whether each labeling function identified a
relevant text or not. The labeling functions are returned to add
flexibility in how this package is used; for example, future definitions
of Registration may differ from the one we used.

## Examples

``` r
# \donttest{
# Path to a bundled example PMC XML file.
filepath <- system.file(
  "extdata", "PMID32171256-PMC7071725.xml", package = "rtransparency"
)

# Identify and extract meta-data and indicators of transparency.
results_table <- rt_register_pmc(filepath, remove_ns = TRUE)
# }
```
