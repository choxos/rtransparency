# Builds data/rt_demo.rda: a small, simulated corpus of detector output used to
# illustrate rt_summary(), rt_score() and rt_plot() in examples and the
# vignette. The data are SIMULATED, not real detector output; prevalences and
# their time trends are chosen to resemble published findings (high conflicts of
# interest and funding disclosure, lower protocol registration, low but rising
# data sharing, and rare code sharing) so the illustrations look realistic.

set.seed(2024)

n <- 1200L
year <- sample(2010:2024, n, replace = TRUE)
type <- sample(
  c("research-article", "review-article", "systematic-review"),
  n, replace = TRUE, prob = c(0.70, 0.20, 0.10)
)

# Centered, scaled year so the logistic trends are gentle.
yr <- (year - 2017) / 4
draw <- function(intercept, slope) {
  stats::rbinom(n, 1, stats::plogis(intercept + slope * yr)) == 1L
}

rt_demo <- tibble::tibble(
  pmid = sprintf("%08d", sample(20000000:39999999, n)),
  year = year,
  type = type,
  is_coi_pred         = draw( 0.9, 0.45),  # ~70-75%, rising
  is_fund_pred        = draw( 1.3, 0.30),  # ~80%
  is_register_pred    = draw(-1.1, 0.50),  # ~25%
  is_open_data        = draw(-1.8, 0.70),  # ~15-20%, rising
  is_open_code        = draw(-3.1, 0.80),  # ~5%, rising
  is_novelty_pred     = draw( 0.1, 0.10),
  is_replication_pred = draw(-2.4, 0.20)
)

save(rt_demo, file = "data/rt_demo.rda", version = 2)
