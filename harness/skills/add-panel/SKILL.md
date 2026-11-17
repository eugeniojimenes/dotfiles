---
name: add-panel
description: Add a Quickshell panel to the Sway desktop of this repo (toggle script, full-screen transparent PanelWindow, Esc and outside-click close, close on workspace switch with cursor warp, waybar and menu wiring, spec with manual criteria). Use when the owner wants a new popup panel or to replace a TUI or fuzzel picker with one.
---

# add-panel

Rules: `harness/rules/sway.md`. Why the pattern: `docs/sway.md` "Panels". Skeleton: `references/panel.md`. Existing panels to copy from: `wifi/` + `bluetooth/` (flow in `flow.js`, tested), `sound/`, `display/`, `calendar/`.

## Steps

1. Spec first: `docs/specs/<name>-panel.md` (format `docs/specs/README.md`). Criterion 1 = qmllint (`Test: tests/static.sh: qmllint`); behaviour criteria mostly `Test: manual`. Copy the shared ones from `docs/specs/wifi-panel.md`: icon click opens and second click closes; Esc closes; outside click or workspace switch closes, cursor moves to centre of other output.
2. `sway/.config/sway/<name>/toggle` + `shell.qml` from `references/panel.md`. Root = `PanelShell`: `ln -s ../common sway/.config/sway/<name>/common`, then `import "common"` (Quickshell refuses `../common`, outside the panel dir): overlay window, exclusive keyboard, outside click close, workspace-switch close with cursor warp, theme colours. Panel adds: namespace `sway-<name>`, card with a `MouseArea` swallowing clicks, Esc → `Qt.quit()`, footer `AdvancedLink` when a TUI exists. Never re-copy the shared blocks into the panel.
3. Async flow (connect, pair, wait for a result) = logic in `<name>/flow.js`, tested through `qmltestrunner` (`harness/rules/tests.md`). Data: Quickshell services first (`Quickshell.Networking`, `Quickshell.Bluetooth`, `Quickshell.Services.Pipewire`...); external command via `Process` only when no service exists. Anything that polls runs only while panel open.
4. Wire: waybar module `on-click` in `apps/waybar.jsonc`, menu entry in `bin/menu`. New external command = package in `nixos/common.nix` `programs.sway.extraPackages`.
5. `tests/manual.md`: row `Spec <name>-panel | Criteria N to M.` under each host.
6. `git add`, `bin/check static` (qmllint resolves types, `panels-load` starts the panel in headless Sway, shellcheck toggle, waybar JSON), `bin/check`.
7. Try it: `swaymsg exec ~/.config/sway/<name>/toggle`, same as waybar (run directly it blocks the agent shell: `exec quickshell` stays in foreground). Never `pkill -f` from the agent shell. Owner checks the manual criteria on the live session and writes the date.
8. README Sway entry + `docs/sway.md` if the panel list there changes (pt-br pairs too). Commit `feat(sway): Quickshell <name> panel`.

## Acceptance

- qmllint clean, `panels-load` ok; toggle opens and closes; Esc, outside click, workspace switch close it; cursor follows to the other output.
- Nothing left running after close (`pgrep -af '^[^ ]*quickshell -p .*/sway/<name>/shell.qml'` empty; unanchored `pgrep -f` matches the agent's own shell).
- Spec + manual rows in place; `bin/check` passes.

## Pitfalls (from this repo)

- Exclusive keyboard focus without the `I3IpcListener` close: after a workspace switch every window lost input until the panel closed.
- Sway skips `mouse_warping` while a layer surface holds the keyboard: without the `seat - cursor set` call the cursor stays on the old output.
- `pkill -f '<pattern>'` from `bash -c` whose command line holds the same pattern kills the agent shell. Use the toggle script.
- `Bluetooth.defaultAdapter` (Quickshell 0.3) trips qmllint `unresolved-type`: qmltypes names the type without its C++ namespace. Line-level `// qmllint disable unresolved-type` on that line only, never a global disable.
- `import "../common"` passes qmllint but Quickshell says "PanelShell is not a type" and the panel never opens (happened 2026-11-17). Use the `common` symlink.
- qmllint false positives already disabled in `tests/static.sh` (`unqualified`, `comma`, `uncreatable-type`, `signal-handler-parameters`); anything else it reports = real.
