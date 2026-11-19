# pre-commit

Files: `.githooks/pre-commit`, `.githooks/commit-msg` and `.githooks/pre-push`, enabled per clone with `git config core.hooksPath .githooks` (`dotfiles-doctor --fix` sets it).

## Purpose

The repo is public. The hooks refuse a commit when a staged file, a staged path or the commit message holds a term from the private forbidden-terms list, or when the staged changes hold a secret. The term scan reads the index, so what gets checked is what the commit would publish. It runs on the local machine only. CI does not run it. It also warns, without refusing, when a human doc is staged without its pair in the other language. The pre-push hook runs the same scans on every commit about to be pushed, its message, paths and added lines, because commits made by a rebase or a squash never went through the other two hooks.

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
10. A human doc staged without its pair (`docs/x.md` without `docs/x.pt-br.md`, either way, README and `harness/README` too) prints a warning naming the missing pair, and the commit goes through. Specs and other files never warn. Test: `tests/unit/.githooks/pre-commit.bats: "doc staged without its pair: warning, commit allowed"`
11. A push of clean commits goes through. Test: `tests/unit/.githooks/pre-push.bats: "push: clean commits go through"`
12. A term added by one of the commits to push refuses the push, even when a later commit removes it. The output names the commit and the file, never the term. Test: `tests/unit/.githooks/pre-push.bats: "push: a term added in one commit and removed in the next, refused, the term never shown"`
13. A term in the message or in a path of a commit to push refuses the push. The output names the commit only, never the term or the path. Test: `tests/unit/.githooks/pre-push.bats: "push: a term in a commit message or a path, refused, the term never shown"`
14. A secret in any commit to push refuses the push, even when a later commit removes it, and the value is never shown. Test: `tests/unit/.githooks/pre-push.bats: "push: a secret in a commit, removed later, refused, the value never shown"`
15. Only the commits the remote does not have yet are scanned, so history already published never blocks a push. Test: `tests/unit/.githooks/pre-push.bats: "push: only commits the remote lacks are scanned"`
16. Without `~/.private/forbidden-terms` the term scan is skipped and the push goes through. Test: `tests/unit/.githooks/pre-push.bats: "push: term list absent, terms skipped, the push goes through"`
