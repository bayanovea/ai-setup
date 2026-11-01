---
worth: yes
added: 2026-11-01
---
# Move the remaining private data under ~/AI/ai-setup-private/

`AGENTS.md` sets one place for private data, `~/AI/ai-setup-private/<tool>/`. Two locations predate it:

- `~/AI/english-learning/` (corpus, journals, drills): paths in `claude/skills/english-prompt` and
  `claude/skills/english-review`, and the `mkdir` in `install.sh`.
- `~/Work/perf-review/` (`PERF_REVIEW_DIR`): `claude/hooks/perf-review-session-end.sh`,
  `claude/skills/perf-review-log`. It may sit under `~/Work` on purpose; ask before moving it.

Done when both live under the template and nothing in the repo points at the old paths.
