---
description: Sway desktop config, scripts and Quickshell panels
paths:
  - "sway/**"
globs: sway/**
alwaysApply: false
---

# Sway rules

Why behind each: `docs/sway.md`. Skills: `add-keybinding`, `add-panel`.

- Bash script = `#!/usr/bin/env bash` (NixOS has no `/bin/bash`). POSIX script = `#!/bin/sh`.
- Every binding gets `#: <title>` on the line above, except workspace bindcodes in `config.d/50-workspaces` (titles generated). `bin/keybindings` (`Super + K`) shows it; no title = raw command shown.
- Explicit paths only: `$dir/...` in config, `~/.config/sway/...` in scripts. App configs live in `apps/`, passed by path; stock `~/.config/<app>` never read.
- Outputs: `output "<make> <model> <serial>"` from `swaymsg -t get_outputs -p`, in `hosts/<hostname>`. Never connector names (`eDP-1`, `HDMI-A-1`): they shift with driver load order. Nothing machine-specific in `config.d/`.
- `config.d/` pieces numbered, load in name order; variables in `config` come first. New topic = new numbered piece, not a new include.
- Panels follow the panel pattern (toggle script, full-screen transparent `PanelWindow`, Esc + outside click close, `I3IpcListener` closes on workspace focus change with cursor warp). Skill `add-panel`.
- Apply config: `swaymsg reload`. Panel change: close and reopen it through `swaymsg exec ~/.config/sway/<name>/toggle` (run directly, the toggle blocks the shell: `exec quickshell` in foreground).
- Never `pkill -f` a pattern that also matches the agent's own shell command line: `pkill -f 'quickshell -p .*/sway/wifi/shell.qml'` inside `bash -c` kills that bash. `pgrep -f` has the same trap: the wrapper bash matches too. Anchor the pattern to the process start: `pgrep -af '^[^ ]*quickshell -p .*/sway/wifi/shell.qml'`, then kill by PID.
- Touched script without bats test = add one in `tests/unit/sway/.config/sway/<path>.bats` same commit (`float`, `session-env`, panel `toggle`s = static-only by decision). Behaviour change of a script or panel = update its spec in `docs/specs/`.
- New external command = package in `nixos/common.nix` (`programs.sway.extraPackages`) + stub in `tests/helpers/stubs/` when a test reaches it.
- Notebook-only behaviour (`display/reinit`, GPU order in `bin/start`, touchpad block) listed in `docs/machines.md`: keep list current.
- `display/ctl` edits `alacritty/.config/alacritty/alacritty.toml` in place: diff there after text-size change = expected.
- Check: `bin/check static` (`sway -C` per host, `qmllint`, waybar JSON, shellcheck), `bin/check unit`.
