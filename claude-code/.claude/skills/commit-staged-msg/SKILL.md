---
name: commit-staged-msg
description: Generate a commit message based on staged changes and repo conventions
allowed-tools: Bash, Read, Grep
---

## Staged Changes
!`git diff --cached`

## Recent Commits
!`git log --oneline -5`

Based on the staged changes and recent commit history above, generate a commit message that follows the style and conventions visible in the recent commits.

Propose the message only and copy to clipboard with `wl-copy`. Do NOT run git commit.
