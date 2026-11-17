# Claude Code module

The `claude-code` module holds my global Claude Code configuration. Stow places it in `~/.claude/`. It is a different thing from the project files at the repo root (`AGENTS.md`, `CLAUDE.md`, `.claude/`, `harness/`), which only apply to sessions inside this repo.

## Contents

- `claude-code/.claude/CLAUDE.md`: global instructions, mainly English learning feedback.
- `claude-code/.claude/skills/`: custom skills.
- `claude-code/.claude/statusline-command.sh`: the status line.

The files in `claude-code/.claude/` are prompt text, not documentation. Its skills use the em dash as a list separator that the model reads, and rewording them would change the model's behaviour. They are left as they are and excluded from the em dash sweep.

## Linking file by file

Stow links this module file by file instead of linking the whole directory, because `~/.claude/` already holds runtime state that is not tracked: `plugins/`, `projects/`, `ide/`, `settings.local.json`. That state stays out of the repo because stow never links the directory itself. No `.gitignore` entry does that work.

Claude Code also treats `claude-code/.claude/` as a project settings directory when a session starts anywhere under `claude-code/`, and writes its `settings.json` there. `.gitignore` therefore ignores everything in that directory except the files the module ships. Claude Code also syncs the claude.ai account's skills into `skills/synced/`, which is ignored for the same reason.

## Why settings.json is not tracked

`settings.json` used to be tracked here. It was removed because both keys Claude Code writes into it leaked work details into this public repo. `extraKnownMarketplaces` holds internal git URLs. `enabledPlugins` names each plugin together with its marketplace, so a work marketplace shows up by name. The second one is easy to miss, since each value looks like a harmless boolean. The repo history was rewritten to remove the file, see [public-repo.md](public-repo.md).

The file is now machine-local, a real file at `~/.claude/settings.json` and not a symlink into this module. An encrypted copy lives in the private repo `~/.private` (`claude-settings.json.age`), so it survives a machine rebuild. `~/.private/private unlock` decrypts it straight to its live path. Run that before registering marketplaces again with `claude plugin marketplace add <url>`. The registration itself stays machine-local in `~/.claude/plugins/known_marketplaces.json`.

Settings that carry nothing private (model, status line, TUI options) could go into a tracked file later if there is ever a reason. Today one file is enough.

`dotfiles-doctor` flags `~/.claude/settings.json` when it is a symlink or missing.
