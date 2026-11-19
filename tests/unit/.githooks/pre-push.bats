#!/usr/bin/env bats

# Temp repo with its own copy of the hooks and bin/check, pushing to a bare repo. Real git and gitleaks: stubs off PATH.
# Bad commits are made with hooks off, as a rebase or squash makes them.
setup() {
  load "${BATS_TEST_DIRNAME%/tests/unit/*}/tests/helpers/common"
  PATH=${PATH#"$REPO/tests/helpers/stubs:"}
  export GIT_CONFIG_GLOBAL=$BATS_TEST_TMPDIR/gitconfig GIT_CONFIG_NOSYSTEM=1
  git config --global user.name t && git config --global user.email t@t
  git config --global init.defaultBranch main
  git init -q --bare "$BATS_TEST_TMPDIR/remote.git"
  r=$BATS_TEST_TMPDIR/repo
  mkdir -p "$r/bin" "$r/.githooks" "$HOME/.private"
  cp "$REPO/bin/check" "$r/bin/" && cp "$REPO/.githooks/pre-push" "$r/.githooks/"
  cd "$r" && git init -q && git config core.hooksPath .githooks
  git remote add origin "$BATS_TEST_TMPDIR/remote.git"
  git add . && git commit -qm base
  echo zorblax >"$HOME/.private/forbidden-terms"
}

# Commit without hooks, as a rewrite would.
raw_commit() { git -c core.hooksPath=/dev/null commit -qm "$1"; }

# Built at runtime so this file holds nothing a scanner flags. Shape of a GitHub PAT, value made up.
fake_token() { printf 'ghp_%s' "$(printf 'a1B2c3D4e5%.0s' 1 2 3 4 | cut -c1-36)"; }

@test "push: clean commits go through" {
  echo hello >notes && git add notes && raw_commit notes
  run git push -q origin main
  assert_success
}

@test "push: a term added in one commit and removed in the next, refused, the term never shown" {
  echo 'see Zorblax' >notes && git add notes && raw_commit add
  echo clean >notes && git add notes && raw_commit clean
  run git push -q origin main
  assert_failure
  assert_output --regexp 'commit [0-9a-f]{12}: notes adds a forbidden term'
  assert_output --partial 'push refused'
  [[ ${output,,} != *zorblax* ]]
  run git ls-remote origin
  assert_output ''
}

@test "push: a term in a commit message or a path, refused, the term never shown" {
  echo hi >notes && git add notes && raw_commit 'fix for ZORBLAX'
  run git push -q origin main
  assert_failure
  assert_output --regexp 'commit [0-9a-f]{12}: message holds a forbidden term'
  git -c core.hooksPath=/dev/null commit -q --amend -m clean
  echo hi >Zorblax-notes && git add Zorblax-notes && raw_commit path
  run git push -q origin main
  assert_failure
  assert_output --regexp 'commit [0-9a-f]{12}: a path holds a forbidden term'
  [[ ${output,,} != *zorblax* ]]
}

@test "push: a secret in a commit, removed later, refused, the value never shown" {
  tok=$(fake_token)
  echo "token=$tok" >conf && git add conf && raw_commit leak
  git rm -q conf && raw_commit gone
  run git push -q origin main
  assert_failure
  assert_output --partial 'push refused'
  refute_output --partial "$tok"
}

@test "push: only commits the remote lacks are scanned" {
  echo 'see zorblax' >notes && git add notes && raw_commit old
  git -c core.hooksPath=/dev/null push -q origin main
  echo clean >notes && git add notes && raw_commit new
  run git push -q origin main
  assert_success
}

@test "push: term list absent, terms skipped, the push goes through" {
  rm "$HOME/.private/forbidden-terms"
  echo zorblax >notes && git add notes && raw_commit notes
  run git push -q origin main
  assert_success
}
