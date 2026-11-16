#!/usr/bin/env bats

setup() {
  load "${BATS_TEST_DIRNAME%/tests/unit/*}/tests/helpers/common"
  link_sway
  portal=$'Monitor: HDMI-A-1\nWindow: Notes (draft) - Editor (42)\nRegion: odd'
}

@test "portal lines become rows: label without prefix and id, original line hidden in column 2" {
  stub fuzzel --rc 1
  run "$SWAY/bin/share-picker" <<<"$portal"
  run awk -F'\t' '{ print $2 }' "$STUBS/fuzzel.stdin"
  assert_output "$portal"
  run awk -F'\t' '{ sub(/^[^ ]*  /, "", $1); print $1 }' "$STUBS/fuzzel.stdin"
  assert_output $'HDMI-A-1\nNotes (draft) - Editor\nRegion: odd'
}

@test "monitor picked: line returned verbatim, notifications hidden" {
  stub fuzzel 'Monitor: HDMI-A-1'
  run "$SWAY/bin/share-picker" <<<"$portal"
  assert_success
  assert_output 'Monitor: HDMI-A-1'
  run calls
  assert_line 'makoctl mode -a screenshare'
}

@test "window picked: line returned, notifications untouched" {
  stub fuzzel 'Window: Notes (draft) - Editor (42)'
  run "$SWAY/bin/share-picker" <<<"$portal"
  assert_success
  assert_output 'Window: Notes (draft) - Editor (42)'
  run calls
  refute_line --partial makoctl
}

@test "picker closed: exit 1, portal cancels the share" {
  stub fuzzel --rc 1
  run "$SWAY/bin/share-picker" <<<"$portal"
  assert_failure 1
  assert_output ''
}
