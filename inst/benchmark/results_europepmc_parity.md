# Europe PMC parity

Package version 1.2.0. 13 articles (the benchmark fixtures and the bundled example) were downloaded from both NCBI PMC and the Europe PMC REST API and run through `rt_all_pmc()`.

Indicator fields (the ten decisions, license and guideline) identical: 155 of 156.

Differing fields:

| PMCID | Field | NCBI | Europe PMC |
|---|---|---|---|
| PMC5998853 | oa_license | CC-BY-NC-SA-4.0 | CC-BY-NC-4.0 |

Europe PMC omits some license URLs; `oa_license` is then read from the license text, which can disagree with the URL when the publisher's own metadata disagree (for example text saying CC BY-NC and a URL saying CC BY-NC-SA). This is a small sample: it shows the detectors parse Europe PMC XML, not that their accuracy is identical on it.
