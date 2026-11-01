---
name: english-prompt
description: Take the user's task prompt written in English (non-native speaker learning IT English), correct the English, enrich the prompt when it helps the task, append one record to the English-learning corpus, then execute the corrected prompt as a normal task. Use on /english-prompt, when the global rules say to run it on an English message, or when the user asks to check their English prompt.
---

# English Prompt

The user's message is a **working prompt written in English**. The user is learning English
(especially IT English), so this skill does four things in order: correct the language, enrich the
prompt, record the raw material, execute the task.

If there is no text after the command, ask for an English prompt and stop.

**Main constraint: never slow the working flow.** Error-class analysis, statistics and level
assessment are not done here — the separate `english-review` skill does that on demand. Here: only
one append to the corpus; corrections never appear in the reply.

## 1. Correct the English

- Fix every error of any kind: grammar, articles, prepositions, tenses, word order, word choice,
  idiom, register (formal / IT style).
- If the thought is built differently in natural English, rewrite the sentence, don't patch it word by word.
- Record real errors only: `wrong → right` + one line why. Don't invent corrections to fill space.

## 2. Enrich the prompt

- Small safe gaps (obvious paths, formats, defaults, context that is unambiguous) — fill them yourself
  and **list what you added** so the user notices.
- `AskUserQuestion` only when the missing input genuinely changes the result and cannot be safely
  assumed. Don't ask for the sake of asking.
- If the prompt is complete, add nothing and don't say so at length.

## 3. Append to the corpus (exactly one Bash call)

The source of truth for all learning is the append-only file
`~/AI/english-learning/corpus.jsonl`: one JSON line per message.

**Do not read** the corpus or the class journals, **do not map** errors to classes, **do not compute**
statistics — `english-review` does all that later from the saved raw material. Here only append what
was already produced in steps 1–2.

Record format (one line, fields in this order):

```json
{"ts":"2026-08-21T14:02:00Z","words":73,"original":"raw text exactly as the user typed it","corrected":"final corrected text","fixes":[{"wrong":"willn't","right":"won't","why":"will not contracts irregularly","tag":"competence"}],"assumed":["scale not specified -> picked CEFR"],"asked":false}
```

- `original` — **verbatim**, typos included; the denominators (article slots, question count) are
  computed from it later. Never normalise it.
- `tag`: `competence` — a rule the user doesn't know (article, preposition, inversion, `won't`);
  `haste` — a typo or slip of fast typing (`enought`, `Becase`, a dropped letter). The user writes in
  a working flow; this split separates real level from hurry.
- `assumed` — what step 2 had to fill in; `asked` — whether `AskUserQuestion` was used. From these
  `english-review` derives the prompt-error classes.
- No errors → `"fixes":[]`. Write the line anyway: error-free messages are the denominator.

Append with one command, JSON-escaped, the object on one line:

```bash
cat >> ~/AI/english-learning/corpus.jsonl <<'JSONL'
{"ts":"…", …}
JSONL
```

## 4. Execute the task

Run the corrected and enriched prompt as an ordinary task.
