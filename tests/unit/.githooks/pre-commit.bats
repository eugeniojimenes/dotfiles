#!/usr/bin/env bats

# Temp repo carrying its own copy of the hook and bin/check, as a clone would. Real git and gitleaks: stubs off PATH.
setup() {
  load "${BATS_TEST_DIRNAME%/tests/unit/*}/tests/helpers/common"
  PATH=${PATH#"$REPO/tests/helpers/stubs:"}
  export GIT_CONFIG_GLOBAL=$BATS_TEST_TMPDIR/gitconfig GIT_CONFIG_NOSYSTEM=1
  git config --global user.name t && git config --global user.email t@t
  r=$BATS_TEST_TMPDIR/repo
  mkdir -p "$r/bin" "$r/.githooks" "$HOME/.private"
  cp "$REPO/bin/check" "$r/bin/" && cp "$REPO/.githooks/pre-commit" "$r/.githooks/"
  cd "$r" && git init -q && git config core.hooksPath .githooks
  git add . && git commit -qm base
  echo zorblax >"$HOME/.private/forbidden-terms"
}

# Built at runtime so this file holds nothing a scanner flags. Shape of a GitHub PAT, value made up.
fake_token() { printf 'ghp_%s' "$(printf 'a1B2c3D4e5%.0s' 1 2 3 4 | cut -c1-36)"; }

@test "staged secret: commit refused, value never shown" {
  tok=$(fake_token)
  echo "token=$tok" >conf && git add conf
  run git commit -qm leak
  assert_failure
  assert_output --partial 'conf'
  assert_output --partial 'commit refused'
  refute_output --partial "$tok"
  [ "$(git rev-list --count HEAD)" -eq 1 ]
}

@test "forbidden term: commit refused with file:line, never the term" {
  printf 'one\nsee Zorblax here\n' >notes && git add notes
  run git commit -qm term
  assert_failure
  assert_line 'notes:2'
  assert_output --partial 'git checkout <file>'
  refute_output --partial -i zorblax
  [ "$(git rev-list --count HEAD)" -eq 1 ]
}

@test "clean change: commit allowed" {
  echo hello >notes && git add notes
  run git commit -qm clean
  assert_success
  [ "$(git rev-list --count HEAD)" -eq 2 ]
}

@test "term list absent: terms skipped, commit allowed" {
  rm "$HOME/.private/forbidden-terms"
  echo zorblax >notes && git add notes
  run git commit -qm clean
  assert_success
}
