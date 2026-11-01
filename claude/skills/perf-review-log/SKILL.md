---
name: perf-review-log
description: Update the personal performance-review artifact with distilled, non-duplicate accomplishments, hard problems solved, and leadership work. Use when the user runs /perf-review-log manually, or when invoked headlessly by the SessionEnd hook with a condensed-transcript path argument.
---

# perf-review-log

Maintains one artifact for an engineer's periodic performance review:

```
~/Work/perf-review/review.md        # or $PERF_REVIEW_DIR/review.md
```

This is one specific personal file, not a per-project config. Always read it before editing, and
always edit by merging (see "Merge rule"), never by rewriting the file.

If the file does not exist yet, create it with the section headings below and nothing else.

## File sections (H2 headings)

- `## Key achievements and impact`
- `## Technical decisions and hard problems`
- `## Leadership, mentoring, process`
- `## Cross-team work`
- `## Metrics`
- `## 🔍 Draft — needs review`

## What counts as significant (write it in)

- Shipped features/projects with a clear outcome or impact.
- Hard technical problems: root-caused bugs, tricky migrations, design decisions with trade-offs, incidents resolved.
- Leadership/mentoring: onboarding, reviews that changed direction, process or tooling improvements you drove, hiring.
- Cross-team work: coordinating with other teams, unblocking external dependencies, negotiating scope.
- Concrete metrics when they came up (latency, cost, reliability, throughput, team velocity).

## What to skip

- Routine work with no notable difficulty or outcome (reading files, running builds, config tweaks, this skill's own setup).
- Anything already captured in substance (see merge rule).
- Exploration or research that led nowhere yet.

## Merge rule (keep the file from becoming a log)

Before adding a bullet, scan the existing sections for a bullet on the same theme or project. If found,
extend or refine it with the new detail instead of appending a new one. Add a new bullet only for a
genuinely distinct piece of work.

Bullets are outcome-focused ("what changed / what impact / what was hard and how it was solved"), one
or two lines. If a bullet sprawls, tighten it.

If a section has grown large (>12 bullets) and you are running interactively, propose consolidating
older related bullets and do it only with agreement. Never silently delete information in auto mode.

## Mode detection

- **Auto mode:** the argument is a file path to a condensed transcript (plain text of user/assistant
  messages, produced by the SessionEnd hook). Read that file as the source material.
- **Manual mode:** no such argument — an interactive `/perf-review-log` call. Use the current
  conversation as the source.

## Auto mode (headless, unattended)

1. Read the condensed transcript.
2. Read the current artifact.
3. Extract candidate significant items per the criteria above.
4. For each candidate:
   - clearly significant and unambiguous → merge into the right section;
   - uncertain (impact unclear, maybe already covered, maybe not noteworthy) → append a short bullet
     to `## 🔍 Draft — needs review`, prefixed with the date and project directory, e.g.
     `- [2026-10-18, project-x] ...`.
5. Don't ask questions. Don't restructure existing content beyond the merge rule. If nothing is
   significant, make no edits.
6. Keep edits minimal and targeted — Edit, not a full rewrite.

## Manual mode (interactive)

1. Read the artifact.
2. Review the current conversation for significant items and merge them. Ask briefly if something is
   ambiguous — few questions, batched.
3. Walk the draft section: for each item, ask whether to promote it (possibly merged with an existing
   bullet), rewrite it, or discard it. Remove resolved items from the draft section.
4. If a section is large, offer to consolidate — only with agreement.
5. Report briefly what was added, changed or resolved.
