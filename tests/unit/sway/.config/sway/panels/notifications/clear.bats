#!/usr/bin/env bats

setup() {
  load "${BATS_TEST_DIRNAME%/tests/unit/*}/tests/helpers/common"
  QS="quickshell ipc -p $HOME/.config/sway/panels/notifications.qml call notifications"
}

@test "popups: dismissPopups over IPC, the centre keeps them" {
  run "$SWAY/panels/notifications/clear" popups
  assert_success
  run calls
  assert_output "$QS dismissPopups"
}

@test "all: clearAll over IPC" {
  run "$SWAY/panels/notifications/clear" all
  assert_success
  run calls
  assert_output "$QS clearAll"
}

@test "no argument: usage, exit 2, nothing sent" {
  run "$SWAY/panels/notifications/clear"
  assert_failure 2
  assert_output --partial 'clear popups'
  run calls
  assert_output ''
}
