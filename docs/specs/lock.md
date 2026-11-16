# Lock screen

Files: `sway/.config/sway/lock/lock` (script), `sway/.config/sway/lock/shell.qml` (Quickshell lock screen), `sway/.config/sway/apps/swaylock` (fallback config). The script runs from `Super + Shift + L`, the menu entry System > Lock, and swayidle after 5 minutes idle and before sleep.

## Purpose

The lock screen covers every output with a blurred picture of what was on it, a clock and a password field, and unlocks only after PAM accepts the password. The script returns only once the session is locked, because swayidle waits for it before letting the machine sleep. If the Quickshell lock does not come up, swaylock locks the session instead.

## Acceptance criteria

1. Before locking, the script takes one screenshot per active output into `$XDG_RUNTIME_DIR/sway-lock`, a directory with mode 0700. Test: `tests/unit/sway/.config/sway/lock/lock.bats: "locks: one screenshot per active output in a 0700 runtime dir, returns once locked"`
2. The script returns as soon as the lock screen reports that the session is locked, and does not start swaylock. Test: `tests/unit/sway/.config/sway/lock/lock.bats: "locks: one screenshot per active output in a 0700 runtime dir, returns once locked"`
3. If the lock screen has not reported a lock within 5 seconds, the script runs swaylock, so the session is never left open. Test: `tests/unit/sway/.config/sway/lock/lock.bats: "Quickshell never locks: swaylock after 5s, the session is never left open"`
4. Running the script while the lock screen is already up does nothing. Test: `tests/unit/sway/.config/sway/lock/lock.bats: "already locked: exits at once, nothing else runs"`
5. The screenshots are deleted when the lock screen exits after an unlock. Test: `tests/unit/sway/.config/sway/lock/lock.bats: "screenshots removed once Quickshell exits (unlock)"`
6. The lock screen file parses, and every type, property and import resolves against Qt and Quickshell. Test: `tests/static.sh: qmllint`
7. Every output shows its own blurred screenshot, the time, the date and a password field. Test: manual
8. The correct password unlocks the session through the PAM service `swaylock`. A wrong one clears the field and shows "Wrong password", with the number of failed attempts from the second one on. Esc clears the field. Test: manual
9. If the Quickshell process dies while locked, Sway keeps every output covered until another locker unlocks it. Test: manual
10. swayidle locks the session after 5 minutes idle and before the machine goes to sleep. Test: manual
