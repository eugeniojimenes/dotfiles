---
description: Sway desktop config, scripts and Quickshell panels
paths:
  - "sway/**"
globs: sway/**
alwaysApply: false
---

# Sway rules

Why behind each: `docs/sway.md`. Skills: `add-keybinding`, `add-panel`.

- Bash script = `#!/usr/bin/env bash` (NixOS has no `/bin/bash`). POSIX script = `#!/bin/sh`. Format = `nix fmt` (shfmt, style in `.editorconfig`); one-line `{ a; b; }` groups get split, so prefer `cond && return` early exits.
- Every binding gets `#: <title>` on the line above, except workspace bindcodes in `config.d/50-workspaces` (titles generated). `bin/keybindings` (`Super + K`) shows it; no title = raw command shown.
- Explicit paths only: `$dir/...` in config, `~/.config/sway/...` in scripts. App configs live in `apps/`, passed by path; stock `~/.config/<app>` never read.
- `/etc/sway/config.d` not included: `bin/session-env` does the systemd/D-Bus env import. Menu = Quickshell panel `panels/menu.qml`, tree + search + actions in `panels/menu/menu.mjs`; apps from `DesktopEntries` (`XDG_DATA_DIRS`), launched by id through `gtk-launch`.
- Screen-share portal settings (`chooser_cmd`, `exec_before`, `exec_after`) = `xdg.portal.wlr.settings` in `nixos/common.nix`: NixOS starts the portal with `--config`, `~/.config/xdg-desktop-portal-wlr` never read. Picker = `bin/share-picker` + `panels/share.qml`.
- Outputs: `output "<make> <model> <serial>"` from `swaymsg -t get_outputs -p`, in `hosts/<hostname>`. Never connector names (`eDP-1`, `HDMI-A-1`): they shift with driver load order. Nothing machine-specific in `config.d/`.
- `config.d/` pieces numbered, load in name order; variables in `config` come first. New topic = new numbered piece, not a new include.
- Panels live in `panels/` (one Quickshell root): entry `panels/<name>.qml`, `panels/<name>/` for toggle, `.mjs` logic, scripts. Pattern: toggle script + `PanelShell` from `panels/common/` (overlay window, outside click and workspace switch close, cursor warp, `Theme` colours as `win.fg`...). Panel adds namespace, card, own keys (Esc). Shared behaviour change = edit `common/`, never copy into a panel. Skill `add-panel`.
- Colours = Catppuccin Mocha, named once per format: panels `Theme` (`common/Theme.qml`, translucent = `Qt.alpha(Theme.x, a)`), waybar `@define-color` at top of `apps/waybar.css`, Sway `set $x` in `config.d/10-look`. No hex literal elsewhere except formats without variables (`apps/fuzzel.ini`, `apps/swaylock`, `bin/float`). Static step `palette` fails on any hex outside Mocha.
- Panel `Text` showing a value (or component root `Text` whose users set it) = `textFormat` declared: `Text.PlainText`, or `Text.StyledText` only for vetted markup (notification body through `Notify.safeBody`). Default AutoText makes a string with a tag rich text, which fetches `<img src>` over the network (title, SSID, track name, window title = attacker text). Static step `plain-text`.
- Panel QML: Qt order (id, property declarations, functions, object properties, children), blank line between groups. Typed properties where Qt has the type (`list<string>`, `list<int>`, `real`); `var` only for Quickshell objects. Every clickable `MouseArea` gets `cursorShape: Qt.PointingHandCursor` (not the outside-close or click-swallowing ones).
- Panel `.mjs`: header says what `panel` and the other params are and maps the state fields. Full-word names (`panel`, `network`, `device`), never `p`/`n`/`d`. Two or more booleans = one named object (`{ connecting, disconnected }`). Explicit `if` over arithmetic on booleans.
- Apply config: `swaymsg reload`. Panel change: close and reopen it through `swaymsg exec ~/.config/sway/panels/<name>/toggle` (run directly, the toggle blocks the shell: `exec quickshell` in foreground).
- Never `pkill -f` a pattern that also matches the agent's own shell command line: `pkill -f 'quickshell -p .*/sway/panels/wifi.qml'` inside `bash -c` kills that bash. `pgrep -f` has the same trap: the wrapper bash matches too. Anchor the pattern to the process start: `pgrep -af '^[^ ]*quickshell -p .*/sway/panels/wifi.qml'`, then kill by PID.
- Touched script without bats test = add one in `tests/unit/sway/.config/sway/<path>.bats` same commit. Static-only exception (same command every run): `harness/rules/tests.md`. Behaviour change of a script or panel = update its spec in `docs/specs/`.
- New external command = package in `nixos/common.nix` (`programs.sway.extraPackages`) + stub in `tests/helpers/stubs/` when a test reaches it.
- Notebook-only behaviour (`panels/display/reinit`, GPU order in `bin/start`, touchpad block) listed in `docs/machines.md`: keep list current.
- `panels/display/ctl` edits `alacritty/.config/alacritty/alacritty.toml` in place: diff there after text-size change = expected.
- Check: `bin/check static` (`sway -C` per host, `qmllint`, `panels-load` = every `panels/*.qml` (lock in dry mode) loaded by Quickshell in headless Sway, waybar JSON, shellcheck), `bin/check unit`.
- Quickshell refuses imports outside the entry file's dir (qmllint does not): entry files stay at top of `panels/`, import `"common"`, `"<name>"` (its components) and `"<name>/x.mjs"`. Big panel = components `panels/<name>/<Upper>.qml`, logic in `.mjs`; a component imports `"../common"` and `"x.mjs"` (`../` only from `panels/<name>/` to `panels/common`, never out of `panels/`). `import qs.common` works in Quickshell but qmllint cannot resolve it: relative only. Never an entry file inside a subdir.
- Passing an object into a component: never `prop: prop` (`deck: deck`): inside the component the name is its own property, still empty. Distinct id (`deck: deckItem`).
- `Repeater` / `ListView` over a JS array: every new array recreates every delegate (timers restart, state lost). Delegate holds state (timer, animation) = `model: ScriptModel { values: <array> }`: delegates of items still in the list kept.
