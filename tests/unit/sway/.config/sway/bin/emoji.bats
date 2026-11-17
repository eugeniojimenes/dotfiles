#!/usr/bin/env bats

setup() {
  load "${BATS_TEST_DIRNAME%/tests/unit/*}/tests/helpers/common"
  # Same layout as Unicode's emoji-test.txt: comments, groups, and every qualification status.
  export EMOJI_LIST=$BATS_TEST_TMPDIR/emoji-test.txt
  cat >"$EMOJI_LIST" <<'EOF2'
# emoji-test.txt
# group: Smileys & Emotion
1F600                                                  ; fully-qualified     # 😀 E1.0 grinning face
263A FE0F                                              ; fully-qualified     # ☺️ E0.6 smiling face
263A                                                   ; unqualified         # ☺ E0.6 smiling face
1F44D 1F3FD                                            ; fully-qualified     # 👍🏽 E1.0 thumbs up: medium skin tone
1F3FD                                                  ; component           # 🏽 E1.0 medium skin tone
EOF2
}

@test "list: fully-qualified emoji only, each as emoji and name" {
  stub fuzzel --rc 1
  run "$SWAY/bin/emoji"
  assert_success
  assert_equal "$(cat "$STUBS/fuzzel.stdin")" "$(printf '%s\n' '😀  grinning face' '☺️  smiling face' \
    '👍🏽  thumbs up: medium skin tone')"
}

@test "pick: emoji typed into the focused window and left on the clipboard" {
  printf '👍🏽  thumbs up: medium skin tone' >"$STUBS/fuzzel.out"
  run "$SWAY/bin/emoji"
  assert_success
  assert_equal "$(cat "$STUBS/wl-copy.stdin")" '👍🏽'
  run calls
  assert_line 'wtype 👍🏽'
}

@test "Esc: nothing typed or copied" {
  stub fuzzel --rc 1
  run "$SWAY/bin/emoji"
  assert_success
  run calls
  refute_line --partial wtype
  refute_line --partial wl-copy
}
