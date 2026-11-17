#!/usr/bin/env bats

setup() {
  load "${BATS_TEST_DIRNAME%/tests/unit/*}/tests/helpers/common"
  stub xdg-user-dir "$BATS_TEST_TMPDIR/videos"
  # wf-recorder writes the file named by its last argument, then exits as if stopped.
  echo 'echo video >"${@: -1}"' >"$STUBS/wf-recorder.sh"
  PIDFILE=$XDG_RUNTIME_DIR/sway-record.pid
}

teardown() { [[ -z ${REC-} ]] || kill -9 "$REC" 2>/dev/null || true; }

# A real process named wf-recorder (/proc comm = script file name), standing for a running recording. Job control on,
# else bash may start the background job with SIGINT ignored and the stop under test could never end it.
fake_recording() {
  mkdir -p "$BATS_TEST_TMPDIR/bin"
  printf '#!%s\ntrap "exit 130" INT\nwhile :; do sleep 0.1; done\n' "$BASH" >"$BATS_TEST_TMPDIR/bin/wf-recorder"
  chmod +x "$BATS_TEST_TMPDIR/bin/wf-recorder"
  set -m
  "$BATS_TEST_TMPDIR/bin/wf-recorder" &
  REC=$!
  set +m
  echo "$REC" >"$PIDFILE"
  # Until the child has exec'd, its comm is still bash.
  for _ in $(seq 50); do
    [[ $(cat "/proc/$REC/comm") == wf-recorder ]] && return
    sleep 0.02
  done
  return 1
}

@test "area: slurp region, MP4 in the XDG videos dir, saved notification" {
  stub slurp '10,10 20x20'
  run "$SWAY/bin/record" area
  assert_success
  ls "$BATS_TEST_TMPDIR"/videos/recording-*.mp4
  [[ ! -e $PIDFILE ]]
  run calls
  assert_line --regexp "^wf-recorder -g 10,10 20x20 -f $BATS_TEST_TMPDIR/videos/recording-[0-9_-]+\.mp4$"
  assert_line --regexp "^notify-send -a Recording Recording saved $BATS_TEST_TMPDIR/videos/recording-"
  # Waybar poked once when it starts and once when it ends.
  [[ $(grep -c '^pkill -RTMIN+9 -f ^waybar $' "$STUBS/calls") == 2 ]]
}

@test "while recording: notifications hidden and floating box, both undone at the end" {
  stub slurp '0,0 5x5'
  # Recording lasts until the box has started, so its kill below always finds it.
  echo 'until grep -q ^quickshell "$STUBS/calls"; do sleep 0.01; done; echo video >"${@: -1}"' >"$STUBS/wf-recorder.sh"
  run "$SWAY/bin/record" area
  assert_success
  run grep -E '^(makoctl|wf-recorder|quickshell|notify-send) ' "$STUBS/calls"
  assert_line --index 0 'makoctl mode -a recording'
  assert_line --index 1 --regexp '^wf-recorder '
  assert_line --index 2 "quickshell -p $SWAY/bin/../panels/recording.qml"
  assert_line --index 3 'makoctl mode -r recording'
  # Last: the saved notification is not hidden by the recording mode.
  assert_line --index 4 --regexp '^notify-send -a Recording Recording saved '
}

@test "area: Esc in slurp records nothing" {
  stub slurp --rc 1
  run "$SWAY/bin/record" area
  assert_success
  run calls
  refute_line --partial wf-recorder
  refute_line --partial notify-send
  refute_line --partial makoctl
}

@test "screen: focused output, video only" {
  stub swaymsg '[{"name":"eDP-1","focused":false},{"name":"HDMI-A-1","focused":true}]'
  run "$SWAY/bin/record" screen
  assert_success
  run calls
  assert_line --regexp "^wf-recorder -o HDMI-A-1 -f $BATS_TEST_TMPDIR/videos/recording-"
}

@test "running: start or stop interrupts it, nothing new starts" {
  for arg in area screen stop; do
    fake_recording
    run "$SWAY/bin/record" "$arg"
    assert_success
    rc=0
    wait "$REC" || rc=$?
    # 130 = 128 + SIGINT: wf-recorder finishes the file on SIGINT.
    assert_equal "$rc" 130
  done
  # No slurp, no wf-recorder, no waybar poke: only the signal.
  run calls
  assert_output ''
}

@test "status: icon only while wf-recorder runs, stale PID ignored" {
  run "$SWAY/bin/record" status
  assert_success
  run jq -e '.text == ""' <<<"$output"
  assert_success

  fake_recording
  run "$SWAY/bin/record" status
  run jq -e '.class == "recording" and .text != ""' <<<"$output"
  assert_success
  kill "$REC"

  # PID of a live process that is not wf-recorder: this test's shell.
  echo $$ >"$PIDFILE"
  run "$SWAY/bin/record" status
  run jq -e '.text == ""' <<<"$output"
  assert_success
}

@test "wf-recorder fails: file removed, failure notification" {
  stub slurp '0,0 5x5'
  echo 'touch "${@: -1}"; exit 1' >"$STUBS/wf-recorder.sh"
  run "$SWAY/bin/record" area
  run ls "$BATS_TEST_TMPDIR"/videos
  assert_output ''
  run calls
  assert_line --regexp '^notify-send -a Recording -u critical Recording failed '
  assert_line 'makoctl mode -r recording'
}

@test "no argument: usage, exit 2" {
  run "$SWAY/bin/record"
  assert_failure 2
  assert_output --partial 'record area'
}
