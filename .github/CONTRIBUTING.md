# Contributing to rtransparency

Thanks for your interest in improving `rtransparency`. This package detects
research-transparency indicators in biomedical full text, so changes should be
evidence-driven and conservative.

## Before opening an issue

- Search existing issues and pull requests to avoid duplicates.
- For detector problems, include a minimal text or XML excerpt that shows the
  false positive or false negative.
- Do not upload copyrighted full-text articles unless their license permits it.
  Prefer a short, legally shareable excerpt and article identifiers.
- For CRAN or installation problems, include `sessionInfo()` and the exact error.

## Before opening a pull request

- Keep changes focused. Avoid mixing detector logic, documentation, metadata, and
  release chores unless they are inseparable.
- Add or update tests for behavior changes.
- Update documentation and benchmark notes when user-facing semantics change.
- Keep claims about accuracy tied to a named benchmark or validation file.
- Run the relevant checks locally before submitting.

## Development setup

Install the development dependencies with:

```r
install.packages(c(
  "devtools", "testthat", "roxygen2", "rmarkdown", "knitr",
  "readxl", "furrr", "future", "ggplot2"
))
```

The PDF helper `rt_read_pdf()` requires the external `pdftotext` utility from
poppler.

## Checks

Run these before opening a pull request:

```r
devtools::test()
devtools::document()
```

Then build and check the source tarball:

```sh
R CMD build .
R CMD check --as-cran rtransparency_*.tar.gz
```

If your change touches URLs, also run:

```r
urlchecker::url_check()
```

## Detector changes

Detector changes should be based on row-level evidence, not only aggregate
metrics. A good detector pull request includes:

- the motivating false positive or false negative,
- the smallest safe rule change,
- regression tests for the new case,
- a short note on possible precision/recall tradeoffs,
- updated benchmark outputs if benchmark scripts were rerun.

## Documentation changes

Documentation should be precise about limitations:

- AI disclosure is experimental and not accuracy-corrected.
- Replication correction uses a hybrid validation basis.
- Data/code benchmarks are reproducible native-detector benchmarks, not a claim
  that every use case has the same operating characteristics.

## Code of conduct

All contributors are expected to follow the project Code of Conduct.
