#!/usr/bin/env bats

setup() {
  load "${BATS_TEST_DIRNAME%/tests/unit/*}/tests/helpers/common"
  QS="quickshell ipc -p $HOME/.config/sway/panels/notifications.qml call notifications"
}

@test "status: the daemon's bell JSON, as it comes" {
  stub quickshell '{"text":"󰂚 2","tooltip":"2 new","class":"unread"}'
  run "$SWAY/bin/dnd" status
  assert_success
  assert_output '{"text":"󰂚 2","tooltip":"2 new","class":"unread"}'
  run calls
  assert_output "$QS status"
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
