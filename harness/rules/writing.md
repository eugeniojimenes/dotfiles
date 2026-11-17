---
description: Writing style per audience for markdown, and the en/pt-br pair rule
paths:
  - "**/*.md"
globs: "**/*.md"
alwaysApply: false
---

# Writing rules

Full rules: `AGENTS.md` "Writing style". Applies to every `.md` except `claude-code/.claude/**` (prompt text, left as is). Code comments: compressed, wrap ~120.

Audience decides style:

- Agent text (`AGENTS.md`, `CLAUDE.md`, `harness/rules/**`, `harness/skills/**`): compressed, caveman `full`, fragments fine, all technical substance kept.
- Human docs (`README*`, `docs/**`, `docs/specs/**`, `harness/README*`, `tests/manual.md`): plain English, full sentences. No em dash, no "not just X but Y", no bold label on every bullet (exception: README module list), no filler opener. "durable", "seam", "artifact" only where no normal word works. No clause vouching for a fact ("by design", "not by luck", "on purpose"): state fact, reason in own sentence.
- Both: no em-dash (U+2014), no AI tells ("moreover", "furthermore", "additionally", "however", "it is worth noting", "crucial", "robust", "seamless", "comprehensive", "leverage"). Never hard wrap markdown: one paragraph or bullet = one line. Code blocks, commands, paths, option names, error strings verbatim.

Pairs:

- `README.md` + `README-pt-br.md`, `docs/<x>.md` + `docs/<x>.pt-br.md`, `harness/README.md` + `harness/README.pt-br.md`. Edit one = edit other in same commit. New page = both files + line in `docs/README.md` and `docs/README.pt-br.md`.
- pt-br: Brazilian Portuguese, same structure, technical terms, code, commands untranslated. Links point at pt-br pairs; `docs/specs/` links stay (English only).
- `bin/check static` step `doc-pairs` warns on a missing pair. Em-dash sweep is step `em-dash`.
- Public repo: no secret, no employer detail in any example.
