# Power panel

Files: `sway/.config/sway/panels/power.qml` (Quickshell), `sway/.config/sway/panels/power/power.mjs` (text and glyphs), `sway/.config/sway/panels/power/toggle` (run by a click on the waybar battery icon and by Setup › Power in the menu).

## Purpose

The panel gathers what the battery icon cannot show: the charge with its state and estimate, the power draw, the battery health, the power profile and the charge limit. Profile and limit change from the panel itself, without a password. It reads UPower and power-profiles-daemon over D-Bus, so it runs nothing while it is closed.

## Acceptance criteria

1. The panel file parses, every type, property and import resolves against Qt and Quickshell, and Quickshell loads it in a headless Sway. Test: `tests/static.sh: qmllint`, `tests/static.sh: panels-load`
2. A click on the waybar battery icon opens the panel, and a second click closes it. Setup › Power in the menu opens it too. Test: manual
3. The top shows a battery glyph for the charge in eleven steps (a plug variant while on AC), the percentage, a bar of the same length, and a line with the state: charging with the time to full, on battery with the time left, fully charged, or plugged in and not charging. Test: `tests/unit/sway/.config/sway/panels/power/power.bats: "status line per UPower state, with the estimate when there is one"`, `tests/unit/sway/.config/sway/panels/power/power.bats: "battery glyph: eleven steps, plug glyphs on AC, clamped"`, manual
4. Estimates read as hours and minutes ("2 h 05 min"), minutes, or "under 1 min", and are left out when UPower has none. Test: `tests/unit/sway/.config/sway/panels/power/power.bats: "duration: hours and minutes, under a minute, no estimate"`
5. Under the bar, the power draw in watts shows while it is above zero, and the battery health when the battery reports it. On a machine without a laptop battery, the whole charge section is hidden and the panel shows only the power profile. Test: `tests/unit/sway/.config/sway/panels/power/power.bats: "detail line: draw while above zero, health when reported"`, manual
6. The power profile row has Saver, Balanced and Performance (Performance only when the machine has it), with the current one highlighted. A click or Left/Right sets the profile, and the waybar profile icon follows. A degraded performance profile shows the reason in red. Test: manual
7. The charge limit row shows only when UPower says the battery supports a charge threshold. Its On/Off chip switches the threshold without a password prompt and shows the new state. Test: manual
8. Esc, a click outside the panel or a workspace switch closes it. When the switch lands on another output, the cursor moves to the centre of that output. Test: manual
