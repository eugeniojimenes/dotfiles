#!/usr/bin/env bats

setup() { load "${BATS_TEST_DIRNAME%/tests/unit/*}/tests/helpers/common"; }

@test "status: no mode gives empty text" {
  stub makoctl default
  run "$SWAY/bin/dnd" status
  assert_success
  run jq -e '.text == ""' <<<"$output"
  assert_success
}

@test "status: dnd mode gives the dnd class" {
  stub makoctl $'default\ndnd'
  run "$SWAY/bin/dnd" status
  assert_success
  run jq -e '.class == "dnd"' <<<"$output"
  assert_success
}

@test "status: screenshare wins over dnd" {
  stub makoctl $'dnd\nscreenshare'
  run "$SWAY/bin/dnd" status
  assert_success
  run jq -e '.class == "share"' <<<"$output"
  assert_success
}

@test "status: recording hides like a screen share, with its own tooltip" {
  stub makoctl $'dnd\nrecording'
  run "$SWAY/bin/dnd" status
  assert_success
  run jq -e '.class == "share" and (.tooltip | test("recording"))' <<<"$output"
  assert_success
}

@test "status: never pokes waybar" {
  stub makoctl dnd
  run "$SWAY/bin/dnd" status
  run calls
  refute_output --partial pkill
}

@test "toggle, share-on, share-off, record-on, record-off: makoctl mode change, then waybar signal 8" {
  for arg in toggle share-on share-off record-on record-off; do run "$SWAY/bin/dnd" "$arg"; done
  run calls
  assert_output "$(printf '%s\n' \
    'makoctl mode -t dnd' 'pkill -RTMIN+8 -f ^waybar ' \
    'makoctl mode -a screenshare' 'pkill -RTMIN+8 -f ^waybar ' \
    'makoctl mode -r screenshare' 'pkill -RTMIN+8 -f ^waybar ' \
    'makoctl mode -a recording' 'pkill -RTMIN+8 -f ^waybar ' \
    'makoctl mode -r recording' 'pkill -RTMIN+8 -f ^waybar ')"
}
