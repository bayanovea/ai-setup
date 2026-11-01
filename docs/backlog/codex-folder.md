---
worth: yes
added: 2026-11-01
---
# add codex/ with the Codex config worth versioning

Bring in a credential-free part of `~/.codex/config.toml` as a snippet, like
`claude/settings.snippet.json`, and decide which `claude/` skills Codex should load from
`~/.codex/skills`. Never copy `~/.codex` wholesale: `auth.json`, `history.jsonl` and the sqlite
state sit next to the config. Later `claude/CLAUDE.md` can become a shared `AGENTS.md` for both.
