# Sources and the numbers behind the tiers

Compiled 2026-10-30. Re-check yearly: marker vocabulary rotates with model generations, and the
detector landscape moves with it. The shape rules (uniform sentences, template macro-structure,
genericity) have held since 2023 and are the durable part.

## Why the tiers are drawn where they are

- **Clusters, not words.** Pangram states its human-readable clues (em dashes, lists, headings,
  stock phrases, Markdown) "are not the inputs driving the main model". GPTZero uses a deep
  classifier; perplexity and burstiness are explanatory only. Kokoc's experiment: surface edits of
  YandexGPT text raised Quetext's AI score from 72.7% to 91.5%. Hence §4 (shape) exists and is not
  optional.
- **Ordinary words carry as much signal as exotic ones.** Kobak et al.: the "safe common words"
  group (across, additionally, comprehensive, crucial, enhancing, exhibited, insights, notably,
  particularly, within) carried the same excess (Δ=0.110) as 222 rare words (Δ=0.111). humanizemy
  corpus: overall 9.5x, important 8.2x, including 7.7x, factors 6.7x, help 5.7x, may 4.6x. Hence
  the "common-word cluster" row in the density tier.
- **Vocabulary decays.** "delve" peaked 2023–early 2024 and fell below its pre-ChatGPT baseline;
  GPT-5 removes it when editing. WP:AISIGNS by era: 2023–24 delve/tapestry/testament; 2024–25
  align with/showcasing/fostering; 2025–26 emphasizing/enhance/highlighting; 2026+ dependable/
  quietly/matters/multifaceted/practical with short 8–20-word sentences. Hence the markers file
  is dated and the skill leans on shape.
- **Over-correction is now a tell.** vc.ru (2025–26 markers) and Guy Macon's list: staccato
  fragments, pseudo-Socratic Q&A, "And honestly...", coaching tone, emoji bullets are the
  "humanized" style's own fingerprint. Hence principle 3 and the fragment row.
- **Em dash numbers.** Pangram: AI 17/10k words vs human 2/10k; OpenAI models ~45/10k, Gemini 3
  Pro 3/10k, Claude above human. Freeburg 2026: GPT-4.1 10.6/1k vs human 3.2/1k, GPT-5.4 1.4/1k.
  Human published range 0.33–17/1k. A July 2026 study: only Claude still exceeds professional
  writers. Hence "1 per ~250 words" (about 4/1k, inside the human band) and "never two in a
  sentence". Russian: the long dash is grammar; goodtarget and iphones.ru list it explicitly as
  not a signal.
- **Triads and contrast frames.** Pangram: triads 19/10k vs 5/10k (4x); "not only...but also"
  3/10k vs 1/10k. WP:AISIGNS: negative parallelism "common among human writers" but
  "stereotypically an AI sign". Rostovtsev flags «Не X, а Y» and anaphora as high false-positive in
  Russian. Hence one per text, not zero.
- **"rather than" and hedges.** writehuman: "rather than" 17,251 vs 6,859 occurrences AI vs
  humanized (~2.5x), their single strongest multi-word edit; ensuring/highlights/supports/reflects
  3–4x; one pass cut GPTZero 73.7% → 4.0%.
- **Trailing "-ing" analysis.** searchatlas: main clause + participial tail 2–5x more in AI;
  WP:SUPERFICIAL. Delete tier because the tail is never the content.
- **Specificity.** WP:AISIGNS "regress to the mean": "inventor of the first train-coupling device"
  → "a revolutionary titan of industry". Liang et al.: ICLR reviews with "et al." citations were
  significantly less AI-modified. kalinkindev: «нет реальных цифр, городов, тарифов».
- **Perfect grammar is not a tell.** WP:AISIGNS "Ineffective indicators"; goodtarget; detectors
  flag 61% of TOEFL essays (Liang 2023). Hence "never inject errors".
- **Register is not a tell.** WP:AISIGNS: the correlation "does not extend to all formal,
  academic, or 'fancy'-sounding prose"; Russian officialese is native in official genres
  (kalinkindev, goodtarget). Hence §3.
- **Detector false-positive zones.** Pangram model card: texts under 50 words, code, tables,
  bullet lists, technical instructions, references, templates, equations, non-native English.
  Hence the §3 list and the short-text edge case.
- **Russian absence signals.** Rostovtsev, vc.ru, arXiv 2405.09279: no particles (же, ведь, вот,
  -то), no sentence-initial «а/и/но», no idiom, profanity 50x rarer, uniform 15–20-word sentences.
  Restored only in casual register because adding them to a formal letter is itself a mismatch.
- **Length.** AI text "repeats its arguments" (Pangram CEO), fractal summaries (humanizer #45).
  Removing recaps and tails shortens by 10–25% without losing a fact.

## Primary pages

- Wikipedia:Signs of AI writing (WP:AISIGNS) and sub-pages WP:AISIGNS/Markup, Wikipedia:Signs of
  AI use in comments, WikiProject AI Cleanup guide, User:Guy Macon/AI Slop Detection (120 patterns)
- Википедия:Признаки сгенерированности текста (ВП:ПРГЕН; a translation of the English page),
  ВП:Нейросеть, ВП:Подлог источников

## Corpus studies

- Kobak et al., "Delving into ChatGPT usage in academic writing through excess vocabulary",
  arXiv 2406.07016; Science Advances 2025
- Liang et al., "Monitoring AI-Modified Content at Scale", ICML 2024, arXiv 2403.07183
- Yakura et al., "Empirical evidence of LLM's influence on human spoken communication",
  arXiv 2409.01754
- "Accelerated Drift of Scientific Prose in the LLM Era", arXiv 2610.26008
- "An LLM-Associated Register Shift in Korean Journal Abstracts", arXiv 2609.07447
- humanizemy.ai, "It Isn't Delve" corpus study (https://humanizemy.ai/research/corpus-shift-nlp)
- Simon Willison on "delve" and Nigerian English (https://www.simonwillison.net/2024/Apr/18/delve/)

## Detector vendors

- Pangram, 9 signals with per-10k rates; model card false-positive zones
- GPTZero, perplexity and burstiness explainer
- writehuman.ai, "The real signature of AI writing isn't the em dash anymore" (2026)
- searchatlas.com, AI patterns in writing
- halfaccessible.com, em dash counts (Freeburg 2026)

## Practitioner lists

- Humanizer Claude Code skill, 45 patterns (gist vdemonchy/61eabbac9f0726e31bf3ea0c9f190f22)
- Hacker News: "How would you describe the way AI writes versus a human?" (43523658),
  "Semantic ablation" (47049088), "On AI writing" (50171771), "load-bearing" (48905248)
- Grammarly, common AI words

## Russian

- Ростовцев, «205 маркеров нейротекста» (pavelrostovtsev.ru/markery-neiroteksta)
- goodtarget.ru, признаки ИИ-текста, с разделом ложных срабатываний
- iphones.ru, «тире и списки больше ни о чём не говорят»
- vc.ru, «55 маркеров» (ai/2936857) and «44 маркера» (ai/2856452)
- Habr/BotHub, маркеры и артефакты нейрослопа (bothub/articles/1085684)
- nn-ai.ru, 20 маркеров; kalinkindev.ru; kokoc.com; text.ru; pressfeed.ru; t-j.ru; skillbox.ru
