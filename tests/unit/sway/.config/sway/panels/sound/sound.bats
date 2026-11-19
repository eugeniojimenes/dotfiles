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
@test "media card: the chosen player, else the playing one, else a paused one with a track; stale ones skipped" { qt test_media_player; }
@test "player instance: D-Bus name without the MPRIS prefix, as playerctl names it" { qt test_instance; }
@test "media card arrows: next or previous player with a track, wrapping around" { qt test_step_player; }
@test "track time: m:ss, h:mm:ss from one hour on" { qt test_clock; }
