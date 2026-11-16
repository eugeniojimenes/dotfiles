# pre-commit

Files: `.githooks/pre-commit`, enabled per clone with `git config core.hooksPath .githooks` (`dotfiles-doctor --fix` sets it).

## Purpose

The repo is public. The hook refuses a commit when a tracked file holds a term from the private forbidden-terms list or when the staged changes hold a secret. It runs on the local machine only. CI does not run it.

## Acceptance criteria

1. A staged secret (gitleaks rule hit) refuses the commit. The output names the file and never shows the value. Test: `tests/unit/.githooks/pre-commit.bats: "staged secret: commit refused, value never shown"`
2. A forbidden term in a tracked file refuses the commit. The output gives `file:line` and the revert hint, never the term. Test: `tests/unit/.githooks/pre-commit.bats: "forbidden term: commit refused with file:line, never the term"`
3. A clean change commits. Test: `tests/unit/.githooks/pre-commit.bats: "clean change: commit allowed"`
4. Without `~/.private/forbidden-terms` the term scan is skipped and the commit goes through. Test: `tests/unit/.githooks/pre-commit.bats: "term list absent: terms skipped, commit allowed"`
5. Without `gitleaks` on `PATH` the hook runs the version pinned by `flake.lock` through `nix shell`. Test: manual
