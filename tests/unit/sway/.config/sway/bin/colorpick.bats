#!/usr/bin/env bats

setup() { load "${BATS_TEST_DIRNAME%/tests/unit/*}/tests/helpers/common"; }

@test "pick: hex color on the clipboard and in a notification" {
  stub hyprpicker $'[ERR] could not load cursor theme\n#89b4fa'
  run "$SWAY/bin/colorpick"
  assert_success
  run cat "$STUBS/wl-copy.stdin"
  assert_output '#89b4fa'
  run calls
  assert_line 'hyprpicker -q -f hex'
  assert_line 'notify-send -a Color picker #89b4fa Copied to the clipboard'
}

@test "Esc: nothing copied, no notification" {
  stub hyprpicker --rc 1
  run "$SWAY/bin/colorpick"
  assert_success
  run calls
  assert_output 'hyprpicker -q -f hex'
}

@test "lens up without moving the mouse: cursor nudged 1 px and back while hyprpicker runs" {
  echo 'sleep 0.5; echo "#000000"' >"$STUBS/hyprpicker.sh"
  run "$SWAY/bin/colorpick"
  assert_success
  run calls
  assert_line 'swaymsg -q seat - cursor move 1 0'
  assert_line 'swaymsg -q seat - cursor move -1 0'
}
