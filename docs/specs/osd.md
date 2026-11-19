# OSD

Files: `sway/.config/sway/bin/osd` (changes the value, then asks for the popup), `sway/.config/sway/bin/media` (media keys, asks for the track popup), `sway/.config/sway/panels/notifications/Osd.qml` (the popup, inside the notification daemon), `sway/.config/sway/panels/notifications/notify.mjs` (`osdIcon`, `trackText`, `trackIcon`), `sway/.config/sway/config.d/60-media` (keys), `sway/.config/sway/apps/waybar.jsonc` (wheel and right click on the bar icons).

## Purpose

The volume, microphone and brightness keys show a small popup with an icon, a bar and the value, and the media keys show the track. The popup lives in the notification daemon, which is always running, so no separate program stays in memory for it. It replaces swayosd, a GTK4 program that used about 130 MB for this popup alone.

## Acceptance criteria

1. `osd volume up` unmutes the default output and raises it by 5%, never above 100%. `osd volume down` lowers it by 5%. Then the popup shows the new value. Test: `tests/unit/sway/.config/sway/bin/osd.bats: "volume up: unmuted, +5% capped at 100%, popup with the new value"`, `tests/unit/sway/.config/sway/bin/osd.bats: "volume down: -5%, popup with the new value"`
2. `osd volume mute` toggles the mute of the default output, and the popup shows it muted or not with the current value. Test: `tests/unit/sway/.config/sway/bin/osd.bats: "volume mute: toggled, popup marked muted"`
3. `osd mic mute` toggles the mute of the default input, and the popup shows the microphone's state. Test: `tests/unit/sway/.config/sway/bin/osd.bats: "mic mute: default input toggled, popup with its state"`
4. `osd brightness up` and `osd brightness down` change the backlight by 5% through brightnessctl, never down to 0, show the popup and tell an open Display panel to re-read. Test: `tests/unit/sway/.config/sway/bin/osd.bats: "brightness: 5% steps on the backlight, never 0, popup and Display panel refresh"`
5. With the notification daemon down, the value still changes and the script exits 0. Test: `tests/unit/sway/.config/sway/bin/osd.bats: "daemon down: value changed, exit 0"`
6. A missing or unknown argument prints the usage, exits 2 and changes nothing. Test: `tests/unit/sway/.config/sway/bin/osd.bats: "no argument or unknown one: usage, exit 2, nothing changed"`
7. The volume icon has three steps by level and a muted one, the microphone icon is on or muted, and the brightness icon has three steps by level. Test: `tests/unit/sway/.config/sway/panels/notifications/notify.bats: "osd icon: volume and brightness by level, muted ones"`
8. The popup shows at the bottom centre of the focused output with the icon, a bar and the percentage, grey when muted. Pressing the key again updates the same popup, and it goes away 1.5 seconds after the last press. It never takes the keyboard or a click. Test: manual
9. The volume, mute, microphone and brightness keys run `osd`, also on the lock screen. So do the wheel and right click on the bar volume icon and the wheel on the bar monitor icon. Test: manual
10. After `media toggle`, `next` or `previous`, `media` asks the daemon for the track popup of the player the command acted on, with the action. Without a player holding a track, it asks for none. Test: `tests/unit/sway/.config/sway/bin/media.bats: "toggle, next, previous: track popup asked for the player and the action, none without a player"`
11. The track popup reads "Artist - Title", the title alone when the track has no artist, and the player name when it has no title. Test: `tests/unit/sway/.config/sway/panels/notifications/notify.bats: "track text: artist - title, title alone, player name without a title"`
12. The track popup's icon is next or previous for those keys, and for play/pause it is play while the player plays and pause while it is paused, following the player. The icon and the text are the colour of the bar track: cyan while it plays, grey while paused. The text is cut with an ellipsis when too long. After next or previous it shows the new track once the player reports it, and it goes away 2.5 seconds after the last press or track change. The media keys and the clicks on the bar track show it. Test: `tests/unit/sway/.config/sway/panels/notifications/notify.bats: "track icon: next and previous by action, else play or pause by state"`, manual
