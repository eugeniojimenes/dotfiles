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
- Tests never inside a stow module (would get linked into `$HOME`). Layout: `tests/static.sh` (static layer), `tests/unit/<module path mirrored>/<script>.bats`, `tests/helpers/` (stubs), `tests/checks.nix` (flake checks), `tests/manual.md` (hardware and live session, per host).
- Touched script without tests gets one in same commit. Exception = static-only: script runs same command every time, nothing read at run time picks a path (`float`, `session-env`). Test there = command copied, catches no bug. Only branch = a result the stub fakes (panel `toggle`: `pkill || exec quickshell`) = static-only too. Any real branch (fallback value, create vs reattach, argument check) = bats test (`term`, `sys-tools`).
- Bats file path mirrors script path: `tests/unit/<module>/<path>/<script>.bats`, e.g. `tests/unit/sway/.config/sway/bin/dnd.bats`.
- Each bats file: `setup() { load "${BATS_TEST_DIRNAME%/tests/unit/*}/tests/helpers/common"; }`. Gives temp `HOME`, `XDG_*`, `$STUBS`, stubs first on `PATH`, helpers `stub`, `calls`, `link_sway`.
- Run real script, never a copy. External commands = stubs: `ln -s _stub tests/helpers/stubs/<cmd>`. Canned behaviour: `stub <name> [--rc N] [output]`, custom logic `$STUBS/<name>.sh`. Assert on `calls`.
- Hardcoded system path a test must fake = env override with real default, `${DRM_SYSFS:-/sys/class/drm}` style, plus one-line comment. Production behaviour unchanged.
- Unit sandbox: no network, no Wayland, shebangs patched. Needs those = `manual`.
- Panel logic worth a test (async flows, state machines) = ES module beside the QML (`<name>.mjs`, `export function`, `import "<name>.mjs" as X`: isolated from the panel scope, strict mode, valid for TS server and prettier; never `.js` with or without `.pragma library`; state passed in, enums mapped to booleans in QML), QtTest file next to its bats wrapper, one `@test` per test function (static `spec-tests` fails on a function without `qt <fn>;`) via `qmltestrunner -import "$QML" -input <file>.qml <case>::<fn>` (`$QML` = Qt's `lib/qt-6/qml` beside `qmltestrunner`, see the example bats) (`QT_QPA_PLATFORM=offscreen`). Examples: `tests/unit/sway/.config/sway/panels/{bluetooth,wifi}/flow.{qml,bats}` (flows), `panels/calendar/calendar.{qml,bats}` (date math, fixed `TZ`).
- Spec criterion ends with exactly one form per test: `Test: tests/unit/<path>.bats: "<exact @test name>"`, `Test: tests/static.sh: <step>`, `Test: manual`. Rename a `@test` = update the spec line; static step `spec-tests` fails otherwise. Also fails: test in a bats file some spec cites, but no criterion cites it (new test = new or extended criterion). Bats file no spec cites = skipped.
- `manual` criterion = row in `tests/manual.md` under each host it applies to. When: whole list on new host or `bin/update` moving NixOS release, kernel series or NVIDIA branch; behaviour change with manual criterion = ask owner to check that item before commit, record on their word. Pass = `bin/manual-pass "<item>"...`: last pass per item and host in `tests/manual-passes.toml` (machine, CPU, GPUs; per item date, NixOS, kernel, NVIDIA, displays, `--with` peripherals), updated in place, history = git. Agent runs it only on owner's word that the items passed. Agent drove the check (skill `manual-check`) = `--with agent-driven`. Never add a serial, MAC or UUID to it (public repo).
- New static step: function + `step <name> <fn>` in `tests/static.sh`. Non-zero = fail; warning-only steps print and return 0. New tool = add to the `static` tool list in `tests/checks.nix`.
- Specs: English only, human-doc style (see `**/*.md` rule). Spec for new script, panel, stow module, or behaviour change of one; same commit as code. Config tweak, small fix: test only, no spec.
- Bug a test exposes = separate `fix(...)` commit.
- Flake sees tracked files only: `git add` new tests before `bin/check`.
