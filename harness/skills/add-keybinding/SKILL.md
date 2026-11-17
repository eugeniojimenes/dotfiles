---
name: add-keybinding
description: Add or change a Sway keybinding in this repo with its `#:` title, a conflict check against existing bindings, reload and test. Use when the owner asks for a new shortcut, to rebind a key, or to bind a script.
---

# add-keybinding

Rules: `harness/rules/sway.md`. Spec: `docs/specs/keybindings.md`.

## Steps

1. Pick piece by topic in `sway/.config/sway/config.d/`: `30-apps` launchers, `40-windows` focus/layout, `50-workspaces`, `60-media` volume/brightness/screenshots, `70-session` reload/exit. Lock key lives in `30-apps` (`$mod+Shift+l`). Machine-only key = `hosts/<hostname>`, but `bin/keybindings` reads only `config` + `config.d/*`: such a key never shows in `Super + K`.
2. Conflict check. List every existing combo:
   ```sh
   grep -hE '^\s*bind(sym|code)' sway/.config/sway/config sway/.config/sway/config.d/* sway/.config/sway/hosts/* | sort
   ```
   Same combo (modifier order and `--to-code`, `--locked` flags aside) = conflict. Ask owner before replacing one. Also `bin/keybindings` (`Super + K`) shows the live list with titles.
3. Write binding with `#: <Title>` on the line directly above. Title = what it does, sentence case, no trailing period. Use `$mod`, `$dir`, `$term` variables; script path via `$dir/bin/<script>`.
4. Binding runs a new script: `sway/.config/sway/bin/<name>`, executable, `#!/usr/bin/env bash` or `#!/bin/sh`, header comment = purpose. Plus bats test `tests/unit/sway/.config/sway/bin/<name>.bats` and spec when it is a new feature (skill `new-feature`).
5. `bin/check static` (`sway -C` per host, shellcheck) and `bin/check unit` if a script changed.
6. Apply: `swaymsg reload`. Owner presses the key to confirm; `Super + K` shows the title.
7. Commit `feat(sway): <key> <action>`. README module list or `docs/sway.md` + pt-br pair only when the binding is worth documenting there.

## Acceptance

- `#:` title present, shows in `Super + K`.
- No conflict with existing combo (or owner approved the replacement).
- `bin/check` passes; key works after `swaymsg reload`.

## Pitfalls

- Title not directly above: `bin/keybindings` shows raw command instead.
- Workspace `bindcode`s get generated titles; do not add `#:` there.
- Binding in `hosts/<hostname>`: missing from `Super + K` (parser skips `hosts/`). Prefer `config.d/` unless the key only makes sense on that machine.
- `$var` inside the command must exist in `config` (variables load before `config.d/*`).
- Testing a panel binding by `pkill -f '<pattern>'` from a shell whose command line holds the pattern kills that shell. Use the toggle script.
