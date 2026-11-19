# Stay awake

Files: `sway/.config/sway/bin/idle`, started by `sway/.config/sway/config.d/90-autostart`, bound in `sway/.config/sway/config.d/70-session`, listed under Toggle in `sway/.config/sway/panels/menu/menu.mjs`, shown by the `custom/idle` module in `sway/.config/sway/apps/waybar.jsonc`.

## Purpose

`idle` runs swayidle and switches it between normal and stay awake, for a talk, a long build or a video that should keep the screen on. Stay awake drops the idle timeouts (screensaver, lock, screens off) but keeps swayidle running, so a suspend or a lid close still locks the session first.

## Acceptance criteria

1. `idle start` runs swayidle with the screensaver at 5 minutes, the lock at 7 minutes, the screens off at 7.5 minutes, the lock before sleep and the display hook after resume. Test: `tests/unit/sway/.config/sway/bin/idle.bats: "start: screensaver at 5 min, lock at 7 min, screens off at 7.5 min, lock before sleep"`
2. `idle toggle` from normal restarts swayidle without the timeouts, keeps the lock before sleep and the resume hook, sends waybar signal 10 and asks the daemon for the "Stay awake on" popup (`osd switch awake on`). Test: `tests/unit/sway/.config/sway/bin/idle.bats: "toggle from normal: swayidle without timeouts, still locks before sleep, waybar signal 10, popup"`
3. `idle toggle` while awake restarts swayidle with the timeouts again and asks for the "Stay awake off" popup. Test: `tests/unit/sway/.config/sway/bin/idle.bats: "toggle from awake: back to the timeouts, popup"`
4. `idle status` prints the waybar JSON: a cup icon with class `awake` while staying awake, empty text otherwise. Test: `tests/unit/sway/.config/sway/bin/idle.bats: "status: icon only while awake"`
5. Toggle › Stay awake in the menu runs `idle toggle`. Test: `tests/unit/sway/.config/sway/panels/menu/menu.bats: "entries: each runs its script or panel toggle"`
6. `Super + Ctrl + I` toggles stay awake, the bar icon appears and a click on it switches back. While awake the screen stays on, without the screensaver and unlocked, past 8 minutes idle, and suspending still shows the lock screen on resume. Test: manual
7. `idle` with no argument prints the usage and exits 2. Test: `tests/unit/sway/.config/sway/bin/idle.bats: "no argument: usage, exit 2"`
