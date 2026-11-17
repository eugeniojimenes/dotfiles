---
description: Test layers (static, bats unit, manual) and feature specs
paths:
  - "tests/**"
  - "docs/specs/**"
  - "bin/check"
globs: tests/**, docs/specs/**, bin/check
alwaysApply: false
---

# Tests and specs rules

Spec format + criterion mapping: `docs/specs/README.md`. Run: `bin/check [static|unit|terms]`.

- Layers: static (`tests/static.sh`), unit (bats), eval (`nix flake check` evaluates every host), terms (local only). Flake checks in `tests/checks.nix`; `flake.nix` only imports it.
- Tests never inside a stow module (would get linked into `$HOME`).
- Bats file path mirrors script path: `tests/unit/<module>/<path>/<script>.bats`, e.g. `tests/unit/sway/.config/sway/bin/dnd.bats`.
- Each bats file: `setup() { load "${BATS_TEST_DIRNAME%/tests/unit/*}/tests/helpers/common"; }`. Gives temp `HOME`, `XDG_*`, `$STUBS`, stubs first on `PATH`, helpers `stub`, `calls`, `link_sway`.
- Run real script, never a copy. External commands = stubs: `ln -s _stub tests/helpers/stubs/<cmd>`. Canned behaviour: `stub <name> [--rc N] [output]`, custom logic `$STUBS/<name>.sh`. Assert on `calls`.
- Hardcoded system path a test must fake = env override with real default, `${DRM_SYSFS:-/sys/class/drm}` style, plus one-line comment. Production behaviour unchanged.
- Unit sandbox: no network, no Wayland, shebangs patched. Needs those = `manual`.
- Spec criterion ends with exactly one form per test: `Test: tests/unit/<path>.bats: "<exact @test name>"`, `Test: tests/static.sh: <step>`, `Test: manual`. Rename a `@test` = update the spec line.
- `manual` criterion = row in `tests/manual.md` under each host it applies to. Pass = owner writes date.
- New static step: function + `step <name> <fn>` in `tests/static.sh`. Non-zero = fail; warning-only steps print and return 0. New tool = add to the `static` tool list in `tests/checks.nix`.
- Specs: English only, human-doc style (see `**/*.md` rule). Specs for new script, panel, module, or behaviour change; same commit as code.
- Bug a test exposes = separate `fix(...)` commit.
- Flake sees tracked files only: `git add` new tests before `bin/check`.
