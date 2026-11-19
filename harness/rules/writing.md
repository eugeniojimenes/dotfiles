---
description: Writing style per audience for markdown, and the en/pt-br pair rule
paths:
  - "**/*.md"
globs: "**/*.md"
alwaysApply: false
---

# Writing rules

Applies to every `.md` except `claude-code/.claude/**` (prompt text, em-dash = list separator the model reads, left as is, excluded from sweep).

Audience decides style:

- Agent text (`AGENTS.md`, `CLAUDE.md`, `harness/rules/**`, `harness/skills/**`): compressed, caveman `full`. Drop articles, filler, hedging, pleasantries. Fragments fine. Short synonyms. `=` and `:` over spelled-out copulas. All technical substance stays. Never touch code blocks, command lines, API names, error strings, option names.
- Human docs (`README*`, `docs/**`, `docs/specs/**`, `harness/README*`, `tests/manual.md`), owner's rule verbatim: "Plain English, full sentences, no AI tell language. Avoid em dashes, "not just X but Y", bold labels on every bullet, filler openers, and words like "durable", "seam", "artifact" where a normal word works. Do not append a clause that vouches for a fact instead of explaining it, asserting that something is intentional, earned or no accident ("and not by luck", "by design"). State the fact, and give the reason in its own sentence when the reason matters. Do not hard wrap. One paragraph or bullet is one line, however long. Only code blocks keep their own line breaks." Owner exception: README module list keeps bold module names (main doc, scanned by eye).
- Code comments: compressed like agent text. Wrap at ~120 (`colorcolumn = "120"` in `lazyvim/.config/nvim/lua/config/options.lua`).

Everywhere:

- No em-dash (U+2014), no ` -- ` pause, no AI tells: `AGENTS.md` "Writing style" (they apply to every file and commit message, so they live there).
- Markdown never hard-wrapped: one paragraph or bullet = one line.
- Sweep (static step `em-dash`): `git ls-files -z ':!claude-code/.claude' | LC_ALL=C.UTF-8 xargs -0 grep -nP -d skip '\x{2014}'` (`-d skip`: harness links are dirs).

Pairs:

- `README.md` + `README-pt-br.md`, `docs/<x>.md` + `docs/<x>.pt-br.md`, `harness/README.md` + `harness/README.pt-br.md`. Edit one = edit other in same commit. New page = both files + line in `docs/README.md` and `docs/README.pt-br.md`.
- pt-br: Brazilian Portuguese, same structure, technical terms, code, commands untranslated. Links point at pt-br pairs; `docs/specs/` links stay (English only).
- English only: `docs/specs/`, agent text, code comments.
- Pair = same count of non-empty lines. `bin/check static` step `doc-pairs` fails on a mismatch, warns on a missing pair. Pre-commit warns on one side staged alone.
- Public repo: no secret, no employer detail in any example.
