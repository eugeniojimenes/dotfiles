#!/usr/bin/env bats

setup() { load "${BATS_TEST_DIRNAME%/tests/unit/*}/tests/helpers/common"; }

@test "first run: session with btop and lazydocker, kill on pane exit, no resurrect keys" {
  echo '[[ $3 == has-session ]] && exit 1' >"$STUBS/tmux.sh"
  run "$SWAY/bin/sys-tools"
  run calls
  assert_line --index 0 'tmux -L sys-tools has-session -t sys-tools'
  assert_line --index 1 'tmux -L sys-tools new-session -d -s sys-tools -n btop btop ; new-window -d -n docker lazydocker ; set-hook -g pane-exited kill-server ; unbind C-s ; unbind C-r'
  assert_line --index 2 'tmux -L sys-tools attach -t sys-tools'
}

@test "already running: reattach only" {
  run "$SWAY/bin/sys-tools"
  run calls
  assert_output $'tmux -L sys-tools has-session -t sys-tools\ntmux -L sys-tools attach -t sys-tools'
}
