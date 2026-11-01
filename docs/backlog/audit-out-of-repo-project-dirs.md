---
worth: yes
added: 2026-11-01
---
# audit the out-of-repo folders my AI projects created

To keep repos publishable, agents moved data out of them: `data/` dirs, `~/.config/<project>/`,
`~/.<project>/`, storage and state dirs, caches. I accepted each proposal as it came, so nobody
knows the full list, which project owns which folder, or whether it is still in use.

What the audit covers:
- Inventory: for every project under `~/AI/` (and `~/Work/` where agents worked), grep its code,
  configs, hooks and `install.sh` for paths outside the repo; list the folders that exist in `~`,
  `~/.config`, `~/Library/Application Support` and similar with owner and size.
- Per folder: keep / move / delete. Orphans with no owning project are candidates to delete
  (ask first, read nothing private).
- One convention for all projects, extending `AGENTS.md`'s `~/AI/ai-setup-private/<tool>/` template
  (or a sibling root per project), and a rule in `claude/CLAUDE.md` that an agent proposing a new
  out-of-repo path names it in the project's docs.

The audit report is private (it lists my projects and data): it goes under `~/AI/ai-setup-private/`,
not into this repo. `private-data-to-one-template.md` is the ai-setup slice of this and can be
done first or folded in.
