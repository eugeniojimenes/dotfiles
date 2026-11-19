# Screensaver

Files: `sway/.config/sway/panels/screensaver.qml` (Quickshell, every output), `sway/.config/sway/panels/screensaver/screensaver.mjs` (slide and clock logic), `sway/.config/sway/panels/screensaver/screensaver` (start and stop, run by swayidle), `sway/.config/sway/bin/idle` (timeouts), `sway/.config/sway/config.d/40-windows` (`inhibit_idle fullscreen`).

## Purpose

After 5 minutes idle, every output shows the wallpapers of `~/Pictures/Wallpapers` in turn, dimmed, under a big clock and date that move to a new spot at each slide. It is a visual signal, not a lock: any input ends it without a password, and the lock screen still comes 2 minutes later. While a window is fullscreen, nothing of this happens.

## Acceptance criteria

1. swayidle starts the screensaver after 5 minutes idle, ends it on any activity, locks at 7 minutes and turns the screens off at 7.5 minutes. Test: `tests/unit/sway/.config/sway/bin/idle.bats: "start: screensaver at 5 min, lock at 7 min, screens off at 7.5 min, lock before sleep"`
2. `screensaver start` runs Quickshell detached, so swayidle does not wait on it. Test: `tests/unit/sway/.config/sway/panels/screensaver/screensaver.bats: "start: screensaver detached when neither it nor the lock screen is up"`
3. `screensaver start` does nothing while the screensaver or the lock screen is already up. Test: `tests/unit/sway/.config/sway/panels/screensaver/screensaver.bats: "start: nothing when the screensaver or the lock screen is already up"`
4. `screensaver stop` ends it by its exact command line. Test: `tests/unit/sway/.config/sway/panels/screensaver/screensaver.bats: "stop: ends the screensaver by its exact command line"`
5. The outputs start on different images and advance together, so two outputs never show the same image while there are enough images. Without images, the clock shows alone. Test: `tests/unit/sway/.config/sway/panels/screensaver/screensaver.bats: "images: outputs start apart and move together, none = clock alone"`
6. At every slide the clock moves to a new spot inside the screen, different on each output. Test: `tests/unit/sway/.config/sway/panels/screensaver/screensaver.bats: "clock: a new spot inside the screen at every slide, per output"`
7. The screensaver file parses, every type, property and import resolves against Qt and Quickshell, and Quickshell loads it in a headless Sway. Test: `tests/static.sh: qmllint`, `tests/static.sh: panels-load`
8. Every output shows a wallpaper, dimmed, changing every 20 seconds with a fade, under the clock and date. The pointer is hidden. Test: manual
9. A key, a click, the wheel or moving the mouse ends the screensaver, and the key that ends it does not reach the focused window. Test: manual
10. While a window is fullscreen (a video, slides), neither the screensaver, the lock nor screens off starts. Test: manual
11. `screensaver` with no argument prints the usage and exits 2. Test: `tests/unit/sway/.config/sway/panels/screensaver/screensaver.bats: "no argument: usage, exit 2"`
