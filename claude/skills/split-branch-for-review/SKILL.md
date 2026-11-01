---
name: split-branch-for-review
description: "Rewrites a feature branch into a review-oriented commit sequence. Use only on /split-branch-for-review, when the existing history reflects the order work happened (plan steps, agent/AI iterations, review fixups) instead of the order a reviewer should read it, and the branch will be squashed on merge."
---

# Split branch for review

## When

The branch is functionally done, but its history is an execution log: "address review findings",
"fix tests", "close plan", commits that undo each other. The reviewer will read the PR/MR commit by
commit and the current order teaches them nothing.

Precondition: **the branch is squash-merged**. Then the rewritten history is a review aid only —
you do not owe it bisectability, per-commit compilability, or long-term maintainability. If the
branch is merged with real commits, stop and tell the user this skill's trade-offs don't apply.

Not for: a single fixup (use `git commit --fixup`), or a normal commit of pending work.

## The goal that drives every decision

One reviewer, reading commits oldest → newest, should arrive at the final state without ever
jumping back. Each commit answers "why am I now looking at this?" from the previous one.

## Procedure

### 1. Establish the base and the ticket

- Base branch: never hardcode `master`/`main`. Take it from the argument if given, else from
  `git symbolic-ref refs/remotes/origin/HEAD` when a remote exists, else `AskUserQuestion`.
  Below, `BASE` is the result.
- Ticket key: usually the tail of the branch name (`user/task/some-feature/PROJ-1234` → `PROJ-1234`).
  Confirm against `git log --oneline -10 BASE` — the repo's existing convention wins.

### 2. Read the *final diff*, not the history

```
git log --oneline BASE..HEAD          # only to see what noise you're replacing
git diff BASE...HEAD --stat
git diff BASE...HEAD -- <file/dir>    # read the real changes, file group by file group
```

The intermediate commits are misleading by definition — a change may have been added, reverted and
re-added. Only `BASE...HEAD` is the truth. Never plan the split from commit subjects.

### 3. Design the sequence

Group by **narrative role**, not by directory and not by commit type. The order that works in
practice, layered outward from the contract:

1. **Docs / plan / spec** — the reviewer gets the model of the change before any code. Include
   design docs and the implementation plan.
2. **Foundation** — the data model, new statuses/enums/errors, the layer everything else builds on.
   Fold a small model change into the commit that first *uses* it rather than making it its own
   commit.
3. **Core logic**, one commit per coherent step, ordered so each is motivated by the previous.
4. **Surfacing** — handlers, API responses, metrics, logging: the layer where the new behaviour
   becomes observable from outside.
5. **Unrelated cleanups** (lint fixes, drive-by test tidying) — last, in one commit, explicitly
   labelled so the reviewer can skip it. Never scatter these into the logic commits: they are the
   main source of "why is this here?" noise.

Sizing: medium commits. No micro-commits — a two-line change is not a commit unless it is a
genuinely separate concern (the cleanup bucket). A commit that touches 4–8 files across one layer
is right.

Tests go **with the code they test**, never in a separate "add tests" commit.

Splitting one file across two commits (different hunks belong to different steps) is fine and often
correct — see step 4 for the mechanics.

### 4. Save the branch, then rebuild

**Mandatory first step, before touching anything:** snapshot the current branch under its own name
plus the suffix `-copy-before-commits-split`. This is not optional and not a scratch name — it is
how the pre-split state stays findable later, so the reviewer's questions can always be checked
against what was actually written.

```
BACKUP="$(git branch --show-current)-copy-before-commits-split"
git branch -f "$BACKUP" HEAD
```

The backup doubles as the source of all file content below, so keep it until the split is verified
*and* the user says it can go. If a branch with that name already exists, an earlier split was
interrupted — ask before overwriting it.

Working tree must be clean. Then:

```
git reset --hard BASE
```

For each planned commit, materialise its files from the backup ref and commit:

```
git checkout "$BACKUP" -- <paths...>
git commit -F - <<'EOF'
...
EOF
```

Mechanics that bite:

- **Deletions and renames.** `git checkout <ref> -- <dir>` adds and updates files but never removes
  the ones the final state deleted. Run `git rm` for those explicitly (a rename shows up as
  delete-old + add-new).
- **Splitting a file across commits.** Don't fight `git add -p`. Write the intermediate version of
  the file by hand (edit the `BASE` version to contain only that commit's hunks), commit it, then
  `git checkout $BACKUP -- <file>` in the later commit to reach the final version.
- **Last commit.** `git checkout $BACKUP -- <project root>` sweeps up whatever is left, which
  also catches anything you forgot to plan.

### 5. Verify

```
git diff $BACKUP HEAD --stat        # MUST be empty
```

An empty diff proves the rewrite lost nothing. This is the only mandatory check.

Optionally build once at `HEAD` (the tree is identical to the original, so this only catches a
mistake in step 4). **Do not** try to make every intermediate commit compile — pursuing that
collapses the split back into one commit whenever a rename crosses layers. State the caveat in the
report instead.

Finally, delete the backup branch only after the user confirms, and warn that pushing now needs
`--force-with-lease`.

## Commit messages

Default format (override with whatever `git log BASE` shows):

```
PROJ-1234 Imperative summary in English

Тело на языке, принятом в репозитории.
```

Body rules — this is where the review value lives:

- **Short summary of what changed.** Do not enumerate every detail; the diff is right there.
- **The transition.** Why this step follows the previous one, or what next step it prepares. This is
  the sentence that lets a reviewer move between commits without re-deriving context.
- Name the concrete wrong behaviour being fixed ("a live channel was returned as not_found") rather
  than restating the mechanism.
- 3–8 lines. If a commit needs more, it is probably two commits.

## Report back

List the resulting commits in order with a one-line rationale each, and state explicitly:

- the tree is verified identical to the pre-split branch;
- intermediate commits are not guaranteed to compile (and why that's acceptable here);
- the full name of the `…-copy-before-commits-split` branch holding the pre-split state, and that a
  force-push is required.
