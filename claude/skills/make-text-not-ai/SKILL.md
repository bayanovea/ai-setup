---
name: make-text-not-ai
description: Rewrite any text (English or Russian, any genre) so it no longer carries the marks of AI-generated writing, without inventing facts, changing meaning or register, or adapting to a particular author. Also used as a final pass over text Claude itself drafts. Use on /make-text-not-ai, "humanize", "de-AI", "make it sound human", "does this read as AI", "убери следы ИИ", "перепиши по-человечески", "очеловечь", "чтобы не было видно, что писала нейросеть".
---

# Make text not AI

The text has the statistical fingerprint of a language model. Remove the fingerprint, keep the
content. The reader must not be able to tell a model was involved; the author must not find a single
changed fact, a shifted meaning, or a new tone they did not have.

Three principles decide every edit:

1. **Detection works on clusters, not words.** One em dash, one triad, one "robust" is nothing;
   the same tells in every paragraph are the fingerprint. Fix the pattern, not the instance.
   A rewrite that swaps marker words but keeps the shape (intro → three points → recap, every
   paragraph four sentences, every claim hedged) still reads as AI.
2. **AI text is generic where human text is specific.** Models regress to the mean: the rare fact
   becomes a positive generality ("invented the first train coupling" → "revolutionized industry").
   Prefer the fact. Where the source has no fact, cut the generality; never invent one.
3. **Do not over-correct.** Fake typos, slang, "honestly...", staccato fragments, rhetorical
   questions, a coaching tone and emoji are themselves 2025–26 tells of "humanized" output.
   The target is a competent person writing plainly, not a performance of humanity.

Marker lists with replacements: `references/markers.md`. Source numbers: `references/sources.md`.

## 0. Before editing

Read the whole text once. Fix in your head:

- **Language.** Rules differ: in Russian the long dash is normal punctuation and officialese
  («является», «в рамках») is native in bureaucratic genres; in English the spaced em dash and
  the exotic-metaphor cluster (tapestry, testament, delve) are the loudest tells.
- **Genre and destination.** Email, chat message, README, Slack post, article, docs page, cover
  letter, Wikipedia article, academic abstract. Genre sets the thresholds in §2 and the exemptions
  in §3: Markdown is damning in an email and normal in a README; "In conclusion" is fine in a
  paper that concludes.
- **Register.** Set by destination and audience, not by the source's current style (that style is
  what is being fixed). A corporate tech blog is blog register; a client email is business
  register; a spec, an official letter, a paper are formal. Formal stays formal, casual stays
  casual. Human formal is not AI formal: the difference is specificity and shape, not a lower
  register.
- **Facts.** List the concrete claims (names, numbers, dates, versions, steps, positions) and the
  author's certainty on each ("will", "should", "we expect"). Every one must survive at the same
  certainty. Nothing may be added to the list. A quantifier without items ("several issues,
  including X") is the author's claim: keep it, and flag that the items are missing.
- **Order.** Keep the source order where it carries meaning (steps, chronology, an argument).
  Elsewhere paragraphs may move, typically so the text ends on the most concrete point.

If the text is a message the user is about to send and it names private people or data, the global
sensitive-data rule applies as usual.

## 1. Delete tier: remove on sight, zero cost

No human writing the genre produces these. Remove without counting.

- **Chat residue.** Openers ("Certainly!", "Great question", "You're absolutely right", "I hope
  this email finds you well", «Конечно», «Отличный вопрос»), closers ("I hope this helps", "Let me
  know if", "Would you like me to", "Please don't hesitate to reach out", "I look forward to
  continuing our journey", «Надеюсь, это было полезно», «Дайте знать»). A genre's own courtesy
  stays in one line ("Thanks", "Best regards", «С уважением»); offers of further help go.
  Also "Here is a polished version", knowledge-cutoff and
  source-availability disclaimers ("as of my last update", "while details are limited", "based on
  available information", «по имеющимся данным», «на момент написания»), self-reference ("as an
  AI"), unfilled placeholders (`[Your Name]`, `[Дата]`, `XX%`).
- **Debris.** Citation metadata (`oaicite`, `turn0search0`, `[cite: 3]`, `【85†L26】`),
  `utm_source=chatgpt.com`/`openai`, HTML attributes, literal `**` or `###` in plain text, emoji as
  bullets or heading decoration, `→`, `✅`, box-drawing characters, mixed curly/straight quotes
  (pick the convention the destination uses).
- **Meta-narration and scaffolding.** "In this article we will", "Let's dive in", "Let's break this
  down", «В этой статье мы рассмотрим», «Давайте разберёмся», "Key takeaways", "TL;DR" the house
  style did not ask for, a "Conclusion"/«Заключение» section or paragraph that only restates,
  preview-then-recap at every level.
- **Grand generic openers.** "In today's fast-paced world", "In the ever-evolving landscape of",
  «В современном мире», «Не секрет, что», «Как известно». Start with the first real sentence.
- **Importance puffery and significance tails.** "plays a crucial/pivotal role in shaping",
  "marks a pivotal moment", "a testament to", "enduring legacy", "underscores the importance",
  «играет ключевую роль», «неизгладимый след», «подчёркивает важность», and the trailing "-ing"
  analysis ("..., highlighting its commitment to", "..., reflecting broader trends", «..., что
  демонстрирует», «..., подчёркивая»). Keep the fact the clause hangs on; drop the clause. If the
  sentence is only the clause, drop the sentence.
- **Exotic-metaphor vocabulary.** tapestry, testament, realm, delve, beacon, "navigate the
  landscape", "embark on a journey", "unlock the potential", «многогранный», «погрузиться в»,
  «палитра возможностей», «путь к». Replace with the plain noun or verb, or cut.
- **Vague authority with no name.** "Experts argue", "Studies show", "Industry reports", «Эксперты
  отмечают», «Ряд исследований показал». Name the source if the text or the user has it; otherwise
  state the claim plainly as the author's, or cut it.
- **"It's important to note" filler.** "It's worth noting", "Notably", "Importantly", "That being
  said", «Важно отметить», «Стоит отметить», «Следует подчеркнуть». Delete the phrase, keep the
  sentence.
- **Didactic caveats nobody asked for.** "It's important to remember that results may vary",
  "always consult a professional", «важно помнить, что».

## 2. Density tier: count, then fix above threshold

These are normal in human writing at low rates. Count across the whole text first; edit only when
the count says it is the pattern. Thresholds are for ordinary prose; under ~150 words, halve them.
"Overall", "Ultimately", «Таким образом», «В целом» are delete tier when they open a recap and
density tier when they merely link two paragraphs.

| Tell | Keep up to | Fix by |
|---|---|---|
| Em dash, English (`—`, especially spaced ` — ` pairs) | 1 per ~250 words, never two in a sentence | comma, period, parentheses, colon |
| Long dash, Russian | not a tell; leave | nothing |
| Rule of three (three adjectives, three bullets, three examples) | 1 per ~300 words, no two in a row | make it two, four, or one; keep when the three are the real set. "Firstly/Secondly/Thirdly", «Во-первых… В-третьих» enumerators are scaffolding: prose or a plain list |
| "Not X, but Y" / "not just X, it's Y" / "X rather than Y" | 1 per text | state Y |
| Paragraph-opening transitions (Additionally, Furthermore, Moreover, Overall, «Кроме того», «Более того», «Таким образом», «Тем не менее») | 1 per 4 paragraphs | delete; let content carry the link |
| Hedges (may, might, could, typically, tends to, «может», «способен», «как правило») | where uncertainty is real | assert, or say what is actually unknown. Keep the author's own certainty level: "we remain confident X will" becomes "X will" or "X should", not "X might" |
| Unsupported intensifiers (significantly, truly, deeply, remarkably, «существенно», «безусловно», «поистине») | 0 unless backed by a number | delete, or give the number |
| Copula avoidance (serves as, stands as, boasts, features, represents; «является», «представляет собой», «выступает в качестве», «осуществляет») | occasional | is, has, does; plain verb |
| Nominalisations («осуществление», «реализация», «проведение анализа»; "implementation of", "utilization of") | native in legal/bureaucratic text | verb |
| Synonym carousel for the same referent (protagonist → central figure → hero) | 0 | repeat the noun |
| Bold phrases | 1 per screen; bold+colon list items only for real glossaries/parameters | plain text, or prose |
| Headings | none under ~300 words; above that, where a reader navigates; sentence case, named after content, not "Overview/Conclusion" | merge or rename |
| Bullet lists | for enumerable things (steps, options, parameters, metrics), plain bullets, in any genre | prose when the list is an argument or has fewer than three real items; drop the bold labels; drop Markdown syntax the destination will not render |
| Tiny tables (two facts, Metric/Value) | 0 | a sentence |
| Rhetorical question + answer, "Here's the thing", "The best part?" | 1 per text | state the point |
| Staccato fragments ("Not a bug. A design flaw."), anaphora drumbeat | 0 in technical/business text | one sentence |
| "From X to Y" range with non-comparable ends | 0 | list the actual items |
| Russian passive and «который»-chains («было принято решение», «методы, которые позволяют…, идеи, которые…») | occasional | active voice, split |
| Common-word cluster (overall, important, including, factors, help, ensure, «в целом», «важно», «в том числе», «в рамках», «данный») | ordinary rate | thin out; most are deletable |

## 3. Leave alone: the false-positive zone

Do not touch these. "Fixing" them makes the text worse and still detectable.

- Domain vocabulary where it names a property the text measures or specifies: "robust to node
  loss", "scalable to 10k connections", «надёжный: 99.95% за квартал». The same words as bare
  praise ("a comprehensive update", "a robust solution", «эффективное решение», «качественный
  продукт») are puffery and go. The test is whether a number or a comparison could follow.
- Lists, tables, numbered steps and headers in instructions, specs, RFCs, READMEs.
- Correct grammar and spelling. Never inject errors.
- Formal register in genres where it is native: legal, academic, Russian officialese in official
  letters. Fix shape and specificity there, not vocabulary.
- One em dash, one triad, one contrast frame, one real hedge, one teaching analogy.
- "In conclusion" in a paper that concludes; a TL;DR where house style asks for one.
- Markdown in README, GitHub, Slack, Obsidian.
- The author's own voice, including non-native formal English ("utilize", "delve" can be someone's
  real idiolect). If the user wrote part of it, their part is the reference register.
- First person, opinions, asides, a complaint, a named risk: these are human signals. Keep every
  one the source has; do not add ones it does not.

## 4. Shape pass

After the word-level passes, fix the structure, which is what detectors actually weigh.

- **Opening.** First sentence states something specific. No definition of the topic, no framing.
- **Ending.** End on the last concrete point, a next step, or a decision. No summary, no
  "the future looks bright" / «Будущее за…», no "despite challenges... continues to thrive".
- **Macro-template.** If the text is intro → N parallel sections → conclusion, let the sections be
  unequal: the one that matters gets the space, a minor one gets a sentence. Drop the mirrored
  intro/outro.
- **Paragraphs.** Sizes follow content weight. No run of three paragraphs with the same sentence
  count. A one-sentence paragraph is allowed when the sentence earns it.
- **Sentences.** Read any five in a row: if they share length and shape (main clause + "-ing" tail,
  or "X, Y, and Z"), rewrite two. Mix one short sentence and one long one per ~150 words.
  Avoid producing a drumbeat of fragments in the process.
- **Specificity.** Portability test: a sentence that could be moved to a text on any other topic
  unchanged is filler. Anchor it to a fact that is in the source, or cut it. Where a fact is
  missing and the sentence matters, cut it and tell the user where real data is needed.
- **Position.** If the source has an opinion or a judgement, bring it forward; both-sides filler
  ("while X has benefits, it also has drawbacks") around a stated position goes.
- **Russian live speech,** only in casual or blog register: a particle (же, ведь, вот), a sentence
  starting with «А»/«Но», active voice. One or two per text, not a sprinkling. Not in a formal
  letter or a spec.
- **Length.** As short as the facts allow. Light input loses 10–25%; filler-heavy input can lose
  more than half, and that is correct. Never longer, never padded back to look substantial.

## 5. Self-audit, then output

Rescan the rewrite as if it were new input: rewrites re-introduce em dashes, triads, "not X but
Y", bold bullets, "honestly", fragments, and hedges. Then check facts against the §0 list: nothing
lost, nothing added, nothing reversed.

Output:

- The rewritten text, in the input's format (plain if plain, fenced if fenced, Markdown only where
  the destination renders it). Not in a code block unless the input was. Clipboard only through
  `txt-copy`/`md-copy` or an explicit ask.
- Verdict: the global ▶ Verdict block, one line with the classes of tells removed and counts
  ("12 delete-tier, em dashes 7 → 1, triads 5 → 1, recap paragraph cut"), the word count before
  and after, and any place that needs real data from the author.
- A change list only on request ("покажи что изменил", "show the diff").

When this skill is applied to text Claude is about to write (a letter, a post, a doc), draft it
under §1–§4 from the start, then run §5. Do not write the AI version first and humanize it after.

## Edge cases

- **Text is already clean.** Say so in the Verdict and return it unchanged; do not edit to justify
  the run.
- **Very short text** (under 50 words). Only the delete tier and the opening/ending rules apply.
- **Code, logs, config, quoted material.** Untouched. Comments in code follow the global
  comment rules, not this skill.
- **Mixed-language text.** Apply each language's rules to its spans; do not translate.
- **Wikipedia or academic destination.** Add the genre's own tells: inline name-dropping of outlets
  ("featured in national media"), "refers to" leads, "Awards and recognition" sections, fabricated
  or unverifiable citations. Citations the skill cannot verify are flagged, not deleted.
