---
name: research-mode
description: "Run task with aggressive research and clarification: context7 for lib docs, websearch for current info, batch clarifying questions upfront before work."
disable-model-invocation: true
allowed-tools: WebSearch, WebFetch, mcp__plugin_context7_context7__resolve-library-id, mcp__plugin_context7_context7__query-docs, Read, Grep, Glob, Bash
---

# Research Mode

Apply directives this prompt only. No persist later turns.

## Directives

1. **context7** — any lib/framework/SDK/API/CLI in task. Resolve ID, query docs. Training stale.
2. **websearch** — time-sensitive, version-specific, current state (releases, breaking changes, issues).
3. **Ask many questions upfront, batched.** Surface every ambiguity, assumption, edge case, decision: scope, env/versions, I/O formats, existing conventions, trade-offs, success criteria. Re-ask mid-work on new ambiguity. No silent guessing.

Research first, ask first, act last. Wrong-assumption cost > round-trip cost.

## Task

$ARGUMENTS
