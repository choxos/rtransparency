# Identify transparency indicators across many PMC XML files.

A batch wrapper around \[rt_all_pmc()\] for corpus-scale runs over a
directory (or an explicit vector) of PMC XML files. It isolates per-file
failures so a single malformed file cannot abort the run, shows a
progress bar, can resume an interrupted run, and can run in parallel
when the furrr package is installed.

## Usage

``` r
rt_all_pmc_dir(
  dir,
  pattern = "\\.xml$",
  recursive = FALSE,
  remove_ns = FALSE,
  all_meta = FALSE,
  output = NULL,
  parallel = FALSE,
  progress = TRUE,
  chunk_size = 200L
)
```

## Arguments

- dir:

  A directory containing PMC XML files, or a character vector of file
  paths.

- pattern:

  A regular expression for file names, used only when \`dir\` is a
  single existing directory (default \`"\\xml\$"\`).

- recursive:

  Whether to descend into subdirectories when \`dir\` is a directory
  (default \`FALSE\`).

- remove_ns, all_meta:

  Passed through to \[rt_all_pmc()\].

- output:

  Optional path to a CSV file for incremental, resumable output (see
  Details). \`NULL\` (default) keeps results in memory only.

- parallel:

  Whether to process files in parallel via furrr (default \`FALSE\`).

- progress:

  Whether to show a progress bar (default \`TRUE\`).

- chunk_size:

  Number of files per write/flush when \`output\` is set (default
  \`200\`).

## Value

A \[tibble\]\[tibble::tibble\] with one row per file, carrying the same
columns as \[rt_all_pmc()\] (plus any rows read back from a pre-existing
\`output\`). Files that could not be processed have \`is_success =
FALSE\`.

## Details

When \`output\` is supplied, results are written to that CSV in chunks
as the run proceeds. Re-running with the same \`output\` skips files
already present in it and appends only the new results, so a long run
can be resumed after an interruption. Each file is processed inside
\[tryCatch()\]; a file that errors contributes a row with \`is_success =
FALSE\` rather than stopping the run.

Parallelism uses furrr's \`future_map()\` and honors whatever
\`future::plan()\` is active (for example
\`future::plan("multisession")\`); with no plan it runs sequentially.
Install furrr and future to use it.

## See also

\[rt_all_pmc()\] for a single file.

## Examples

``` r
# \donttest{
# Process every PMC XML in a directory (here, the bundled example file).
dir <- system.file("extdata", package = "rtransparency")
out <- tempfile(fileext = ".csv")
res <- rt_all_pmc_dir(dir, remove_ns = TRUE, output = out, parallel = FALSE)
# }
```
