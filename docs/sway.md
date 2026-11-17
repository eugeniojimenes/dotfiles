# Sway

The whole desktop lives in one directory, `sway/.config/sway/`, which stow links to `~/.config/sway/`. Every app is started with an explicit path into this directory, so the stock `~/.config/<app>` locations are never read.

## Layout

- `config` sets the variables, then runs `include config.d/*`, then `include hosts/$(hostname)`.
- `config.d/` is the config split by topic into numbered pieces (`10-look`, `20-input`, `30-apps` and so on). They load in name order, and the variables in `config` must come first.
- `hosts/<hostname>` holds that machine's `output` lines. It loads last so it can override the shared pieces, and a missing file is skipped. See [machines.md](machines.md).
- `bin/` holds the scripts that bindings, waybar and the menu run.
- `apps/` holds the configs for waybar, fuzzel, swaylock and wiremix.
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

## Screen recording

`bin/record` records a region (`Ctrl + Print`) or the focused screen (`Ctrl + Shift + Print`) to an MP4 in `~/Videos`. The Capture menu has the same two. The video has no audio. While it records, a small box in the bottom-right corner shows the elapsed time, and notifications are hidden, as during a screen share. Sway has no way to keep a window or a notification out of the capture, so the box shows up in the video when the recorded area includes that corner, and a notification would too. Pressing either key again, picking any record entry, or clicking the box or the red icon in the bar stops the recording. wf-recorder encodes with x264 on the CPU. It only encodes frames that changed, so the load stays low, and the notebook has no VA-API driver installed for the Intel GPU. The spec is [docs/specs/screen-recording.md](specs/screen-recording.md).

## Notifications

Notifications come from `panels/notifications.qml`, a Quickshell process that owns the freedesktop notification service and draws the popups in the top right corner of the focused monitor. It replaced mako so that notifications can be kept with their time and their actions for a notification centre. Unlike the other panels it is always running: `config.d/90-autostart` starts it through `panels/notifications/run`, which starts it again if it crashes. mako is no longer installed, because its D-Bus service file would let D-Bus start it whenever the Quickshell daemon is down, and the two would then compete for the same service name.

A left click runs the notification's default action, a right click dismisses it, and its other actions show as buttons. A popup stays 5 seconds unless the sender asks for another time, and a critical one stays until clicked. Popups that arrive together form a deck: the newest in front, older ones behind it with their top edges showing, so their number and border colours read at a glance without filling the right side of the screen. With the pointer over the deck it fans out into a list, and nothing times out until the pointer leaves. Do not disturb, a whole-screen share and a screen recording each turn on a mode that hides popups. They are separate modes, so ending a share never turns off a Do not disturb set by hand. During a share or a recording, one card takes the place of the popups and says only how many notifications arrived and why they are hidden, with no app name or text, so you know something came in without showing it. A critical one keeps the card on screen with a red border until clicked. Do not disturb shows nothing at all. Chromium browsers such as Brave already hide their own web notifications while they share the screen, but notifications from other apps, such as the Slack app, used to show. `bin/dnd` switches them over Quickshell IPC, and the modes on are saved in `$XDG_RUNTIME_DIR`, so they survive a restart of the daemon.

The bell in the bar is grey when quiet, blue with the number of notifications that arrived since the centre was last opened, yellow in Do not disturb and red while a share or recording hides popups. A click on it, `Super + Ctrl + ,` or Notifications in the menu opens the notification centre: every notification of the session, newest first, with its time and actions. A click on an entry runs its default action, the close mark dismisses it, and Clear dismisses all. The centre also has the Do not disturb switch, and a middle click on the bell toggles it too. The centre lives inside the daemon, because only the daemon holds the notifications and can still run their actions. It uses the same `PanelShell` as the other panels with `keepAlive` set, so closing it hides the window instead of ending the process. The rules are in `panels/notifications/notify.mjs`. The spec is [docs/specs/notifications.md](specs/notifications.md).

## Battery warnings

UPower (`nixos/common.nix`) tracks the battery and powers the machine off at 2%. Its default action is hybrid sleep, which needs a swap device, and this machine only has zram. `poweralertd`, started in `config.d/90-autostart`, turns UPower's levels into notifications: low at 20%, critical at 5%. It also sends a notification on every charge state change, such as plugging in the charger. The notification daemon never shows those, and shows the warnings with a red border until they are clicked, including while Do not disturb, a screen share or a recording hides everything else.

## Polkit agent

`polkit-gnome-authentication-agent-1`, started in `config.d/90-autostart`, shows the password dialog when an app asks polkit for an admin action, such as formatting a disk in GNOME Disks or opening a folder as administrator in Nautilus. Without an agent in the session those actions fail at once. NixOS keeps the agent in the package's `libexec/` directory, so `nixos/common.nix` adds `/libexec` to `environment.pathsToLink` and Sway starts it from `/run/current-system/sw/libexec`.

## Stay awake, night light and power profile

These three are in the Toggle menu, and each one shows in the bar. `bin/idle` (`Super + Ctrl + I`) stops the lock and the screen blanking while you are idle. It restarts swayidle without its timeouts instead of stopping it, so a suspend or a lid close still locks the session first. A cup icon in the bar shows while it is on. `bin/nightlight` (`Super + Ctrl + N`) warms the screen to 4000 K with gammastep until you turn it off, and shows a moon icon. There is no schedule. The power profile icon belongs to waybar's own `power-profiles-daemon` module: a green leaf for power-saver, a grey heart pulse for balanced and an orange bolt for performance. A click cycles them, and Toggle › Power profile picks one directly. On this Lenovo LOQ, `Fn + Q` changes the firmware mode itself in a loop of quiet, balanced and performance, which the kernel reports as `low-power`, `balanced` and `balanced-performance`. power-profiles-daemon 0.30 has no profile for `balanced-performance`, so on that step the icon stays on balanced, and it follows the other two steps about 2 seconds late. The daemon's own performance profile is the kernel's `performance`, which this machine maps to the BIOS extreme mode. A click on the battery icon opens the power panel, which also shows the time left, the power draw, the battery health and the charge limit. The charge limit is UPower's charge threshold, which on this Lenovo is the conservation mode. polkit lets the active user change it without a password. The spec is [docs/specs/power-panel.md](specs/power-panel.md). The specs are [docs/specs/stay-awake.md](specs/stay-awake.md) and [docs/specs/night-light.md](specs/night-light.md).

## Clipboard history and emoji

`bin/clipboard`, started in `config.d/90-autostart`, stores every copy with cliphist. `Super + V` lists them in fuzzel, newest first, and the chosen one goes back on the clipboard. The history is kept in `$XDG_RUNTIME_DIR`, which is in memory, so it disappears at logout and never reaches the disk. System › Clear clipboard history empties it earlier, for example after copying a password by hand. Copies that a password manager marks as sensitive are never stored. `Super + .` opens `bin/emoji`, a fuzzel list of Unicode's emoji searched by English name. The pick is typed into the focused window with wtype and also left on the clipboard. The list is `emoji-test.txt` from the `unicode-emoji` package, which `nixos/common.nix` links into `/run/current-system/sw/share/unicode`. The specs are [docs/specs/clipboard-history.md](specs/clipboard-history.md) and [docs/specs/emoji-picker.md](specs/emoji-picker.md).

## Panels

The panels are Quickshell windows. Each panel has a `toggle` script that kills the running panel or starts a new one, so a click on its waybar icon or menu entry opens and closes it. While a panel is open, a scanner or listener runs; once it closes, nothing keeps running.

A panel is a full-screen transparent `PanelWindow` on the overlay layer with exclusive keyboard focus. Esc closes it, and so does a click outside the visible card.

Exclusive keyboard focus does not follow a workspace switch. Switching workspace by key or by a click on another output would leave every window without input until the panel closed. So each panel listens to Sway's workspace events through `I3IpcListener` and closes itself on a focus change, the way a popup would. Sway also skips its own mouse warping while a layer surface holds the keyboard, so when the switch moves to another output the panel moves the cursor to the center of the new workspace before it quits.

All of this lives once in `common/PanelShell.qml`, and every panel except the lock screen is a `PanelShell` with its own card. Quickshell only loads files from the directory of the entry file it runs, which is why every entry file sits at the top of `panels/` and imports `"common"` and its own `<name>/` files from there. An import that leaves that directory passes qmllint but fails in Quickshell, so `bin/check static` also starts every panel in a headless Sway (step `panels-load`). `common/Theme.qml` holds the colours and the font, and `common/AdvancedLink.qml` is the footer link that opens a panel's full TUI in a floating terminal. A fix to the shared behaviour goes there, so it reaches every panel at once.

## Terminal opacity and text size

Alacritty's opacity is set live by `bin/opacity` through `alacritty msg config`. Text size is set by `display/ctl`, which edits `alacritty/.config/alacritty/alacritty.toml` in place. The edit shows up in `git status`. Commit it to keep the new size as the default, or check out the file to drop it.
