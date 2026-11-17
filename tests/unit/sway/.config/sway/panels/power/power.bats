#!/usr/bin/env bats
# power/power.mjs through qmltestrunner (QtTest, offscreen: no Wayland). One @test per function in power.qml.

setup() {
  load "${BATS_TEST_DIRNAME%/tests/unit/*}/tests/helpers/common"
  QML=$(dirname "$(readlink -f "$(command -v qmltestrunner)")")/../lib/qt-6/qml
  export QT_QPA_PLATFORM=offscreen
}

qt() {
  run qmltestrunner -import "$QML" -input "$BATS_TEST_DIRNAME/power.qml" "power::$1"
  assert_success
  assert_output --partial "PASS   : qmltestrunner::power::$1()"
}

@test "duration: hours and minutes, under a minute, no estimate" { qt test_duration; }
@test "status line per UPower state, with the estimate when there is one" { qt test_status; }
@test "battery glyph: eleven steps, plug glyphs on AC, clamped" { qt test_icon; }
