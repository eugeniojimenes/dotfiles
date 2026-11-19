# Night light

Files: `sway/.config/sway/bin/nightlight`, bound in `sway/.config/sway/config.d/60-media`, listed under Toggle in `sway/.config/sway/bin/menu`, shown by the `custom/nightlight` module in `sway/.config/sway/apps/waybar.jsonc`. `gammastep` comes from `nixos/common.nix`.

## Purpose

`nightlight` warms the screen to 4000 K by hand. Nothing turns it on or off by schedule. gammastep holds the colour change while it runs, so ending the process puts the screen back.

## Acceptance criteria

1. `nightlight toggle` while off starts `gammastep -m wayland -O 4000` detached and sends waybar signal 11. Test: `tests/unit/sway/.config/sway/bin/nightlight.bats: "toggle when off: gammastep holds 4000 K, waybar signal 11"`
2. `nightlight toggle` while on ends that gammastep and starts nothing. Test: `tests/unit/sway/.config/sway/bin/nightlight.bats: "toggle when on: gammastep ended, nothing new starts"`
3. `nightlight status` prints the waybar JSON: a moon icon with class `on` while on, empty text otherwise. Test: `tests/unit/sway/.config/sway/bin/nightlight.bats: "status: icon only while on"`
4. Toggle › Night light in the menu runs `nightlight toggle`. Test: `tests/unit/sway/.config/sway/bin/menu.bats: "Toggle > Stay awake and Night light run their toggles"`
5. `Super + Ctrl + N` warms every screen, the bar icon appears, and a click on it or the key again restores the normal colours. Test: manual
6. `nightlight` with no argument prints the usage and exits 2. Test: `tests/unit/sway/.config/sway/bin/nightlight.bats: "no argument: usage, exit 2"`
