#!/usr/bin/env bats

setup() { load "${BATS_TEST_DIRNAME%/tests/unit/*}/tests/helpers/common"; }

@test "window open (Wayland app_id): focused, nothing started" {
  run "$SWAY/bin/focus-or-run" Slack slack
  assert_success
  run calls
  assert_output 'swaymsg -q [app_id="(?i)^Slack$"] focus'
}

@test "window open under XWayland: found by class" {
  echo '[[ $2 == *app_id* ]] && exit 2' >"$STUBS/swaymsg.sh"
  run "$SWAY/bin/focus-or-run" spotify spotify
  assert_success
  run calls
  assert_line --index 1 'swaymsg -q [class="(?i)^spotify$"] focus'
  refute_line --regexp '^spotify'
}

@test "no window: the command starts with its arguments" {
  stub swaymsg --rc 2
  run "$SWAY/bin/focus-or-run" sys-tools alacritty --class sys-tools -e btop
  assert_success
  run calls
  assert_line --index 2 'alacritty --class sys-tools -e btop'
}

@test "name with criteria syntax or no command: refused, exit 2" {
  run "$SWAY/bin/focus-or-run" 'x"] kill; [' slack
  assert_failure 2
  run "$SWAY/bin/focus-or-run" slack
  assert_failure 2
  run calls
  refute_output --partial swaymsg
}
