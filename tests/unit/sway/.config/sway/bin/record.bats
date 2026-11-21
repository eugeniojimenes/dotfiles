#!/usr/bin/env bats

setup() {
  load "${BATS_TEST_DIRNAME%/tests/unit/*}/tests/helpers/common"
  stub xdg-user-dir "$BATS_TEST_TMPDIR/videos"
  # wf-recorder writes the file named by its last argument, then exits as if stopped.
  echo 'echo video >"${@: -1}"' >"$STUBS/wf-recorder.sh"
  PIDFILE=$XDG_RUNTIME_DIR/sway-record.pid
  QS="quickshell ipc -p $HOME/.config/sway/panels/notifications.qml call notifications"
}

teardown() { [[ -z ${REC-} ]] || kill -9 "$REC" 2>/dev/null || true; }

# HACK: A real process named wf-recorder (/proc comm = script file name), standing for a running recording. Job control
# on, else bash may start the background job with SIGINT ignored and the stop under test could never end it.
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
  ls "$BATS_TEST_TMPDIR"/videos/Screenrecords/recording-*.mp4
  [[ ! -e $PIDFILE ]]
  run calls
  assert_line --regexp "^wf-recorder -g 10,10 20x20 -f $BATS_TEST_TMPDIR/videos/Screenrecords/recording-[0-9_-]+\.mp4$"
  assert_line --regexp "^notify-send -a Recording Recording saved $BATS_TEST_TMPDIR/videos/Screenrecords/recording-"
  # Waybar poked once when it starts and once when it ends.
  [[ $(grep -c '^pkill -RTMIN+9 -f ^waybar $' "$STUBS/calls") == 2 ]]
}

@test "while recording: notifications hidden and floating box, both undone at the end" {
  stub slurp '0,0 5x5'
  # Recording lasts until the box has started, so its kill below always finds it.
  echo 'until grep -q recording.qml "$STUBS/calls"; do sleep 0.01; done; echo video >"${@: -1}"' >"$STUBS/wf-recorder.sh"
  run "$SWAY/bin/record" area
  assert_success
  run grep -E '^(wf-recorder|quickshell|notify-send) ' "$STUBS/calls"
  assert_line --index 0 "$QS modeOn recording"
  assert_line --index 1 --regexp '^wf-recorder '
  assert_line --index 2 "quickshell -p $SWAY/bin/../panels/recording.qml"
  assert_line --index 3 "$QS modeOff recording"
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
  refute_line --partial 'call notifications'
}

@test "screen: focused output, video only" {
  stub swaymsg '[{"name":"eDP-1","focused":false},{"name":"HDMI-A-1","focused":true}]'
  run "$SWAY/bin/record" screen
  assert_success
  run calls
  assert_line --regexp "^wf-recorder -o HDMI-A-1 -f $BATS_TEST_TMPDIR/videos/Screenrecords/recording-"
}

@test "audio: the default microphone is recorded too, area and screen" {
  stub slurp '10,10 20x20'
  run "$SWAY/bin/record" area audio
  assert_success
  stub swaymsg '[{"name":"eDP-1","focused":true}]'
  run "$SWAY/bin/record" screen audio
  run calls
  assert_line --regexp "^wf-recorder --audio -g 10,10 20x20 -f "
  assert_line --regexp "^wf-recorder --audio -o eDP-1 -f "
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
  run ls "$BATS_TEST_TMPDIR"/videos/Screenrecords
  assert_output ''
  run calls
  assert_line --regexp '^notify-send -a Recording -u critical Recording failed '
  assert_line "$QS modeOff recording"
}

@test "wf-recorder fails after writing: file kept, may-be-incomplete notification" {
  stub slurp '0,0 5x5'
  echo 'echo video >"${@: -1}"; exit 1' >"$STUBS/wf-recorder.sh"
  run "$SWAY/bin/record" area
  ls "$BATS_TEST_TMPDIR"/videos/Screenrecords/recording-*.mp4
  run calls
  assert_line --regexp '^notify-send -a Recording -u critical Recording may be incomplete .*recording-.*\.mp4 \(wf-recorder exit 1\)$'
}

@test "no argument: usage, exit 2" {
  run "$SWAY/bin/record"
  assert_failure 2
  assert_output --partial 'record area'
}

@test "record killed while recording: wf-recorder finishes the file, mode off, box closed" {
  stub slurp '0,0 5x5'
  # HACK: Background jobs start with SIGINT ignored, and bash cannot trap a signal ignored on entry: env resets it, so
  # this wf-recorder finishes the file on SIGINT like the real one.
  echo 'exec env --default-signal=INT bash -c '"'"'trap "echo video >\"$1\"; exit 0" INT; while :; do sleep 0.05; done'"'"' _ "${@: -1}"' \
    >"$STUBS/wf-recorder.sh"
  "$SWAY/bin/record" area 3>&- &
  rec=$!
  for _ in $(seq 200); do
    grep -q recording.qml "$STUBS/calls" 2>/dev/null && break
    sleep 0.02
  done
  kill -TERM "$rec"
  for _ in $(seq 200); do
    kill -0 "$rec" 2>/dev/null || break
    sleep 0.02
  done
  run kill -0 "$rec"
  assert_failure
  [[ ! -e $PIDFILE ]]
  ls "$BATS_TEST_TMPDIR"/videos/Screenrecords/recording-*.mp4
  run grep -E '^(quickshell|notify-send) ' "$STUBS/calls"
  assert_line "$QS modeOff recording"
  assert_line --regexp '^notify-send -a Recording Recording saved '
}

@test "record signalled again while wf-recorder finishes: file kept, saved notification" {
  stub slurp '0,0 5x5'
  # Takes 0.5 s to finish the file after SIGINT, so the second TERM lands while it is still writing.
  echo 'exec env --default-signal=INT bash -c '"'"'trap "sleep 0.5; echo video >\"$1\"; exit 0" INT; while :; do sleep 0.05; done'"'"' _ "${@: -1}"' \
    >"$STUBS/wf-recorder.sh"
  "$SWAY/bin/record" area 3>&- &
  rec=$!
  for _ in $(seq 200); do
    grep -q recording.qml "$STUBS/calls" 2>/dev/null && break
    sleep 0.02
  done
  kill -TERM "$rec"
  sleep 0.1
  kill -TERM "$rec"
  for _ in $(seq 200); do
    kill -0 "$rec" 2>/dev/null || break
    sleep 0.02
  done
  ls "$BATS_TEST_TMPDIR"/videos/Screenrecords/recording-*.mp4
  run grep '^notify-send ' "$STUBS/calls"
  assert_output --regexp '^notify-send -a Recording Recording saved '
}
