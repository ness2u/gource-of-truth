# AGENTS.md — Gource of Truth

Bash tooling that renders a unified Gource visualization ("pseudo-monorepo")
across every git repo under `~/git`, via a containerized Alpine/Gource/FFmpeg
engine. Small, stable utility — see `readme.md` for usage.

Rules:
- Pure Bash + containers; no Python in scripts (use yq/jq/awk if needed).
- `got.conf` controls repo discovery/ignore patterns; `scripts/common.sh` is the
  shared discovery library used by the `super-git-*` mass tools.
- Output `.mp4` artifacts land in `output/` and are not committed.
- History in `audit.md`; tasks in `todo.md`.
