# pre-commit

Files: `.githooks/pre-commit` and `.githooks/commit-msg`, enabled per clone with `git config core.hooksPath .githooks` (`dotfiles-doctor --fix` sets it).

## Purpose

The repo is public. The hooks refuse a commit when a staged file, a staged path or the commit message holds a term from the private forbidden-terms list, or when the staged changes hold a secret. The term scan reads the index, so what gets checked is what the commit would publish. It runs on the local machine only. CI does not run it.

## Acceptance criteria

1. A staged secret (gitleaks rule hit) refuses the commit. The output names the file and never shows the value. Test: `tests/unit/.githooks/pre-commit.bats: "staged secret: commit refused, value never shown"`
2. A forbidden term in a staged file refuses the commit. The output gives `file:line` and the revert hint, never the term. Test: `tests/unit/.githooks/pre-commit.bats: "forbidden term: commit refused with file:line, never the term"`
3. A clean change commits. Test: `tests/unit/.githooks/pre-commit.bats: "clean change: commit allowed"`
4. Without `~/.private/forbidden-terms` the term scan is skipped and the commit goes through. Test: `tests/unit/.githooks/pre-commit.bats: "term list absent: terms skipped, commit allowed"`
5. Without `gitleaks` on `PATH` the hook runs the version pinned by `flake.lock` through `nix shell`. Test: manual
6. A term staged and then removed from the work tree only still refuses the commit. Test: `tests/unit/.githooks/pre-commit.bats: "term staged, then cleaned in the work tree only: commit refused"`
7. A term only in an unstaged edit does not block an unrelated commit. Test: `tests/unit/.githooks/pre-commit.bats: "term only in an unstaged edit: commit allowed"`
8. A term in a staged path refuses the commit. The output gives the path's row in `git ls-files`, never the path. Test: `tests/unit/.githooks/pre-commit.bats: "term in a staged path: commit refused, path never shown"`
9. A term in the commit message refuses the commit, never showing the term. Test: `tests/unit/.githooks/pre-commit.bats: "term in the commit message: commit refused, term never shown"`
