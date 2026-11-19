#!/usr/bin/env bats

setup() {
  load "${BATS_TEST_DIRNAME%/tests/unit/*}/tests/helpers/common"
  # grim writes the file wl-copy and notify-send then use.
  echo 'touch "${@: -1}"' >"$STUBS/grim.sh"
}

@test "area: no xdg-user-dir falls back to ~/Pictures/Screenshots and creates it" {
  stub xdg-user-dir --rc 127
  stub slurp '10,10 20x20'
  run "$SWAY/bin/screenshot" area
  assert_success
  [[ -d $HOME/Pictures/Screenshots ]]
  run calls
  assert_line --regexp "^grim -g 10,10 20x20 $HOME/Pictures/Screenshots/screenshot-[0-9_-]+\.png$"
  assert_line --regexp "^notify-send -a Screenshot -i $HOME/Pictures/Screenshots/screenshot-.*\.png -A edit=Edit Screenshot saved "
  [[ -f $STUBS/wl-copy.stdin ]]
}

@test "default mode is area, into Screenshots in the XDG pictures dir" {
  stub xdg-user-dir "$BATS_TEST_TMPDIR/pics"
  stub slurp '0,0 5x5'
  run "$SWAY/bin/screenshot"
  assert_success
  run calls
  assert_line --regexp "^grim -g 0,0 5x5 $BATS_TEST_TMPDIR/pics/Screenshots/screenshot-"
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
  assert_line --regexp "^grim -o HDMI-A-1 $HOME/Pictures/Screenshots/screenshot-"
}

@test "Edit in the notification: satty on the same file, Enter and Copy copy its result and save it" {
  stub xdg-user-dir --rc 1
  stub slurp '0,0 5x5'
  stub notify-send edit
  run "$SWAY/bin/screenshot" area
  assert_success
  run calls
  assert_line --regexp "^notify-send -a Screenshot -i (.*\.png) -A edit=Edit Screenshot saved \1$"
  assert_line --regexp "^satty --filename (.*\.png) --output-filename \1 --copy-command wl-copy --early-exit --actions-on-enter save-to-clipboard --save-after-copy$"
}

@test "notification closed without Edit: no editor" {
  stub xdg-user-dir --rc 1
  stub slurp '0,0 5x5'
  run "$SWAY/bin/screenshot" area
  assert_success
  run calls
  refute_line --partial satty
}
