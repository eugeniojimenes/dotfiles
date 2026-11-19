# Screenshot

Files: `sway/.config/sway/bin/screenshot`, bound to `Print` (area) and `Shift + Print` (screen) in `sway/.config/sway/config.d/60-media`, listed under Capture in `sway/.config/sway/bin/menu`.

## Purpose

Take a screenshot of a dragged region or of the focused output, keep it as a file and on the clipboard, and offer to annotate it from the notification, so a quick capture costs one key and an edited one a click more.

## Acceptance criteria

1. The screenshot is saved as `screenshot-<date>.png` in `Screenshots` inside the XDG pictures directory, or in `~/Pictures/Screenshots` when that is not set, the directory created when missing. Test: `tests/unit/sway/.config/sway/bin/screenshot.bats: "area: no xdg-user-dir falls back to ~/Pictures/Screenshots and creates it"`, `tests/unit/sway/.config/sway/bin/screenshot.bats: "default mode is area, into Screenshots in the XDG pictures dir"`
2. Esc while dragging cancels without a capture or a notification. Test: `tests/unit/sway/.config/sway/bin/screenshot.bats: "area: Esc in slurp exits cleanly, no capture"`
3. `screen` captures the focused output. Test: `tests/unit/sway/.config/sway/bin/screenshot.bats: "screen: captures the focused output"`
4. The image goes to the clipboard, and the notification has an Edit button that opens it in satty, where Enter or the copy button puts the edited image on the clipboard and saves it over the same file. Test: `tests/unit/sway/.config/sway/bin/screenshot.bats: "Edit in the notification: satty on the same file, Enter and Copy copy its result and save it"`
5. When the notification closes without Edit, no editor opens. Test: `tests/unit/sway/.config/sway/bin/screenshot.bats: "notification closed without Edit: no editor"`
6. Edit opens satty with the screenshot. Enter or the copy button writes the annotated image over the file, puts it on the clipboard and closes satty; the save button only writes the file. The Edit button works for 10 minutes after the shot. Test: manual
