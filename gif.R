# install.packages(c("gifski", "ggplot2"))
library(gifski)
library(ggplot2)

# remotes::install_github("mjfrigaard/ghreadme")
library(ghreadme)

# pull commits + stars + issues + prs in one call ----
# (multi-include returns a named old shape)
# stats <- collect_git_commits(
#   user    = "mjfrigaard",
#   emails  = c("mjfrigaard@pm.me", "mjfrigaard@gmail.com"),
#   include = c("commits", "stars", "issues", "prs")
# )
stats <- readRDS(file = "2026-06-03-stats.rds")

# recipe 1: cumulative commits, sliding the end date ----
date_seq <- seq(
  from = as.Date("2023-02-01"),  # one month after date_begin
  to   = max(stats$commits$date),
  by   = "1 month"
)

cum_dir <- file.path(tempdir(), "cumulative-frames")
dir.create(cum_dir, showWarnings = FALSE, recursive = TRUE)

for (i in seq_along(date_seq)) {
  p <- cumulative_line_plot(
    stats$commits,
    date_begin = "2023-01-01",
    date_end   = date_seq[[i]],
    top_n      = 8
  )
  ggsave(
    filename = file.path(cum_dir, sprintf("%04d.png", i)),
    plot     = p,
    width = 1000, height = 600, units = "px", dpi = 96, bg = "white"
  )
}

make_gif(cum_dir, "cumulative.gif",
         width = 1000, height = 600,
         first_duration = 1, frame_duration = 0.4, last_duration = 4)

# recipe 2: calendar heatmap, year by year ----
years <- sort(unique(stats$commits$year))

cal_dir <- file.path(tempdir(), "calendar-frames")
dir.create(cal_dir, showWarnings = FALSE, recursive = TRUE)

for (i in seq_along(years)) {
  p <- calendar_heatmap_plot(
    stats$commits,
    date_begin = paste0(min(years), "-01-01"),
    date_end   = paste0(years[[i]], "-12-31"),
    title      = paste("Through", years[[i]])
  )
  ggsave(
    filename = file.path(cal_dir, sprintf("%04d.png", i)),
    plot     = p,
    width = 1100, height = 700, units = "px", dpi = 96, bg = "white"
  )
}

make_gif(cal_dir, "calendar.gif",
         width = 1100, height = 700,
         first_duration = 1, frame_duration = 1.2, last_duration = 4)

# recipe 3: punchcard carousel across repos ----
# Rank by commit count (original behavior):
top_repos <- stats$commits |>
  dplyr::count(repo, sort = TRUE) |>
  dplyr::slice_head(n = 6) |>
  dplyr::pull(repo)

# Alternative: rank by stars received (now that stats$stars is available)
# top_repos <- head(stats$stars$repo, 6)

punch_dir <- file.path(tempdir(), "punchcard-frames")
dir.create(punch_dir, showWarnings = FALSE, recursive = TRUE)

for (i in seq_along(top_repos)) {
  p <- punchcard_plot(stats$commits, repo = top_repos[[i]], title = top_repos[[i]])
  ggsave(
    filename = file.path(punch_dir, sprintf("%04d.png", i)),
    plot     = p,
    width = 1000, height = 500, units = "px", dpi = 96, bg = "white"
  )
}

make_gif(punch_dir, "punchcard.gif",
         width = 1000, height = 500,
         first_duration = 1, frame_duration = 1.5, last_duration = 4)