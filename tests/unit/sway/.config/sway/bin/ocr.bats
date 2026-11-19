#!/usr/bin/env bats

setup() { load "${BATS_TEST_DIRNAME%/tests/unit/*}/tests/helpers/common"; }

@test "area read: grim's PNG to tesseract (English and Portuguese), text on the clipboard, escaped preview" {
  stub slurp '10,20 300x40'
  stub tesseract $'\n Ação: 42 < 50 & more\nsecond line\n\n\f'
  run "$SWAY/bin/ocr"
  assert_success
  run calls
  assert_line 'grim -g 10,20 300x40 -'
  assert_line 'tesseract stdin stdout -l eng+por'
  assert_line --partial 'notify-send -a OCR -- Text copied  Ação: 42 &lt; 50 &amp; more'
  run cat "$STUBS/wl-copy.stdin"
  assert_output $' Ação: 42 < 50 & more\nsecond line'
}

@test "Esc in slurp: nothing read, nothing copied" {
  stub slurp --rc 1
  run "$SWAY/bin/ocr"
  assert_success
  run calls
  assert_output 'slurp '
}

@test "no text found: notification says so, clipboard untouched" {
  stub slurp '10,20 300x40'
  stub tesseract $'  \n\f'
  run "$SWAY/bin/ocr"
  assert_success
  run calls
  assert_line --partial 'notify-send -a OCR -- No text found'
  refute_line --partial wl-copy
}
