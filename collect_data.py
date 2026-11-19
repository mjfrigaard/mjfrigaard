"""Pull my GitHub activity with hubbub and save it to data/.

Run: GITHUB_PAT=$(gh auth token) HUBBUB_EMAILS="a@x.com,b@y.com" uv run collect_data.py
"""

# /// script
# requires-python = ">=3.10"
# dependencies = ["hubbub @ git+https://github.com/mjfrigaard/hubbub"]
# ///

import os
from pathlib import Path

from hubbub import collect_git_commits

emails = [e for e in os.environ.get("HUBBUB_EMAILS", "").split(",") if e] or None

stats = collect_git_commits(
    user="mjfrigaard",
    emails=emails,
    include=["commits", "stars", "issues", "prs"],
    tz="America/Phoenix",
)
Path("data").mkdir(exist_ok=True)
for name, df in stats.items():
    df.write_parquet(f"data/{name}.parquet")
    print(name, df.shape)
