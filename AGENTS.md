# ai-setup — project rules

My setup for AI tools. One top-level folder per tool (`claude/`, later `codex/`, `hermes/`,
`agterm/`); tool-agnostic material (`templates/`, `reference/`) stays at the root.

## This repo is public

Everything committed here is published. Nothing personally sensitive goes in:

- secrets, tokens, `.env`, `auth.json` and other credential files;
- personal data, private correspondence, chat or session transcripts;
- to-do lists, task boards, calendars;
- corpora, journals and reports built from my sessions or memory.

Not sensitive: rules, skills, hooks, prompts, configs without credentials, a bot's personality
(hermes `SOUL.md`).

- When in doubt, stop and ask before writing or committing it.
- Before each commit, check the staged diff against the list above.
- Bring a tool's config in file by file. Never link or copy a tool's home (`~/.hermes`, `~/.codex`)
  wholesale: they keep credentials next to the config.

## Where private data goes

One template: the private counterpart of `<tool>/…` lives in `~/AI/ai-setup-private/<tool>/…`,
outside this repo. The repo refers to it only by path, and `install.sh` creates the directories.
Example: memory-audit reports go to `~/AI/ai-setup-private/claude/memory-audit/`.
Putting that directory under git or on any remote is my call; ask first.
