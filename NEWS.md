<div align="justify">

# rtransparent 0.3.1

* Data and code detection dependencies (`oddpub`, `tokenizers`) are now optional (moved to `Suggests`); the package loads and every other indicator runs without them. The data and code functions raise a clear, actionable error when these packages are absent.
* Added an internal PMC full-text XML fetch helper for the accuracy benchmark, backed by NCBI E-utilities (EFetch) with a PMC OAI-PMH fallback (adapted from `metareadr`, GPL-3).


# rtransparent 0.3.0

* `rt_novelty` and `rt_novelty_pmc` added: detect claims of novelty ("for the first time") in TXT and PMC XML files.
* `rt_replication` and `rt_replication_pmc` added: detect replication/validation components in TXT and PMC XML files.
* `rt_register` and `rt_register_pmc` expanded: now detect registrations on ISRCTN, ANZCTR (ACTRN), DRKS, IRCT, and UMIN in addition to NCT and PROSPERO.
* `rt_all` and `rt_all_pmc` updated to include novelty and replication indicators.
* A formal testthat test suite has been added (`tests/testthat/`).


# rtransparent 0.2.5

* A vignette has been added to help illustrate how to use the package.


# rtransparent 0.2

* `rt_coi` now searches for Conflicts of interest statements within text files.
* `rt_fund` now searches for Funding statements within text files.
* `rt_register` now searches for Registration statements within text files.
* `rt_all` now searches for many indicators within text files.
* `rt_read_pdf` now converts PDF files into TXT using poppler.


# rtransparent 0.1

* Initial commit of functions to analyze PMC XML files for indicators.


</div>