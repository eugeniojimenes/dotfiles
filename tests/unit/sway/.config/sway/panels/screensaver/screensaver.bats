#!/usr/bin/env bats
# panels/screensaver/screensaver (start/stop for swayidle) with stubs, and screensaver.mjs through qmltestrunner
# (QtTest, offscreen: no Wayland), one @test per function in screensaver.qml.

setup() {
  load "${BATS_TEST_DIRNAME%/tests/unit/*}/tests/helpers/common"
  QML=$(dirname "$(readlink -f "$(command -v qmltestrunner)")")/../lib/qt-6/qml
  export QT_QPA_PLATFORM=offscreen
  QS="quickshell -p $HOME/.config/sway/panels/screensaver.qml"
  # pgrep finds the command lines listed in $STUBS/running.
  : >"$STUBS/running"
  echo 'grep -qxF -- "${!#}" "$STUBS/running"; exit $?' >"$STUBS/pgrep.sh"
}

qt() {
  run qmltestrunner -import "$QML" -input "$BATS_TEST_DIRNAME/screensaver.qml" "screensaver::$1"
  assert_success
  assert_output --partial "PASS   : qmltestrunner::screensaver::$1()"
}

@test "start: screensaver detached when neither it nor the lock screen is up" {
  run "$SWAY/panels/screensaver/screensaver" start
  assert_success
  run calls
  assert_line "setsid -f $QS"
}

@test "start: nothing when the screensaver or the lock screen is already up" {
  echo "$QS" >"$STUBS/running"
  run "$SWAY/panels/screensaver/screensaver" start
  echo "quickshell -p $HOME/.config/sway/panels/lock.qml" >"$STUBS/running"
  run "$SWAY/panels/screensaver/screensaver" start
  run calls
  refute_line --partial setsid
}

@test "stop: ends the screensaver by its exact command line" {
  run "$SWAY/panels/screensaver/screensaver" stop
  assert_success
  run calls
  assert_output "pkill -fx $QS"
}

@test "no argument: usage, exit 2" {
  run "$SWAY/panels/screensaver/screensaver"
  assert_failure 2
  assert_output --partial 'screensaver start'
}

@test "images: outputs start apart and move together, none = clock alone" { qt test_image_index; }
@test "clock: a new spot inside the screen at every slide, per output" { qt test_clock_spot; }
