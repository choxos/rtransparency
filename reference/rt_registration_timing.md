# Check whether ClinicalTrials.gov registrations were prospective

Looks up trials in the ClinicalTrials.gov registry (API version 2) and
compares the date the registration was first submitted with the study
start date. A registration is prospective when it was submitted no later
than the start date (plus an optional grace period).

## Usage

``` r
rt_registration_timing(nct_ids, grace_days = 0)
```

## Arguments

- nct_ids:

  A character vector of NCT numbers, for example from
  \[rt_trial_ids()\]. Other identifiers are returned with \`NA\` dates.

- grace_days:

  Days after the start date within which a registration still counts as
  prospective (default \`0\`). Some studies allow 30 days.

## Value

A tibble with one row per unique identifier: \`nct_id\`,
\`first_submitted\` and \`first_posted\` (the registration dates),
\`start_date\`, \`start_date_precision\` (\`"day"\` or \`"month"\`),
\`start_date_type\` (\`"ACTUAL"\` or \`"ESTIMATED"\`),
\`days_after_start\` (submission date minus start date; negative when
registered before the start) and \`is_prospective\`. Trials the registry
does not know have \`NA\` dates.

## Details

When the registry gives the start date to the month only, a registration
submitted within that month cannot be classified and \`is_prospective\`
is \`NA\`; one submitted before the month is prospective and one after
it is retrospective. The start date the registry holds may be an
estimate for trials not yet started (\`start_date_type\`).

## See also

\[rt_trial_ids()\], \[rt_register_pmc()\]

## Examples

``` r
# \donttest{
# Needs internet access and the jsonlite package.
if (requireNamespace("jsonlite", quietly = TRUE)) {
  try(rt_registration_timing(c("NCT04368728", "NCT00000102")))
}
#> # A tibble: 2 × 8
#>   nct_id      first_submitted first_posted start_date start_date_precision
#>   <chr>       <date>          <date>       <date>     <chr>               
#> 1 NCT04368728 2020-04-27      2020-04-30   2020-04-29 day                 
#> 2 NCT00000102 1999-11-03      1999-11-04   NA         NA                  
#> # ℹ 3 more variables: start_date_type <chr>, days_after_start <int>,
#> #   is_prospective <lgl>
# }
```
