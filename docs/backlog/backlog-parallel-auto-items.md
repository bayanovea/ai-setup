---
worth: yes
where: claude/skills/backlog-parallel/SKILL.md
added: 2026-11-04
---
# backlog-parallel: run `auto: yes` items without approval

`claude/CLAUDE.md` now lets the agent mark an item `auto: yes` (fix clear, blast radius small, no
decision left, approach stated in the body). `backlog-parallel` still gates every batch on the user's
ok (Phase 1, step 5); teach it to take `auto: yes` items on its own, keeping the ok only for the rest.
