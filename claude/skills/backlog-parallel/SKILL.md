---
name: backlog-parallel
description: Pick the most important items from a repo's docs/backlog/, brief them, then fix several at once with one isolated git-worktree agent per group. Afterwards merge them into the default branch, run the full test suite, then plan and run the post-deploy prod checks (the user does only the ones that need them). Use when the user asks to choose or summarize important backlog items, asks whether backlog items can run in parallel or in worktrees, says "work the backlog in parallel", "launch these backlog tasks", "/backlog-parallel", or wants a batch of backlog fixes taken through to a merged, tested branch. "/backlog-parallel auto", or a request for the backlog items that can be done without the user, runs the same flow in auto mode: the agent picks the items that pass its own autonomy check and stops only before pushing. For one backlog item, or for listing and triaging the backlog, use the backlog skill instead.
---

# Backlog in parallel

Takes a batch of `docs/backlog/` items from selection to a merged, tested default branch, with one
worktree agent per group of items. The user owns two gates: which items to run, and every push. Every
other step is yours, including how to group the work and every prod check you can run yourself. In
[auto mode](#auto-mode) the first gate is yours too.

This skill orchestrates and does not define the item format. If a `backlog` skill is available (it owns
`worth`/`where`/`added` and the create-then-delete lifecycle), follow its format rules for any item you
create, edit or delete. Answer in the user's language. Prompts to subagents are in English.

Before starting, read the repo's `CLAUDE.md` and the project memory. Test commands, deploy mechanics,
host facts and earlier lessons live there, not here. When this skill and the repo disagree, the repo
wins.

## Auto mode

`/backlog-parallel auto`, or the user asking for what can be done without them. The same run with the
item gate removed: you pick, launch, merge and test on your own; the user still owns every push.

An item qualifies when all of this holds, checked now against the current code, not taken from the
item's text:
- the fix is clear: the body states the approach, and the code confirms it is the right one;
- the blast radius is small: a few files, no schema, API or config-format change, nothing that changes
  how the user works;
- no product or design decision is left;
- it can be verified locally: a test proves it, or the existing suite covers it. CI, deploy and infra
  items never qualify.

`auto: yes` in the frontmatter is the filer's judgement that the item qualifies. Treat it as a strong
signal, not as permission: an `auto: yes` item that fails a check stays out, and you drop the field
from the item in place with one line on what failed, so the next run does not re-check it (commit that
edit in Phase 5). An item without the field qualifies only when every check passes without doubt; say
in the launch message that you promoted it. Priority order and default count are the normal ones.

What changes per phase:
- Phase 1, steps 4–5: no stop. The list, with one line per item on why it qualifies, and the items you
  left out with the check they failed, go into the launch message. If nothing qualifies, say so and
  stop.
- Phase 3, step 3: merge without asking.
- Pushing and Phase 4 are unchanged: never push without an explicit yes.

## Phase 1: Select and brief

1. Glob `docs/backlog/*.md` and read every item in full. If there is no `docs/backlog/`, say so and stop.
2. Verify each `where` against the current code. Report a stale item as stale, not as work.
3. Pick up to the number the user asked for (default 5) from `worth: yes`, in this order:
   - data loss
   - downtime or unsafe deploys
   - security
   - wrong data or wrong results that users see
   - cleanup

   Within one tier, prefer high value for small effort. Items filed in one review usually share the
   same `added` date, so age gives no ordering. When the order is your judgement, say so.
4. **Show the list first and stop.** Before any grouping talk, list the picked items. For each one:
   - **What:** one line on what the item is about, with `file:line`.
   - **Why it's a problem:** what it costs if left (downtime, data, security, wrong results). Say
     plainly when nothing is exploitable or broken today.
   - **Fix:** a one-line sketch if you already know it. If you don't yet, write "fix: after analysis"
     and send the sketch as soon as you have it, still before launching.

   Do not paste the item body back. Also name the items you left out and why (owner-only manual work,
   needs prod, `worth: later`), and any new problem you found while checking.
5. **Wait for the user's ok** (skipped in auto mode). They answer in plain text: ok, or drop/add items. Do not use
   AskUserQuestion for this, and do not launch anything before the ok.
6. **Parallelism analysis.** Do it yourself and do not ask the user about it. Report the outcome in
   the launch message (Phase 2); the user will object in text if they want something else.
   - **File overlap.** List which files each fix will touch, including the test files and docs every
     change tends to edit (a big e2e file, `CLAUDE.md`, `Makefile`).
   - **Test isolation.** Read the test harness (Makefile, compose files, test config) and check whether
     two runs at once collide: fixed host ports, `container_name`, a fixed compose project name, a
     shared local test DB, one DB name. Compose without `-p` or `name:` takes the project name from the
     directory, so worktrees are isolated by default. Say what you found, not what you assume.
   - **Cost.** Each Docker-based e2e run builds its own image, so several at once load the machine.
   - **Local verification.** Mark items that can't be verified locally (CI workflows, deploy scripts,
     infra). An agent can prepare those, but only a push proves them.
   - **Grouping.**
     - Give tiny items (a one-line fix, an escape) to one shared agent; parallelism pays off only on
       the long items.
     - Give a separate agent to any item that needs design decisions.
     - Do not put two items that edit the same function into parallel agents.
   - **Merge order.** Small and low-risk first, large next, CI and deploy changes last, so the first
     push runs the new gate on the final test suite.

   Ask the user only when a choice is genuinely theirs: a product or design decision, or a fix that
   changes how they work (a new manual step, a link that stops working). Grouping is not such a choice.

## Phase 2: Launch

Launch all groups in one message, one `Agent` call each, with `isolation: "worktree"`. Use the Agent
tool, not the Workflow tool: Workflow needs the user's explicit opt-in. In the same message, tell the
user briefly: the groups and what each agent does, what runs in parallel and why that is safe (files,
test isolation), what can't be verified locally, and the merge order. Do not poll; completion
notifications arrive on their own.

A subagent cannot ask questions mid-task, so its prompt must settle every decision it would otherwise
guess at. Before writing a decision into a prompt, check the facts it depends on in the code (for
example, how a value is stored today), or the agent will faithfully implement a wrong assumption.
Build each prompt from this template:

```
You are working in a git worktree of <repo> (<one-line stack>). Read the repo's CLAUDE.md first.
Fix <N> backlog item(s): <docs/backlog/slug.md, ...> (read them).

First: `git merge --ff-only <default-branch>`. Agent worktrees can start on an older commit than the
current default branch, and the backlog files may be missing until you do this.

## <Item>: problem
<2–5 lines with file:line, verified against the current code>

## Decisions already made: implement these
<numbered list: approach, error handling, locking, naming. Everything you would otherwise guess.>
Out of scope: <the parts that stay in the backlog>

## Tests
- <exact commands from CLAUDE.md that must pass>
- Another worktree may be running its own <e2e> at the same time; that is fine because <why it is
  isolated>. Clean up afterwards with <down -v or equivalent>.
- If a suite needs something you don't have (a local DB, credentials), report it as skipped and why.
  Never point tests at another database to make them run.
- Put new tests next to related tests, not at the end of shared test files. Other branches append there.
- Where feasible, check that the new test fails on the old code.
- Clean up only what you created, by name or tag. Never run prune commands (`docker system/builder/
  image/volume prune`, `git gc --prune`): they delete other worktrees' and the user's state.

## Finish
- Update CLAUDE.md only where the behaviour it documents changed.
- `git rm` the backlog item in the same commit as its fix. If part of the item stays undone, edit the
  item in place to cover only the rest, and rename it if its slug no longer fits. Fix links from other
  items to a deleted or renamed slug.
- A new problem you find but are not asked to fix becomes a new backlog item, not a silent extra fix.
- Match surrounding style and the repo's commit message style. One commit per item.
- Commit only on your worktree branch. Never push, never merge into <default-branch>, never touch prod
  (no SSH, no tunnels, no prod data).

## Report back
Branch, commit SHAs and messages, files per commit, test results with pass counts (paste failures, name
skipped suites and why). Then, as separate lists: changes you made that were not asked for, and the
points you were unsure about.
```

## Phase 3: Review, merge, test

**As each report arrives:**
- Spot-check the parts of the diff that matter. The report is the agent's claim, not proof.
- Relay a short summary to the user: what was done, any unrequested changes and whether they are
  sound, risks, and expected merge friction.

**When all agents are done:**
1. **Dry-run the merge.** Use `git merge-tree --write-tree`, chaining through a temporary
   `git commit-tree` for a third branch.
2. **A clean merge does not prove a correct result.** Two branches that add the same guard or helper
   at different lines merge without conflict and leave both copies. Show the merged content of every
   file more than one branch touched and read it.
3. Ask before merging into the default branch (not in auto mode). On yes:
   - Bring the commits over in the agreed order. Use cherry-pick when history is linear; otherwise
     follow the repo's convention.
   - Fix duplicates and amend each fix into the commit that introduced it.
4. **Run the full test suite on the merged branch.** If something fails, first rerun it on the base
   commit in a temporary worktree to see whether it was already failing. Report that plainly; don't
   paper over it.
5. **Clean up.**
   - Confirm the content landed: `git cherry <default> <branch>` should show `-`; an amended commit
     shows `+`.
   - Then `git worktree remove` and `git branch -D` for each agent.
   - Delete the Docker images the agents' test runs built.
6. **Pushing.**
   - Never push without an explicit yes; in many repos a push to the default branch is a deploy.
   - Before asking, run `git log origin/<default>..<default>`. Earlier unpushed commits ride along, so
     say how many commits will actually go out.
   - When the push deploys, the message that asks for the push also carries the Phase 4 plan. Do not
     wait to be asked for it.

## Phase 4: Prod check plan (always, when a push deploys)

This phase is mandatory whenever the push deploys, whether or not the user asks for it. The user should
only do what needs them.

**First, find out what you can run yourself.** Before writing the plan, probe your own access, read-
only: SSH to the host in batch mode (`ssh -o BatchMode=yes -o ConnectTimeout=10 <host> true`), `curl` to
the public endpoints, `gh` for CI runs. The project memory may already say what works. Every check you
can run is yours. Hand the user only what needs them: a secret only they hold, a browser or UI check, a
login, a decision, or access you don't have.

**Write the plan** with two clearly separated parts, "I run" and "You run". Only include what tests
cannot prove: the real environment (secrets, host keys, tooling in the built image, cron, the real data
shape) and the user-visible symptoms (downtime, broken pages). For each check give a ready command with
the values filled in, the expected result, and what a failure means.

- **Before the push.** Things that make the first run fail: a mismatched pinned key, orphan containers a
  `--remove-orphans` would delete, a secret value, disk space for a new base image. Take a baseline only
  when it can differ. A counter that is always 0 (a job that runs every minute) is not a baseline. Run
  these yourself before asking for the push when you have access.
- **During the deploy.** Watch the CI run (`gh run watch` if available). Run the 1 request/s uptime loop
  yourself in the background, writing to a file in your scratchpad, and read it afterwards.
- **After the deploy.** Write probes that are safe and idempotent:
  - To recompute something, pick an input whose result must come out identical, and compare a hash.
  - To test an error path, trigger it with input that fails before any write.
  - Never create, edit or delete real data. A probe that rewrites data with an identical result runs
    only if it was in the plan the user saw before the push.
  - Check a secret by its length or a hash, never by printing it.
- **Deferred checks.** Some regressions show up only over time, such as an item that keeps failing and
  retrying. Give the query, and offer to run it yourself the next day.
- **Not checked.** List what you left out and why: covered by tests, or provable only by breaking prod.
- **Rollback.** The exact revert for each risky commit.

**When the user says the deploy is done**, run all of your checks at once, without being asked, and
report the results as a table: check, result, pass or fail. Then list only what is left for the user.

**Steps for the user** are numbered instructions they can follow without asking back: where to go or
what to run, the exact command, the expected result, and what to do if it differs. Anything longer than
one short line (a loop, a multi-line script) goes into a script file you write to the scratchpad, for
the user to run with `bash <file>`: shells mangle pasted one-liners (zsh escapes `;` after a URL).
Never ask the user to paste a secret into the chat.

Answer the user's questions while they work through their steps. Fix wrong commands at once, for example
a column type you got wrong or a tool missing from the image.

## Phase 5: Wrap up

- Make sure every finished item is gone from `docs/backlog/` and every leftover reads correctly on its
  own.
- Record what the next iteration needs:
  - repo facts: test pitfalls, wrong docs → `CLAUDE.md`, committed but not pushed without asking;
  - prod facts: container names, missing tools, safe probes, column types → project memory;
  - a deferred check the user still has to run → project memory.
- Suggest which items suit the next batch, given how they overlap.
