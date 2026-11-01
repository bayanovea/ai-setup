---
name: english-review
description: Periodic review pass over the English-learning corpus. Reads ~/AI/english-learning/corpus.jsonl since the last watermark, updates the error-class journals, computes per-class accuracy rates and trends, rates the user's CEFR level with evidence, and generates drills. Use on /english-review or when the user asks about their English progress, level, or wants exercises.
---

# English Review

The deferred analysis of the corpus that `english-prompt` fills. Here it is fine to be slow and
thorough: this skill is not in the working flow, it is run by hand.

Learning directory: `~/AI/english-learning/`

- `corpus.jsonl` — **source of truth**, append-only, one line per message. Never edit or rewrite it.
- `state.json` — watermark: `{"last_reviewed_ts": "...", "reviews": [...]}`.
- `english-error-classes.md`, `prompt-error-classes.md` — **derived** artifacts. This skill is their
  only writer.
- `mistakes.md` — recurring errors logged by a coach in sessions (ids `E-001`…), with review dates.
  Read it: it is evidence too, and a class that already exists there should not be created twice
  under a new name — reference the `E-` id.
- `progress.md` — history of level ratings and metrics by date.
- `drills/` — exercises: `YYYY-MM-DD-<class>.json` (written here), `<id>.answers.json` (written by
  `drills/serve.py` as the user answers), `index.html` + `serve.py` (the viewer; don't regenerate).
- `reports/YYYY-MM-DD-teacher.md` — reports for the user's human teacher, written by the `teacher`
  mode below. Derived, kept so the next report can say what changed.

## 1. Read what is new

Take the `corpus.jsonl` records with `ts > state.last_reviewed_ts`. If there are none, say so and
stop without rewriting anything.

The skill argument can narrow the window (`/english-review last-month`, `/english-review all`) —
use that range, but move the watermark only forward.

## 2. Update the error classes

For each record, file `fixes` into classes in `english-error-classes.md`, and `assumed` / `asked` into
classes in `prompt-error-classes.md`, following the rules in the header of those files:

- Matches an existing class → add the date and a fresh example (keep up to 5, newest first), update
  the **Seen** line.
- A stable new pattern → create a class. A one-off typo (`tag: haste`) does not get a class; it only
  counts in the step-3 statistics.
- A class is a rule that can be drilled with an exercise, not a single error.

## 3. Compute metrics

Count against the **saved `original` texts**, not the number of errors — without a denominator there
is no trend.

For each of the top-3 active classes, count the **opportunities** (how many places in the text the
rule applied) and report accuracy:

- articles — the number of noun phrases that required an article decision;
- questions — the number of interrogative sentences;
- preposition + clause — the number of such junctions;
- likewise for whichever class is currently being drilled.

**Drill results:** for each `drills/*.answers.json` not yet logged in `state.json`, take the first
entry of `checks` (`correct/total`, `wrong[]`) — the first attempt is the honest score, later ones
are after seeing the key. It measures rule knowledge, not production: report it next to the corpus
accuracy for that class, never mix it into the opportunity counts. A drill with no `checks` is "not
done"; say so.

Plus window totals: words, errors per 100 words, `competence` vs `haste` share, how many messages had
no errors.

**Lexical variety:** type-token ratio over the window's `original` texts, the most-repeated content
verbs and linking words, and the alternatives that never appear (e.g. `check` ×11 while `verify`,
`confirm`, `ensure` are 0). This is the evidence for "needs synonyms", so compute it, don't guess it.

**Range growth:** separately note constructions the user used **for the first time and correctly**
(inversion, conditionals, passive, complex subordination, idioms). This is the only thing that shows
B2 → C1 movement; an error counter never will.

## 4. Rate the level

Give a CEFR rating **with a breakdown**, not one letter: range/vocabulary, grammatical accuracy,
communicative effectiveness, ceiling when writing carefully (from the `haste` share). Every number
points at a step-3 metric.

Honesty rules:

- If the window is under ~4 weeks or ~20 messages, say plainly that this is a baseline, not a
  measured trend.
- Compare with the previous `progress.md` entry; call a change a trend only when the **error rate**
  moves, not the absolute count.
- The user writes in a working flow without thinking about language. `haste` errors understate the
  visible level — account for that, but don't excuse systematic things (articles, inversion, verb
  government) as hurry: fluency doesn't produce those.

Append the result to `progress.md`: date, window, metrics, rating, what changed.

## 5. Close the loop

- Class statuses: `active` → `drilling` (exercises issued) → `closed` (zero hits in the last ~200
  opportunities for that class). Blocks are never deleted.
- Issue exercises for **one** class — the top-1 by opportunities with errors, not by absolute hits.
  10–15 items built from the user's **own** sentences in the corpus: this is the IT English they
  actually need, not a textbook. Write them to `drills/YYYY-MM-DD-<class>.json` (format below)
  and tell the user to open them with `python3 ~/AI/english-learning/drills/serve.py <id>`.
- Update `state.json`: new `last_reviewed_ts` and a record of the run, including `drill_results`
  (`{id: "correct/total"}`) for the answer files read in step 3.

### Drill file format

The viewer (`drills/index.html`) renders any file of this shape; add a section `type` there before
using a new one.

```json
{
  "date": "YYYY-MM-DD",
  "title": "Articles before countable nouns",
  "class": "<class name from the journal>",
  "mistake_id": "E-010",
  "baseline": "Article accuracy on explicit slots in the corpus: 52%.",
  "intro": "What to do and why, 1–3 sentences.",
  "rules": ["rule card line", "..."],
  "sections": [
    {"title": "Sentences", "type": "gaps", "choices": ["a", "an", "the", "—"],
     "items": [{"context": "optional: Earlier: the mobile app calls the gateway.",
                "text": "[ ] gateway would return [ ] 502.", "key": ["the", ["a", "the"]], "note": "optional"}]},
    {"title": "Self-check", "type": "free",
     "items": [{"prompt": "Write three sentences ...", "lines": 6, "key": "optional reference answer"}]}
  ]
}
```

- `gaps`: each `[ ]` in `text` is one input; `key` has one entry per gap, an array where several
  answers are right. `choices` only suggests; any text is accepted and compared case-insensitively
  (`-`, empty-looking `none` → `—`). Count the gaps against `key` before writing.
- `context`: one line on what the conversation already established, shown above the sentence. Write
  it whenever a gap's answer depends on something outside the sentence (`the mobile app` named in an
  earlier message). Without it the user reads the sentence as a first mention, where `a` is a fair
  answer, and the drill measures guessing instead of the rule.
- `exclude` (optional): gap indexes shown but not scored. Use it only to rescore an issued drill
  whose key turned out to depend on context the drill did not show; a new drill gets `context`
  instead. Rescoring rewrites `checks[0]` in the answers file and keeps the old numbers in `raw`.
- `choice`: the entry step for classes a gap cannot test. `text` marks the calqued span as
  `[[...]]`, `options` has 3 replacements for it (one natural, two plausible calques), `key` is the
  natural one. Auto-graded like gaps. Recognition only: use it for the first drill on a class.
- Step up (`choice` → `rewrite`, scaffolded → free, hinted gaps → bare) only after a confident
  result on the current step — roughly 85%+ on a first check, not just one pass; a shaky result
  gets another drill at the same step with fresh sentences. The user asked for this after a
  premature rewrite drill: free production without scaffolding is too hard while recognition
  is still shaky. "Check filled" also works for `rewrite` items: it reveals the key only for
  written ones and locks them, recorded in `first` as `{given}`.
- `rewrite`: for classes a gap cannot test (calques, collocations, word order). Item: `text` (the
  user's own wrong phrase, unrelated typos fixed), `key` (a natural version), `note`, optional
  `context`. Check locks the answers and shows the key; the user self-marks each ✓/✗ into `marks`
  (`{item: bool}`). Score = `true` marks / items; re-read the locked answers yourself and say where
  you disagree with a mark.
- "Check filled" grades and reveals only the items that are fully filled, item by item; each gap's
  first attempt is frozen in `first` (`{item: [{ok, given}]}`), and the final Check builds
  `checks[0]` from those frozen attempts, so `checks[0]` stays the honest score either way.
- `free`: a textarea, not auto-graded; `key` is shown after Check. Read these answers in the next
  review as fresh corpus-like text for the drilled class.

## `teacher` mode

`/english-review teacher` writes a report for the user's human teacher (Russian-speaking; the report
is in Russian) to `reports/YYYY-MM-DD-teacher.md` and copies it to the clipboard (`pbcopy`). The
user sends it by hand, roughly every 1–2 weeks. It reads the journals, `progress.md`, `state.json`,
`mistakes.md` and the previous report; it does not re-run steps 1–5 — run a plain review first if the
watermark is older than the corpus.

The teacher does not change their course: the report is extra signal, one screen, judgements first,
numbers only where they support a judgement.

1. **Снимок** — level with breakdown, window, words, competence errors per 100 words.
2. **Что изменилось с прошлого отчёта** — diff against the previous `reports/*-teacher.md`: classes
   that moved status, accuracy that moved, new classes. First report: say so.
3. **Главные проблемы** — top 5–7 classes by share of errors: pattern in one line, 2 examples
   `wrong → right` taken as they are from the journals (work fragments are fine, the teacher may see
   them), status, trend, and a one-line judgement.
4. **Суждения** — the subjective part, each backed by a fact from the data:
   - returned: a `closed`/`drilling` class with fresh hits;
   - drilling does not help: accuracy flat after a drill was issued;
   - variety: from the lexical-variety metric;
   - spoken vs written: `E-` items from `mistakes.md` absent from the corpus and vice versa;
   - range growth: from `progress.md`.
5. **Что уже делается здесь** — drills issued, which class, so the teacher does not duplicate.
6. **Вопросы учителю** — 1–3, concrete.

Not in the report: raw prompts, message-level content, anything beyond `wrong → right` fragments.

## Boundaries

Don't touch `corpus.jsonl`. Don't hand-edit the class journals outside this skill — the next run
would overwrite the edit. If a journal diverges from the corpus, rebuild it from the corpus, not the
other way round.
