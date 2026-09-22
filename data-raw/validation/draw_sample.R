# Draw a random sample of open-access PMC articles from one publication year.
#
# Usage: Rscript draw_sample.R <year> <n> <seed> <out.csv> [extra query]
#
# Searches PMC (E-utilities esearch) for open-access articles published in
# <year>, optionally restricted by an extra query (for enriched samples), and
# draws <n> of them uniformly at random. Set ENTREZ_KEY to
# raise the NCBI rate limit.

args <- commandArgs(trailingOnly = TRUE)
if (length(args) < 4) stop("usage: draw_sample.R <year> <n> <seed> <out.csv> [query]")
year <- args[1]; n <- as.integer(args[2]); seed <- as.integer(args[3]); out <- args[4]
extra <- if (length(args) > 4) paste0(" AND (", args[5], ")") else ""
key <- Sys.getenv("ENTREZ_KEY")
pause <- if (nzchar(key)) 0.11 else 0.34
base <- "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esearch.fcgi?db=pmc"
q <- function(term, retstart, retmax) {
  Sys.sleep(pause)
  uri <- paste0(base, "&term=", utils::URLencode(term, reserved = TRUE),
                "&retstart=", retstart, "&retmax=", retmax,
                if (nzchar(key)) paste0("&api_key=", key))
  xml2::read_xml(uri)
}
# ESearch cannot page past the first 9,999 results, so the PMC UID space is
# bisected until every window holds at most 9,999 matches; articles are then
# drawn uniformly over all matches by mapping global offsets to windows.
term <- paste0('"open access"[filter] AND ', year, "[pdat]", extra)
win_term <- function(lo, hi) sprintf("%s AND %.0f:%.0f[uid]", term, lo, hi)
count <- function(lo, hi) as.integer(xml2::xml_text(xml2::xml_find_first(
  q(win_term(lo, hi), 0, 0), "//Count")))
windows <- data.frame(lo = numeric(0), hi = numeric(0), n = integer(0))
split_range <- function(lo, hi, n = count(lo, hi)) {
  if (n == 0) return(invisible())
  if (n <= 9999 || lo == hi) {
    windows <<- rbind(windows, data.frame(lo = lo, hi = hi, n = n))
    return(invisible())
  }
  mid <- floor((lo + hi) / 2)
  split_range(lo, mid)
  split_range(mid + 1, hi)
}
split_range(1, 99999999)
total <- sum(windows$n)
message("matching articles: ", total, " in ", nrow(windows), " UID windows")
if (total < n) stop("fewer matches than the requested sample")
set.seed(seed)
offsets <- sort(sample.int(total, n) - 1L)
cum <- c(0, cumsum(windows$n))
w <- findInterval(offsets, cum)
within <- offsets - cum[w]
ids <- vapply(seq_along(offsets), function(i) xml2::xml_text(xml2::xml_find_first(
  q(win_term(windows$lo[w[i]], windows$hi[w[i]]), within[i], 1), "//Id")),
  character(1))
res <- data.frame(pmcid = paste0("PMC", ids), year = year, query = term,
                  seed = seed, drawn = format(Sys.Date()))
utils::write.csv(res, out, row.names = FALSE)
message("wrote ", out, " (", nrow(res), " articles)")
