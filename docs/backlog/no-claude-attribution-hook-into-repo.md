---
worth: yes
where: ~/.claude/hooks/no-claude-attribution.sh
added: 2026-11-01
auto: yes
---
# move the no-claude-attribution hook into claude/hooks/

`claude/CLAUDE.md` says a PreToolUse hook blocks Claude attribution in commits, but the hook is a
plain file in `~/.claude/hooks`, not a symlink, and `claude/settings.snippet.json` lacks its entry
(`~/.claude/settings.json:91` has it). A fresh install gets the rule without the guard. Move the
file to `claude/hooks/`, rerun `install.sh`, add the entry to the snippet and a README row.

Verified approach: copy the file byte-identical with mode 755, since `install.sh` already links
every `claude/hooks/*.sh`. Add a `PreToolUse` entry with matcher `Bash` and timeout 5, as the live
settings have it. The repo change alone changes nothing live: the plain file keeps running until
`install.sh` replaces it with a symlink and leaves a `.bak`. That rerun touches the live home, so
an agent leaves it to the owner and narrows this item to it.
