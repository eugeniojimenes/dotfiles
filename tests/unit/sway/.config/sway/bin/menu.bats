#!/usr/bin/env bats

setup() {
  load "${BATS_TEST_DIRNAME%/tests/unit/*}/tests/helpers/common"
  # No .desktop files: the root menu lists only its own entries.
  export XDG_DATA_HOME=$BATS_TEST_TMPDIR/data XDG_DATA_DIRS=$BATS_TEST_TMPDIR/data
}

# fuzzel answers per call: $1 for the first menu shown, $2 for the second... "@Label" = the action of the line with that
# label in what fuzzel was given; "rc=N" = exit N with no output.
answers() {
  printf 'answers=(%s)\n' "$(printf '%q ' "$@")" >"$STUBS/fuzzel.sh"
  cat >>"$STUBS/fuzzel.sh" <<'EOF'
n=$(grep -c '^fuzzel ' "$STUBS/calls")
a=${answers[n - 1]-}
case $a in
  rc=*) exit "${a#rc=}" ;;
  @*) awk -F'\t' -v l="${a#@}" 'index($1, l) { print $2; exit }' "$STUBS/fuzzel.stdin" ;;
  *) printf '%s' "$a" ;;
esac
EOF
}

launched() { calls | sed -n 's/^setsid -f sh -c //p'; }

@test "Setup > Bluetooth runs the bluetooth panel toggle" {
  answers @Setup @Bluetooth
  run "$SWAY/bin/menu"
  assert_success
  [[ $(launched) == "$HOME/.config/sway/panels/bluetooth/toggle" ]]
}

@test "Esc at the top: exit 0, nothing launched" {
  answers rc=1
  run "$SWAY/bin/menu"
  assert_success
  [[ -z $(launched) ]]
}

@test "Left in a submenu: back to the root menu" {
  answers @Setup rc=10 rc=1
  run "$SWAY/bin/menu"
  assert_success
  [[ $(calls | grep -c '^fuzzel ') == 3 ]]
  [[ -z $(launched) ]]
}

@test "Toggle > Stay awake and Night light run their toggles" {
  answers @Toggle '@Stay awake'
  run "$SWAY/bin/menu"
  assert_success
  [[ $(launched) == "$HOME/.config/sway/bin/idle toggle" ]]
  : >"$STUBS/calls"
  answers @Toggle '@Night light'
  run "$SWAY/bin/menu"
  [[ $(launched) == "$HOME/.config/sway/bin/nightlight toggle" ]]
}

@test "Toggle > Power profile: current one checked, pick sets it" {
  stub powerprofilesctl balanced
  answers @Toggle '@Power profile' @performance
  run "$SWAY/bin/menu"
  assert_success
  grep -q $'󰄬  balanced\t' "$STUBS/fuzzel.stdin"
  [[ $(launched) == 'powerprofilesctl set performance' ]]
}

@test "root: Clipboard history and Emoji run their scripts, System clears the history" {
  answers '@Clipboard history'
  run "$SWAY/bin/menu"
  [[ $(launched) == "$HOME/.config/sway/bin/clipboard pick" ]]
  : >"$STUBS/calls"
  answers @Emoji
  run "$SWAY/bin/menu"
  [[ $(launched) == "$HOME/.config/sway/bin/emoji" ]]
  : >"$STUBS/calls"
  answers @System '@Clear clipboard history'
  run "$SWAY/bin/menu"
  [[ $(launched) == "$HOME/.config/sway/bin/clipboard clear" ]]
}
