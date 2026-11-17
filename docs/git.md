# Git

`git/.gitconfig` sets colored output, `develop` as the default branch and a commit message template (`git/.gitmessage`) based on Conventional Commits.

## Work identity

The work identity is included conditionally by `[includeIf "gitdir:~/*-workspace/"]` at the bottom of `.gitconfig`. The pattern is a glob so that it matches the work checkout directory without naming the employer, which a literal path would do.

The include points at `~/.gitconfig-work`, a symlink into the private repo `~/.private` (payload `gitwork`, ciphertext `gitconfig-work.age`). The work email never lands in this repo.

A missing target is not an error: git skips an include whose path does not exist. On a machine where `~/.private` is not unlocked, git falls through to the personal `[user]` section. `settings.json` in the Claude Code module follows the same reasoning, see [claude-code.md](claude-code.md).

## Pre-commit hook

`.githooks/pre-commit` refuses a commit that would publish a secret or a forbidden term. See [public-repo.md](public-repo.md).
