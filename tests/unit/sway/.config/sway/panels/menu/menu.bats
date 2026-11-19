#!/usr/bin/env bats
# menu/menu.mjs through qmltestrunner (QtTest, offscreen: no Wayland). One @test per function in menu.qml.

setup() {
  load "${BATS_TEST_DIRNAME%/tests/unit/*}/tests/helpers/common"
  QML=$(dirname "$(readlink -f "$(command -v qmltestrunner)")")/../lib/qt-6/qml
  export QT_QPA_PLATFORM=offscreen
}

qt() {
  run qmltestrunner -import "$QML" -input "$BATS_TEST_DIRNAME/menu.qml" "menu::$1"
  assert_success
  assert_output --partial "PASS   : qmltestrunner::menu::$1()"
}

@test "root: the categories in order, Apps first, no app listed" { qt test_root; }
@test "apps: under Apps by name with their icon, launched by desktop id through gtk-launch, never a shell" { qt test_apps; }
@test "entries: each runs its script or panel toggle" { qt test_actions; }
@test "power profile: current one checked, a pick sets it and shows the popup" { qt test_power_profile; }
@test "terminal opacity: ten steps, the saved one checked" { qt test_opacity; }
@test "hibernation set up: Suspend hibernates later and Hibernate is listed; without it, plain Suspend" { qt test_hibernation; }
@test "search: every level below, own entries first, deeper ones with their path, apps by name or generic name" { qt test_search; }
@test "back: parent of a submenu, path of an entry" { qt test_back; }
@test "cursor: held at both ends, -1 without rows" { qt test_step; }
