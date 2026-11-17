#!/usr/bin/env bats
# calendar/calendar.js through qmltestrunner (QtTest, offscreen: no Wayland). One @test per function in calendar.qml.

setup() {
  load "${BATS_TEST_DIRNAME%/tests/unit/*}/tests/helpers/common"
  QML=$(dirname "$(readlink -f "$(command -v qmltestrunner)")")/../lib/qt-6/qml
  export QT_QPA_PLATFORM=offscreen
  # POSIX rule, no tzdata needed (CI sandbox has none): US Eastern, DST from 8 March 2026.
  export TZ=EST5EDT,M3.2.0,M11.1.0
}

qt() {
  run qmltestrunner -import "$QML" -input "$BATS_TEST_DIRNAME/calendar.qml" "calendar::$1"
  assert_success
  assert_output --partial "PASS   : qmltestrunner::calendar::$1()"
}

@test "month step wraps across year edges both ways" { qt test_step_across_year_edges; }
@test "ISO week numbers at year edges, week 53 included" { qt test_iso_week_at_year_edges; }
@test "grid: 6 weeks from the Monday on or before the 1st" { qt test_grid_starts_on_monday; }
@test "grid: one day per cell across a DST change" { qt test_grid_across_dst_change; }
@test "today mark: same day whatever the time" { qt test_same_day_ignores_time; }
@test "year progress: 0 on 1 January, half in early July" { qt test_year_progress; }
