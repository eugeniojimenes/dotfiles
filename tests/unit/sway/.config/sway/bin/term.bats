#!/usr/bin/env bats

setup() { load "${BATS_TEST_DIRNAME%/tests/unit/*}/tests/helpers/common"; }

@test "no saved opacity: 0.92" {
  run "$SWAY/bin/term"
  run calls
  assert_output 'alacritty -o window.opacity=0.92'
}

@test "empty state file: 0.92" {
  mkdir -p "$XDG_STATE_HOME/sway" && : >"$XDG_STATE_HOME/sway/terminal-opacity"
  run "$SWAY/bin/term"
  run calls
  assert_output 'alacritty -o window.opacity=0.92'
}

@test "saved opacity used, arguments passed through" {
  mkdir -p "$XDG_STATE_HOME/sway" && echo 0.8 >"$XDG_STATE_HOME/sway/terminal-opacity"
  run "$SWAY/bin/term" -e btop
  run calls
  assert_output 'alacritty -o window.opacity=0.8 -e btop'
}
