# Manual checklist

These checks need real hardware or a live Wayland session, so no automated layer runs them. Go through the list of the host you are on after a change that touches the area, and after a `nix flake update`. Write the date in "Last pass" when an item passes. Items marked with a spec name come from that spec's acceptance criteria in `docs/specs/`.

## loc-nixos (notebook, Intel iGPU and NVIDIA RTX 3050)

| Item | How to check | Last pass |
| --- | --- | --- |
| Wi-Fi | Connect to a known network, then to a new one with a password, from the Wi-Fi panel. | |
| Sound | Play audio on the speakers and on headphones. Switch the output in the sound panel and change the volume. | |
| Bluetooth | Pair a device and play audio through it. | |
| Brightness, built-in panel | Fn keys and the Display panel slider both change it. | |
| Brightness, external monitor | The Display panel slider changes it over DDC/CI. | |
| Suspend with an external monitor | Suspend and resume with the monitor plugged in. The monitor must come back. Then disable `display/reinit` for one test and note whether it is still needed. | |
| Screen share | Share the whole screen and then a single window in Google Meet. The wlr portal picker opens and notifications stay hidden while the whole screen is shared. | |
| Lock screen | `Super + Shift + L` shows the Quickshell lock with the blurred backdrop on every output. The password unlocks it. Same check as spec lock criteria 7 and 8. | 2026-11-16 |
| Steam on the dGPU | A game started with `prime-run %command%` runs on the NVIDIA card. | |
| Rollback | Boot a previous generation from the boot menu and check that it starts Sway. | |
| Spec keybindings | Criterion 10. | |
| Spec wifi-panel | Criteria 2 to 11. | |
| Spec sound-panel | Criteria 2 to 10. | |
| Spec lock | Criteria 7 to 10. Criterion 9: lock, switch to a TTY, kill the Quickshell lock process, and check that the outputs stay covered. | |
| Spec sys-tools | Criteria 4 to 6. | |
| Spec dotfiles-doctor | Criterion 12: `dotfiles-doctor` exits 0. | |
| Spec pre-commit | Criterion 5: with no `gitleaks` on `PATH`, commit a scratch change and reset it. The hook passes and takes about a second warm. | |
