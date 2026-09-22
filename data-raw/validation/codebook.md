# Labeling codebook

Label what the **article itself** reports about **its own study**. Use `TRUE`,
`FALSE`, or leave blank when the item cannot be assessed (for example `ai`
before 2023). Add a short note for any borderline call.

| Column | TRUE when the article ... |
|---|---|
| coi | contains a conflict-of-interest disclosure, positive or negative ("none declared" counts). |
| fund | states that the work received funding (a statement of no funding is FALSE). |
| reg | reports a registration of its protocol (trial registry, PROSPERO, OSF, ...). |
| nov | claims its own work is novel or first ("to our knowledge, the first ..."). |
| rep | reports performing a replication or an external/independent validation. |
| data | makes its own data available (repository, accession, supplement, in the article); "on request" is FALSE. |
| code | makes its own analysis code available; "on request" is FALSE. |
| ai | discloses use or non-use of generative AI in preparing the manuscript (2023 onward). |
| ai_used | (only when `ai` is TRUE) states that AI *was* used. |
| reporting | states that it followed a reporting guideline (CONSORT, PRISMA, STROBE, ...). |
| ethics | reports approval, waiver or exemption by an ethics body, or that approval was not required. |
| consent | reports how informed consent was handled (obtained, waived, not required). |
