# Open-access licensing and reporting-guideline validation

Two indicators added in 1.1.0, validated on the **1000-article 2023 open-access
sample**. Every article was read and hand-labeled by the maintainer (the ground
truth), independently of the detector, then compared with the detector output.
95% confidence intervals are stratified bootstrap (2000 resamples).

| Indicator | n | Positives | Sensitivity | Specificity | PPV | Accuracy |
|---|---:|---:|---:|---:|---:|---:|
| Open-access license | 1000 | 999 | 100.0% [100, 100] | 100.0% [100, 100] | 100.0% | 100.0% |
| Reporting guideline | 1000 | 65 | 93.8% [87.7, 98.5] | 99.0% [98.3, 99.6] | 87.1% | 98.7% |

**Open-access license.** Read from the structured JATS `<license>` element and
its license-reference URL. The license *type* (CC-BY vs CC-BY-NC / NC-ND / SA,
CC0, or retained copyright) matched the hand label in **99.8%** of articles
(997/999). The sample is the PMC open-access subset, so almost every article is
openly licensed (999/1000); the single non-open article (retained copyright) was
classified correctly. Specificity is therefore a ceiling estimate from few
negatives.

**Reporting guideline.** Detected precision-first: a guideline counts only in a
reporting context, common-word acronyms (ARRIVE, CARE, RECORD, REMARK, SPIRIT,
PROCESS) require the upper-case form beside a guideline noun, and animal-welfare
("Care and Use of Laboratory Animals"), clinical/treatment, and non-adherence
("a PRISMA-compliant search could not be used") mentions are vetoed. The named
guideline is returned. Coverage spans the EQUATOR catalogue (CONSORT, PRISMA and
its extensions, STROBE, ARRIVE, STARD, TRIPOD, COREQ, SRQR, SQUIRE, CHEERS, CARE,
PROCESS, STROCSS, RAMESES and the wider reportilo guideline list). The remaining
misses are non-English statements and a few captions; the residual false
positives are guidelines named but not actually followed by the article.
