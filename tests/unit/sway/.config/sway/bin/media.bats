#!/usr/bin/env bats
# playerctl stubbed: $STUBS/players holds the `playerctl -a metadata` lines (status, instance, name, artist, title).

setup() {
  load "${BATS_TEST_DIRNAME%/tests/unit/*}/tests/helpers/common"
  # Players listed by `-a metadata`; `--follow` prints the same lines once, then ends (waybar would keep it running).
  cat >"$STUBS/playerctl.sh" <<'SH'
[[ $1 == -a && $2 == --follow ]] && cat "$STUBS/follow" 2>/dev/null && exit 0
[[ $1 == -a ]] && cat "$STUBS/players"
SH
}

players() {
  local line
  : >"$STUBS/players"
  for line in "$@"; do printf '%s\n' "${line//|/$'\x1f'}" >>"$STUBS/players"; done
  cp "$STUBS/players" "$STUBS/follow"
}

@test "status: the playing player wins over one paused after it, text and tooltip, Pango escaped" {
  players 'Paused|spotify|spotify|The Blaze|Runaway' 'Playing|brave.instance1|brave|Channel|Tips & <tricks>'
  run "$SWAY/bin/media" status
  assert_success
  run jq -e '.text == "󰐊 Channel - Tips &amp; &lt;tricks&gt;" and .tooltip == "brave: Channel - Tips &amp; &lt;tricks&gt;" and .class == "playing"' <<<"${lines[0]}"
  assert_success
}

@test "status: none playing = first paused with a track, stale player skipped; title alone without artist" {
  players 'Paused|brave.instance1|brave||' 'Paused|spotify|spotify||Runaway'
  run "$SWAY/bin/media" status
  run jq -e '.text == "󰏤 Runaway" and .class == "paused"' <<<"${lines[0]}"
  assert_success
}

@test "status: text cut at 70 characters, tooltip whole" {
  players "Playing|spotify|spotify|Artist|$(printf 'x%.0s' {1..80})"
  run "$SWAY/bin/media" status
  local line=${lines[0]}
  run jq -r '.text' <<<"$line"
  assert_output "󰐊 Artist - $(printf 'x%.0s' {1..60})…"
  run jq -r '.tooltip | length' <<<"$line"
  assert_output 98
}

@test "status: no player with a track = empty text (module hidden)" {
  players 'Stopped|brave.instance1|brave||'
  run "$SWAY/bin/media" status
  assert_output '{"text": ""}'
}

@test "status: the last player leaving (empty line) hides the module, no error" {
  players 'Playing|spotify|spotify|A|Song'
  echo >>"$STUBS/follow"
  : >"$STUBS/players"
  run "$SWAY/bin/media" status
  assert_success
  refute_output --partial 'bad array subscript'
  assert_equal "${lines[-1]}" '{"text": ""}'
}

@test "toggle, next, previous: on the playing player" {
  players 'Paused|spotify|spotify|A|Song' 'Playing|brave.instance1|brave|B|Video'
  for action in toggle next previous; do run "$SWAY/bin/media" "$action"; done
  run grep -v -e ' -a ' -e '^quickshell' "$STUBS/calls"
  assert_output "$(printf '%s\n' 'playerctl -p brave.instance1 play-pause' 'playerctl -p brave.instance1 next' \
    'playerctl -p brave.instance1 previous')"
}

@test "toggle without a player holding a track: playerctl's own pick" {
  players 'Stopped|spotify|spotify||'
  run "$SWAY/bin/media" toggle
  run grep -v -e ' -a ' -e '^quickshell' "$STUBS/calls"
  assert_output 'playerctl play-pause'
}

@test "pick: that player wins while it has a track, a refresh is asked" {
  players 'Playing|brave.instance1|brave|B|Video' 'Paused|spotify|spotify|A|Song'
  run "$SWAY/bin/media" pick spotify
  assert_success
  # Every status loop by its command line, the bash one only (not the sh -c waybar may start it through).
  run calls
  assert_line 'pkill -USR1 -f ^[^ ]*bash [^ ]*/sway/bin/media status$'
  run "$SWAY/bin/media" toggle
  run grep -v -e ' -a ' -e '^quickshell' -e '^pkill' "$STUBS/calls"
  assert_output 'playerctl -p spotify play-pause'
}

@test "pick: a picked player without a track is skipped" {
  players 'Playing|brave.instance1|brave|B|Video' 'Stopped|spotify|spotify||'
  echo spotify >"$XDG_RUNTIME_DIR/sway-media-player"
  run "$SWAY/bin/media" toggle
  run grep -v -e ' -a ' -e '^quickshell' "$STUBS/calls"
  assert_output 'playerctl -p brave.instance1 play-pause'
}

@test "status: another player starting to play ends the pick" {
  players 'Paused|spotify|spotify|A|Song' 'Paused|brave.instance1|brave|B|Video'
  echo spotify >"$XDG_RUNTIME_DIR/sway-media-player"
  run "$SWAY/bin/media" status
  run jq -r '.tooltip' <<<"${lines[0]}"
  assert_output 'spotify: A - Song'
  printf 'Playing\x1fbrave.instance1\x1fbrave\x1fB\x1fVideo\n' >"$STUBS/follow"
  run "$SWAY/bin/media" status
  [[ ! -s $XDG_RUNTIME_DIR/sway-media-player ]]
}

@test "pick without a player: usage error, exit 2" {
  run "$SWAY/bin/media" pick
  assert_failure 2
}

@test "no argument: usage, exit 2" {
  run "$SWAY/bin/media"
  assert_failure 2
  assert_output --partial 'media status'
}

@test "toggle, next, previous: track popup asked for the player and the action, none without a player" {
  players 'Playing|brave.instance1|brave|B|Video'
  run "$SWAY/bin/media" next
  run grep '^quickshell' "$STUBS/calls"
  assert_output "quickshell ipc -p $HOME/.config/sway/panels/notifications.qml call osd track brave.instance1 next"
  : >"$STUBS/calls"
  players 'Stopped|spotify|spotify||'
  run "$SWAY/bin/media" toggle
  run grep -c '^quickshell' "$STUBS/calls"
  assert_output 0
}
