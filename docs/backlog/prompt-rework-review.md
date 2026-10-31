---
worth: later
added: 2026-10-31
---
# Periodic review of agent transcripts for prompts that caused rework

An `english-review`-style pass over Claude Code / Codex sessions: find prompts that led to rework
(corrections, "wrong", reverted diffs) and name what each lacked — goal, stop boundary, a constraint,
raw material. Output: habits to change, or rules worth moving into CLAUDE.md / skills.

Unknown that settles the value: whether rework is frequent and patterned enough to be worth a skill,
or rare enough that asking "what in my prompt led you here?" on the spot already covers it. Also
open: how to detect rework from transcripts reliably (`~/.claude/projects/*/*.jsonl`).
