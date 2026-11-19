#!/usr/bin/env bats

setup() { load "${BATS_TEST_DIRNAME%/tests/unit/*}/tests/helpers/common"; }

@test "toggle when off: gammastep holds 4000 K, waybar signal 11, popup" {
  stub pgrep --rc 1
  run "$SWAY/bin/nightlight" toggle
  assert_success
  run calls
  assert_output "$(printf '%s\n' 'pgrep -f (^|/)gammastep -m wayland -O' \
    'setsid -f gammastep -m wayland -O 4000' 'pkill -RTMIN+11 -f ^waybar ' \
    "quickshell ipc -p $HOME/.config/sway/panels/notifications.qml call osd switched nightlight on")"
}

@test "toggle when on: gammastep ended, nothing new starts, popup" {
  stub pgrep --rc 0
  run "$SWAY/bin/nightlight" toggle
  assert_success
  run calls
  assert_line 'pkill -f (^|/)gammastep -m wayland -O'
  refute_line --partial setsid
  assert_line "quickshell ipc -p $HOME/.config/sway/panels/notifications.qml call osd switched nightlight off"
}

@test "status: icon only while on" {
  stub pgrep --rc 1
  run "$SWAY/bin/nightlight" status
  run jq -e '.text == ""' <<<"$output"
  assert_success
  stub pgrep --rc 0
  run "$SWAY/bin/nightlight" status
  run jq -e '.class == "on" and .text != ""' <<<"$output"
  assert_success
}

@test "no argument: usage, exit 2" {
  run "$SWAY/bin/nightlight"
  assert_failure 2
  assert_output --partial 'nightlight toggle'
}
