## Resubmission

This is a resubmission of the new package `rtransparency`. In response to the
review by Benjamin Altmann (CRAN), I have:

* Replaced every use of the `T` and `F` shorthands with `TRUE` and `FALSE`, in
  the R sources and therefore in the man-page `\usage` sections.

* Replaced `\dontrun{}` with `\donttest{}` and made the examples runnable. Each
  example now runs against the bundled example XML file (via `system.file()`) or
  a small temporary text file written inside the example. Only `rt_read_pdf()`
  still uses `\dontrun{}`, because it requires the external `pdftotext` utility
  (poppler), which may be absent on the check machine.

## R CMD check results

0 errors | 0 warnings | 1 note

* The note is the standard "New submission" note. Examples were checked with
  `R CMD check --as-cran --run-donttest`.

## Submission notes

* `rtransparency` is a renamed, enhanced fork of the (CRAN-unpublished)
  `rtransparent` tool of Serghiou et al. (2021, doi:10.1371/journal.pbio.3001107).
  It is renamed to avoid confusion with that project and is submitted under the
  new name rather than as an update to `rtransparent`. Stylianos Serghiou is
  credited as an author in Authors@R, and the foundational paper is cited in the
  Description field and in `inst/CITATION`.

* The test suite does not access the network; tests run on the bundled example
  files and on temporary files.

* Optional, heavier capabilities (parallel corpus processing via furrr and
  future, plotting via ggplot2) are in Suggests, and the package degrades
  gracefully when they are absent.

* The package contains no code from the AGPL-licensed `oddpub` package; data and
  code sharing detection is implemented natively. `rt_read_pdf()` is an original
  wrapper around the poppler `pdftotext` command-line utility. The only adapted
  code is an internal, benchmark-only NCBI OAI fallback derived from
  `metareadr::mt_read_pmcoa()` (GPL-3); its author, Stylianos Serghiou, is
  credited in `Authors@R`.

* The README carries the standard CRAN status badge, whose link
  (`https://CRAN.R-project.org/package=rtransparency`) is not yet live and
  returns 404 until this submission is accepted; it resolves on acceptance.

## Test environments

* local macOS, R 4.6.0 (0 errors, 0 warnings, 1 note)
* GitHub Actions (r-lib/actions, full `R CMD check`): macOS-release,
  windows-release, ubuntu-devel, ubuntu-release, ubuntu-oldrel-1
* win-builder (devel)
