#!/usr/bin/env bats
# share/share.mjs through qmltestrunner (QtTest, offscreen: no Wayland). One @test per function in share.qml.

setup() {
  load "${BATS_TEST_DIRNAME%/tests/unit/*}/tests/helpers/common"
  QML=$(dirname "$(readlink -f "$(command -v qmltestrunner)")")/../lib/qt-6/qml
  export QT_QPA_PLATFORM=offscreen
}

qt() {
  run qmltestrunner -import "$QML" -input "$BATS_TEST_DIRNAME/share.qml" "share::$1"
  assert_success
  assert_output --partial "PASS   : qmltestrunner::share::$1()"
}

@test "rows file: one card per row, the portal line keeps its own tabs, rows without a line dropped" { qt test_parse; }
@test "step: held at both ends, -1 without cards" { qt test_step; }
