#!/usr/bin/env bats

setup() {
  load "${BATS_TEST_DIRNAME%/tests/unit/*}/tests/helpers/common"
  stub git --rc 128
  export CLAUDE_CONFIG_DIR=$BATS_TEST_TMPDIR/claude
  mkdir -p "$CLAUDE_CONFIG_DIR"
  input='{"workspace":{"current_dir":"/nowhere"},"model":{"display_name":"Opus"}}'
}

status() { "$REPO/claude-code/.claude/statusline-command.sh" <<<"$input"; }

@test "caveman badge for any mode name, upper-cased" {
  for mode in full caveman wenyan-ultra; do
    echo "$mode" >"$CLAUDE_CONFIG_DIR/.caveman-active"
    run status
    assert_output --partial "[CAVEMAN:${mode^^}]"
  done
}

@test "caveman mode sanitized: only a-z 0-9 -, 64 bytes at most" {
  printf 'Ultra;rm -rf\e[31m\n' >"$CLAUDE_CONFIG_DIR/.caveman-active"
  run status
  assert_output --partial '[CAVEMAN:ULTRARM-RF31M]'
  head -c 100 /dev/zero | tr '\0' a >"$CLAUDE_CONFIG_DIR/.caveman-active"
  run status
  assert_output --partial "[CAVEMAN:$(printf 'A%.0s' {1..64})]"
}

@test "caveman: no badge when the name sanitizes to nothing, or the flag is a symlink" {
  echo '!!!' >"$CLAUDE_CONFIG_DIR/.caveman-active"
  run status
  refute_output --partial CAVEMAN
  echo full >"$BATS_TEST_TMPDIR/target"
  ln -sf "$BATS_TEST_TMPDIR/target" "$CLAUDE_CONFIG_DIR/.caveman-active"
  run status
  refute_output --partial CAVEMAN
}

@test "ponytail badge only for lite, full, ultra" {
  for mode in lite full ultra FULL; do
    echo "$mode" >"$CLAUDE_CONFIG_DIR/.ponytail-active"
    run status
    assert_output --partial "[PONYTAIL:${mode^^}]"
  done
  echo evil >"$CLAUDE_CONFIG_DIR/.ponytail-active"
  run status
  refute_output --partial PONYTAIL
}

@test "flags read from ~/.claude when CLAUDE_CONFIG_DIR is unset" {
  unset CLAUDE_CONFIG_DIR
  mkdir -p "$HOME/.claude" && echo full >"$HOME/.claude/.caveman-active"
  run status
  assert_output --partial '[CAVEMAN:FULL]'
}

@test "no flags: directory and model only" {
  run status
  refute_output --partial CAVEMAN
  refute_output --partial PONYTAIL
  assert_output --partial Opus
}
