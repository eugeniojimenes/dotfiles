#!/usr/bin/env bats

setup() {
  load "${BATS_TEST_DIRNAME%/tests/unit/*}/tests/helpers/common"
  link_sway
  run_dir=$XDG_RUNTIME_DIR/sway-lock
  stub pgrep --rc 1
  stub swaymsg '[{"name":"eDP-1","active":true},{"name":"HDMI-A-1","active":true},{"name":"DP-5","active":false}]'
  echo 'touch "${@: -1}"' >"$STUBS/grim.sh"
}

# Quickshell that locks: reports the backdrop it was given, signals locked, stays up a moment like a real lock.
locks() {
  cat >"$STUBS/quickshell.sh" <<'SH'
stat -c %a "$SWAY_LOCK_SHOTS" >"$STUBS/mode"
ls "$SWAY_LOCK_SHOTS" >"$STUBS/shots"
touch "$SWAY_LOCK_MARKER"
sleep 1
SH
}

@test "locks: one screenshot per active output in a 0700 runtime dir, returns once locked" {
  locks
  run "$SWAY/panels/lock/lock"
  assert_success
  [[ $(cat "$STUBS/mode") == 700 ]]
  run cat "$STUBS/shots"
  assert_line eDP-1.png
  assert_line HDMI-A-1.png
  refute_line DP-5.png
  run calls
  assert_line "quickshell -p $HOME/.config/sway/panels/lock.qml"
  refute_line --partial swaylock
}

@test "screenshots removed once Quickshell exits (unlock)" {
  locks
  run "$SWAY/panels/lock/lock"
  sleep 1.5
  [[ ! -e $run_dir ]]
}

@test "already locked: exits at once, nothing else runs" {
  stub pgrep --rc 0
  run "$SWAY/panels/lock/lock"
  assert_success
  run calls
  assert_output "pgrep -fx quickshell -p $HOME/.config/sway/panels/lock.qml"
}

@test "Quickshell never locks: swaylock after 5s, the session is never left open" {
  run "$SWAY/panels/lock/lock"
  run calls
  assert_line "swaylock -f -C $HOME/.config/sway/apps/swaylock"
}
