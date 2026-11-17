@AGENTS.md

# Claude Code

Everything above applies. Claude-only notes:

- `.claude/settings.local.json` (repo root) stays untracked: `/.claude/` ignored, permission entries name work tools.
- Global config of the owner = `claude-code/.claude/` (stow module). Project config = this file, `AGENTS.md`, `.claude/`.
