#!/usr/bin/env bats
# bluetooth/flow.js through qmltestrunner (QtTest, offscreen platform: no Wayland, no BlueZ). One @test per function
# in flow.qml, so spec criteria name them like any other bats test.

setup() {
  load "${BATS_TEST_DIRNAME%/tests/unit/*}/tests/helpers/common"
  QML=$(dirname "$(readlink -f "$(command -v qmltestrunner)")")/../lib/qt-6/qml
  export QT_QPA_PLATFORM=offscreen
}

qt() {
  run qmltestrunner -import "$QML" -input "$BATS_TEST_DIRNAME/flow.qml" "flow::$1"
  assert_success
  assert_output --partial "PASS   : qmltestrunner::flow::$1()"
}

@test "new device: link up mid-pairing never closes the panel, connect over D-Bus after Pair()" { qt test_new_device_pairing; }
@test "new device: connected after pairing, panel stays open" { qt test_new_device_connects_later; }
@test "new device: pairing fails, message shown, nothing connected" { qt test_pairing_fails; }
@test "paired device: panel closes once connected" { qt test_paired_device_closes_once_connected; }
@test "paired device: back to disconnected, Connection failed, panel stays open" { qt test_paired_device_connect_fails; }
@test "connected device: click disconnects, panel stays open" { qt test_connected_device_disconnects; }
@test "busy device: click ignored" { qt test_busy_device_ignored; }
@test "forget: pairing removed, flow dropped" { qt test_forget; }
