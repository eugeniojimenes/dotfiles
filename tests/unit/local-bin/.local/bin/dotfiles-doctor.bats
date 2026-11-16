#!/usr/bin/env bats

# Stow state from `stow -n -v <mod>`, three signals (stow 2.4.1): rc 0 + nothing = linked, rc 0 + LINK lines = not
# linked, rc 1 + WARNING conflicts = real file where the symlink belongs. Simulation always prints its own warning.
setup() {
  load "${BATS_TEST_DIRNAME%/tests/unit/*}/tests/helpers/common"
  cat >"$STUBS/stow.sh" <<'SH'
[[ $1 == -n ]] || exit 0
echo 'WARNING: in simulation mode so not modifying filesystem.' >&2
case ${*: -1} in
  sway) echo 'LINK: .config/sway => ../dotfiles/sway/.config/sway' ;;
  tmux)
    echo 'WARNING! stowing tmux would cause conflicts:'
    echo '  * cannot stow dotfiles/tmux/.config/tmux/tmux.conf over existing target .config/tmux/tmux.conf'
    exit 1
    ;;
esac
SH
  doctor=$REPO/local-bin/.local/bin/dotfiles-doctor
}

@test "linked: rc 0 and only the simulation warning" {
  run "$doctor"
  assert_line '  ok    bash'
  assert_line '  ok    git'
}

@test "not linked: LINK lines, repair printed" {
  run "$doctor"
  assert_line '  FAIL  sway not stowed'
  assert_line '        fix: stow sway'
}

@test "conflict: rc 1, stow's message shown, resolved by hand" {
  run "$doctor"
  assert_line '  FAIL  tmux conflict'
  assert_line --partial 'over existing target .config/tmux/tmux.conf'
  assert_line --partial 'resolve by hand'
  assert_failure 1
}

@test "only dirs with dot-prefixed contents are modules" {
  run "$doctor"
  run calls
  assert_line 'stow -n -v sway'
  refute_line 'stow -n -v nixos'
  refute_line 'stow -n -v tests'
}

@test "--fix stows the unlinked module, never the conflicting one" {
  run "$doctor" --fix
  run calls
  assert_line 'stow sway'
  refute_line 'stow tmux'
}

@test "unknown argument: exit 2" {
  run "$doctor" --bogus
  assert_failure 2
}
