---
name: memory-audit
description: Audit and clean Claude Code's auto-memory (~/.claude/projects/<slug>/memory/) for one project or all of them. Inventories every memory file, sorts each into keep / trim / merge / move / delete, promotes stable rules to CLAUDE.md or a skill, rebuilds MEMORY.md and reports what changed and why. Use on /memory-audit, when the user asks to clean or review memory, when a memory contradicts the repo or the user, or when a MEMORY.md index passes ~25 lines.
---

# Memory audit

Auto-memory is a per-git-root directory: `~/.claude/projects/<cwd-with-slashes-as-dashes>/memory/`
(the slug is the **git root**, so every project inside one repo shares a directory: `~/AI` holds
job-study, lazada-scout sessions started from `~/AI`, and the coaching side of vk-ad-skip).
`MEMORY.md` is loaded into every session; the other files are read on demand. So the index costs
context every time, and a wrong fact in any file costs a wrong action once it is read.

## 1. Inventory

```bash
cd ~/.claude/projects && for d in ./*/memory; do
  n=$(ls -- "$d" | wc -l | tr -d ' '); echo "$n  $d"; done | sort -rn
```

Then for each non-empty dir: `cat MEMORY.md`, `ls -lt`, and read every file (they are short). Note
the git root and the project `CLAUDE.md`, `docs/backlog/`, `docs/plans/completed/`, project skills:
those are the places a memory may already duplicate.

Back up before touching anything:
`tar czf ~/.claude/memory-backup-$(date +%F).tgz -C ~/.claude/projects <each>/memory`.

## 2. Sort every file

One verdict per file. The questions, in order:

1. **Is it still true?** Location, host, CLI names, flags, dates that passed. A memory that says
   "pending check on <date>" where the date is gone, or names a command that was renamed → **delete**
   (or fix if the durable part is still needed).
2. **Is it a task or a journal entry?** "Deploy X, day-after check pending", "state as of <date>",
   per-session logs, shopping rounds → not memory. Finished work → **delete**; open work → **move** to
   the repo (`docs/backlog/`, a plan's Post-Completion, the data dir) and keep at most a one-line
   pointer.
3. **Does the repo already say it?** Ops recipes, flags, architecture in `CLAUDE.md`; completed plans;
   research docs → **delete** the duplicate, keep only the sentence that is *not* derivable (the
   owner's decision, the why-not, the invariant).
4. **Is it a stable rule that a skill or CLAUDE.md applies at the moment it matters?** A feedback
   memory with three or more "Update" / "Nth time" paragraphs is a rule memory did not enforce.
   **Promote** it: into the skill that runs at that moment (e.g. a review skill) or the project
   `CLAUDE.md`, and shrink the memory to the rule plus one line of why.
5. **Several files on one topic?** Grading rules, question format, deploy mechanics → **merge** into
   one file with numbered sections; update `[[links]]` and any skill that names the old files.
6. Otherwise **keep**, and **trim**: a memory is the current rule, one *why* (date + what happened),
   one *how to apply*. History stays only when it changes how to apply the rule.

What belongs in memory and nowhere else: user preferences and corrections with their reason;
owner decisions and their why-not; invariants that are not visible in code (ordering, "never do X
by itself"); pointers to private data locations; calibration facts ("my estimates run 2–3× low").

## 3. Apply

- `rm` deleted files; write merged/trimmed ones; keep frontmatter (`name`, `description`, `type`).
- Moved content goes to the repo or data dir first, then the memory becomes a pointer.
- Rebuild `MEMORY.md`: one line per file, hook ≤ 120 chars, grouped (feedback → reference → project).
- Verify: every `[[link]]` resolves, every file is indexed, every index line has a file, no
  memory contradicts `CLAUDE.md`. A link check:

```bash
d=~/.claude/projects/<slug>/memory
grep -oh '\[\[[^]]*\]\]' "$d"/*.md | sort -u | tr -d '[]' | while read -r l; do [ -f "$d/$l.md" ] || echo "dangling: $l"; done
for f in "$d"/*.md; do b=$(basename "$f"); [ "$b" = MEMORY.md ] || grep -q "($b)" "$d/MEMORY.md" || echo "not indexed: $b"; done
```

- If a skill referenced merged memory names, update the skill in the same pass.

## 4. Report

Verdict with per-project before → after counts; `From you`: what the user must decide (e.g. a
memory that contradicts a current instruction). After the blank line, one list: what was deleted
and why (one line per group, not per file), what was promoted or moved and where. Keep the backup path in the report.

## `--report` mode (headless, launchd every 2 weeks)

Invoked as `/memory-audit --report` by `run-report.sh` (`claude -p`, no user present). The script
has already run the mechanical checks and passes their output in the prompt: active projects
(sessions newer than the previous report), per-project counters, dangling `[[links]]`, unindexed
files, index lines without a file. In this mode:

- Memory files are Claude's own notes: read every one of them, including those whose *name* mentions
  keys or private data (they hold pointers, not secrets). The ALARM rule applies to the files they
  point to, never to the memory files themselves.
- **No edits and no backup in this mode**: headless writes under `~/.claude` are refused by the
  harness, and judgement about what is still true belongs to an interactive run with the user. The
  mechanical fixes from the script's output and "check / pending by <date>" sentences whose date has
  passed go into the report as the first section, "Apply next time".
- A candidate goes into the report only on §2 questions 1–3 (no longer true, task or journal,
  duplicates the repo) with the evidence (the CLAUDE.md line, the passed date, the renamed command).
  Style merges and "could be shorter" are not candidates; they only grow the report.
- Report = counters, fired triggers, mechanical fixes to apply, candidates (file, verdict, evidence),
  and what the user must decide. Write it to the path given in the prompt
  (`~/AI/ai-setup-private/claude/memory-audit/YYYY-MM-DD.md`, outside the public repo), nothing else.

## When to run

- A project memory index passes ~25 lines, or a file passes ~2 KB.
- Any memory turned out wrong in a session (the user corrected a "fact" that came from memory).
- After a project milestone: publication, migration, a plan moved to `completed/`, a search or
  phase closed. Most task-state memories die at that moment.
- Routine: every 3–4 weeks for an active project; once a quarter for the rest.

## Symptoms that memory is hurting, not helping

- The same correction is written into memory more than twice ("third time", "Update N").
- Memory and `CLAUDE.md` disagree on a host, flag, command or language rule.
- A session starts by reading a long memory as a to-do list, or memory tells the next session to
  "check X on <date>".
- A memory holds data the repo or data dir should hold (requirements, round logs, numbers that
  change weekly), and a short rewrite once lost a requirement the user noticed.
- Two memory directories hold overlapping facts about one repo (shared git root + the repo's own).
