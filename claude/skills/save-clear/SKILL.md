---
name: save-clear
description: Persist what this session learned, then clear the context. Use on /save-clear, or when the user says they are about to run /clear, /compact, start a new session, or asks to "save what needs saving and clear". Writes durable facts to auto-memory, open work to the repo (plan Post-Completion, backlog, project CLAUDE.md), reports what was saved and dropped, then types /clear into the session itself when running under agterm.
---

# Save, then clear

The context is about to disappear. Everything worth keeping must land in a file now; everything
else is noise and must not be written anywhere. Default is to save little: a session that produced
only ordinary work saves nothing, and that is a correct outcome.

Do not ask questions unless a single item genuinely needs the user's call. Do not commit, push, or
run anything that changes repo state beyond writing the files below.

## 1. Walk the session

Reread the conversation from the start and list candidates in four buckets:

- **User corrections and preferences** — anything the user told you to do differently, confirmed as
  right, or stated about themselves and their tools. Include the reason they gave.
- **Decisions and invariants** — choices with a why-not, constraints not visible in code, "never do
  X on its own", calibration facts ("my estimates run 2× low").
- **Open work** — tasks started and not finished, follow-ups the user agreed to, things found and
  parked, open questions that only the user can answer.
- **Pointers** — URLs, tickets, dashboards, private data locations that came up and are not already
  recorded anywhere.

Drop anything that: the repo, its `CLAUDE.md`, git history or a completed plan already records; is a
journal entry ("today we did X"); is transient build state; or is derivable from the code.

## 2. Route each survivor to its home

One home per item, chosen in this order:

| Item | Home |
|---|---|
| Correction, preference, calibration, owner decision with its why | auto-memory: `~/.claude/projects/<slug>/memory/<name>.md` + one index line in `MEMORY.md` |
| Rule the user had to repeat, or one a skill should apply at the moment it matters | project `CLAUDE.md` or the relevant skill (then memory keeps only a one-line pointer, if anything) |
| Unfinished task in an active plan | that plan's Post-Completion / tasks section in `docs/plans/` |
| Unfinished task with no plan | `docs/backlog/` if the project has it, else a `project` memory with the next concrete step |
| Significant accomplishment, hard problem solved | only if the project opts in (`perf-review-track: true` in `CLAUDE.local.md`): run `/perf-review-log` |
| External resource | `reference` memory, unless a repo doc is the obvious place |

Memory files follow the frontmatter format (`name`, `description`, `metadata.type`), one fact per
file, `**Why:**` and `**How to apply:**` lines for feedback and project entries, `[[links]]` to
related memories. Before writing, check whether an existing memory already covers the fact and
update it instead of adding a duplicate. Convert "today", "yesterday", "next week" to absolute
dates. Never put content into `MEMORY.md`, only the one-line pointer.

Uncommitted changes in the working tree are not yours to save: mention them in the report so the
user decides.

## 3. Schedule the clear, then report

`/clear` is a CLI command, not a tool: the model cannot run it directly. Under agterm the session
can type it into itself. If a question for the user is still open (step 2 produced an item you
could not place, or uncommitted changes need a decision), skip this step, ask, and let the user
clear by hand — a `/clear` landing on top of an unanswered question loses the question.

When `AGTERM_ENABLED=1` and `AGTERM_SESSION_ID` is set, as the **last tool call** of the turn:

```bash
(nohup sh -c 'sleep 4; agtermctl session type "/clear
" --target "$AGTERM_SESSION_ID" --socket "$AGTERM_SOCKET"' >/dev/null 2>&1 &)
```

The delay lets the report below reach the screen first; the detached shell survives the tool
call. The keystrokes land in the prompt buffer the user also types into, so the report must warn
in one line that `/clear` fires in a few seconds. If the typed command arrives as a queued message
instead of executing, say so once in the next session's first reply and leave the clear to the
user — do not retry typing.

Outside agterm: end the report with one line asking the user to run `/clear`.

Then the report, in standard reply blocks. Verdict: how many items saved and where, in one
sentence, plus the clear notice. `From you`: uncommitted changes, and any item you could not
place. After the blank line, one list: each saved item with its path, and one line for what was
considered and dropped (grouped, with the reason). If nothing was worth saving, say so in one sentence.
