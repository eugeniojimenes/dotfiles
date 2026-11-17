#!/usr/bin/env bats
# wifi/flow.mjs through qmltestrunner (QtTest, offscreen: no Wayland, no NetworkManager). One @test per function in
# flow.qml, so spec criteria name them like any other bats test.

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

@test "list: connected first, then by signal, hidden networks left out" { qt test_list_connected_first_then_signal_hidden_left_out; }
@test "saved or open network: connects without a prompt, panel closes once it is up" { qt test_saved_network_connects_and_closes; }
@test "new PSK network: password row, Enter connects with it, panel closes once up" { qt test_new_psk_network_asks_then_connects; }
@test "saved network, secret refused: Wrong password, Esc closes the row" { qt test_saved_network_refused_secret_says_wrong_password; }
@test "enterprise network and other failures: message shown, panel stays" { qt test_enterprise_and_other_failures; }
@test "connected or changing network: click ignored" { qt test_connected_or_changing_network_ignored; }
