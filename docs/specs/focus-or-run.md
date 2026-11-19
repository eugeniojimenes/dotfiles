# Focus or run

Files: `sway/.config/sway/bin/focus-or-run`, used by `Super + M` (Spotify), `Super + Shift + S` (Slack) and `Super + Shift + T` (system tools) in `sway/.config/sway/config.d/30-apps`.

## Purpose

Apps that live in one window get a key that brings that window forward when it is open and starts the app only when it is not, so a second press never opens a duplicate. Browsers are left out: their key opens a new window on every press, which is how the owner uses them.

## Acceptance criteria

1. When a window whose app_id matches the name (whole name, any case) is open, it gets the focus and nothing is started. Test: `tests/unit/sway/.config/sway/bin/focus-or-run.bats: "window open (Wayland app_id): focused, nothing started"`
2. An XWayland window is found by its class the same way. Test: `tests/unit/sway/.config/sway/bin/focus-or-run.bats: "window open under XWayland: found by class"`
3. With no such window, the command runs with its arguments. Test: `tests/unit/sway/.config/sway/bin/focus-or-run.bats: "no window: the command starts with its arguments"`
4. A name holding anything but letters, digits, dot, dash or underscore, or a missing command, is refused with exit 2, so a name never reaches swaymsg as criteria syntax. Test: `tests/unit/sway/.config/sway/bin/focus-or-run.bats: "name with criteria syntax or no command: refused, exit 2"`
5. `Super + M` with Spotify open on another workspace jumps to it instead of starting a second Spotify, and `Super + Shift + S` does the same for Slack. Test: manual
