# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

Personal dotfiles for an Arch/Omarchy-based system, managed with **GNU Stow**. Each top-level directory is a Stow module: `alacritty`, `bash`, `claude-code`, `git`, `hypr`, `lazyvim`, `local-bin`, `mise`, `mpv`, `omp`, `opencode`, `rubocop`, `steam`, `tmux`.

Stow creates symlinks from each module's contents into `$HOME`, mirroring the directory structure. For example, `hypr/.config/hypr/hyprland.lua` becomes `~/.config/hypr/hyprland.lua`.

## Common commands

```sh
# Apply a module (run from repo root ~/dotfiles)
stow <module>          # e.g. stow hypr

# Remove a module's symlinks
stow -D <module>       # e.g. stow -D hypr

# After stowing mise, install declared tool versions
mise install
```

## Architecture: Omarchy layering pattern

**DO NOT EDIT OMARCHY DEFAULTS DIRECTLY.** The pattern throughout this repo is:

1. Omarchy defaults live in `$OMARCHY_PATH/default/` (`/usr/share/omarchy` since Omarchy 4; `~/.local/share/omarchy` is now a symlink to it) — loaded first, never edited.
2. User overrides live in this repo and are sourced/applied **after** the defaults, overwriting what needs to change.

This applies to:
- **Hyprland** (`hypr/.config/hypr/`): **Lua since Omarchy 4** — Hyprland 0.56 loads `hyprland.lua` in preference to `hyprland.conf`, so the old hyprlang files are dead and were removed. `hyprland.lua` bootstraps Omarchy's Lua module path, `require`s `default.hypr.omarchy`, then `require`s the local overrides: `monitors.lua`, `input.lua`, `bindings.lua`, `looknfeel.lua`, `autostart.lua`. The rest — `hypridle.conf`, `hyprlock.conf`, `hyprsunset.conf`, `xdph.conf` — are still hyprlang standalone configs (Omarchy ships no default to layer), edited in full. Add customizations only to these files.
  - Two APIs: `hl.*` is raw Hyprland (`hl.config`, `hl.monitor`, `hl.env`, `hl.bind`, `hl.unbind`, `hl.dsp.*`); `o.*` is Omarchy's sugar (`o.bind`, `o.window`, `o.launch_on_start`) defined in `$OMARCHY_PATH/default/hypr/helpers.lua`. Stubs for the editor live at `/usr/share/hypr/stubs` (wired up by `.luarc.json`).
  - Overrides load *after* the defaults, but a keybind is not an override — a second `o.bind` on a claimed key adds a duplicate. **`hl.unbind("...")` first, then rebind.**
- **Bash** (`bash/.bashrc`): resolves `OMARCHY_PATH` (honouring `/etc/omarchy.conf`), then sources `$OMARCHY_PATH/default/bash/rc`; local additions follow.

**LazyVim is the exception** — it does not source-then-override. Omarchy's Neovim config ships as a separate pacman package (`omarchy-nvim`, installed to `/usr/share/omarchy-nvim/config/`), and there is nothing to `source` from Lua. The files that came from Omarchy are **vendored as real files** in `lazyvim/.config/nvim/`: `lua/plugins/all-omarchy-themes.lua` and `plugin/after/transparency.lua`. Refresh them by diffing against `/usr/share/omarchy-nvim/config/`, never by symlinking to it (root-owned, and the path has already moved once).

**Never point a file inside a stowed module at a path outside the repo.** Modules are stowed at the directory level, so Omarchy's migrations (`sed -i`, `cp` against `~/.config/...`) resolve through the directory symlink and edit this repo's real files — which is intended, and shows up in `git status` after an update. A *file*-level symlink escaping the repo breaks that: migrations are guarded by `[[ -f ... ]]`, which is false for a dangling link, so the update is skipped silently and machines drift. `lua/plugins/theme.lua` shows the alternative — resolve the path at runtime.

## Public repo — no secrets

**IMPORTANT:** This repository is **public**. Never add tokens, API keys, passwords, private SSH/GPG keys, or any personal credentials to any file here. If a config requires a secret (e.g. an env var), reference it by variable name only and set the actual value outside this repo.

## Commit style

The default branch is `develop` (not `main`/`master`).

Conventional Commits format enforced via commit template (`git/.gitmessage`):

```
<type>(<scope>): <short summary>
```

Types: `build|chore|ci|docs|feat|fix|perf|refactor|style|test`

Examples from this repo's history:
```
feat(hypr): change browser keybind to brave
feat(lazyvim): rust develop
fix(lazyvim): treesitter identation bug in ruby
refactor(rubocop): consolidate into stow module and update configs
feat(tmux): migrate to XDG config path and add session persistence
docs(readme): update tmux install instructions for XDG path
```

## Key module notes

- **alacritty**: not the Omarchy 4 default — Quattro ships **foot** and installs `~/.local/share/applications/foot.desktop`, which `xdg-terminal-exec` then picks. Every Omarchy launcher (`omarchy-launch-terminal`, `omarchy-launch-tui`) goes through it, so the whole session silently moves to foot's `~/.config/foot/foot.ini` (font size 9). Reclaim it with `omarchy-default-terminal alacritty`, which writes `~/.config/xdg-terminals.list`. That file is machine-local and untracked; re-run the command on a fresh machine. See `TERMINAL-CHOICE.md` for why Alacritty.
- **lazyvim** (`lazyvim/.config/nvim/`): LazyVim-based Neovim config. Plugin specs live in `lua/plugins/`. Lock file is `lazy-lock.json`.
- **mise** (`mise/.config/mise/config.toml`): Manages Node 22, Python 3.11, Ruby 3.4, Rust (latest), uv (latest). Run `mise install` after stowing.
- **local-bin** (`local-bin/.local/bin/`): Personal scripts on `PATH`. Currently just `asdf`, a shim that forwards to mise because a work CLI hardcodes `asdf` calls and has no mise backend (see `NVIM-RUBY-LSP-FIX.md`). This is the one module stow links **file by file** rather than as a directory: `~/.local/bin` already holds unrelated real files, including the 115 MB `mise` binary and the tool shims mise generates, none of which belong in this repo. That is the opposite of the tmux rule above, and deliberate — nothing runs migrations against `~/.local/bin`, so there is no `sed -i` to resolve through a directory link.
- **tmux**: Requires TPM at `~/.local/share/tmux/plugins/tpm` — *not* under `~/.config/tmux`, which must hold only `tmux.conf` so stow can link it as a directory (see the migration warning above; this module drifted out of the repo once because of a file-level link). The path is set via `TMUX_PLUGIN_MANAGER_PATH` at the bottom of `tmux.conf`. After stowing, install plugins inside tmux with `prefix + I`. Reboot persistence comes from tmux-resurrect + tmux-continuum. Continuum tests for a second tmux server **only at plugin load**, and when it finds one it installs no save hook and skips auto-restore — so the isolated servers spawned by `hypr/.config/hypr/tmux-launch.sh` opt themselves out, and the primary (always first to start) keeps saving. No `%if` gating in `tmux.conf` is needed for this; don't re-add it. Old snapshots need no external cleanup either — resurrect's `remove_old_backups()` runs on every save, honouring `@resurrect-delete-backup-after` and always keeping the 5 newest.
- **claude-code** (`claude-code/.claude/`): Global Claude Code config — `CLAUDE.md` (English learning feedback instructions), `settings.json`, custom skills (`skills/`), and `statusline-command.sh`. Stow it to place at `~/.claude/`. Machine-local state (`settings.local.json`, per-project memory) is gitignored and stays out of the repo.

