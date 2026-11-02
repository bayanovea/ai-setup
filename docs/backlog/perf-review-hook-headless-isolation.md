---
worth: maybe
where: claude/hooks/perf-review-session-end.sh
added: 2026-11-02
---
# isolate the perf-review hook's headless `claude -p` call

The SessionEnd hook runs `claude -p "/perf-review-log ..."` under the main `~/.claude` config, so
that run loads the global `CLAUDE.md` and fires every user hook (reply-format reminder, agterm naming,
possibly SessionEnd again). It needs the `perf-review-log` skill, so a separate `CLAUDE_CONFIG_DIR`
does not fit as is; parts of `claude/recipes/isolated-headless-claude.md` do (empty cwd,
`--setting-sources ""`). Check what fires today, then decide what to strip.
