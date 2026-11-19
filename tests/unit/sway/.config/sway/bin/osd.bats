#!/usr/bin/env bats
# bin/osd: change the value (wpctl, brightnessctl), then ask the notification daemon for the popup over IPC.

setup() {
  load "${BATS_TEST_DIRNAME%/tests/unit/*}/tests/helpers/common"
  ipc="quickshell ipc -p $HOME/.config/sway/panels/notifications.qml call osd popup"
}

@test "volume up: unmuted, +5% capped at 100%, popup with the new value" {
  stub wpctl 'Volume: 0.85'
  run "$SWAY/bin/osd" volume up
  assert_success
  run calls
  assert_output "wpctl set-mute @DEFAULT_AUDIO_SINK@ 0
wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+
wpctl get-volume @DEFAULT_AUDIO_SINK@
$ipc volume 85 false"
}

@test "volume down: -5%, popup with the new value" {
  stub wpctl 'Volume: 0.40'
  run "$SWAY/bin/osd" volume down
  assert_success
  run calls
  assert_output "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-
wpctl get-volume @DEFAULT_AUDIO_SINK@
$ipc volume 40 false"
}

@test "volume mute: toggled, popup marked muted" {
  stub wpctl 'Volume: 0.07 [MUTED]'
  run "$SWAY/bin/osd" volume mute
  assert_success
  run calls
  assert_output "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
wpctl get-volume @DEFAULT_AUDIO_SINK@
$ipc volume 7 true"
}

@test "mic mute: default input toggled, popup with its state" {
  stub wpctl 'Volume: 1.00'
  run "$SWAY/bin/osd" mic mute
  assert_success
  run calls
  assert_output "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle
wpctl get-volume @DEFAULT_AUDIO_SOURCE@
$ipc mic 100 false"
}

@test "brightness: 5% steps on the backlight, never 0, popup and Display panel refresh" {
  stub brightnessctl 'nvidia_wmi_ec_backlight,backlight,400,50%,800'
  stub pgrep --rc 0
  run "$SWAY/bin/osd" brightness down
  assert_success
  run "$SWAY/bin/osd" brightness up
  run grep -v '^pgrep' "$STUBS/calls"
  assert_output "brightnessctl -c backlight -q -n set 5%-
brightnessctl -c backlight -m
$ipc brightness 50 false
quickshell ipc -p $HOME/.config/sway/panels/display.qml call display refresh
brightnessctl -c backlight -q -n set 5%+
brightnessctl -c backlight -m
$ipc brightness 50 false
quickshell ipc -p $HOME/.config/sway/panels/display.qml call display refresh"
}

@test "daemon down: value changed, exit 0" {
  stub wpctl 'Volume: 0.50'
  stub quickshell --rc 1
  run "$SWAY/bin/osd" volume down
  assert_success
  run grep -c '^wpctl set-volume' "$STUBS/calls"
  assert_output 1
}

@test "switch: popup asked for the kind and value, nothing changed" {
  run "$SWAY/bin/osd" switch awake on
  assert_success
  run "$SWAY/bin/osd" switch profile balanced
  run calls
  assert_output "$(printf '%s\n' "${ipc% popup} switched awake on" "${ipc% popup} switched profile balanced")"
}

@test "switch without a value or for another kind: usage, exit 2" {
  run "$SWAY/bin/osd" switch awake
  assert_failure 2
  run "$SWAY/bin/osd" switch volume on
  assert_failure 2
  run calls
  assert_output ''
}

@test "no argument or unknown one: usage, exit 2, nothing changed" {
  run "$SWAY/bin/osd"
  assert_failure 2
  assert_output --partial 'osd volume up|down|mute'
  run "$SWAY/bin/osd" volume loud
  assert_failure 2
  run calls
  assert_output ''
}
