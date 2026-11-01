---
worth: yes
where: ~/.claude/hooks/no-claude-attribution.sh
added: 2026-11-01
---
# move the no-claude-attribution hook into claude/hooks/

`claude/CLAUDE.md` says a PreToolUse hook blocks Claude attribution in commits, but the hook is a
plain file in `~/.claude/hooks`, not a symlink, and `claude/settings.snippet.json` lacks its entry
(`~/.claude/settings.json:111` has it). A fresh install gets the rule without the guard. Move the
file to `claude/hooks/`, rerun `install.sh`, add the entry to the snippet and a README row.
