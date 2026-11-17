#!/usr/bin/env bats
# display/refresh: after a brightness key, tell the Display panel to re-read, only when it is open.

setup() { load "${BATS_TEST_DIRNAME%/tests/unit/*}/tests/helpers/common"; }

@test "panel closed: quickshell never called, exit 0" {
  stub pgrep --rc 1
  run "$SWAY/display/refresh"
  assert_success
  run grep -c '^quickshell' "$STUBS/calls"
  assert_output 0
}

@test "panel open: ipc refresh sent to the display panel" {
  run "$SWAY/display/refresh"
  assert_success
  run grep '^pgrep' "$STUBS/calls"
  assert_output 'pgrep -f quickshell -p .*/sway/display/panel.qml'
  run grep '^quickshell' "$STUBS/calls"
  assert_output "quickshell ipc -p $HOME/.config/sway/display/panel.qml call display refresh"
}
