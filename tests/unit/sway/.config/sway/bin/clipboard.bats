#!/usr/bin/env bats

setup() {
  load "${BATS_TEST_DIRNAME%/tests/unit/*}/tests/helpers/common"
  DB=$XDG_RUNTIME_DIR/cliphist/db
  # cliphist: list prints two entries, decode saves the line it got and prints the stored text.
  cat >"$STUBS/cliphist.sh" <<'SH'
case ${*: -1} in
  list) printf '7\tsecond copy\n3\tfirst copy\n' ;;
  decode) cat >"$STUBS/decode.stdin"; echo 'first copy' ;;
esac
SH
}

@test "watch: every copy stored in the session's runtime dir" {
  run "$SWAY/bin/clipboard" watch
  assert_success
  run calls
  assert_output "wl-paste --watch cliphist -db-path $DB store"
  [[ -d ${DB%/*} ]]
}

@test "pick: history in fuzzel, the chosen entry decoded back onto the clipboard" {
  printf '3\tfirst copy' >"$STUBS/fuzzel.out"
  run "$SWAY/bin/clipboard" pick
  assert_success
  assert_equal "$(cat "$STUBS/fuzzel.stdin")" $'7\tsecond copy\n3\tfirst copy'
  assert_equal "$(cat "$STUBS/decode.stdin")" $'3\tfirst copy'
  assert_equal "$(cat "$STUBS/wl-copy.stdin")" 'first copy'
  run calls
  assert_line --regexp '^fuzzel --dmenu .*--with-nth=2 --match-nth=2 '
}

@test "pick: Esc leaves the clipboard alone" {
  stub fuzzel --rc 1
  run "$SWAY/bin/clipboard" pick
  assert_success
  run calls
  refute_line --partial decode
  refute_line --partial wl-copy
}

@test "clear: history wiped" {
  run "$SWAY/bin/clipboard" clear
  assert_success
  run calls
  assert_output "cliphist -db-path $DB wipe"
}

@test "no argument: usage, exit 2" {
  run "$SWAY/bin/clipboard"
  assert_failure 2
  assert_output --partial 'clipboard pick'
}
