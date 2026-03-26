---
name: commit-staged-msg
description: Generate a commit message based on staged changes and repo conventions
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
- For larger diffs (multiple files or conceptual changes): add a body separated by a blank line, using a bulleted list (` - `) to summarize the key changes

Copy the message to clipboard with `wl-copy`. Do NOT run git commit.
