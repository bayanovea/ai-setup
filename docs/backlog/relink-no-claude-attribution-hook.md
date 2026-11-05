---
worth: yes
where: ~/.claude/hooks/no-claude-attribution.sh
added: 2026-11-01
---
# relink the live no-claude-attribution hook to the repo copy

`claude/hooks/no-claude-attribution.sh` is in the repo, but `~/.claude/hooks/no-claude-attribution.sh`
is still the plain file it was copied from, so an edit to the repo copy does not reach the live
guard. Rerun `install.sh`: it moves the plain file to `.bak` and links the repo copy. Delete the
`.bak` afterwards.
