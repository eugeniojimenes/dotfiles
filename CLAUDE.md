# CLAUDE.md

## What this repo is

Personal dotfiles for an Arch/Omarchy-based system, managed with **GNU Stow**. Each top-level directory is a Stow module: `alacritty`, `bash`, `claude-code`, `git`, `hypr`, `lazyvim`, `mise`, `mpv`, `steam`, `tmux`.

Stow creates symlinks from each module's contents into `$HOME`, mirroring the directory structure. For example, `hypr/.config/hypr/hyprland.conf` becomes `~/.config/hypr/hyprland.conf`.

## Architecture: Omarchy layering pattern

**DO NOT EDIT OMARCHY DEFAULTS DIRECTLY.** The pattern throughout this repo is:

1. Omarchy defaults live in `~/.local/share/omarchy/default/` — sourced first, never edited.
2. User overrides live in this repo and are sourced/applied **after** the defaults, overwriting what needs to change.

This applies to:
- **Hyprland** (`hypr/.config/hypr/`): `hyprland.conf` sources Omarchy defaults, then sources the local override files (`input.conf`, `bindings.conf`, `monitors.conf`, etc.). Add customizations only to those override files.
- **Bash** (`bash/.bashrc`): sources `~/.local/share/omarchy/default/bash/rc`, then any local additions follow.

## Public repo — no secrets

**IMPORTANT:** This repository is **public**. Never add tokens, API keys, passwords, private SSH/GPG keys, or any personal credentials to any file here. If a config requires a secret (e.g. an env var), reference it by variable name only and set the actual value outside this repo.

## Commit style

Conventional Commits format enforced via commit template (`git/.gitmessage`):

```
<type>(<scope>): <short summary>
```

Types: `build|ci|docs|feat|fix|perf|refactor|style|test`

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

- **lazyvim** (`lazyvim/.config/nvim/`): LazyVim-based Neovim config. Plugin specs live in `lua/plugins/`. Lock file is `lazy-lock.json`.
- **mise** (`mise/.config/mise/config.toml`): Manages Node 22, Python 3.11, Ruby 3.4, Rust (latest), uv (latest). Run `mise install` after stowing.
- **tmux**: Requires TPM at `~/.config/tmux/plugins/tpm`. After stowing, install plugins inside tmux with `prefix + I` (installs tmux-resurrect, tmux-continuum, etc.).
- **claude-code** (`claude-code/.claude/CLAUDE.md`): Global Claude Code instructions (English learning feedback). Stow it to place at `~/.claude/CLAUDE.md`.

