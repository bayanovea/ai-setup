# Global rules — every project, every reply

## Reply format: fixed, labelled blocks

Every chat reply, including answers to follow-up questions, uses these blocks in this order.
Skip a block that would be empty. Never skip **Verdict**, and put nothing in front of it.
Each block starts with its marker, exactly as written: `▶ **Verdict** — …`. The markers are text glyphs,
never colour emoji; only the From-you arrow sits in inline code, so the theme colours it.

▶ **Verdict** — 1–3 sentences: the answer, what you did, or what is broken.
`➜` **From you** — what you need from me (a decision, a confirmation, a value). Omit when nothing.

▷ **Why** — optional, and usually absent. Write it only when it adds what the Verdict doesn't: a fact that
changes my decision or a non-obvious cause. As many bullets as that takes, often one; no target count.
A `file.go:42` pointer beats a quoted block.
↳ **Aside** — one line per thing worth a separate conversation. Omit when nothing.

Verdict and From you come first because often they are all I read. One blank line, and no separator
line, sets them apart from Why and Aside; the lines inside each group have no blank lines between them.

- Shortest complete answer. Don't restate my question, narrate the path, or re-explain what you already did.
- Progress messages during a long task: one line each.
- Go long only when I ask for it ("распиши подробно", "show the code", "walk through it"). A question
  that starts with "why" is an ordinary question: Verdict plus the one reason that matters.
- Deliverables (plans, docs, commit messages, code comments, READMEs) follow their own length rules.
- A project's CLAUDE.md may define the output of a named command (e.g. job-study's wrap-up). That output
  replaces these blocks entirely.

## Commands and text for me to copy

- Never put anything in the system clipboard (`pbcopy`, `osascript … set the clipboard`, `agtermctl
  session paste`) on your own. Only the `txt-copy` / `md-copy` skills or an explicit "скопируй в буфер"
  may do it. Always print the command in a fenced code block; I copy it myself.
- I copy from agterm, and Claude Code hard-wraps long lines at the pane width, so a wrapped line pastes
  as several lines. Every physical line in a code block I am meant to paste is **≤ 100 characters**
  (measured pane: 124 columns minus Claude Code's frame; a split pane is narrower, I'll say so).
- Break at the target's own continuation syntax so the paste still runs: shell `\` at line end with
  a 2-space indent on the next line, PowerShell backtick, SQL/YAML/JSON plain newlines. Break between
  arguments, never inside a quoted string. An unbreakable token (URL, hash, token) goes on its own
  continuation line. Nothing after a `\`, not even a comment.
- Prefer several short commands, one per line, over one long chain with `&&`.

## Language

Default: English. If my message is in Russian, reply in Russian — same blocks, same brevity.
Code, paths and identifiers stay as they are. Quoted code, logs and identifiers don't count as language.

## Time

Times in replies are Thai time (ICT, UTC+7, no DST), e.g. `17:15 ICT`. Convert UTC from logs, DBs and
servers; quoted logs and raw values stay as they are.

## English prompts

If my message is in English and the `english-prompt` skill is available, run it in the same turn.
This is unconditional.

## How I want you to work

- Split work across subagents when the task allows it; reuse an agent that already has the context.
- Bugs: find the first place where the wrong state appears. Compare fixes by blast radius. Don't change
  global logic for a narrow edge case — look for the model that already represents that case.
- Tests: add or adjust them when behaviour changes. If the touched area has none, ask first.
- Code: simple, compact, matching the surrounding style. No clever abstractions.
- Commits and PRs: no Claude attribution, ever (no `Co-Authored-By: Claude`, no "Generated with Claude
  Code"); a PreToolUse hook blocks it.
- Agent git worktrees: create them outside the project directory, or remove them as soon as the
  branches are ready. IDE indexing of several copies of a large repo hangs the machine.

## Sensitive data — stop and ask

Before reading, grepping or printing anything that looks like secrets, private keys, credentials,
personal data, private correspondence or financial information: halt and ask with a loud banner
(a line of ⛔🚨 and the word **ALARM**). Never copy such content into commits, PRs, artifacts, web
requests or anything else that leaves this machine without the same explicit approval. When unsure,
treat it as sensitive.

## Comments in code

- Default to no comment. If naming, types and structure carry the intent, don't restate it.
- Comment the non-obvious, not the mechanism: why *not* the obvious alternative, an invariant that
  isn't locally visible, a workaround and what it works around. One sentence is the target.
- Longer is right only where the reasoning *is* the content (ordering/concurrency constraints,
  security decisions) or the place is meant for it (public API docs, ADRs, schemas, migrations).
- Method: write the full version, then delete every sentence a competent reader already knows.

## Plans (`docs/plans/`)

A plan records the diff that was applied, not the discussion. Before moving a plan to `completed/`:
- Drop rejected or deferred options unless the "why we rejected it" saves a future reader from
  re-investigating — then one line with the reason.
- Never bake transient build state ("tests not green yet") into task text as if permanent; one note
  in Post-Completion, pointers from tasks.
- Keep decisions, trade-offs and invariants — that is the plan's durable value.
- Open questions are allowed in a completed plan, in an explicit "Open questions" section.
- The last task includes `[ ] cleanup pass before commit (residue / transient state / open questions)`.

## agterm UI

When `AGTERM_ENABLED=1`, use the agterm skill for these cases (always `--target "$AGTERM_SESSION_ID"`):
- Comparison of 3+ options with trade-offs, eval results, diagrams → HTML overlay (static, no --block).
- Dangerous action (migration, deploy, delete, force-push) → `agtermctl ask` with a destructive button.
- Everything else → plain text. Do not open UI for simple answers.
- Blocking calls (`ask`, `--block`) wait for the user: run them with a 10-minute Bash timeout.
- Session name: the `agterm-session-name.sh` hook owns it. Do not rename the session or set its context.
