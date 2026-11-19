# Panels

Files: `sway/.config/sway/panels/common/PanelShell.qml` (window, closing rules), `sway/.config/sway/panels/common/AdvancedLink.qml` (link to the full program), `sway/.config/sway/panels/<name>/toggle` (one per panel), `sway/.config/sway/apps/waybar.jsonc` and `sway/.config/sway/panels/menu/menu.mjs` (what runs the toggles).

## Purpose

The popup panels (Bluetooth, calendar, display, power, sound and Wi-Fi) share their window, their closing rules and the way they open. This spec covers that shared part once, so each panel's spec covers only what is inside its card. Esc stays in each panel's spec, because each panel handles its own keys. The notification centre opens over IPC and is covered by the notifications spec.

## Acceptance criteria

1. Every path under `~/.config/sway` that the waybar config, the Sway config, a panel (the menu's `menu.mjs` included) or the NixOS config (`nixos/*.nix` and the host files: the session start and the screen-share portal hooks) runs exists in the repo. Each panel's `toggle` names only that panel's entry file, and a toggle that starts a panel starts one built on `PanelShell` and closes it by its exact command line (`pkill -fx`), so no other process whose command line holds the same text is killed. Test: `tests/static.sh: sway-paths`
2. A click on a panel's waybar icon opens the panel, and a second click closes it. The menu entries under Setup open the same panels. Test: manual
3. A click outside the card or a workspace switch closes the panel. When the switch lands on another output, the cursor moves to the centre of that output. Test: manual
4. The Advanced link at the bottom of the Wi-Fi, Bluetooth and sound panels opens `nmtui`, `bluetoothctl` or `wiremix` (with `apps/wiremix.toml`) in a floating terminal and closes the panel. Test: manual
5. Every text in a panel, the notification daemon, the share picker, the lock screen and the screensaver that shows a value declares its format, and text that comes from outside (notification titles and app names, action labels, window titles, track names, network and device names) is drawn as plain text. Qt's default format turns a string holding a tag into rich text, which fetches an image source over the network, so a Wi-Fi network named `<img src=...>` or a page title could otherwise make the machine contact any address. Test: `tests/static.sh: plain-text`
