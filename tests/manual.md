# Manual checklist

These checks need real hardware or a live Wayland session, so no automated layer runs them. Go through the whole list of the host you are on when the host is new and after a `bin/update` that changes the NixOS release, the kernel series or the NVIDIA driver branch. A commit that changes a behaviour with a manual criterion checks that item before it is committed. A routine `bin/update` inside the same release needs no pass. When items pass, record them with `bin/manual-pass "<item>"...`. It keeps the last pass of each item per machine in `tests/manual-passes.toml`, with the machine model, the GPUs, the displays and the NixOS, kernel and driver versions, so a later regression can be compared with them. It commits nothing: commit the file with the change the items validate, or on its own. `git log -p tests/manual-passes.toml` shows the earlier passes. Items marked with a spec name come from that spec's acceptance criteria in `docs/specs/`. An AI agent can run the items that need only the live session (panels, popups, key bindings, timing) with the `manual-check` skill in `harness/`. The pass is still recorded on the owner's word, with `--with agent-driven`.

## loc-nixos (notebook, Intel iGPU and NVIDIA RTX 3050)

| Item | How to check |
| --- | --- |
| Wi-Fi | Connect to a known network, then to a new one with a password, from the network panel. |
| Sound | Play audio on the speakers and on headphones. Switch the output in the sound panel and change the volume. |
| Internal microphone | With the mic at 100%, `pw-record /tmp/mic.wav` while speaking for 5 seconds (Ctrl+C to stop), then `pw-play /tmp/mic.wav`: the voice is clear, not distorted. A Google Meet call sounds clean to the other side. |
| Bluetooth | Pair a device and play audio through it. |
| Lock screen | `Super + Shift + L` shows the Quickshell lock with the blurred backdrop on every output. The password unlocks it. Same check as spec lock criteria 7 and 8. |
| Battery warnings | On battery below 20%, a "power level low" notification with a red border shows, also with Do not disturb on. Plugging the charger shows nothing. `upower -i /org/freedesktop/UPower/devices/DisplayDevice` lists `warning-level`. |
| Power profile | A click on the bar icon cycles power-saver (green leaf), balanced (grey heart pulse) and performance (orange bolt), and Toggle › Power profile in the menu sets one. `powerprofilesctl get` agrees with the icon after each change. `Fn + Q` moves the icon between power-saver and balanced about 2 seconds after the key; its third step (firmware performance) leaves it on balanced. |
| Polkit agent | `pkexec true` opens a dark password dialog, and the right password returns with exit 0. |
| Steam on the dGPU | A game started with `prime-run %command%` runs on the NVIDIA card. |
| Rollback | The boot menu shows for 1 second: press an arrow key to stop the countdown, boot a previous generation and check that it starts Sway. |
| Spec display-panel | Criteria 2, 3, 5 to 8 and 11. Brightness: Fn keys and the slider on the built-in panel, the slider on the external monitor (DDC/CI). Criterion 11: suspend and resume with the external monitor plugged in, it must come back; once, disable `display/reinit` and note whether it is still needed. |
| Spec screen-share | Criteria 5 to 9. Share the whole screen and then a single window in Google Meet. For the window, put two windows side by side on one workspace first: each row shows its own thumbnail and workspace. |
| Spec menu | Criteria 8 to 11. Type "screen" at the top: the Capture entries show with their path. Type "fire" or "browser": Firefox. Esc twice from Style › Terminal opacity gets back to the top, and so do Left and Backspace with an empty search. An app installed with `nix profile` or a `.desktop` file in `~/.local/share/applications` shows up under Apps with its icon. |
| Spec panels | Criteria 2 to 4. Open and close any one panel from its icon and from Setup in the menu, close it with a click outside and with a workspace switch to the other output, and use Advanced in one of the panels that has it. |
| Spec osd | Criteria 8, 9, 12 and 15. Criterion 15: `Super + Ctrl + I` twice, `Super + Ctrl + N` twice, Toggle › Do not disturb twice and each power profile from the menu, then the Do not disturb chip in the centre (no popup). Media keys and clicks on the bar track: play/pause, next and previous with Spotify and a video in Brave. Volume keys, mute, microphone mute and the brightness Fn keys, also with the screen locked; the wheel and right click on the bar volume icon and the wheel on the monitor icon. Hold a key: one popup that follows the value. |
| Cedilla in Chromium apps | With the USB keyboard (us/intl), `'` then `c` gives ç in Brave and in Slack, accents (á, ã, ê) still work, and the notebook's ABNT2 keyboard keeps its own ç key and accents. |
| Spec keybindings | Criterion 10. |
| Spec network-panel | Criteria 3 to 6 and 8. |
| Spec calendar-panel | Criteria 4 to 7. Check a month whose 1st is a Monday and the week numbers around New Year. |
| Spec sound-panel | Criteria 2 to 7 and 9 to 13. For 12, play Spotify and a video in Brave at the same time. |
| Spec bluetooth-panel | Criteria 2 to 11. Pair a device that needs no code (headphones), then one that asks for a code through Advanced. |
| Spec lock | Criteria 7 to 10. Criterion 9: lock, switch to a TTY, kill the Quickshell lock process, and check that the outputs stay covered. |
| Spec screen-recording | Criteria 11 to 13. Capture › Record area with microphone: speak, stop, play the file: the voice is there and in sync. |
| Spec screensaver | Criteria 8 to 10. Leave the machine idle for 5 minutes with two images or more in `~/Pictures/Wallpapers`; with an external monitor, both outputs show different images. Press a key in a terminal: the screensaver ends and nothing is typed. Play a video fullscreen for 8 minutes: no screensaver, no lock. |
| Spec stay-awake | Criterion 6. |
| Spec night-light | Criterion 5. |
| Spec focus-or-run | Criterion 5. With Spotify and Slack open on another workspace, `Super + M` and `Super + Shift + S` jump to them; with them closed, the same keys start them. |
| Spec screenshot | Criterion 6. `Print`, then Edit in the notification: draw an arrow, press Enter, paste somewhere: the arrow is there and the file in `~/Pictures/Screenshots` has it too. |
| Spec colorpick | Criterion 4. `Super + Ctrl + Print` with the mouse still: the lens shows at once. Over the blue workspace highlight in the bar it copies `#89b4fa`. |
| Spec hibernation | Criteria 3 to 6. Save your work first. System › Hibernate: the notebook powers off; after the LUKS passphrase the lock screen shows and the session is as it was (with the external monitor plugged in too). `cat /sys/bus/pci/devices/0000:01:00.0/power/runtime_status` returns to `suspended`. On battery, close the lid: it suspends. Criterion 6: on battery, close the lid and leave it for more than 2 hours; opening it asks for the LUKS passphrase, since it hibernated, and the session comes back. |
| Spec ocr | Criterion 4. `Super + Print` over a paragraph of a web page in Portuguese, paste it: accents and punctuation come out right. |
| Spec clipboard-history | Criterion 6. |
| Spec emoji-picker | Criterion 5. |
| Spec notifications | Criteria 4, 12 to 19, 23, 24 and 27 to 29. Criterion 24: `id=$(notify-send -p A one)`, then `notify-send -r "$id" A two`: the popup shows "two" again for its full time, and the centre lists it once, on top. Criterion 29: with Do not disturb on, `notify-send -e x` leaves the bell count as it was. Criterion 28: `notify-send -t 30000 x`, then `~/.config/sway/bin/dnd share-on`: the popup leaves the screen and the centre lists it; `dnd share-off` after. Criterion 4: `notify-send A`, then `notify-send B` 3 seconds later: A leaves 5 seconds after it appeared and B 5 seconds after it did, not later. Criterion 14: `pkill -fx "quickshell -p $HOME/.config/sway/panels/notifications.qml"` from another terminal, then `notify-send test` a few seconds later shows a popup. |
| Spec power-panel | Criteria 2 and 4 to 7. Check the charge limit on AC: with it on, the battery stops charging below 100%. |
| Spec sys-tools | Criteria 4 to 6. |
| Spec dotfiles-doctor | Criterion 12: `dotfiles-doctor` exits 0. |
| Spec pre-commit | Criterion 5: with no `gitleaks` on `PATH`, commit a scratch change and reset it. The hook passes and takes about a second warm. |
| Spec update | Criteria 11 and 12. `mise upgrade --dry-run` offers only releases at least 7 days old (`MISE_MINIMUM_RELEASE_AGE=0s mise upgrade --dry-run` shows newer ones). System › Update opens a floating terminal that stays open until Enter. |
