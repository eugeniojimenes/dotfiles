#!/usr/bin/env bats
# sound/sound.mjs through qmltestrunner (QtTest, offscreen: no Wayland, no PipeWire). One @test per function in
# sound.qml.

setup() {
  load "${BATS_TEST_DIRNAME%/tests/unit/*}/tests/helpers/common"
  QML=$(dirname "$(readlink -f "$(command -v qmltestrunner)")")/../lib/qt-6/qml
  export QT_QPA_PLATFORM=offscreen
}

qt() {
  run qmltestrunner -import "$QML" -input "$BATS_TEST_DIRNAME/sound.qml" "sound::$1"
  assert_success
  assert_output --partial "PASS   : qmltestrunner::sound::$1()"
}

@test "lists: outputs, inputs, playing apps; recording streams and nodes without audio left out" { qt test_devices; }
@test "names: description, then nickname, then node name; apps by application name" { qt test_labels; }
@test "volume: stops at 0 and at 100%" { qt test_clamp; }
