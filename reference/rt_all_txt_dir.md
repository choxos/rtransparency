# Identify transparency indicators across many TXT or PDF files.

The plain-text counterpart of \[rt_all_pmc_dir()\]: runs \[rt_all()\] on
every text file, and \[rt_all_pdf()\] on every PDF, in a directory (or
an explicit vector of paths), with the same per-file error isolation,
progress bar, resumable CSV output and optional parallelism.

## Usage

``` r
rt_all_txt_dir(
  dir,
  pattern = "\\.(txt|pdf)$",
  recursive = FALSE,
  output = NULL,
  parallel = FALSE,
  progress = TRUE,
  chunk_size = 200L
)
```

## Arguments

- dir:

  A directory containing TXT and/or PDF files, or a character vector of
  file paths.

- pattern:

  A regular expression for file names, used only when \`dir\` is a
  single existing directory (default: \`.txt\` and \`.pdf\` files).

- recursive, parallel, progress, chunk_size:

  As in \[rt_all_pmc_dir()\].

- output:

  Optional path to a CSV file for incremental, resumable output, with
  the same behavior as in \[rt_all_pmc_dir()\].

## Value

A \[tibble\]\[tibble::tibble\] with one row per file: \`filename\` (the
path), the columns of \[rt_all()\], \`is_success\` and \`error\`.

## See also

\[rt_all()\], \[rt_all_pdf()\], \[rt_all_pmc_dir()\]

## Examples

``` r
# \donttest{
d <- file.path(tempdir(), "rt_txt_example")
dir.create(d, showWarnings = FALSE)
writeLines("Conflicts of interest: none declared.",
           file.path(d, "PMID00000001.txt"))
writeLines("This work was funded by the Wellcome Trust (grant 12345).",
           file.path(d, "PMID00000002.txt"))
res <- rt_all_txt_dir(d, progress = FALSE)
# }
```
