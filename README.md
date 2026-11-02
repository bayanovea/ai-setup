# ai-setup

My AI-tool setup, one folder per tool. `claude/` holds the Claude Code configuration: global rules,
hooks and skills, symlinked into `~/.claude` by `install.sh`. Everything here is employer-independent
and public; the rules for this repo are in `AGENTS.md`.

## What's inside

| Path | What it is | Why |
|---|---|---|
| `claude/CLAUDE.md` | Global rules for every project | Reply format with fixed labelled blocks (Verdict / From you, then Why / Aside after a blank line), language rule, how I want agents to work, sensitive-data stop, code-comment and plan rules |
| `claude/hooks/answer-style-reminder.sh` | `UserPromptSubmit` | Re-injects the reply-format rule every turn. `CLAUDE.md` is read once per session and loses weight in a long context; this doesn't |
| `claude/hooks/sensitive-file-guard.sh` | `PreToolUse` / `Read` | Pauses reads of files whose *name* looks like secrets (`.env`, `*.pem`, `credentials`, …) and asks for explicit approval. Name-based on purpose — content matching would fire on every IP in normal code |
| `claude/hooks/agterm-idle-after-clear.sh` | `Notification` / `idle_prompt` | Under agterm, clears the unseen badge left by the idle ping of a session with no reply yet (right after `/clear`). Claude Code cannot mute only that ping |
| `claude/hooks/agterm-session-name.sh` | `UserPromptSubmit` / `Stop` / `SessionStart` | Under agterm, names the tab after the topic Claude Code puts in its terminal title. A leading `[project]` the user typed is kept; `/clear` leaves only it, or `✳ new` without one. Hook-driven because a rule asking the model to set the name was forgotten more often than not |
| `claude/hooks/perf-review-session-end.sh` | `SessionEnd` | For projects that opt in (`perf-review-track: true` in `CLAUDE.local.md`): distils the session transcript into a performance-review file via a headless `claude -p` call with a $1 budget |
| `claude/skills/english-prompt` | skill | Corrects my English prompt, fills small gaps, appends one record to a learning corpus, then runs the task. Runs on every English message |
| `claude/skills/english-review` | skill | Periodic pass over that corpus: error classes, accuracy per class, CEFR rating with evidence, drills built from my own sentences |
| `claude/skills/save-clear` | skill | `/save-clear`: walks the session, routes durable facts to auto-memory and open work to plans/backlog, reports, then types `/clear` into its own agterm session |
| `claude/skills/perf-review-log` | skill | Merges significant work into one review artifact without turning it into a log |
| `claude/skills/unit-test-writer` | skill | Behaviour-first unit tests, table-driven, mock at boundaries only |
| `claude/skills/split-branch-for-review` | skill (manual only) | Rewrites a squash-merged branch into a sequence a reviewer can read top to bottom |
| `claude/skills/make-text-not-ai` | skill | Strips the AI fingerprint from any text (EN/RU) without changing facts, meaning or register. Three tiers: delete on sight, fix above a density threshold, leave alone; then a shape pass, since detectors weigh structure over words. Marker lists and the source numbers live in `references/` |
| `claude/recipes/isolated-headless-claude.md` | recipe | Calling `claude -p` from a script on the subscription with none of my rules, hooks, plugins or MCP servers: a dedicated `CLAUDE_CONFIG_DIR` plus the flags that close the remaining leaks (`--bare` needs an API key) |
| `hermes/docker-compose.yaml` | Hermes gateway | Runs `nousresearch/hermes-agent` with `~/.hermes` as its data volume: `docker compose -f hermes/docker-compose.yaml up -d`. Credentials and the agent's state stay in `~/.hermes`, never here |
| `templates/AGENTS.md` + `CLAUDE.local.md` | per-repo template | One tool-agnostic rules file read by Claude Code, Codex and OpenCode |
| `reference/ralphex-roles/` | prompts | Five review roles (implementation, testing, quality, simplification, documentation) usable as subagent prompts in any multi-agent review |
| `reference/task-spec-format.md` | format | Three-section task description: what exists / what to change / resulting scenario and checks |
| `claude/settings.snippet.json` | settings | The hook, skill-override and display entries to merge into `~/.claude/settings.json`. `tui: fullscreen` + `viewMode: focus` show one line per tool call and the reply; `Ctrl+O` expands the rest |

Private data lives outside this repo, in `~/AI/ai-setup-private/<tool>/` (memory-audit reports), plus
two older locations: `~/AI/english-learning/`, `~/Work/perf-review/`.

## Install

```bash
git clone <this repo> ~/AI/ai-setup
~/AI/ai-setup/install.sh
# merge claude/settings.snippet.json into ~/.claude/settings.json, then /hooks or restart
```

Check: a reply starts with ▶ **Verdict**; asking to read any `.env` raises the ⛔🚨 banner.

## Design notes

- **Format over length.** The old rule said "be brief" and still produced walls of text I could not
  skim across several parallel sessions. Fixed block labels fix the *reading* problem: the eye lands
  on the same place every time, and a missing label is visible at a glance.
- **Hook, not just a rule.** A style rule in `CLAUDE.md` fades by the middle of a long session. The
  per-turn hook is what keeps it alive.
- **Name-based secret guard.** Content heuristics fire on every hostname in real code; file names are
  a narrow, cheap and good-enough signal.
