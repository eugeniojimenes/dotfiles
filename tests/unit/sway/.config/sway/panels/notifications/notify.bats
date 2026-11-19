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
@test "screen hidden: share and recording take popups off the screen, dnd alone does not" { qt test_screen_hidden; }
@test "timeout: sender's value, 5 s by default, never for critical or 0" { qt test_timeout; }
@test "modes: on, off and toggle per name, unknown names ignored" { qt test_set_mode; }
@test "history cap: oldest let go first, never one on screen" { qt test_overflow; }
@test "history: poweralertd state changes never kept, its warnings are" { qt test_keep; }
@test "time in the centre: now, minutes, hours, then the clock" { qt test_ago; }
@test "bar bell: mode wins (recording, share, dnd), else the unread count" { qt test_bell; }
@test "deck closed: front lowest, older edges a gap higher and smaller, up to three" { qt test_deck_closed; }
@test "deck open: a list, newest on top, a gap between cards" { qt test_deck_open; }
@test "centre: kept ones only, newest first; meta line with or without app name" { qt test_centre_items; }
@test "body: b, i, u, a and br stay markup, any other tag (img included, any spacing or nesting) shows as text" { qt test_safe_body; }
@test "arrival: end of the history once per id, unread after the centre opened, reload carry-overs silent and read" { qt test_arrive_history; }
@test "arrival: hidden ones counted, a critical one keeps the card red, ephemeral ones let go unless shown" { qt test_arrive_hidden_and_ephemeral; }
@test "osd icon: volume and brightness by level, muted ones" { qt test_osd_icon; }
@test "track text: artist - title, title alone, player name without a title" { qt test_track_text; }
@test "track icon: next and previous by action, else play or pause by state" { qt test_track_icon; }
@test "switch popup: stay awake, night light, do not disturb on and off, power profiles; unknown ones none" { qt test_switch_popup; }
@test "centre hidden text: count and the reason, share wins over recording" { qt test_centre_hidden_text; }
