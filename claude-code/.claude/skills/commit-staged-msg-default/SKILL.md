---
name: commit-staged-msg-default
description: "DEFAULT: Generate a commit message based on staged changes and repo conventions"
disable-model-invocation: true
allowed-tools: Bash, Read, Grep
---

## Staged Changes
!`git diff --cached`

## Recent Commits
!`git log --oneline -5`

Based on the staged changes and recent commit history above, generate a commit message following the repo's conventions:
- Format: `type(scope): description`
- Types: feat, fix, refactor, docs, test, chore
- Keep the subject line short and focused — capture the *purpose*, not an exhaustive list of every change
- If the diff touches many things, identify the main theme rather than enumerating each modification
- Present tense, lowercase, no period
- For small, focused diffs: subject line only
- For larger diffs (multiple files or conceptual changes): add a body using a bulleted list (` - `) to summarize the key changes. Do NOT insert a blank line between subject and body — lazygit adds that automatically

If `$ARGUMENTS` contains "commit", run `git commit` directly with a blank line between subject and body (standard git format). Do NOT copy to clipboard.
Otherwise (no arguments or anything else), copy the message to clipboard with `wl-copy` and do NOT run git commit.
