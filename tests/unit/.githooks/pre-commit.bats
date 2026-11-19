#!/usr/bin/env bats

# Temp repo carrying its own copy of the hook and bin/check, as a clone would. Real git and gitleaks: stubs off PATH.
setup() {
  load "${BATS_TEST_DIRNAME%/tests/unit/*}/tests/helpers/common"
  PATH=${PATH#"$REPO/tests/helpers/stubs:"}
  export GIT_CONFIG_GLOBAL=$BATS_TEST_TMPDIR/gitconfig GIT_CONFIG_NOSYSTEM=1
  git config --global user.name t && git config --global user.email t@t
  r=$BATS_TEST_TMPDIR/repo
  mkdir -p "$r/bin" "$r/.githooks" "$HOME/.private"
  cp "$REPO/bin/check" "$r/bin/" && cp "$REPO/.githooks/pre-commit" "$REPO/.githooks/commit-msg" "$r/.githooks/"
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
  [[ ${output,,} != *zorblax* ]]
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

@test "term staged, then cleaned in the work tree only: commit refused" {
  echo 'see zorblax' >notes && git add notes
  echo clean >notes
  run git commit -qm staged
  assert_failure
  assert_line 'notes:1'
  [ "$(git rev-list --count HEAD)" -eq 1 ]
}

@test "term only in an unstaged edit: commit allowed" {
  echo clean >notes && git add notes && git commit -qm notes
  echo 'see zorblax' >notes
  echo other >other && git add other
  run git commit -qm other
  assert_success
}

@test "term in a staged path: commit refused, path never shown" {
  echo hi >"Zorblax-notes" && git add "Zorblax-notes"
  run git commit -qm path
  assert_failure
  assert_output --partial 'forbidden term in a path, see: git ls-files | sed -n'
  [[ ${output,,} != *zorblax* ]]
}

@test "term in the commit message: commit refused, term never shown" {
  echo hello >notes && git add notes
  run git commit -qm 'fix for ZORBLAX'
  assert_failure
  assert_output --partial 'commit-msg: commit refused'
  [[ ${output,,} != *zorblax* ]]
  [ "$(git rev-list --count HEAD)" -eq 1 ]
}

@test "doc staged without its pair: warning, commit allowed" {
  mkdir -p docs/specs harness
  for f in docs/x.md docs/x.pt-br.md harness/README.md harness/README.pt-br.md docs/specs/y.md; do echo a >"$f"; done
  git add . && git commit -qm docs
  echo b >>docs/x.md && echo b >>harness/README.pt-br.md && echo b >>docs/specs/y.md && git add .
  run git commit -qm one-side
  assert_success
  assert_line 'warning: docs/x.md staged without docs/x.pt-br.md'
  assert_line 'warning: harness/README.pt-br.md staged without harness/README.md'
  refute_output --partial 'specs'
  echo c >>docs/x.md && echo c >>docs/x.pt-br.md && git add .
  run git commit -qm both
  assert_success
  refute_output --partial 'warning'
}
