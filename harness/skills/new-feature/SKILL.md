---
name: new-feature
description: Ship a new feature or a behaviour change in this repo spec-first - decide whether a spec is needed, write acceptance criteria, tests first, implement, bin/check, docs pairs, commit. Use for a new script, panel, stow module, or a change in what an existing one does.
---

# new-feature

Rules: `AGENTS.md` "Specs and tests", `harness/rules/tests.md`. Spec format: `docs/specs/README.md`.

## Steps

1. Spec needed? Yes = creates a script, panel or stow module, or changes behaviour of an existing one. No = config tweak, small fix: test only, skip to 3.
2. Spec `docs/specs/<feature>.md` (English, human style): title + files, Purpose (2 to 3 sentences), numbered acceptance criteria, each one observable behaviour ending in `Test: tests/unit/<path>.bats: "<name>"`, `Test: tests/static.sh: <step>` or `Test: manual`. Existing spec = edit criteria in place.
3. Tests first: bats file mirroring the script path, cases for each automated criterion, run `bin/check unit` and watch them fail for the right reason. Manual criteria = rows in `tests/manual.md` per host.
4. Implement smallest change inside the right place: module file, `nixos/` (skill `nixos-change`), Sway (`add-keybinding`, `add-panel`). New stow module = top-level dir with dot-prefixed contents, `stow <module>`, README module list.
5. `git add` new files. `bin/check` passes (static, unit, eval, terms).
6. Docs: README (en + pt-br) when install or use changes; `docs/<topic>.md` + `.pt-br.md` when how or why changes. Agent rule changed = `AGENTS.md` or `harness/`.
7. Live check what tests cannot (owner for hardware or session items).
8. Commit `feat(<scope>): <summary>`, spec + tests + code + docs together. Bug found on the way = separate `fix(...)`.

## Acceptance

- Every criterion maps to a test or a `tests/manual.md` row.
- `bin/check` passes, em-dash sweep clean, doc pairs present.
- No secret, no employer detail anywhere in the change.

## Pitfalls

- Test inside a module directory: gets linked into `$HOME`. Tests live in `tests/`.
- Untracked file: flake checks do not see it, test "passes" by not existing. `git add` first.
- Test reaching a real system path: add an env override with the real default (`${DRM_SYSFS:-/sys/class/drm}`).
- Stub missing: script calls the real command in the sandbox and fails oddly. `ln -s _stub tests/helpers/stubs/<cmd>`.
- Criterion with no test and no manual row = not a criterion yet.
