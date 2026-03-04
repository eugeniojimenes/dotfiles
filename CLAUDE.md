# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

Personal dotfiles for an Arch/Omarchy-based system, managed with **GNU Stow**. Each top-level directory is a Stow module: `alacritty`, `bash`, `claude-code`, `git`, `hypr`, `lazyvim`, `mise`, `mpv`, `steam`, `tmux`.

Stow creates symlinks from each module's contents into `$HOME`, mirroring the directory structure. For example, `hypr/.config/hypr/hyprland.conf` becomes `~/.config/hypr/hyprland.conf`.

## Applying / removing modules

```sh
cd ~/dotfiles

# Apply a module (creates symlinks in $HOME)
stow <module>

# Remove symlinks for a module
stow -D <module>
```

## Architecture: Omarchy layering pattern

**Do not edit Omarchy defaults directly.** The pattern throughout this repo is:

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

## Key module notes

- **lazyvim** (`lazyvim/.config/nvim/`): LazyVim-based Neovim config. Plugin specs live in `lua/plugins/`. Lock file is `lazy-lock.json`.
- **mise** (`mise/.config/mise/config.toml`): Manages Node 22, Python 3.11, Ruby 3.4, Rust (latest), uv (latest). Run `mise install` after stowing.
- **tmux**: Requires TPM at `~/.tmux/plugins/tpm` and Catppuccin theme at `~/.tmux/plugins/catppuccin` (pinned to v2.1.3).
- **claude-code** (`claude-code/.claude/CLAUDE.md`): Global Claude Code instructions (English learning feedback). Stow it to place at `~/.claude/CLAUDE.md`.

## Hyprland config files (hypr module)

| File | Purpose |
|---|---|
| `hyprland.conf` | Entry point — sources defaults and local overrides |
| `input.conf` | Keyboard layout, mouse/touchpad settings |
| `bindings.conf` | Custom keybindings |
| `monitors.conf` | Monitor layout |
| `looknfeel.conf` | Gaps, borders, animations |
| `autostart.conf` | Autostart programs |
| `hypridle.conf` | Idle/sleep behavior |
| `hyprlock.conf` | Lock screen |
| `hyprsunset.conf` | Night light / color temperature |
| `envs.conf` | Environment variables |
