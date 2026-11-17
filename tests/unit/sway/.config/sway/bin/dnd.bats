#!/usr/bin/env bats

setup() {
  load "${BATS_TEST_DIRNAME%/tests/unit/*}/tests/helpers/common"
  QS="quickshell ipc -p $HOME/.config/sway/panels/notifications.qml call notifications"
}

@test "status: no mode gives empty text" {
  stub quickshell ''
  run "$SWAY/bin/dnd" status
  assert_success
  run jq -e '.text == ""' <<<"$output"
  assert_success
}

@test "status: dnd mode gives the dnd class" {
  stub quickshell dnd
  run "$SWAY/bin/dnd" status
  assert_success
  run jq -e '.class == "dnd"' <<<"$output"
  assert_success
}

@test "status: screenshare wins over dnd" {
  stub quickshell 'dnd screenshare'
  run "$SWAY/bin/dnd" status
  assert_success
  run jq -e '.class == "share"' <<<"$output"
  assert_success
}

@test "status: recording hides like a screen share, with its own tooltip" {
  stub quickshell 'dnd recording'
  run "$SWAY/bin/dnd" status
  assert_success
  run jq -e '.class == "share" and (.tooltip | test("recording"))' <<<"$output"
  assert_success
}

@test "status: never pokes waybar" {
  stub quickshell dnd
  run "$SWAY/bin/dnd" status
  run calls
  refute_output --partial pkill
}

@test "toggle, share-on, share-off, record-on, record-off: mode change over IPC, then waybar signal 8" {
  for arg in toggle share-on share-off record-on record-off; do run "$SWAY/bin/dnd" "$arg"; done
  run calls
  assert_output "$(printf '%s\n' \
    "$QS modeToggle dnd" 'pkill -RTMIN+8 -f ^waybar ' \
    "$QS modeOn screenshare" 'pkill -RTMIN+8 -f ^waybar ' \
    "$QS modeOff screenshare" 'pkill -RTMIN+8 -f ^waybar ' \
    "$QS modeOn recording" 'pkill -RTMIN+8 -f ^waybar ' \
    "$QS modeOff recording" 'pkill -RTMIN+8 -f ^waybar ')"
}

@test "status: daemon down gives empty text" {
  stub quickshell --rc 1
  run "$SWAY/bin/dnd" status
  assert_success
  run jq -e '.text == ""' <<<"$output"
  assert_success
}
