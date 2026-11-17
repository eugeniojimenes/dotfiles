# Sound panel

Files: `sway/.config/sway/panels/sound.qml` (Quickshell), `sway/.config/sway/panels/sound/sound.mjs` (lists, names, volume limit), `sway/.config/sway/panels/sound/toggle` (run by a click on the waybar volume icon and by the menu entry Setup > Sound).

## Purpose

The panel controls PipeWire directly: output and input volume, mute, the default devices and the volume of each app. The detailed mixer, `wiremix`, is one click away for anything else.

## Acceptance criteria

1. The panel file parses, every type, property and import resolves against Qt and Quickshell, and Quickshell loads it in a headless Sway. Test: `tests/static.sh: qmllint`, `tests/static.sh: panels-load`
2. A click on the waybar volume icon opens the panel, and a second click closes it. Test: manual
3. The Output and Input sections each show the default device with its name, a volume slider, the volume in percent and a live level bar. When a section has no device it says "No output device" or "No input device". Test: manual
4. Clicking a slider sets the volume, and the mouse wheel steps it by 5%. Volume stays between 0% and 100%. Test: `tests/unit/sway/.config/sway/panels/sound/sound.bats: "volume: stops at 0 and at 100%"`, manual
5. Clicking a section's icon toggles mute, and the icon changes to the muted one. Test: manual
6. When more than one output or input device exists, a list under the section picks the default, with a check mark on the current one. Devices are named by their PipeWire description, else nickname, else node name. Test: `tests/unit/sway/.config/sway/panels/sound/sound.bats: "names: description, then nickname, then node name; apps by application name"`, manual
7. The Apps section shows one volume row per app playing audio, named by the app, or "Nothing playing" when there is none. Recording streams, such as a call using the microphone, are not listed. Test: `tests/unit/sway/.config/sway/panels/sound/sound.bats: "lists: outputs, inputs, playing apps; recording streams and nodes without audio left out"`, manual
8. Up or Right raises the output volume by 5%, Down or Left lowers it by 5%, M toggles output mute, and Esc closes the panel. Test: manual
9. A click outside the panel or a workspace switch closes it. When the switch lands on another output, the cursor moves to the centre of that output. Test: manual
10. "Advanced (wiremix)" opens `wiremix` with `apps/wiremix.toml` in a floating terminal. Test: manual
