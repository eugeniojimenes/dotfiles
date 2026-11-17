# Sway

The whole desktop lives in one directory, `sway/.config/sway/`, which stow links to `~/.config/sway/`. Every app is started with an explicit path into this directory, so the stock `~/.config/<app>` locations are never read.

## Layout

- `config` sets the variables, then runs `include config.d/*`, then `include hosts/$(hostname)`.
- `config.d/` is the config split by topic into numbered pieces (`10-look`, `20-input`, `30-apps` and so on). They load in name order, and the variables in `config` must come first.
- `hosts/<hostname>` holds that machine's `output` lines. It loads last so it can override the shared pieces, and a missing file is skipped. See [machines.md](machines.md).
- `bin/` holds the scripts that bindings, waybar and the menu run.
- `apps/` holds the configs for waybar, mako, fuzzel, swaylock and wiremix.
- `panels/` holds the Quickshell panels and the lock screen. Each one has an entry file at the top (`wifi.qml`, `bluetooth.qml`, `sound.qml`, `display.qml`, `calendar.qml`, `lock.qml`) and a directory of the same name with its scripts and logic (`toggle`, `flow.mjs`, `display/ctl`, `lock/lock`).
- `panels/common/` holds what the panels share: `PanelShell.qml`, `Theme.qml` and `AdvancedLink.qml`.

One file lives outside that directory: `sway/.config/xdg-desktop-portal-wlr/sway`, the screen-share picker config.

`/etc/sway/config.d` is not included. `bin/session-env` imports the session environment (`DISPLAY`, `WAYLAND_DISPLAY`, `SWAYSOCK`, `XDG_CURRENT_DESKTOP`) into systemd and D-Bus itself, then restarts `xdg-desktop-portal` so it picks the Sway portal config and screen sharing works.

## Scripts

Bash scripts start with `#!/usr/bin/env bash` because NixOS has no `/bin/bash`. POSIX scripts use `#!/bin/sh`, which NixOS does provide. The menu reads `.desktop` files from `XDG_DATA_DIRS` instead of `/usr/share`, since NixOS keeps them in the store and in profile directories.

## Binding titles

Every binding has a `#: <title>` comment on the line above it. `bin/keybindings` (`Super + K`) reads `config` first and then `config.d/*`, and shows that title for each binding. A binding without a title shows its raw command instead. Workspace bindings get generated titles. Picking a line in the list runs the binding, so the cheat sheet also works as a launcher.

## GPU order at startup

greetd runs `bin/start` (the path is set in `nixos/common.nix`). The script sets `WLR_DRM_DEVICES` with the integrated GPU first. wlroots renders on the first device in that list. Left alone, it picked the NVIDIA card, and every frame for the panel, which is wired to the iGPU, crossed between GPUs through CPU copies: high CPU use and a spinning fan. The NVIDIA card stays in the list, second, because the HDMI and DP ports are wired to it. Without it the external monitors go dark. On a machine with one GPU the ordering does nothing.

## Resume and external monitors

`display/reinit` runs after resume. With the proprietary NVIDIA driver, Sway keeps the external outputs marked active after a suspend while the screen stays black. Disabling and enabling each external output forces a new modeset. This is still needed with NVIDIA's suspend support enabled: on 2026-11-12 the external monitor stayed black without the hook.

## Battery warnings

UPower (`nixos/common.nix`) tracks the battery and powers the machine off at 2%. Its default action is hybrid sleep, which needs a swap device, and this machine only has zram. `poweralertd`, started in `config.d/90-autostart`, turns UPower's levels into notifications: low at 20%, critical at 5%. It also sends a notification on every charge state change, such as plugging in the charger. `apps/mako` hides those and shows the warnings with a red border until they are clicked, including while Do not disturb or a screen share hides everything else.

## Polkit agent

`polkit-gnome-authentication-agent-1`, started in `config.d/90-autostart`, shows the password dialog when an app asks polkit for an admin action, such as formatting a disk in GNOME Disks or opening a folder as administrator in Nautilus. Without an agent in the session those actions fail at once. NixOS keeps the agent in the package's `libexec/` directory, so `nixos/common.nix` adds `/libexec` to `environment.pathsToLink` and Sway starts it from `/run/current-system/sw/libexec`.

## Panels

The panels are Quickshell windows. Each panel has a `toggle` script that kills the running panel or starts a new one, so a click on its waybar icon or menu entry opens and closes it. While a panel is open, a scanner or listener runs; once it closes, nothing keeps running.

A panel is a full-screen transparent `PanelWindow` on the overlay layer with exclusive keyboard focus. Esc closes it, and so does a click outside the visible card.

Exclusive keyboard focus does not follow a workspace switch. Switching workspace by key or by a click on another output would leave every window without input until the panel closed. So each panel listens to Sway's workspace events through `I3IpcListener` and closes itself on a focus change, the way a popup would. Sway also skips its own mouse warping while a layer surface holds the keyboard, so when the switch moves to another output the panel moves the cursor to the center of the new workspace before it quits.

All of this lives once in `common/PanelShell.qml`, and every panel except the lock screen is a `PanelShell` with its own card. Quickshell only loads files from the directory of the entry file it runs, which is why every entry file sits at the top of `panels/` and imports `"common"` and its own `<name>/` files from there. An import that leaves that directory passes qmllint but fails in Quickshell, so `bin/check static` also starts every panel in a headless Sway (step `panels-load`). `common/Theme.qml` holds the colours and the font, and `common/AdvancedLink.qml` is the footer link that opens a panel's full TUI in a floating terminal. A fix to the shared behaviour goes there, so it reaches every panel at once.

## Terminal opacity and text size

Alacritty's opacity is set live by `bin/opacity` through `alacritty msg config`. Text size is set by `display/ctl`, which edits `alacritty/.config/alacritty/alacritty.toml` in place. The edit shows up in `git status`. Commit it to keep the new size as the default, or check out the file to drop it.
