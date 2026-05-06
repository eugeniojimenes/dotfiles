# English Rules Taxonomy

Canonical names for recurring English mistake patterns. When writing an "English Notes" entry, pick `rule` from this list. If the mistake is genuinely novel, append a new rule here following the same format.

Seeded from a corpus of ~187 prior corrections across multiple projects (2025–2026).

## How to use

- Each rule has: `id` (kebab-case key), `name` (human-readable), `pt_calque` (true if driven by Portuguese→English literal mapping), `examples` (canonical wrong→right pairs), `note` (one-line explanation).
- The Stop hook reads this file via `id`. Keep ids stable; rename names freely.
- For pure spelling typos, do NOT add a rule here. Use `category: spelling` in the JSON block instead.

## Rules

### preposition-plus-gerund
- **name:** Preposition + gerund (-ing form)
- **pt_calque:** true
- **trigger PT:** *sobre fazer*, *de fazer*, *em fazer*, *vale a pena fazer*
- **examples:**
  - "about add this" → "about adding this"
  - "about keep it" → "about keeping it"
  - "what do you think to use" → "what do you think about using"
  - "worth to know" → "worth knowing"
  - "worth to learn" → "worth learning"
- **note:** After any preposition (*about, of, on, in, for, by, without, instead of*) and after *worth*, the verb takes `-ing`, never the bare infinitive.

### explain-to-object
- **name:** explain/describe + to + person
- **pt_calque:** true
- **trigger PT:** *me explica*, *me explique*, *me descreva*
- **examples:**
  - "explain me this" → "explain this to me"
  - "explain me these commands" → "explain these commands to me"
  - "explain me better" → "explain it to me better"
- **note:** *explain* and *describe* require *to* before the recipient, unlike *tell/give/show* which take a bare indirect object. Pattern: `explain X to Y`, never `explain Y X`.

### make-changes-to
- **name:** make changes TO (not ON)
- **pt_calque:** true
- **trigger PT:** *fazer mudanças em / no*
- **examples:**
  - "changes I've made on it" → "changes I've made to it"
  - "I've made some changes on the file" → "...changes to the file"
- **note:** Fixed collocation: *make changes to <thing>*. *On* collocates with *work on*, *comment on*, but never with *changes*.

### make-vs-do
- **name:** make vs do (mistakes, PRs, research)
- **pt_calque:** true
- **trigger PT:** *fazer* (covers both *make* and *do* in EN)
- **examples:**
  - "mistakes I've been doing" → "mistakes I've been making"
  - "I've done one PR" → "I've made/opened/submitted one PR"
  - "do research for X" → "do research on X" or just "research X"
- **note:** Mistakes are *made*, not *done*. PRs are *made/opened/submitted*. Research is *done on* a topic. PT *fazer* maps to both verbs; EN splits by collocation — memorize per noun.

### capitalize-languages-nationalities
- **name:** Capitalize languages, nationalities, proper nouns
- **pt_calque:** true
- **trigger PT:** *inglês*, *brasileiro*, *português* (lowercase in PT)
- **examples:**
  - "english" → "English"
  - "brazilian" → "Brazilian"
  - "rails" → "Rails"
  - "tailwind" → "Tailwind"
  - "ruby" → "Ruby"
- **note:** Always capitalize languages, nationalities, and product proper nouns in English. PT keeps these lowercase, so this is a high-frequency miss.

### this-these-agreement
- **name:** this/these and that/those number agreement
- **pt_calque:** false
- **examples:**
  - "this two lines" → "these two lines"
  - "this commands" → "these commands"
  - "this images" → "these images"
- **note:** *this/that* = singular, *these/those* = plural. If the noun is plural (or quantified by a number > 1), use *these/those*.

### embedded-question-no-inversion
- **name:** Embedded/indirect questions — no subject-verb inversion
- **pt_calque:** false
- **examples:**
  - "explain what is a git tag" → "explain what a git tag is"
  - "I don't know why is this happening" → "...why this is happening"
  - "why should I need this" → "why I would need this"
- **note:** Direct question: `What is X?` (verb-subject). Embedded inside another clause: `I want to know what X is` (subject-verb). Inversion only happens in the *outer* question, never the inner one.

### past-participle-after-have
- **name:** Past participle after have/has (present perfect)
- **pt_calque:** false
- **examples:**
  - "I've just saw" → "I've just seen"
  - "I've never went" → "I've never been/gone"
  - "I've never saw" → "I've never seen"
- **note:** Pattern: `have/has + [past participle]`, not simple past. Common irregulars to memorize: see→seen, go→gone/been, do→done, write→written, take→taken.

### then-vs-than
- **name:** then (time) vs than (comparison)
- **pt_calque:** false
- **examples:**
  - "more then 2 years" → "more than 2 years"
  - "is much more security then before" → "...more secure than before"
- **note:** *then* = time sequence ("first X, then Y"). *than* = comparison ("more X than Y"). Pure spelling-by-meaning trap.

### latter-vs-later
- **name:** latter (second of two) vs later (afterward in time)
- **pt_calque:** false
- **examples:**
  - "latter I check it" → "later I check it"
- **note:** *latter* = the second of two things just mentioned. *later* = adverb meaning "afterward".

### secure-vs-security
- **name:** Adjective vs noun (secure / security, proper / properly, etc.)
- **pt_calque:** false
- **examples:**
  - "is much more security" → "is much more secure"
  - "what is the properly domain" → "what is the proper domain"
- **note:** Choose the right part of speech. *secure* (adj) modifies nouns; *security* (noun) is the thing itself. Same trap with *properly* (adv) vs *proper* (adj).

### missing-article
- **name:** Missing article (a/an/the)
- **pt_calque:** true
- **trigger PT:** PT often drops articles where EN requires one
- **examples:**
  - "is there way to store" → "is there a way to store"
  - "current setup of tailwind is ok" → "the current Tailwind setup is OK"
  - "Add a context" → "Add context" (uncountable, no article)
- **note:** Two failure modes: (1) missing required article before singular countable nouns; (2) wrongly adding *a/an* before uncountable nouns (*context*, *research*, *information*). Decide first if the noun is countable here.

### preposition-on-vs-in
- **name:** on vs in for contexts/modes/places
- **pt_calque:** true
- **trigger PT:** PT *em* covers both
- **examples:**
  - "on editing mode" → "in editing mode"
  - "on the top left" → "in the top left (corner)"
  - "what does this 'N' on `HEAD@{N}`" → "...in `HEAD@{N}`"
- **note:** Use *in* for: modes, contents of text, corners/regions. Use *on* for: surfaces, topics, dates, days. PT *em* maps ambiguously — pick by EN convention.

### used-to
- **name:** "used to" idiom (needs -d)
- **pt_calque:** false
- **examples:**
  - "I'm not use to OSS PRs" → "I'm not used to OSS PRs"
- **note:** Idiom *be used to [noun/-ing]* = "be accustomed to". Without the *-d*, "I use to X" reads as habitual present, which is ungrammatical (the habitual *used to* is past-only, also with *-d*).

### gerund-as-subject
- **name:** Gerund as subject of a sentence
- **pt_calque:** false
- **examples:**
  - "run push --force is safe" → "running push --force is safe"
  - "to run push --force is safe" — grammatical but stilted; gerund preferred
- **note:** When a verb phrase is the subject, use the gerund (`-ing`) form, not the bare infinitive. Infinitive-as-subject (*To err is human*) exists but sounds formal/archaic in modern English.

### all-the-noun-order
- **name:** all + the + noun (not "the all noun")
- **pt_calque:** true
- **trigger PT:** *toda a sujeira*
- **examples:**
  - "fix the all dirt" → "fix all the dirt"
- **note:** Order is `all + [article] + noun`, not `[article] + all + noun`. *all* precedes the determiner, unlike PT which puts the article first.

### question-inversion-modals
- **name:** Question word order with modals (can, should, do)
- **pt_calque:** true
- **trigger PT:** PT preserves declarative order in questions via intonation
- **examples:**
  - "this can be unstaged?" → "can it be unstaged?"
  - "What does mean X" → "What does X mean?"
- **note:** Direct yes/no and wh-questions invert: `[modal/aux] + subject + verb`. PT can ask questions without inversion (just intonation/punctuation); EN cannot in formal writing.

### some-vs-a-singular
- **name:** *some* with singular countable noun (use *a/an*)
- **pt_calque:** false
- **examples:**
  - "adding some section" → "adding a section"
  - "to some database" → "to a database"
- **note:** *some* + singular countable sounds vague/dismissive. Use *a/an* for one specific item. *some* fits with plurals (*some sections*) and uncountables (*some research*).

### search-vs-research-vs-look-into
- **name:** search/research/look into — verb + preposition collocations
- **pt_calque:** true
- **trigger PT:** *pesquisar sobre*
- **examples:**
  - "I search about it" → "I researched it" / "I looked into it"
  - "I search the docs" — fine (search + direct object)
  - "I search for info" — fine (search for)
- **note:** *search about* is not idiomatic. Use *search [object]*, *search for [object]*, *research [object]*, or *look into [object]*. Also: past actions need past tense (*searched*, not *search*).

### nationalities-job-adjectives-order
- **name:** Adjective order in job/role phrases
- **pt_calque:** false
- **examples:**
  - "senior-mid developer" → "mid-to-senior developer" / "mid/senior-level developer"
- **note:** EN job-market vocab orders seniority small→large by default. Reverse order ("senior-mid") reads backwards.

### turn-it-public-not-to-public
- **name:** turn / make + adjective (no preposition)
- **pt_calque:** true
- **trigger PT:** *tornar isso público*, *transformar em público*
- **examples:**
  - "turn it to public" → "turn it public" / "make it public"
- **note:** *turn/make + object + adjective* takes no preposition. PT *tornar X em Y* injects a *to/em*; EN drops it.

### double-consonant-before-ing
- **name:** Double the consonant before -ing/-ed (CVC rule)
- **pt_calque:** false
- **examples:**
  - "geting" → "getting"
  - "runing" → "running"
- **note:** When a verb ends in [consonant + short vowel + single consonant] and is one syllable (or stressed on the last), double the final consonant before *-ing*/*-ed*. Borderline category — sits between spelling and grammar.

### misunderstand-prefix-glued
- **name:** *mis-* prefix is glued, never spaced
- **pt_calque:** false
- **examples:**
  - "miss understood" → "misunderstood"
  - "miss use" → "misuse"
- **note:** Prefix *mis-* always attaches directly: *mistake, misuse, misread, misunderstand, misspell*. *miss* (verb) is unrelated.

---

## Categories (for the `category` field)

- `grammar` — verb form, agreement, tense, word order
- `preposition` — wrong preposition or missing one
- `collocation` — wrong verb-noun pairing (make/do, changes to/on)
- `vocabulary` — wrong word choice (then/than, latter/later, secure/security)
- `spelling` — pure typos (do NOT create a rule for these)
- `capitalization` — proper nouns, languages, nationalities
- `idiom` — fixed phrases (used to, worth + gerund)
- `style` — natural-vs-stilted phrasing, not strictly wrong
