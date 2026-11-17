#!/usr/bin/env bats
# notifications/notify.mjs through qmltestrunner (QtTest, offscreen: no Wayland). One @test per function in notify.qml.

setup() {
  load "${BATS_TEST_DIRNAME%/tests/unit/*}/tests/helpers/common"
  QML=$(dirname "$(readlink -f "$(command -v qmltestrunner)")")/../lib/qt-6/qml
  export QT_QPA_PLATFORM=offscreen
}

qt() {
  run qmltestrunner -import "$QML" -input "$BATS_TEST_DIRNAME/notify.qml" "notify::$1"
  assert_success
  assert_output --partial "PASS   : qmltestrunner::notify::$1()"
}

@test "delivery: share and recording hide behind the card, dnd silences, battery warnings pass any mode" { qt test_delivery; }
@test "hidden card text: count, and the reason (share wins over recording)" { qt test_hidden_text; }
@test "timeout: sender's value, 5 s by default, never for critical or 0" { qt test_timeout; }
@test "modes: on, off and toggle per name, unknown names ignored" { qt test_set_mode; }
@test "history cap: oldest let go first, never one on screen" { qt test_overflow; }
