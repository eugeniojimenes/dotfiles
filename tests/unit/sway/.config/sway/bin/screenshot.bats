#!/usr/bin/env bats

setup() {
  load "${BATS_TEST_DIRNAME%/tests/unit/*}/tests/helpers/common"
  # grim writes the file wl-copy and notify-send then use.
  echo 'touch "${@: -1}"' >"$STUBS/grim.sh"
}

@test "area: no xdg-user-dir falls back to ~/Pictures and creates it" {
  stub xdg-user-dir --rc 127
  stub slurp '10,10 20x20'
  run "$SWAY/bin/screenshot" area
  assert_success
  [[ -d $HOME/Pictures ]]
  run calls
  assert_line --regexp "^grim -g 10,10 20x20 $HOME/Pictures/screenshot-[0-9_-]+\.png$"
  assert_line --regexp "^notify-send -a Screenshot -i $HOME/Pictures/screenshot-.*\.png Screenshot saved "
  [[ -f $STUBS/wl-copy.stdin ]]
}

@test "default mode is area, into the XDG pictures dir" {
  stub xdg-user-dir "$BATS_TEST_TMPDIR/pics"
  stub slurp '0,0 5x5'
  run "$SWAY/bin/screenshot"
  assert_success
  run calls
  assert_line --regexp "^grim -g 0,0 5x5 $BATS_TEST_TMPDIR/pics/screenshot-"
}

@test "area: Esc in slurp exits cleanly, no capture" {
  stub xdg-user-dir --rc 1
  stub slurp --rc 1
  run "$SWAY/bin/screenshot" area
  assert_success
  run calls
  refute_line --partial grim
  refute_line --partial notify-send
}

@test "screen: captures the focused output" {
  stub xdg-user-dir --rc 1
  stub swaymsg '[{"name":"eDP-1","focused":false},{"name":"HDMI-A-1","focused":true}]'
  run "$SWAY/bin/screenshot" screen
  assert_success
  run calls
  assert_line --regexp "^grim -o HDMI-A-1 $HOME/Pictures/screenshot-"
}
