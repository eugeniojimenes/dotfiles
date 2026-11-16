#!/usr/bin/env bats

setup() { load "${BATS_TEST_DIRNAME%/tests/unit/*}/tests/helpers/common"; }

@test "saves the value and applies it to open windows" {
  run "$SWAY/bin/opacity" 0.8
  assert_success
  [[ $(cat "$XDG_STATE_HOME/sway/terminal-opacity") == 0.8 ]]
  run calls
  assert_output 'alacritty msg config -w -1 window.opacity=0.8'
}

@test "state defaults to ~/.local/state" {
  unset XDG_STATE_HOME
  run "$SWAY/bin/opacity" 1.0
  assert_success
  [[ $(cat "$HOME/.local/state/sway/terminal-opacity") == 1.0 ]]
}

@test "1 and 1.0 accepted" {
  run "$SWAY/bin/opacity" 1
  assert_success
  run "$SWAY/bin/opacity" 1.0
  assert_success
}

@test "no Alacritty window open: still succeeds" {
  stub alacritty --rc 1
  run "$SWAY/bin/opacity" 0.9
  assert_success
}

@test "out of range or not a number: exit 2, nothing saved or sent" {
  for v in 2 1.5 abc .5 ''; do
    run "$SWAY/bin/opacity" "$v"
    assert_failure 2
  done
  [[ ! -e $XDG_STATE_HOME/sway/terminal-opacity ]]
  run calls
  assert_output ''
}
