## Submission

This is an update of rtransparency from 1.0.0 (on CRAN since 2026-07-01) to
1.2.0. It fixes several detection bugs, unifies the plain-text and XML
interfaces, speeds up the reporting-guideline detector, and adds functions to
download PMC full text, read structured JATS metadata, and check registrations
and links. See NEWS.md.

## R CMD check results

0 errors | 0 warnings | 0 notes (`R CMD check --as-cran`, including
`--run-donttest` examples, on the local environment below).

## Test environments

* local macOS 27, R 4.6.0: Status OK
* GitHub Actions (r-lib/actions, full `R CMD check`): macOS-release,
  windows-release, ubuntu-devel, ubuntu-release, ubuntu-oldrel-1 (to be
  confirmed on the release branch before submission)
* win-builder (devel) (to be run before submission)

## Reverse dependencies

There are no reverse dependencies.

## Notes for CRAN

* Functions that query web services (NCBI E-utilities and ID Converter,
  Europe PMC, ClinicalTrials.gov, PubMed, and link resolution) fail gracefully
  when the service is unreachable: per-item failures are reported in the
  result, and their examples are wrapped in `\donttest{}` with `try()` where a
  call can error. Tests that use the network are skipped on CRAN.
* Only the two examples that need the external `pdftotext` utility
  (`rt_read_pdf()`, `rt_all_pdf()`) use `\dontrun{}`.
* The package remains self-contained: data and code sharing detection is
  implemented natively and contains no code from the AGPL `oddpub` package.
