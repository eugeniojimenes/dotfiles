# CLAUDE.md

Guidance for Claude Code (claude.ai/code) working in this repo.

## What this repo is

Personal dotfiles for Arch/Omarchy system, managed with **GNU Stow**. Each top-level dir = Stow module: `alacritty`, `bash`, `claude-code`, `git`, `hypr`, `lazyvim`, `local-bin`, `mise`, `mpv`, `omp`, `opencode`, `rubocop`, `steam`, `tmux`.

Stow symlinks module contents into `$HOME`, mirroring dir structure. Example: `hypr/.config/hypr/hyprland.lua` becomes `~/.config/hypr/hyprland.lua`.

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

**DO NOT EDIT OMARCHY DEFAULTS DIRECTLY.** Pattern everywhere in repo:

1. Omarchy defaults live in `$OMARCHY_PATH/default/` (`/usr/share/omarchy` since Omarchy 4; `~/.local/share/omarchy` now symlink to it) — load first, never edit.
2. User overrides live in this repo, sourced/applied **after** defaults, overwriting what needs change.

Applies to:
- **Hyprland** (`hypr/.config/hypr/`): **Lua since Omarchy 4** — Hyprland 0.56 loads `hyprland.lua` over `hyprland.conf`, so old hyprlang files dead, removed. `hyprland.lua` bootstraps Omarchy Lua module path, `require`s `default.hypr.omarchy`, then `require`s local overrides: `monitors.lua`, `input.lua`, `bindings.lua`, `looknfeel.lua`, `autostart.lua`. Rest — `hypridle.conf`, `hyprlock.conf`, `hyprsunset.conf`, `xdph.conf` — still hyprlang standalone configs (Omarchy ships no default to layer), edited in full. Add customizations only to these files.
  - Two APIs: `hl.*` = raw Hyprland (`hl.config`, `hl.monitor`, `hl.env`, `hl.bind`, `hl.unbind`, `hl.dsp.*`); `o.*` = Omarchy sugar (`o.bind`, `o.window`, `o.launch_on_start`) defined in `$OMARCHY_PATH/default/hypr/helpers.lua`. Editor stubs at `/usr/share/hypr/stubs` (wired by `.luarc.json`).
  - Overrides load *after* defaults, but keybind not override — second `o.bind` on claimed key adds duplicate. **`hl.unbind("...")` first, then rebind.**
  - To cancel Omarchy *window rule*, remove tag it keyed on — not rebind, not relaunch under different app-id. Omarchy tags window (`+floating-window`) then matches float/center/size rules on that tag; rule-applied tags dynamic (`*` in `hyprctl clients`) and re-evaluated, so override like `o.window("org.omarchy.btop", { tag = "-floating-window" })` in `looknfeel.lua` un-matches them. Hyprland has no "unfloat" rule, and custom app-id would dodge every *other* rule Omarchy keys on real one.
- **Bash** (`bash/.bashrc`): resolves `OMARCHY_PATH` (honouring `/etc/omarchy.conf`), then sources `$OMARCHY_PATH/default/bash/rc`; local additions follow.

**LazyVim is exception** — no source-then-override. Omarchy Neovim config ships as separate pacman package (`omarchy-nvim`, installs to `/usr/share/omarchy-nvim/config/`), nothing to `source` from Lua. Files from Omarchy **vendored as real files** in `lazyvim/.config/nvim/`: `lua/plugins/all-omarchy-themes.lua` and `plugin/after/transparency.lua`. Refresh by diffing against `/usr/share/omarchy-nvim/config/`, never by symlinking to it (root-owned, path already moved once).

**Never point file inside stowed module at path outside repo.** Modules stowed at dir level, so Omarchy migrations (`sed -i`, `cp` against `~/.config/...`) resolve through dir symlink and edit this repo's real files — intended, shows in `git status` after update. *File*-level symlink escaping repo breaks that: migrations guarded by `[[ -f ... ]]`, false for dangling link, so update skipped silently and machines drift. `lua/plugins/theme.lua` shows alternative — resolve path at runtime.

## Public repo — no secrets

**IMPORTANT:** This repository is **public**. Never add tokens, API keys, passwords, private SSH/GPG keys, or any personal credentials to any file here. If a config requires a secret (e.g. an env var), reference it by variable name only and set the actual value outside this repo.

## Commit style

Default branch = `develop` (not `main`/`master`).

Conventional Commits enforced via commit template (`git/.gitmessage`):

```
<type>(<scope>): <short summary>
```

Types: `build|chore|ci|docs|feat|fix|perf|refactor|style|test`

Examples from repo history:
```
feat(hypr): change browser keybind to brave
feat(lazyvim): rust develop
fix(lazyvim): treesitter identation bug in ruby
refactor(rubocop): consolidate into stow module and update configs
feat(tmux): migrate to XDG config path and add session persistence
docs(readme): update tmux install instructions for XDG path
```

## Key module notes

- **alacritty**: not Omarchy 4 default — Quattro ships **foot**, installs `~/.local/share/applications/foot.desktop`, which `xdg-terminal-exec` picks. Every Omarchy launcher (`omarchy-launch-terminal`, `omarchy-launch-tui`) goes through it, so whole session silently moves to foot's `~/.config/foot/foot.ini` (font size 9). Reclaim with `omarchy-default-terminal alacritty`, which writes `~/.config/xdg-terminals.list`. That file machine-local and untracked; re-run command on fresh machine. See `TERMINAL-CHOICE.md` for why Alacritty.
- **lazyvim** (`lazyvim/.config/nvim/`): LazyVim-based Neovim config. Plugin specs in `lua/plugins/`. Lock file `lazy-lock.json`.
- **mise** (`mise/.config/mise/config.toml`): Manages Node 22, Python 3.11, Ruby 3.4, Rust (latest), uv (latest). Run `mise install` after stowing.
- **local-bin** (`local-bin/.local/bin/`): Personal scripts on `PATH`. Currently just `asdf`, shim forwarding to mise because a work CLI hardcodes `asdf` calls and has no mise backend (see `NVIM-RUBY-LSP-FIX.md`). One module stow links **file by file**, not as dir: `~/.local/bin` already holds unrelated real files, including 115 MB `mise` binary and mise-generated tool shims, none belonging in repo. Opposite of tmux rule above, deliberate — nothing runs migrations against `~/.local/bin`, so no `sed -i` to resolve through dir link.
- **tmux**: Requires TPM at `~/.local/share/tmux/plugins/tpm` — *not* under `~/.config/tmux`, which must hold only `tmux.conf` so stow links it as dir (see migration warning above; this module drifted out of repo once from file-level link). Path set via `TMUX_PLUGIN_MANAGER_PATH` at bottom of `tmux.conf`. After stowing, install plugins inside tmux with `prefix + I`. Every binding carries `-N "description"`, matching Omarchy's own `tmux.conf` — that text is what `prefix + ?` and `omarchy-menu-tmux-keybindings` render, so new binding without one shows as raw tmux command. Persistence = tmux-resurrect **only, hand-driven**: `prefix + Ctrl-s` saves, `prefix + Ctrl-r` restores, nothing on timer. tmux-continuum removed on purpose — with auto-restore off its auto-save was destructive: empty server opened after reboot would overwrite snapshot you wanted five minutes later. Don't re-add it, and don't add `%if` server-gating in `tmux.conf`: since no server saves unless asked, start order no longer matters and extra servers from `hypr/.config/hypr/tmux-launch.sh` (`iso-<pid>`) and `hypr/.config/hypr/tmux-sys-tools.sh` (btop + lazydocker on socket `sys-tools`) need no coordination. sys-tools server = viewer, not workspace: at creation sets `pane-exited` hook to `kill-server`, so quitting either TUI closes whole thing, and unbinds `C-s`/`C-r` because resurrect loaded there too and saves to one directory for every server — stray save in that window would overwrite primary's snapshot. `@resurrect-processes` is `'false'` — sentinel checked by `restore_pane_processes_enabled()`, not a list — so restore rebuilds sessions, windows, layouts, cwds, pane contents but relaunches no programs. Cannot restore *some* programs: option is additive to built-in default list already containing nvim, vim, htop, and nothing subtracts from that list. Old snapshots need no external cleanup — resurrect's `remove_old_backups()` runs every save, honouring `@resurrect-delete-backup-after` and always keeping 5 newest.
- **claude-code** (`claude-code/.claude/`): Global Claude Code config — `CLAUDE.md` (English learning feedback instructions), `settings.json`, custom skills (`skills/`), `statusline-command.sh`. Stow it to place at `~/.claude/`. Stow links this module **file by file**, not as dir — `~/.claude/` already holds untracked runtime state (`plugins/`, `projects/`, `ide/`, `settings.local.json`), so that state stays out of repo on its own; no `.gitignore` entry does that work. Claude Code **writes `settings.json` at runtime** (`/config` toggles, `claude plugin` commands), and those writes resolve through file symlink into this repo — plugin changes show up as uncommitted diffs. Read `git status` before committing. Work marketplaces are why that matters: enabling one writes `extraKnownMarketplaces` entry holding internal git URL, which must **not** be committed to public repo. Registration is machine-local in `~/.claude/plugins/known_marketplaces.json` — re-create on fresh machine with `claude plugin marketplace add <work marketplace URL>`, then enable plugins. `enabledPlugins` names them by marketplace name only, safe to track.