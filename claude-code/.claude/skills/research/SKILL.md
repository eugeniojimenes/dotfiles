---
name: research
description: "Trigger on literal token `/research` appearing anywhere in user prompt (start, middle, end). When present, treat as marker requesting context7 + web-search research and upfront clarifying questions before/while working on rest of prompt. Strip the `/research` marker from the effective task. Fire EVERY time `/research` literal appears, even mid-sentence. Do not fire if user only mentions the word 'research' without the slash prefix."
allowed-tools: WebSearch, WebFetch, mcp__plugin_context7_context7__resolve-library-id, mcp__plugin_context7_context7__query-docs, Read, Grep, Glob, Bash
---

# Research (inline marker)

User typed `/research` somewhere in prompt. Apply directives below to current prompt only. Do not persist to later turns.

## Directives

1. **context7** — for any library/framework/SDK/API/CLI mentioned in task: resolve ID, query docs. Training data may be stale.
2. **websearch** — for time-sensitive, version-specific, or current-state info (recent releases, breaking changes, known issues).
3. **Ask anything you need before or as you work** — batch clarifying questions upfront. Surface ambiguities, assumptions, edge cases, decisions: scope, env/versions, I/O formats, existing conventions, trade-offs, success criteria. Re-ask mid-work when new ambiguity arises. No silent guessing.

Research first, ask first, act last. Wrong-assumption cost > round-trip cost.

## Effective task

Strip the `/research` marker from prompt. Treat remaining text as the actual task. Marker position (start/middle/end) is irrelevant — directives apply to whole task.
