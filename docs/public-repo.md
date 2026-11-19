# Public repo

This repo is public on GitHub, with a GitLab mirror. Two kinds of content must never reach it.

## No secrets

No tokens, API keys, passwords, private SSH or GPG keys, or any other personal credential, in any file. When a config needs a secret, for example through an environment variable, it references the variable by name and the value is set outside the repo. Values live in the private repo `~/.private`, encrypted with age. This repo only names that location and never describes what it holds.

## No employer details

This rule covers the company name, internal tool and repo names, internal paths, engine and service names, and marketplace names. It applies to code comments, docs, agent files, skills and examples alike.

A comment that explains why a workaround exists does not need a proper noun. "A work CLI hardcodes `asdf` calls" carries the same reasoning as a comment naming the tool.

Some files are kept out of the repo because tools write work details into them:

- `/.claude/` at the repo root is ignored, except the harness links `.claude/rules` and `.claude/skills`. Claude Code writes `settings.local.json` there for this project, and its permission entries name work tools verbatim.
- `claude-code/.claude/` ignores everything except the files the module ships. See [claude-code.md](claude-code.md), which also explains why `settings.json` is no longer tracked.
- The work git identity comes from a file in `~/.private`, see [git.md](git.md).

## Scans

Two scans look for leaks.

`bin/check terms` greps every tracked file and path for the terms in `~/.private/forbidden-terms`, a list kept encrypted in the private repo and never committed here. It prints only `file:line` for each hit in a file, and for a hit in a path only its row number in `git ls-files`, so the term itself never appears in a log. `bin/check terms --cached` scans the staged version instead of the work tree, and `bin/check terms --message FILE` scans a commit message. When the list is absent, as in CI or on a fresh clone, the scan is skipped with a notice and does not fail.

`gitleaks` looks for secrets. `bin/check static` (local and CI) scans the whole tree with `gitleaks dir`, and the pre-commit hook scans the staged changes with `gitleaks git --staged`. Values are redacted in the output.

The pre-commit hook in `.githooks/pre-commit` runs both scans on the staged changes before every commit and refuses the commit on a hit. The commit-msg hook in `.githooks/commit-msg` runs the term scan on the commit message, which is public too. The pre-push hook in `.githooks/pre-push` runs both scans on each commit about to be pushed (message, paths and added lines), because a rebase or a squash makes commits without running the other two. Git only runs it after the clone points at it, so enable it once per clone with `git config core.hooksPath .githooks`. `dotfiles-doctor --fix` does the same. The hook runs locally only. Its behaviour is listed in [specs/pre-commit.md](specs/pre-commit.md).

When the hook refuses a commit because a tool wrote into a stowed file, such as an installer appending a block to `~/.bashrc`, revert that file with `git checkout <file>`. Otherwise remove the value and keep it outside the repo. Skipping the hook with `git commit --no-verify` is possible, but only with the owner's explicit approval for that one commit.

### What the scans miss

- gitleaks only finds secrets that match its rules: known token formats and high-entropy strings assigned to names like `key` or `token`. A plain password or an unusual token format can pass.
- The term scan only finds the terms on the list. A new internal name has to be added to the list before the scan knows about it.
- The term scan does not run in CI or on a machine where `~/.private` is locked. `dotfiles-doctor` warns when the list is absent.
- The hook does not run when it is not enabled in the clone, or when a commit uses `--no-verify`.
- The commit-msg hook checks commit messages for terms only. gitleaks does not scan them.

## History rewrite of August 2026

On 2026-08-20 the employer name and internal tool names were found in 7 commits at the tip of `develop`, two days old. They were removed with `git filter-repo --replace-text`, together with `--invert-paths --path claude-code/.claude/settings.json`, and force-pushed to both remotes. Every commit from `a5c3a3a` onward got a new SHA. The 250 commits before it were not touched.

If it happens again, take a backup first, then rewrite only `develop` and force-push:

```sh
git bundle create ~/dotfiles-backup.bundle --all
git filter-repo --force --refs develop --replace-text expressions.txt
git push --force-with-lease origin develop
```

`--refs develop` keeps the rewrite off other branches, and it also stops filter-repo from removing the `origin` remote. `origin` has two push URLs, GitHub and the GitLab mirror, and both need the force push.

A force push erases nothing on its own. The old commits stay reachable by SHA on GitHub until GitHub runs garbage collection. When the leak matters, ask GitHub Support to purge the cached views.
