---
worth: yes
added: 2026-11-01
---
# put ~/.config/agterm under git as agterm/

`~/.config/agterm` has no version history: `keymap.conf`, `hooks.conf`, `ghostty.conf`,
`restore-denylist.conf`, `claude-mode.sh` and `agent-status/` (Claude, Codex, opencode, pi status
scripts). Move them into `agterm/` and add an agterm section to `install.sh` that symlinks them back.
Read each file before committing (the repo is public, see `AGENTS.md`); the denylist may name
private paths.
