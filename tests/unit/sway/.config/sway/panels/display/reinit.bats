#!/usr/bin/env bats
# display/reinit: after resume, disable + enable every active external output. Built-in panel never touched.

setup() {
  load "${BATS_TEST_DIRNAME%/tests/unit/*}/tests/helpers/common"
  # Its `sleep 1` waits for the outputs to settle: stubbed for this file only, so no test waits for real.
  mkdir -p "$BATS_TEST_TMPDIR/bin" && ln -s "$REPO/tests/helpers/stubs/_stub" "$BATS_TEST_TMPDIR/bin/sleep"
  PATH=$BATS_TEST_TMPDIR/bin:$PATH
  cat >"$STUBS/swaymsg.sh" <<'SH'
[[ $1 == -t ]] && cat <<'JSON' && exit 0
[{"name": "eDP-1", "active": true}, {"name": "HDMI-A-1", "active": true},
 {"name": "DP-1", "active": false}, {"name": "DP-5", "active": true}]
JSON
SH
}

@test "active external outputs: disable then enable each, built-in panel and inactive ones untouched" {
  run "$SWAY/panels/display/reinit"
  assert_success
  run grep '^swaymsg -q' "$STUBS/calls"
  assert_output "$(printf '%s\n' 'swaymsg -q output HDMI-A-1 disable' 'swaymsg -q output HDMI-A-1 enable' \
    'swaymsg -q output DP-5 disable' 'swaymsg -q output DP-5 enable')"
}

@test "only the built-in panel: no output command" {
  echo '[[ $1 == -t ]] && echo '"'"'[{"name": "eDP-1", "active": true}]'"'"' && exit 0' >"$STUBS/swaymsg.sh"
  run "$SWAY/panels/display/reinit"
  assert_success
  run grep -c '^swaymsg -q' "$STUBS/calls"
  assert_output 0
}
