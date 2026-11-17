#!/usr/bin/env bats

setup() {
  load "${BATS_TEST_DIRNAME%/tests/unit/*}/tests/helpers/common"
  LOCK="$HOME/.config/sway/panels/lock/lock"
  ALWAYS="before-sleep $LOCK after-resume $HOME/.config/sway/panels/display/reinit"
}

@test "start: lock at 5 min, screens off at 5.5 min, lock before sleep" {
  run "$SWAY/bin/idle" start
  assert_success
  run calls
  assert_output "swayidle -w timeout 300 $LOCK timeout 330 swaymsg \"output * power off\" resume swaymsg \"output * power on\" $ALWAYS"
}

@test "toggle from normal: swayidle without timeouts, still locks before sleep, waybar signal 10" {
  stub pgrep --rc 1
  run "$SWAY/bin/idle" toggle
  assert_success
  run calls
  assert_output "$(printf '%s\n' "pgrep -f ^swayidle -w before-sleep" 'pkill -x swayidle' \
    "setsid -f swayidle -w $ALWAYS" 'pkill -RTMIN+10 -f ^waybar ')"
}

@test "toggle from awake: back to the timeouts" {
  stub pgrep --rc 0
  run "$SWAY/bin/idle" toggle
  assert_success
  run calls
  assert_line --regexp "^setsid -f swayidle -w timeout 300 .* $ALWAYS\$"
}

@test "status: icon only while awake" {
  stub pgrep --rc 1
  run "$SWAY/bin/idle" status
  run jq -e '.text == ""' <<<"$output"
  assert_success
  stub pgrep --rc 0
  run "$SWAY/bin/idle" status
  run jq -e '.class == "awake" and .text != ""' <<<"$output"
  assert_success
}

@test "no argument: usage, exit 2" {
  run "$SWAY/bin/idle"
  assert_failure 2
  assert_output --partial 'idle toggle'
}
