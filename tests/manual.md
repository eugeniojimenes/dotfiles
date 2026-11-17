# Manual checklist

These checks need real hardware or a live Wayland session, so no automated layer runs them. Go through the list of the host you are on after a change that touches the area, and after a `nix flake update`. Write the date in "Last pass" when an item passes. Items marked with a spec name come from that spec's acceptance criteria in `docs/specs/`.

## loc-nixos (notebook, Intel iGPU and NVIDIA RTX 3050)

| Item | How to check | Last pass |
| --- | --- | --- |
| Wi-Fi | Connect to a known network, then to a new one with a password, from the Wi-Fi panel. | |
| Sound | Play audio on the speakers and on headphones. Switch the output in the sound panel and change the volume. | |
| Internal microphone | With the mic at 100%, `pw-record /tmp/mic.wav` while speaking for 5 seconds (Ctrl+C to stop), then `pw-play /tmp/mic.wav`: the voice is clear, not distorted. A Google Meet call sounds clean to the other side. | |
| Bluetooth | Pair a device and play audio through it. | |
| Brightness, built-in panel | Fn keys and the Display panel slider both change it. | |
| Brightness, external monitor | The Display panel slider changes it over DDC/CI. | |
| Suspend with an external monitor | Suspend and resume with the monitor plugged in. The monitor must come back. Then disable `display/reinit` for one test and note whether it is still needed. | |
| Screen share | Share the whole screen and then a single window in Google Meet. The wlr portal picker opens and notifications stay hidden while the whole screen is shared. | |
| Lock screen | `Super + Shift + L` shows the Quickshell lock with the blurred backdrop on every output. The password unlocks it. Same check as spec lock criteria 7 and 8. | 2026-11-16 |
| Battery warnings | On battery below 20%, a "power level low" notification with a red border shows, also with Do not disturb on. Plugging the charger shows nothing. `upower -i /org/freedesktop/UPower/devices/DisplayDevice` lists `warning-level`. | |
| Power profile | A click on the bar icon cycles power-saver (green leaf), balanced (grey heart pulse) and performance (orange bolt), and Toggle › Power profile in the menu sets one. `powerprofilesctl get` agrees with the icon after each change. `Fn + Q` moves the icon between power-saver and balanced about 2 seconds after the key; its third step (firmware performance) leaves it on balanced. | |
| Polkit agent | `pkexec true` opens a dark password dialog, and the right password returns with exit 0. | |
| Steam on the dGPU | A game started with `prime-run %command%` runs on the NVIDIA card. | |
| Rollback | The boot menu shows for 1 second: press an arrow key to stop the countdown, boot a previous generation and check that it starts Sway. | |
| Spec keybindings | Criterion 10. | |
| Spec wifi-panel | Criteria 2, 4 to 7 and 9 to 11. | |
| Spec calendar-panel | Criteria 2 and 5 to 8. Check a month whose 1st is a Monday and the week numbers around New Year. | |
| Spec sound-panel | Criteria 2 to 10. | |
| Spec bluetooth-panel | Criteria 2 to 14. Pair a device that needs no code (headphones), then one that asks for a code through Advanced. | |
| Spec lock | Criteria 7 to 10. Criterion 9: lock, switch to a TTY, kill the Quickshell lock process, and check that the outputs stay covered. | |
| Spec screen-recording | Criteria 11 to 13. | |
| Spec stay-awake | Criterion 6. | |
| Spec night-light | Criterion 5. | |
| Spec clipboard-history | Criterion 6. | |
| Spec emoji-picker | Criterion 5. | |
| Spec power-panel | Criteria 2, 3 and 5 to 8. Check the charge limit on AC: with it on, the battery stops charging below 100%. | |
| Spec sys-tools | Criteria 4 to 6. | |
| Spec dotfiles-doctor | Criterion 12: `dotfiles-doctor` exits 0. | |
| Spec pre-commit | Criterion 5: with no `gitleaks` on `PATH`, commit a scratch change and reset it. The hook passes and takes about a second warm. | |
