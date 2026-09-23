#' Identify transparency indicators across many PMC XML files.
#'
#' A batch wrapper around [rt_all_pmc()] for corpus-scale runs over a directory
#' (or an explicit vector) of PMC XML files. It isolates per-file failures so a
#' single malformed file cannot abort the run, shows a progress bar, can resume
#' an interrupted run, and can run in parallel when the \pkg{furrr} package is
#' installed.
#'
#' @details
#' When `output` is supplied, results are written to that CSV in chunks as the
#' run proceeds. Re-running with the same `output` skips files already present
#' in it and appends only the new results, so a long run can be resumed after an
#' interruption. File names are recorded as absolute paths and resuming
#' compares normalized paths, so it also works from another working directory
#' or with relative instead of absolute paths. Each
#' file is processed inside [tryCatch()]; a file that errors contributes a row
#' with `is_success = FALSE` and the error message in `error` rather than
#' stopping the run.
#'
#' Parallelism uses \pkg{furrr}'s `future_map()` and honors whatever
#' `future::plan()` is active (for example `future::plan("multisession")`); with
#' no plan it runs sequentially. Install \pkg{furrr} and \pkg{future} to use it.
#'
#' @param dir A directory containing PMC XML files, or a character vector of
#'   file paths.
#' @param pattern A regular expression for file names, used only when `dir` is a
#'   single existing directory (default `"\\.xml$"`).
#' @param recursive Whether to descend into subdirectories when `dir` is a
#'   directory (default `FALSE`).
#' @param remove_ns,all_meta Passed through to [rt_all_pmc()].
#' @param output Optional path to a CSV file for incremental, resumable output
#'   (see Details). `NULL` (default) keeps results in memory only.
#' @param parallel Whether to process files in parallel via \pkg{furrr}
#'   (default `FALSE`).
#' @param progress Whether to show a progress bar (default `TRUE`).
#' @param chunk_size Number of files per write/flush when `output` is set
#'   (default `200`).
#' @return A [tibble][tibble::tibble] with one row per file (`filename` is the
#'   file's absolute path), carrying the same columns as [rt_all_pmc()] (plus any rows read back from a pre-existing
#'   `output`). Files that could not be processed have `is_success = FALSE`
#'   and the reason in `error`.
#' @seealso [rt_all_pmc()] for a single file.
#' @examples
#' \donttest{
#' # Process every PMC XML in a directory (here, the bundled example file).
#' dir <- system.file("extdata", package = "rtransparency")
#' out <- tempfile(fileext = ".csv")
#' res <- rt_all_pmc_dir(dir, output = out, parallel = FALSE)
#' }
#' @export
rt_all_pmc_dir <- function(dir, pattern = "\\.xml$", recursive = FALSE,
                           remove_ns = TRUE, all_meta = FALSE,
                           output = NULL, parallel = FALSE, progress = TRUE,
                           chunk_size = 200L) {
  files <- .batch_files(dir, pattern, recursive)
  .rt_batch(files, function(f) rt_all_pmc(f, all_meta = all_meta),
            output = output, parallel = parallel, progress = progress,
            chunk_size = chunk_size)
}


#' Identify transparency indicators across many TXT or PDF files.
#'
#' The plain-text counterpart of [rt_all_pmc_dir()]: runs [rt_all()] on every
#' text file, and [rt_all_pdf()] on every PDF, in a directory (or an explicit
#' vector of paths), with the same per-file error isolation, progress bar,
#' resumable CSV output and optional parallelism.
#'
#' @param dir A directory containing TXT and/or PDF files, or a character
#'   vector of file paths.
#' @param pattern A regular expression for file names, used only when `dir` is a
#'   single existing directory (default: `.txt` and `.pdf` files).
#' @param recursive,parallel,progress,chunk_size As in [rt_all_pmc_dir()].
#' @param output Optional path to a CSV file for incremental, resumable output,
#'   with the same behavior as in [rt_all_pmc_dir()].
#' @return A [tibble][tibble::tibble] with one row per file: `filename` (the
#'   path), the columns of [rt_all()], `is_success` and `error`.
#' @seealso [rt_all()], [rt_all_pdf()], [rt_all_pmc_dir()]
#' @examples
#' \donttest{
#' d <- file.path(tempdir(), "rt_txt_example")
#' dir.create(d, showWarnings = FALSE)
#' writeLines("Conflicts of interest: none declared.",
#'            file.path(d, "PMID00000001.txt"))
#' writeLines("This work was funded by the Wellcome Trust (grant 12345).",
#'            file.path(d, "PMID00000002.txt"))
#' res <- rt_all_txt_dir(d, progress = FALSE)
#' }
#' @export
rt_all_txt_dir <- function(dir, pattern = "\\.(txt|pdf)$", recursive = FALSE,
                           output = NULL, parallel = FALSE, progress = TRUE,
                           chunk_size = 200L) {
  files <- .batch_files(dir, pattern, recursive)
  worker <- function(f) {
    if (grepl("\\.pdf$", f, ignore.case = TRUE)) rt_all_pdf(f) else rt_all(f)
  }
  .rt_batch(files, worker, output = output, parallel = parallel,
            progress = progress, chunk_size = chunk_size)
}


# Resolve a batch file list: a single existing directory is expanded by
# pattern; anything else is treated as an explicit vector of file paths.
.batch_files <- function(dir, pattern, recursive) {
  if (length(dir) == 1 && dir.exists(dir)) {
    files <- list.files(dir, pattern = pattern, full.names = TRUE,
                        recursive = recursive, ignore.case = TRUE)
  } else {
    files <- dir
  }

  if (!length(files)) {
    stop("No files to process.", call. = FALSE)
  }

  missing <- !file.exists(files)
  if (any(missing)) {
    stop("File(s) not found: ",
         paste(utils::head(files[missing], 5L), collapse = ", "),
         if (sum(missing) > 5L) ", ..." else "", call. = FALSE)
  }
  # Absolute, canonical paths: the output's filename column then identifies a
  # file wherever a resumed run is started from.
  normalizePath(files, winslash = "/", mustWork = TRUE)
}


# The batch engine shared by rt_all_pmc_dir() and rt_all_txt_dir(): runs
# `worker` on each file with per-file error isolation, optional parallelism,
# and resumable chunked CSV output.
.rt_batch <- function(files, worker, output = NULL, parallel = FALSE,
                      progress = TRUE, chunk_size = 200L) {

  if (parallel) {
    rlang::check_installed(c("furrr", "future"),
                           reason = "to process files in parallel")
  }

  to_char <- function(df) {
    dplyr::mutate(df, dplyr::across(dplyr::everything(), as.character))
  }
  reguess <- function(df) suppressMessages(readr::type_convert(df))

  # Resume: read any existing output (forced to character so re-guessed CSV
  # column types cannot clash with freshly computed rows) and drop files already
  # recorded in it.
  done_rows <- NULL
  if (!is.null(output) && file.exists(output) && file.info(output)$size > 0) {
    done_rows <- readr::read_csv(
      output, col_types = readr::cols(.default = readr::col_character()),
      progress = FALSE
    )
    if ("filename" %in% names(done_rows)) {
      # Compare normalized paths, so a run resumed from another working
      # directory, or with relative instead of absolute paths, still skips the
      # files it has already processed.
      norm <- function(x) normalizePath(x, winslash = "/", mustWork = FALSE)
      files <- files[!norm(files) %in% norm(done_rows$filename)]
    }
  }

  if (!length(files)) {
    return(if (is.null(done_rows)) tibble::tibble() else reguess(done_rows))
  }

  # Per-file worker: never let one file abort the batch. rt_all_pmc() already
  # returns is_success = FALSE on a parse error; this tryCatch is a backstop for
  # any other failure. Every row carries filename, is_success and error.
  process_one <- function(f) {
    r <- tryCatch(
      worker(f),
      error = function(e) tibble::tibble(filename = f, is_success = FALSE,
                                         error = conditionMessage(e))
    )
    if (!"filename" %in% names(r)) r <- tibble::add_column(r, filename = f, .before = 1)
    if (!"is_success" %in% names(r)) r$is_success <- TRUE
    if (!"error" %in% names(r)) r$error <- NA_character_
    r
  }

  mapper <- function(x) {
    if (parallel) {
      furrr::future_map(x, process_one, .progress = progress)
    } else {
      purrr::map(x, process_one, .progress = progress)
    }
  }

  # Process in chunks so progress is flushed to disk periodically (a crash then
  # loses at most one chunk). Each chunk is appended to the output, written as
  # character so a re-read resumes cleanly; the file is rewritten only in the
  # rare case that a chunk brings columns the file does not have yet (for
  # example when every earlier file failed to parse).
  chunk_size <- max(1L, as.integer(chunk_size))
  chunks <- split(files, ceiling(seq_along(files) / chunk_size))
  new_rows <- vector("list", length(files))
  pos <- 0L
  out_cols <- if (!is.null(done_rows)) names(done_rows) else NULL

  write_chunk <- function(rows) {
    rows <- to_char(rows)
    if (is.null(out_cols)) {
      readr::write_csv(rows, output)
      out_cols <<- names(rows)
    } else if (all(names(rows) %in% out_cols)) {
      missing_cols <- setdiff(out_cols, names(rows))
      rows[missing_cols] <- NA_character_
      readr::write_csv(rows[out_cols], output, append = TRUE)
    } else {
      old <- readr::read_csv(
        output, col_types = readr::cols(.default = readr::col_character()),
        progress = FALSE
      )
      combined <- dplyr::bind_rows(old, rows)
      readr::write_csv(combined, output)
      out_cols <<- names(combined)
    }
  }

  for (chunk in chunks) {
    res <- mapper(chunk)
    new_rows[seq_along(res) + pos] <- res
    pos <- pos + length(res)
    if (!is.null(output)) write_chunk(dplyr::bind_rows(res))
  }

  # Rows freshly computed in this run share rt_all_pmc()'s native column types,
  # so they bind directly. When resuming, reconcile with the character-typed
  # done_rows by re-guessing the combined table's column types uniformly.
  typed <- dplyr::bind_rows(new_rows)
  if (is.null(done_rows)) {
    typed
  } else {
    reguess(dplyr::bind_rows(done_rows, to_char(typed)))
  }
}
