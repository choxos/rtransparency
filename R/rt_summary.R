# Corpus-level summaries of transparency indicators.
#
# rt_all_pmc() / rt_data_code_pmc() return one row per article. These helpers
# turn a table of many such rows into the kind of corpus-level summary used in
# meta-research studies of transparency: the prevalence of each indicator with
# a confidence interval, a prevalence corrected for the detector's known
# sensitivity and specificity, a per-article count of indicators met, and a
# quick plot.


# The indicators rt_summary()/rt_score()/rt_plot() recognize, with display
# labels and the order they are reported in.
.rt_indicator_registry <- function() {
  tibble::tibble(
    variable = c(
      "is_coi_pred", "is_fund_pred", "is_register_pred",
      "is_open_data", "is_open_code",
      "is_novelty_pred", "is_replication_pred", "is_ai_pred",
      "is_open_access", "is_reporting_pred"
    ),
    label = c(
      "Conflicts of interest", "Funding disclosure",
      "Protocol registration", "Data sharing", "Code sharing",
      "Novelty", "Replication", "AI disclosure",
      "Open-access license", "Reporting guideline"
    )
  )
}


# The five openness practices that make up the per-article transparency score.
# Novelty and replication are detected too, but they are not adherence
# practices, so they are excluded from the default rt_score() count.
.rt_practice_indicators <- function() {
  c("is_coi_pred", "is_fund_pred", "is_register_pred",
    "is_open_data", "is_open_code")
}


# Wilson score interval for a binomial proportion (no external dependency).
.wilson_ci <- function(x, n, conf_level = 0.95) {
  if (n == 0) return(c(NA_real_, NA_real_))
  z <- stats::qnorm(1 - (1 - conf_level) / 2)
  p <- x / n
  denom <- 1 + z^2 / n
  center <- (p + z^2 / (2 * n)) / denom
  half <- (z * sqrt(p * (1 - p) / n + z^2 / (4 * n^2))) / denom
  c(max(0, center - half), min(1, center + half))
}


# Rogan-Gladen correction: recover the true prevalence from an apparent
# (observed) prevalence given the detector's sensitivity and specificity.
# Returns NA when the test is not informative (sensitivity + specificity <= 1).
.rogan_gladen <- function(p, sensitivity, specificity) {
  denom <- sensitivity + specificity - 1
  out <- (p + specificity - 1) / denom
  out[is.na(denom) | denom <= 0] <- NA_real_
  pmin(pmax(out, 0), 1)
}


# Corrected-prevalence interval that carries the uncertainty of the detector's
# sensitivity and specificity, not only of the apparent prevalence. Draws the
# apparent prevalence, sensitivity and specificity from their Jeffreys
# (Beta(x + 0.5, n - x + 0.5)) posteriors, applies the Rogan-Gladen correction
# to each draw, and returns the percentile interval. With validation counts of
# a few dozen positives this interval is much wider, and more honest, than
# pushing the apparent-prevalence interval through the correction.
.rogan_gladen_mc <- function(k, n, tp, fn, tn, fp, conf_level, n_sim) {
  if (n == 0 || anyNA(c(tp, fn, tn, fp))) return(c(NA_real_, NA_real_))
  ap <- stats::rbeta(n_sim, k + 0.5, n - k + 0.5)
  se <- stats::rbeta(n_sim, tp + 0.5, fn + 0.5)
  sp <- stats::rbeta(n_sim, tn + 0.5, fp + 0.5)
  est <- .rogan_gladen(ap, se, sp)
  a <- (1 - conf_level) / 2
  unname(stats::quantile(est, c(a, 1 - a), na.rm = TRUE, names = FALSE))
}


# Run `code` with a fixed RNG seed without disturbing the caller's RNG state.
.with_seed <- function(seed, code) {
  had <- exists(".Random.seed", envir = globalenv(), inherits = FALSE)
  if (had) old <- get(".Random.seed", envir = globalenv(), inherits = FALSE)
  on.exit(if (had) assign(".Random.seed", old, envir = globalenv())
          else rm(".Random.seed", envir = globalenv()), add = TRUE)
  set.seed(seed)
  code
}


.resolve_indicators <- function(data, indicators) {
  reg <- .rt_indicator_registry()
  if (is.null(indicators)) {
    indicators <- intersect(reg$variable, names(data))
  } else {
    miss <- setdiff(indicators, names(data))
    if (length(miss)) {
      stop("Columns not found in `data`: ", paste(miss, collapse = ", "), ".",
           call. = FALSE)
    }
  }
  if (!length(indicators)) {
    stop(
      "No transparency indicator columns found in `data`. Expected one or ",
      "more of: ", paste(reg$variable, collapse = ", "), ".",
      call. = FALSE
    )
  }
  indicators
}


.coerce_indicator <- function(x, column) {
  if (is.logical(x)) {
    return(x)
  }
  if (is.numeric(x)) {
    ok <- is.na(x) | x %in% c(0, 1)
    if (!all(ok)) {
      stop("`", column, "` must contain only TRUE/FALSE, 0/1, or NA.",
           call. = FALSE)
    }
    return(as.logical(x))
  }
  stop("`", column, "` must be logical or numeric 0/1, with NA allowed.",
       call. = FALSE)
}


#' Summarize transparency indicators across a corpus of articles
#'
#' Takes a data frame with one row per article (such as the output of
#' [rt_all_pmc()] joined with [rt_data_code_pmc()], stacked over many articles)
#' and returns the prevalence of each transparency indicator. For each indicator
#' it reports the number of articles assessed, the number in which the indicator
#' was detected, the apparent prevalence and its Wilson confidence interval and,
#' optionally, a prevalence corrected for the detector's sensitivity and
#' specificity (the Rogan-Gladen estimator).
#'
#' @param data A data frame with one row per article. Indicator columns must be
#'   logical or numeric 0/1 and named as in [rt_all_pmc()]: `is_coi_pred`,
#'   `is_fund_pred`, `is_register_pred`, `is_open_data`, `is_open_code`,
#'   `is_novelty_pred`, `is_replication_pred`, `is_ai_pred`, `is_open_access` and
#'   `is_reporting_pred`. `NA` marks an article that was not assessed for that
#'   indicator (for example `is_ai_pred` before 2023) and is excluded from its
#'   denominator. Other values are rejected rather than silently coerced.
#' @param indicators Optional character vector of indicator columns to
#'   summarize. Defaults to every recognized indicator present in `data`.
#' @param by Optional name of a grouping column (for example a publication year,
#'   journal or article type); the summary is then computed within each group.
#' @param adjust If `TRUE` (default), add a prevalence corrected for detector
#'   sensitivity and specificity using `accuracy`. Indicators absent from
#'   `accuracy` receive `NA` corrected values.
#' @param accuracy A data frame of detector accuracy with columns `variable`,
#'   `sensitivity` and `specificity`, and optionally the validation counts
#'   `tp`, `fn`, `tn` and `fp`. Defaults to [rt_accuracy].
#' @param conf_level Confidence level for the intervals (default `0.95`).
#' @param adj_interval How the interval of the corrected prevalence is
#'   computed. `"simulation"` (the default) propagates the uncertainty of the
#'   detector's sensitivity and specificity, estimated from the validation
#'   counts in `accuracy`, together with that of the apparent prevalence (see
#'   Details). `"fixed"` treats sensitivity and specificity as known and
#'   corrects the bounds of the apparent-prevalence interval, which is too
#'   narrow when the validation sample is small. Indicators without validation
#'   counts always use `"fixed"`.
#' @param n_sim Number of simulation draws for `adj_interval = "simulation"`.
#' @param seed Random seed for the simulation, so results are reproducible.
#'   The caller's random number stream is left untouched.
#' @param register_assessed_only If `TRUE` (default) and `data` has an
#'   `is_research` column (as [rt_all_pmc()] output does), protocol
#'   registration is summarized over the articles the registration detector
#'   assesses: research articles and, when `is_review` is present, reviews
#'   (where PROSPERO registration applies). Editorials, letters, news and
#'   similar types are not assessed and return `FALSE`, so counting them in the
#'   denominator understates registration. `FALSE` counts every article.
#'
#' @details
#' **Corrected prevalence.** The Rogan-Gladen estimator corrects an apparent
#' prevalence `p` for detector error: `(p + specificity - 1) / (sensitivity +
#' specificity - 1)`, truncated to `[0, 1]`. With `adj_interval =
#' "simulation"`, the apparent prevalence, sensitivity and specificity are
#' drawn from their Jeffreys posteriors (`Beta(x + 0.5, n - x + 0.5)`) using the
#' corpus counts and the validation counts, each draw is corrected, and the
#' percentile interval of the draws is reported. Because the correction
#' divides by `sensitivity + specificity - 1` and subtracts `1 - specificity`,
#' uncertainty in specificity dominates for rare indicators (registration, code
#' sharing, replication), which the fixed interval ignores.
#'
#' Rows whose grouping value is `NA` form their own group, labelled `NA`.
#'
#' @return A tibble with one row per indicator (per group, if `by` is given):
#'   the grouping column (when `by` is used), `indicator`, `label`,
#'   `n_articles`, `n_detected`, `percent`, `conf_low`, `conf_high` and, when
#'   `adjust = TRUE`, `adj_percent`, `adj_low` and `adj_high`. Percentages and
#'   interval bounds are on the 0-100 scale.
#'
#' @seealso [rt_score()], [rt_plot()], [rt_accuracy]
#' @examples
#' data(rt_demo)
#' rt_summary(rt_demo)
#'
#' # Apparent prevalence only, no accuracy correction
#' rt_summary(rt_demo, adjust = FALSE)
#'
#' # By article type
#' rt_summary(rt_demo, by = "type")
#' @export
rt_summary <- function(data, indicators = NULL, by = NULL,
                       adjust = TRUE, accuracy = NULL, conf_level = 0.95,
                       adj_interval = c("simulation", "fixed"), n_sim = 10000,
                       seed = 2021, register_assessed_only = TRUE) {
  adj_interval <- match.arg(adj_interval)
  if (!is.data.frame(data)) {
    stop("`data` must be a data frame.", call. = FALSE)
  }
  if (!is.numeric(conf_level) || length(conf_level) != 1 ||
      is.na(conf_level) || conf_level <= 0 || conf_level >= 1) {
    stop("`conf_level` must be a single number between 0 and 1.", call. = FALSE)
  }
  indicators <- .resolve_indicators(data, indicators)
  if (is.null(accuracy)) accuracy <- rt_accuracy

  reg <- .rt_indicator_registry()

  if (!is.null(by)) {
    if (length(by) != 1 || !by %in% names(data)) {
      stop("`by` must name a single column in `data`.", call. = FALSE)
    }
    gv <- data[[by]]
    levels_by <- if (is.factor(gv)) levels(gv) else unique(as.character(gv[!is.na(gv)]))
    splits <- lapply(levels_by, function(g) {
      data[!is.na(gv) & as.character(gv) == g, , drop = FALSE]
    })
    names(splits) <- levels_by
    if (anyNA(gv)) {
      splits <- c(splits, list(data[is.na(gv), , drop = FALSE]))
      names(splits)[length(splits)] <- NA_character_
    }
  } else {
    splits <- list(`All articles` = data)
  }

  rows <- list()
  for (gi in seq_along(splits)) {
    g <- names(splits)[gi]
    d <- splits[[gi]]
    for (v in indicators) {
      x <- .coerce_indicator(d[[v]], v)
      if (v == "is_register_pred" && register_assessed_only &&
          "is_research" %in% names(d)) {
        assessed <- .coerce_indicator(d$is_research, "is_research") %in% TRUE
        if ("is_review" %in% names(d)) {
          assessed <- assessed | .coerce_indicator(d$is_review, "is_review") %in% TRUE
        }
        x[!assessed] <- NA
      }
      n <- sum(!is.na(x))
      k <- sum(x, na.rm = TRUE)
      p <- if (n > 0) k / n else NA_real_
      ci <- .wilson_ci(k, n, conf_level)
      lab <- reg$label[match(v, reg$variable)]
      row <- tibble::tibble(
        indicator = v,
        label = if (is.na(lab)) v else lab,
        n_articles = n,
        n_detected = k,
        percent = 100 * p,
        conf_low = 100 * ci[[1]],
        conf_high = 100 * ci[[2]]
      )
      if (!is.null(by)) {
        row <- tibble::add_column(row, !!by := g, .before = 1)
      }
      rows[[length(rows) + 1]] <- row
    }
  }
  res <- dplyr::bind_rows(rows)

  if (adjust) {
    if (!all(c("variable", "sensitivity", "specificity") %in% names(accuracy))) {
      stop("`accuracy` must have columns `variable`, `sensitivity` and ",
           "`specificity`.", call. = FALSE)
    }
    idx <- match(res$indicator, accuracy$variable)
    se <- accuracy$sensitivity[idx]
    sp <- accuracy$specificity[idx]
    res$adj_percent <- 100 * .rogan_gladen(res$percent / 100, se, sp)
    res$adj_low <- 100 * .rogan_gladen(res$conf_low / 100, se, sp)
    res$adj_high <- 100 * .rogan_gladen(res$conf_high / 100, se, sp)

    has_counts <- all(c("tp", "fn", "tn", "fp") %in% names(accuracy))
    if (adj_interval == "simulation" && has_counts) {
      cnt <- accuracy[idx, c("tp", "fn", "tn", "fp")]
      implied_se <- cnt$tp / (cnt$tp + cnt$fn)
      implied_sp <- cnt$tn / (cnt$tn + cnt$fp)
      off <- abs(implied_se - se) > 0.005 | abs(implied_sp - sp) > 0.005
      if (any(off, na.rm = TRUE)) {
        warning("The validation counts in `accuracy` do not match its ",
                "sensitivity/specificity for: ",
                paste(unique(res$indicator[off %in% TRUE]), collapse = ", "),
                ". The interval uses the counts, the point estimate the ",
                "sensitivity/specificity columns.", call. = FALSE)
      }
      .with_seed(seed, {
        for (i in seq_len(nrow(res))) {
          if (is.na(idx[i]) || anyNA(unlist(cnt[i, ])) || is.na(res$adj_percent[i])) next
          ci <- .rogan_gladen_mc(res$n_detected[i], res$n_articles[i],
                                 cnt$tp[i], cnt$fn[i], cnt$tn[i], cnt$fp[i],
                                 conf_level, n_sim)
          res$adj_low[i] <- 100 * ci[1]
          res$adj_high[i] <- 100 * ci[2]
        }
      })
    }
  }

  tibble::as_tibble(res)
}


#' Count the transparency indicators met by each article
#'
#' Adds a column giving, for each article (row), how many of the transparency
#' indicators were detected. This is the per-article transparency score used to
#' describe how many practices an article adheres to.
#'
#' @param data A data frame with one row per article and indicator columns named
#'   as in [rt_all_pmc()].
#' @param indicators Optional character vector of indicator columns to count.
#'   Defaults to the five openness practices present in `data` (conflicts of
#'   interest, funding, registration, data and code); novelty and replication
#'   are excluded unless requested explicitly, as they are not adherence
#'   practices.
#' @param name Name of the count column to add (default `"n_indicators"`).
#'
#' @return `data` as a tibble with the integer count column added. Rows with no
#'   assessed indicators receive `NA` for the count. Tabulate it (for example
#'   with [table()] or `dplyr::count()`) for the distribution of the number of
#'   practices met.
#'
#' @seealso [rt_summary()]
#' @examples
#' data(rt_demo)
#' scored <- rt_score(rt_demo)
#' table(scored$n_indicators)
#' @export
rt_score <- function(data, indicators = NULL, name = "n_indicators") {
  if (!is.data.frame(data)) {
    stop("`data` must be a data frame.", call. = FALSE)
  }
  if (is.null(indicators)) {
    indicators <- intersect(.rt_practice_indicators(), names(data))
    if (!length(indicators)) {
      # No openness practice present; fall back to any recognized indicator.
      indicators <- .resolve_indicators(data, NULL)
    }
  } else {
    indicators <- .resolve_indicators(data, indicators)
  }
  mat <- vapply(
    indicators,
    function(v) as.integer(.coerce_indicator(data[[v]], v)),
    integer(nrow(data))
  )
  if (is.null(dim(mat))) {
    mat <- matrix(mat, nrow = nrow(data))
  }
  assessed <- rowSums(!is.na(mat))
  score <- as.integer(rowSums(mat, na.rm = TRUE))
  score[assessed == 0] <- NA_integer_
  data[[name]] <- score
  tibble::as_tibble(data)
}


#' Plot transparency indicators
#'
#' Produces a `ggplot` of either the prevalence of each indicator (a bar chart)
#' or the prevalence over time (a line chart). Requires the `ggplot2` package.
#'
#' @param x Either a data frame with one row per article (it is summarized with
#'   [rt_summary()]) or an existing [rt_summary()] result.
#' @param type `"prevalence"` for a bar chart of each indicator's prevalence
#'   (the default), or `"trend"` for prevalence over time (requires `year`).
#' @param indicators,by Passed to [rt_summary()] when `x` is article-level data.
#'   `by` adds facets to the `"prevalence"` plot.
#' @param year For `type = "trend"`, the name of the column in `x` holding the
#'   (numeric) publication year.
#' @param adjusted If `TRUE`, plot the sensitivity/specificity-corrected
#'   prevalence instead of the apparent prevalence. Defaults to `FALSE`.
#' @param accuracy,conf_level Passed to [rt_summary()].
#'
#' @return A `ggplot` object.
#'
#' @seealso [rt_summary()]
#' @examples
#' data(rt_demo)
#' \donttest{
#' if (requireNamespace("ggplot2", quietly = TRUE)) {
#'   rt_plot(rt_demo)                          # prevalence bar chart
#'   rt_plot(rt_demo, type = "trend", year = "year")
#' }
#' }
#' @importFrom rlang .data :=
#' @export
rt_plot <- function(x, type = c("prevalence", "trend"),
                    indicators = NULL, by = NULL, year = NULL,
                    adjusted = FALSE, accuracy = NULL, conf_level = 0.95) {
  type <- match.arg(type)
  rlang::check_installed("ggplot2", reason = "to plot transparency summaries")
  if (!is.data.frame(x)) {
    stop("`x` must be a data frame.", call. = FALSE)
  }
  is_summary <- all(c("indicator", "label", "percent") %in% names(x))
  value_col <- if (adjusted) "adj_percent" else "percent"

  if (type == "prevalence") {
    s <- if (is_summary) {
      x
    } else {
      rt_summary(x, indicators = indicators, by = by, adjust = adjusted,
                 accuracy = accuracy, conf_level = conf_level)
    }
    if (!value_col %in% names(s)) {
      stop("Column `", value_col, "` is not present; ",
           "re-run with `adjust`/`adjusted` set accordingly.", call. = FALSE)
    }
    s$.value <- s[[value_col]]
    p <- ggplot2::ggplot(
      s,
      ggplot2::aes(
        x = stats::reorder(.data$label, .data$.value),
        y = .data$.value,
        fill = .data$label
      )
    ) +
      ggplot2::geom_col() +
      ggplot2::geom_text(
        ggplot2::aes(label = sprintf("%.1f", .data$.value)),
        hjust = -0.15, size = 3.3
      ) +
      ggplot2::coord_flip(clip = "off") +
      ggplot2::scale_y_continuous(
        expand = ggplot2::expansion(mult = c(0, 0.15))
      ) +
      ggplot2::labs(
        x = NULL,
        y = if (adjusted) "Corrected prevalence (%)" else "Prevalence (%)"
      ) +
      ggplot2::theme_minimal() +
      ggplot2::theme(legend.position = "none")
    if (!is_summary && !is.null(by)) {
      p <- p + ggplot2::facet_wrap(stats::as.formula(paste("~", by)))
    }
    return(p)
  }

  # type == "trend"
  if (is_summary) {
    stop("`type = \"trend\"` needs article-level data with a year column, ",
         "not an rt_summary() result.", call. = FALSE)
  }
  if (is.null(year) || !year %in% names(x)) {
    stop("`type = \"trend\"` requires `year` to name a column in `x`.",
         call. = FALSE)
  }
  s <- rt_summary(x, indicators = indicators, by = year, adjust = adjusted,
                  accuracy = accuracy, conf_level = conf_level)
  if (!value_col %in% names(s)) {
    stop("Column `", value_col, "` is not present; ",
         "re-run with `adjusted` set accordingly.", call. = FALSE)
  }
  s$.year <- suppressWarnings(as.numeric(as.character(s[[year]])))
  s$.value <- s[[value_col]]
  ggplot2::ggplot(
    s,
    ggplot2::aes(
      x = .data$.year, y = .data$.value,
      color = .data$label, group = .data$label
    )
  ) +
    ggplot2::geom_line(linewidth = 0.8) +
    ggplot2::geom_point(size = 1.2) +
    ggplot2::labs(
      x = "Year",
      y = if (adjusted) "Corrected prevalence (%)" else "Prevalence (%)",
      color = NULL
    ) +
    ggplot2::theme_minimal()
}
