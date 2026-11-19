# Color picker

Files: `sway/.config/sway/bin/colorpick`, bound to `Super + Ctrl + Print` in `sway/.config/sway/config.d/60-media`, listed under Capture in `sway/.config/sway/panels/menu/menu.mjs`. hyprpicker is in `nixos/common.nix`.

## Purpose

Read the color of any pixel on the screen, for CSS, themes or checking a palette. hyprpicker shows a magnifier so the pick is exact, and the hex value lands on the clipboard.

## Acceptance criteria

1. A pick puts the hex color on the clipboard and shows it in a notification. Only the color gets there: log lines hyprpicker prints on its output are left out. Test: `tests/unit/sway/.config/sway/bin/colorpick.bats: "pick: hex color on the clipboard and in a notification"`
2. Esc cancels: nothing is copied and no notification shows. Test: `tests/unit/sway/.config/sway/bin/colorpick.bats: "Esc: nothing copied, no notification"`
3. While hyprpicker runs, the cursor is nudged 1 pixel and back, because Sway gives a new surface the pointer only on the next motion. Test: `tests/unit/sway/.config/sway/bin/colorpick.bats: "lens up without moving the mouse: cursor nudged 1 px and back while hyprpicker runs"`
4. `Super + Ctrl + Print` and Capture › Color picker show the magnifier at once, without moving the mouse,, and a click over a known color (the blue bar accent, `#89b4fa`) copies that value. Test: manual
