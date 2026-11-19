#!/usr/bin/env bats

setup() {
  load "${BATS_TEST_DIRNAME%/tests/unit/*}/tests/helpers/common"
  link_sway
  portal=$'Monitor: HDMI-A-1 Dell U2720Q\nWindow: Notes (draft) - Editor (42)\nRegion: odd'
  # Window 42 on workspace 3, as `swaymsg -t get_tree` nests it.
  stub swaymsg '{"nodes":[{"type":"output","nodes":[{"type":"workspace","name":"3","nodes":[{"type":"con","app_id":"editor","foreign_toplevel_identifier":"42","nodes":[]}]}]}]}'
  # grim writes the file named by its last argument.
  echo 'echo png >"${@: -1}"' >"$STUBS/grim.sh"
  # The picker (panels/share.qml): keeps a copy of the rows it got, writes $STUBS/pick (if any) as the pick. Other
  # quickshell calls (dnd's IPC) only get recorded.
  cat >"$STUBS/quickshell.sh" <<'SH'
[[ -n ${SHARE_PICKER_IN-} ]] || exit 0
cp "$SHARE_PICKER_IN" "$STUBS/rows"
[[ -f $STUBS/pick ]] && cp "$STUBS/pick" "$SHARE_PICKER_OUT"
SH
  thumbs=$XDG_RUNTIME_DIR/sway-share-picker
}

@test "portal lines become cards: monitor name and model, window title and workspace, original line kept" {
  run "$SWAY/bin/share-picker" <<<"$portal"
  run cat "$STUBS/rows"
  assert_output "$(printf '%s\n' \
    $'monitor\tHDMI-A-1\tDell U2720Q\t'"$thumbs/m1.png"$'\t\tMonitor: HDMI-A-1 Dell U2720Q' \
    $'window\tNotes (draft) - Editor\tworkspace 3\t'"$thumbs/1.png"$'\teditor\tWindow: Notes (draft) - Editor (42)' \
    $'other\tRegion: odd\t\t\t\tRegion: odd')"
  run grep '^quickshell' "$STUBS/calls"
  assert_output "quickshell -p $HOME/.config/sway/panels/share.qml"
}

@test "window title with a tab: a space on the card, the tab kept in the line handed back" {
  stub swaymsg '{"nodes":[]}'
  run "$SWAY/bin/share-picker" <<<$'Window: a\tb (7)'
  run cat "$STUBS/rows"
  assert_output $'window\ta b\t\t'"$thumbs/1.png"$'\t\tWindow: a\tb (7)'
  printf '%s\n' $'Window: a\tb (7)' >"$STUBS/pick"
  run "$SWAY/bin/share-picker" <<<$'Window: a\tb (7)'
  assert_output $'Window: a\tb (7)'
}

@test "monitor picked: line returned verbatim, pick remembered, notifications hidden before the portal gets it" {
  echo 'Monitor: HDMI-A-1 Dell U2720Q' >"$STUBS/pick"
  run "$SWAY/bin/share-picker" <<<"$portal"
  assert_success
  assert_output 'Monitor: HDMI-A-1 Dell U2720Q'
  run cat "$XDG_RUNTIME_DIR/sway-share-target"
  assert_output Monitor
  run grep -c "^quickshell ipc -p $HOME/.config/sway/panels/notifications.qml call notifications modeOn screenshare\$" "$STUBS/calls"
  assert_output 1
}

@test "window picked: line returned, pick remembered, notifications untouched" {
  echo 'Window: Notes (draft) - Editor (42)' >"$STUBS/pick"
  run "$SWAY/bin/share-picker" <<<"$portal"
  assert_success
  assert_output 'Window: Notes (draft) - Editor (42)'
  run cat "$XDG_RUNTIME_DIR/sway-share-target"
  assert_output Window
  run calls
  refute_line --partial 'call notifications'
}

@test "started: a monitor pick or none on record hides notifications, a window pick does not; each pick used once" {
  on="quickshell ipc -p $HOME/.config/sway/panels/notifications.qml call notifications modeOn screenshare"
  target=$XDG_RUNTIME_DIR/sway-share-target
  echo Monitor >"$target"
  run "$SWAY/bin/share-picker" started </dev/null
  assert_success
  run grep -c "^$on\$" "$STUBS/calls"
  assert_output 1
  [[ ! -e $target ]]
  run "$SWAY/bin/share-picker" started </dev/null
  run grep -c "^$on\$" "$STUBS/calls"
  assert_output 2
  echo Window >"$target"
  run "$SWAY/bin/share-picker" started </dev/null
  assert_success
  run grep -c "^$on\$" "$STUBS/calls"
  assert_output 2
  # Used up: the next start without a pick (Brave's real share after its preview) hides.
  run "$SWAY/bin/share-picker" started </dev/null
  run grep -c "^$on\$" "$STUBS/calls"
  assert_output 3
}

@test "picker closed: exit 1, portal cancels the share" {
  run "$SWAY/bin/share-picker" <<<"$portal"
  assert_failure 1
  assert_output ''
}

@test "thumbnails: each window and each monitor as it is now, all removed after the pick" {
  run "$SWAY/bin/share-picker" <<<"$portal"
  run grep '^grim' "$STUBS/calls"
  assert_output "$(printf '%s\n' "grim -o HDMI-A-1 -s 0.2 $thumbs/m1.png" "grim -T 42 -s 0.2 $thumbs/1.png")"
  [[ ! -e $thumbs ]]
}

@test "monitor already shared or recorded: no captures, cards fall back to the app's icon" {
  for mode in screenshare recording; do
    echo "dnd $mode" >"$XDG_RUNTIME_DIR/sway-notification-modes"
    run "$SWAY/bin/share-picker" <<<"$portal"
    run cat "$STUBS/rows"
    assert_output "$(printf '%s\n' \
      $'monitor\tHDMI-A-1\tDell U2720Q\t\t\tMonitor: HDMI-A-1 Dell U2720Q' \
      $'window\tNotes (draft) - Editor\tworkspace 3\t\teditor\tWindow: Notes (draft) - Editor (42)' \
      $'other\tRegion: odd\t\t\t\tRegion: odd')"
  done
  run grep -c '^grim' "$STUBS/calls"
  assert_output 0
}

@test "window asked again within 60 s: the same window back without the picker, once" {
  echo 'Window: Notes (draft) - Editor (42)' >"$STUBS/pick"
  run "$SWAY/bin/share-picker" <<<"$portal"
  rm "$STUBS/pick"
  run "$SWAY/bin/share-picker" <<<"$portal"
  assert_success
  assert_output 'Window: Notes (draft) - Editor (42)'
  run grep -c '^quickshell -p' "$STUBS/calls"
  assert_output 1
  # Used up: a third ask shows the picker (closed here without a pick).
  run "$SWAY/bin/share-picker" <<<"$portal"
  assert_failure 1
  run grep -c '^quickshell -p' "$STUBS/calls"
  assert_output 2
}

@test "window asked again after 60 s, or no longer offered, or a monitor picked: the picker opens" {
  memory=$XDG_RUNTIME_DIR/sway-share-last-window
  printf '%s\t%s\n' "$(($(date +%s) - 61))" 'Window: Notes (draft) - Editor (42)' >"$memory"
  run "$SWAY/bin/share-picker" <<<"$portal"
  printf '%s\t%s\n' "$(date +%s)" 'Window: Gone (7)' >"$memory"
  run "$SWAY/bin/share-picker" <<<"$portal"
  run grep -c '^quickshell -p' "$STUBS/calls"
  assert_output 2
  echo 'Monitor: HDMI-A-1 Dell U2720Q' >"$STUBS/pick"
  run "$SWAY/bin/share-picker" <<<"$portal"
  [[ ! -e $memory ]]
}
