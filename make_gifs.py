"""Animate my commit history for the profile README.

Run: uv run make_gifs.py
"""

# /// script
# requires-python = ">=3.10"
# dependencies = ["hubbub @ git+https://github.com/mjfrigaard/hubbub"]
# ///

import tempfile
from datetime import date
from pathlib import Path

import matplotlib

matplotlib.use("Agg")
import matplotlib.pyplot as plt  # noqa: E402
import polars as pl  # noqa: E402

import hubbub as hb  # noqa: E402

commits = pl.read_parquet("data/commits.parquet")
stars = pl.read_parquet("data/stars.parquet")


def save_frame(fig, frames: Path, i: int, width: int, height: int) -> None:
    fig.set_size_inches(width / 96, height / 96)
    fig.savefig(frames / f"{i:04d}.png", dpi=96, facecolor="white")
    plt.close(fig)


# recipe 1: cumulative commits, sliding the end date ----
frames = Path(tempfile.mkdtemp(prefix="cumulative-frames-"))
ends = pl.date_range(date(2023, 2, 1), commits["date"].max(), "1mo", eager=True)
for i, end in enumerate(ends, start=1):
    fig = hb.cumulative_line_plot(
        commits, date_begin="2023-01-01", date_end=end, top_n=8
    )
    save_frame(fig, frames, i, 1000, 600)
hb.make_gif(frames, "cumulative.gif", 1000, 600,
            first_duration=1, frame_duration=0.4, last_duration=4)

# recipe 2: calendar heatmap, year by year ----
years = sorted(commits.filter(pl.col("year") >= 2023)["year"].unique())
frames = Path(tempfile.mkdtemp(prefix="calendar-frames-"))
for i, yr in enumerate(years, start=1):
    fig = hb.calendar_heatmap_plot(
        commits, date_begin=f"{years[0]}-01-01", date_end=f"{yr}-12-31",
        title=f"Through {yr}",
    )
    save_frame(fig, frames, i, 1100, 700)
hb.make_gif(frames, "calendar.gif", 1100, 700,
            first_duration=1, frame_duration=1.2, last_duration=4)

# recipe 3: punchcard carousel across repos ----
# rank by commit count
top_repos = (
    commits.group_by("repo").agg(n=pl.len())
    .sort("n", descending=True)["repo"].head(6).to_list()
)
# alternative: rank by stars received
# top_repos = stars["repo"].head(6).to_list()
frames = Path(tempfile.mkdtemp(prefix="punchcard-frames-"))
for i, repo in enumerate(top_repos, start=1):
    save_frame(hb.punchcard_plot(commits, repo=repo), frames, i, 1000, 500)
hb.make_gif(frames, "punchcard.gif", 1000, 500,
            first_duration=1, frame_duration=1.5, last_duration=4)

# spiral (static copy of the interactive chart in the hubbub walkthrough) ----
fig = hb.spiral_horizon_plot(commits, date_begin="2020-01-01")
fig.savefig("spiral.png", dpi=96, bbox_inches="tight", facecolor="white")
plt.close(fig)

# introduction ----
hb.who_am_i_gif(
    name="Martin",
    likes="#rstats and data visualization.",
    learn="Shiny for Python app development and Linux administration",
    work="Shiny app-package development tools.",
    collab="#rstats and #pystats packages for data science.",
    output="who_am_i.gif",
)
print("Wrote cumulative.gif, calendar.gif, punchcard.gif, spiral.png, who_am_i.gif")
