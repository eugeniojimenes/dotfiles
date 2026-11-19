# Specs

A spec says what a feature does and which test proves each part of it. Specs are written in English only.

## When a spec is required

Write or update a spec when a change creates a script, a panel or a stow module, or when it changes the behaviour of an existing one. Config tweaks and small fixes do not need a spec. They ship with their test only.

Update the spec in the same commit that changes the behaviour.

## Format

One file per feature, `docs/specs/<feature>.md`, with three parts:

1. A title and the files the feature lives in.
2. Purpose: two or three sentences on what the feature is for.
3. Acceptance criteria: a numbered list. Each criterion is one observable behaviour, followed by the test that covers it.

## Mapping criteria to tests

Each criterion ends with one of these:

- `Test: tests/unit/<path>.bats: "<test name>"` for a bats test. The path mirrors the script's path in the repo, and the name is the exact `@test` string.
- `Test: tests/static.sh: <step>` for a static check, such as `qmllint` or `sway-config`.
- `Test: manual` when the behaviour needs real hardware or a live Wayland session. A manual criterion must also appear in `tests/manual.md`, under each host it applies to.

A criterion may name more than one test. A behaviour with no test and no manual entry is not a criterion yet. Either write the test or add the manual check.

The `spec-tests` step of `bin/check static` reads every `Test:` reference in these files and fails when the bats file or the exact `@test` name is missing, or when the static step does not exist. A renamed test therefore breaks the check instead of leaving its criterion pointing at nothing. The step also fails when a bats file that some spec cites holds a test no criterion cites, so a new test in a specced script comes with its criterion. A bats file no spec cites yet is skipped until its script gets a spec. It also fails when a QtTest file under `tests/unit` has a test function that the bats file beside it never runs with `qt <function>;`, since such a function would never run.
