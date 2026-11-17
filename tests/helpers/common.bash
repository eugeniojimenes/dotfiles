#!/usr/bin/env bash
# Shared setup for tests/unit: isolated HOME and XDG dirs, stubbed commands first on PATH (see stubs/_stub).
# Each test file: setup() { load "${BATS_TEST_DIRNAME%/tests/unit/*}/tests/helpers/common"; }

REPO=${BATS_TEST_DIRNAME%/tests/unit/*}
bats_load_library bats-support
bats_load_library bats-assert

export HOME=$BATS_TEST_TMPDIR/home
export XDG_STATE_HOME=$HOME/.local/state
export XDG_RUNTIME_DIR=$BATS_TEST_TMPDIR/run
export STUBS=$BATS_TEST_TMPDIR/stubs
export PATH=$REPO/tests/helpers/stubs:$PATH
unset XDG_CONFIG_HOME XDG_DATA_HOME CLAUDE_CONFIG_DIR WLR_DRM_DEVICES
mkdir -p "$HOME/.config" "$XDG_RUNTIME_DIR" "$STUBS"

SWAY=$REPO/sway/.config/sway

# Scripts reach their siblings through ~/.config/sway, as stowed.
link_sway() { ln -s "$SWAY" "$HOME/.config/sway"; }

# Canned behaviour for one stub: stub NAME [--rc N] [OUTPUT]. Custom logic: write $STUBS/NAME.sh.
stub() {
  local name=$1
  shift
  if [[ ${1-} == --rc ]]; then
    echo "$2" >"$STUBS/$name.rc"
    shift 2
  fi
  if (($#)); then printf '%s\n' "$1" >"$STUBS/$name.out"; fi
}

# Every stub call so far, one per line: "name arg...".
calls() { cat "$STUBS/calls" 2>/dev/null; }
