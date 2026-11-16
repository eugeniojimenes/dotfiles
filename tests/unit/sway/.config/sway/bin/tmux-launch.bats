#!/usr/bin/env bats

setup() { load "${BATS_TEST_DIRNAME%/tests/unit/*}/tests/helpers/common"; }

@test "client attached to the primary: new server on its own iso-<pid> socket" {
  echo '[[ $1 == list-clients ]] && { echo "/dev/pts/1: main"; exit 0; }' >"$STUBS/tmux.sh"
  run "$SWAY/bin/tmux-launch"
  run calls
  assert_line --index 0 'tmux list-clients'
  assert_line --index 1 --regexp '^tmux -L iso-[0-9]+ new-session$'
}

@test "nothing attached: attach to the primary" {
  run "$SWAY/bin/tmux-launch"
  run calls
  assert_output $'tmux list-clients\ntmux attach'
}

@test "nothing attached and no primary yet: start it" {
  echo '[[ $1 == attach ]] && exit 1' >"$STUBS/tmux.sh"
  run "$SWAY/bin/tmux-launch"
  run calls
  assert_output $'tmux list-clients\ntmux attach\ntmux new'
}
