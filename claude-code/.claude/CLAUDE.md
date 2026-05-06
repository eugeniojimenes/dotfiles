## Language Review

The user is a native Portuguese speaker learning English. For every prompt I receive:

1. First, address the primary task (code review, implementation, debugging, etc.) fully and completely.
2. After completing the main task, add a brief "English Notes" section at the end pointing out any grammar, vocabulary, or phrasing improvements in my prompt — but only if there are actual issues worth mentioning. If the English was fine, skip this section entirely. Keep the English feedback short and educational (explain *why* something is incorrect), not just corrections.
3. After the human-readable "English Notes" section, append a hidden JSON payload inside an HTML comment in the exact format below — even when there are zero corrections (emit an empty array). A `Stop` hook parses this block from the session transcript and logs each correction to a local SQLite database. The HTML comment is invisible in the rendered chat UI but still present in the transcript. **Skip the JSON block only when no English Notes section was emitted at all** (i.e., the prompt had no English content to review, like single-word commands or pure code).

### JSON block contract

After the English Notes section, append exactly this — single line, valid JSON, no pretty-printing:

```
<!-- english-notes
[{"wrong":"...","correct":"...","rule_id":"...","category":"...","pt_calque":true,"explanation":"..."}]
-->
```

- The opening sentinel is the literal line `<!-- english-notes` (no spaces after).
- The closing sentinel is the literal line `-->`.
- Between them, exactly one line: a valid JSON array. One object per correction bullet, in the same order as the bullets.
- Must be HTML-comment-wrapped so it's invisible in the rendered chat. Do NOT use fenced code blocks or any other format.
- `rule_id` MUST come from the `English Rule IDs` list below. If the mistake is genuinely novel and no existing rule fits, use `"rule_id": "novel"` — DO NOT invent new ids inline. (Adding a new rule is an explicit decision: read `~/.claude/english-rules.md`, append a new entry, then use its id.)
- For pure typos, use `"rule_id": "spelling"` and `"category": "spelling"`. Do not force a grammar rule onto a misspelling.
- `pt_calque`: true if the mistake traces to a literal Portuguese-to-English mapping; false otherwise.
- Keep it valid JSON: no comments, no trailing commas, escape internal quotes with `\"`.

### English Rule IDs

Pick `rule_id` from this list. Each entry is the canonical name plus (when relevant) the Portuguese trigger phrase. Full taxonomy with examples and explanations lives at `~/.claude/english-rules.md` — read it only when adding a new rule.

- `preposition-plus-gerund` — PT: *sobre/de/em/por + verbo*; *vale a pena fazer*
- `explain-to-object` — PT: *me explica*
- `make-changes-to` — PT: *fazer mudanças em/no*
- `make-vs-do` — PT: *fazer* covers both
- `capitalize-languages-nationalities` — PT: *inglês, brasileiro, português* (lowercase)
- `this-these-agreement`
- `embedded-question-no-inversion`
- `past-participle-after-have`
- `then-vs-than`
- `latter-vs-later`
- `secure-vs-security` (adj/noun mix-ups generally)
- `missing-article` — PT often drops articles
- `preposition-on-vs-in` — PT *em* maps to both
- `used-to`
- `gerund-as-subject`
- `all-the-noun-order` — PT: *toda a X*
- `question-inversion-modals`
- `some-vs-a-singular`
- `search-vs-research-vs-look-into` — PT: *pesquisar sobre*
- `nationalities-job-adjectives-order`
- `turn-it-public-not-to-public` — PT: *tornar X em Y*
- `double-consonant-before-ing`
- `misunderstand-prefix-glued`
- `spelling` — pure typos (no grammar rule applies)
- `novel` — genuine new pattern not yet in the taxonomy
