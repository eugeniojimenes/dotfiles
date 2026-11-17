@AGENTS.md

# Claude Code

Everything above applies. Claude-only notes:

- Path-scoped rules: `.claude/rules` = link to `harness/rules` (frontmatter `paths:`). Skills: `.claude/skills` = link to `harness/skills`. New rule or skill goes in `harness/`, never straight into `.claude/`. Steps: `harness/README.md`.
- Rest of `.claude/` (`settings.local.json`) stays untracked: `.gitignore` allow-lists only the two links. Permission entries there name work tools.
- Global config of the owner = `claude-code/.claude/` (stow module). Project config = this file, `AGENTS.md`, `.claude/`, `harness/`.
