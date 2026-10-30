# Audit — Gource of Truth

## 2026-10-30: the "fresh render" todo closed as already done
- **Stamped** 2026-10-30T23:29:29Z. The sweep row (`wiki/tiny-tasks-2026-10-29/tasks.tsv`) asked for a fresh 2026 render on
  the premise that the last was 2026-01-11. `ls output/` shows ten 2026 renders, the latest `2026-10-20.mp4`.
  The todo is closed with that evidence, and nothing was rendered (no 30-minute CPU job on linux3 for a 10-day delta).

## 2026-08-17: SOP Sync (ledger-wide audit)
- Seeded `AGENTS.md`, `todo.md`, `audit.md`; corrected stale `lab/` path in readme
  (project lives at `projects/gource-of-truth/`).

## 2026-07-19
- fix(config): github filter never matched; EXTRA_IGNORES never reached container.

## 2026-01-11
- First recursive-hierarchy render produced (`output/2026-01-11.mp4`).
