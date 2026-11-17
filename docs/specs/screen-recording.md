# Screen recording

Files: `sway/.config/sway/bin/record`, bound in `sway/.config/sway/config.d/60-media`, listed under Capture in `sway/.config/sway/bin/menu`, shown by the `custom/record` module in `sway/.config/sway/apps/waybar.jsonc` and by the floating box `sway/.config/sway/panels/recording.qml`. Notifications are hidden through `sway/.config/sway/bin/dnd` and the `recording` mode of `sway/.config/sway/panels/notifications.qml`.

## Purpose

`record` makes a quick MP4 of a screen region or of the focused screen without opening OBS. The same key or menu entry that starts a recording also stops it, and a red icon in the bar and a floating box with the elapsed time show that a recording is running. The video has no audio. Notifications are hidden while it runs, because Sway cannot keep a surface out of the capture.

## Acceptance criteria

1. `record area` lets the user drag a region with slurp and records it with wf-recorder to `recording-<date>.mp4` in the XDG videos directory, falling back to `~/Videos`. Test: `tests/unit/sway/.config/sway/bin/record.bats: "area: slurp region, MP4 in the XDG videos dir, saved notification"`
2. Esc in slurp cancels: nothing is recorded and no notification is sent. Test: `tests/unit/sway/.config/sway/bin/record.bats: "area: Esc in slurp records nothing"`
3. `record screen` records the focused output. No audio is recorded: wf-recorder never gets `-a`. Test: `tests/unit/sway/.config/sway/bin/record.bats: "screen: focused output, video only"`
4. While a recording runs, `record area`, `record screen` and `record stop` send SIGINT to it, so wf-recorder finishes the file, and no new recording starts. Test: `tests/unit/sway/.config/sway/bin/record.bats: "running: start or stop interrupts it, nothing new starts"`
5. `record status` prints the waybar JSON: a red icon with class `recording` while a recording runs, empty text otherwise. A stale PID file whose process is not wf-recorder counts as not running. Test: `tests/unit/sway/.config/sway/bin/record.bats: "status: icon only while wf-recorder runs, stale PID ignored"`
6. Waybar gets signal 9 when a recording starts and when it ends, so the icon follows without polling. Test: `tests/unit/sway/.config/sway/bin/record.bats: "area: slurp region, MP4 in the XDG videos dir, saved notification"`
7. While a recording runs, notifications are hidden: `dnd record-on` turns on the notification mode `recording` before wf-recorder starts, and `dnd record-off` removes it when wf-recorder ends, before the saved or failed notification. Test: `tests/unit/sway/.config/sway/bin/record.bats: "while recording: notifications hidden and floating box, both undone at the end"`
8. The floating box (`panels/recording.qml`) starts with the recording and is killed when it ends. Test: `tests/unit/sway/.config/sway/bin/record.bats: "while recording: notifications hidden and floating box, both undone at the end"`
9. The bar bell is crossed out with a recording tooltip while the `recording` mode is on. Test: `tests/unit/sway/.config/sway/panels/notifications/notify.bats: "bar bell: mode wins (recording, share, dnd), else the unread count"`
10. When wf-recorder fails, the partial file is removed and a critical notification says so. Test: `tests/unit/sway/.config/sway/bin/record.bats: "wf-recorder fails: file removed, failure notification"`
11. `Ctrl + Print` records an area and `Ctrl + Shift + Print` the screen. Pressing either again stops the recording. Clicking the bar icon or the floating box stops it too. Test: manual
12. The Capture menu offers Record area and Record screen. Test: manual
13. The floating box sits in the bottom-right corner of the screen with a red dot, REC and the elapsed time counting up each second. A notification sent during the recording does not show and is not in the video, and a critical battery warning still shows. Test: manual
