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

@test "shared parent linked into the repo: flagged" {
  rmdir "$HOME/.config"
  ln -s "$REPO/sway/.config" "$HOME/.config"
  run "$doctor"
  assert_line '  FAIL  ~/.config is a link into the repo, app data written there lands in git status'
}

@test "~/.claude/settings.json: real file ok, symlink or absent flagged" {
  run "$doctor"
  assert_line '  FAIL  ~/.claude/settings.json absent'
  mkdir -p "$HOME/.claude"
  echo '{}' >"$BATS_TEST_TMPDIR/settings.json"
  ln -s "$BATS_TEST_TMPDIR/settings.json" "$HOME/.claude/settings.json"
  run "$doctor"
  assert_line --partial 'FAIL  ~/.claude/settings.json is a symlink'
  rm "$HOME/.claude/settings.json" && echo '{}' >"$HOME/.claude/settings.json"
  run "$doctor"
  assert_line '  ok    ~/.claude/settings.json'
}

@test "images must open in imv-dir" {
  run "$doctor"
  assert_line --partial 'not opening in imv-dir'
  assert_line '        fix: xdg-mime default imv-dir.desktop image/png image/jpeg image/gif image/webp image/bmp image/tiff'
  stub xdg-mime imv-dir.desktop
  run "$doctor"
  assert_line '  ok    images open in imv-dir'
}

@test "cedilla: checked on the effective compose table" {
  stub xkbcli '<dead_acute> <c> :  "ç" ccedilla'
  run "$doctor"
  assert_line "  ok    cedilla: ' + c types ç"
  stub xkbcli '<dead_acute> <c> :  "ć" cacute'
  run "$doctor"
  assert_line "  FAIL  cedilla: ' + c types ć"
  stub xkbcli ''
  rm "$STUBS/xkbcli.out"
  run "$doctor"
  assert_line --partial 'warn  cedilla: xkbcli unavailable'
}

@test "run through a symlink (stowed into ~/.local/bin): still finds the repo" {
  mkdir -p "$HOME/.local/bin"
  ln -s "$doctor" "$HOME/.local/bin/dotfiles-doctor"
  run "$HOME/.local/bin/dotfiles-doctor"
  run calls
  assert_line 'stow -n -v sway'
}

@test "pre-commit hook: unset flagged, --fix sets it" {
  run "$doctor"
  assert_line '  FAIL  pre-commit hook not enabled, a secret or forbidden term could reach a commit'
  assert_line "        fix: git -C $REPO config core.hooksPath .githooks"
  run "$doctor" --fix
  run calls
  assert_line "git -C $REPO config core.hooksPath .githooks"
  stub git .githooks
  run "$doctor"
  assert_line '  ok    pre-commit hook enabled'
}

@test "forbidden-terms list: absent warns without counting as a problem, present ok, content never shown" {
  stub git .githooks
  run "$doctor"
  assert_line '  warn  ~/.private/forbidden-terms absent, term scan skipped by bin/check and the hook'
  absent=$(grep 'problem(s)' <<<"$output")
  mkdir -p "$HOME/.private" && echo zorblax >"$HOME/.private/forbidden-terms"
  run "$doctor"
  assert_line '  ok    forbidden-terms list'
  refute_output --partial zorblax
  [ "$(grep 'problem(s)' <<<"$output")" = "$absent" ]
}

@test "uosc: found in the mpv wrapper; an installer copy in ~/.config/mpv/scripts flagged, not removed" {
  mkdir -p "$BATS_TEST_TMPDIR/mpvbin" "$HOME/.config/mpv/scripts/uosc"
  printf 'exec mpv --script=/nix/store/x-uosc-5.12.0/share/mpv/scripts/uosc\n' >"$BATS_TEST_TMPDIR/mpvbin/mpv"
  chmod +x "$BATS_TEST_TMPDIR/mpvbin/mpv"
  PATH=$BATS_TEST_TMPDIR/mpvbin:$PATH run "$doctor" --fix
  assert_line '  ok    uosc (mpv wrapper)'
  assert_line '  FAIL  second uosc in ~/.config/mpv/scripts, loads on top of the packaged one'
  [[ -d $HOME/.config/mpv/scripts/uosc ]]
}

@test "uosc: mpv without it, rebuild suggested" {
  # An mpv without uosc first on PATH: the host's own mpv has it.
  mkdir -p "$BATS_TEST_TMPDIR/mpvbin"
  printf 'exec /nix/store/x-mpv-0.40/bin/mpv\n' >"$BATS_TEST_TMPDIR/mpvbin/mpv"
  chmod +x "$BATS_TEST_TMPDIR/mpvbin/mpv"
  PATH=$BATS_TEST_TMPDIR/mpvbin:$PATH run "$doctor"
  assert_line '  FAIL  mpv runs without uosc'
  assert_line '        fix: sudo nixos-rebuild switch --flake ~/dotfiles'
}

@test "tmux plugins: every run-shell of tmux.conf present under the plugin dir" {
  mkdir -p "$BATS_TEST_TMPDIR/plugins/sensible" "$BATS_TEST_TMPDIR/plugins/resurrect"
  touch "$BATS_TEST_TMPDIR/plugins/sensible/sensible.tmux" "$BATS_TEST_TMPDIR/plugins/resurrect/resurrect.tmux"
  TMUX_PLUGINS=$BATS_TEST_TMPDIR/plugins run "$doctor"
  assert_line '  ok    tmux plugins'
}

@test "tmux plugins: one missing, named, rebuild suggested" {
  mkdir -p "$BATS_TEST_TMPDIR/plugins/sensible"
  touch "$BATS_TEST_TMPDIR/plugins/sensible/sensible.tmux"
  TMUX_PLUGINS=$BATS_TEST_TMPDIR/plugins run "$doctor"
  assert_line '  FAIL  tmux plugins missing: resurrect'
  assert_line '        fix: sudo nixos-rebuild switch --flake ~/dotfiles'
}
