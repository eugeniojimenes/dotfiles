#!/usr/bin/env bats

setup() {
  load "${BATS_TEST_DIRNAME%/tests/unit/*}/tests/helpers/common"
  # nmcli: connectivity state from $STUBS/state (default full), monitor prints $STUBS/monitor and exits.
  cat >"$STUBS/nmcli.sh" <<'SH'
case $1 in
  networking) cat "$STUBS/state" 2>/dev/null || echo full ;;
  monitor) cat "$STUBS/monitor" 2>/dev/null ;;
esac
SH
}

@test "watch: login page reported, notification with Open login button" {
  printf '%s\n' "Connectivity is now 'limited'" "Connectivity is now 'portal'" "Connectivity is now 'full'" \
    >"$STUBS/monitor"
  run "$SWAY/bin/portal" watch
  assert_success
  run grep -c '^notify-send ' "$STUBS/calls"
  assert_output 1
  run calls
  assert_line --regexp '^notify-send .*--action=login=Open login .*Wi-Fi needs a login'
}

@test "watch: already behind a login page at start, notification right away" {
  echo portal >"$STUBS/state"
  run "$SWAY/bin/portal" watch
  assert_success
  run calls
  assert_line --regexp '^notify-send .*Wi-Fi needs a login'
}

@test "watch: Open login clicked, login window opens" {
  echo portal >"$STUBS/state"
  stub notify-send login
  run "$SWAY/bin/portal" watch
  assert_success
  run calls
  assert_line --regexp '^brave '
}

@test "watch: notification dismissed, no window" {
  echo portal >"$STUBS/state"
  run "$SWAY/bin/portal" watch
  assert_success
  run calls
  refute_line --regexp '^brave '
}

@test "login: throwaway profile, Aruba login names mapped, plain HTTP page" {
  run "$SWAY/bin/portal" login
  assert_success
  run calls
  assert_line "brave --user-data-dir=$XDG_RUNTIME_DIR/portal-login --no-first-run --new-window\
 --host-resolver-rules=MAP securelogin.hpe.com 1.1.1.1, MAP securelogin.arubanetworks.com 1.1.1.1 http://neverssl.com/"
}

@test "no argument: usage, exit 2" {
  run "$SWAY/bin/portal"
  assert_failure 2
  assert_output --partial 'portal watch'
}
