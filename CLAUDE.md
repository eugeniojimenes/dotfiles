# CLAUDE.md

Guidance for Claude Code (claude.ai/code) in this repo.

## What this repo is

Personal dotfiles for NixOS + Sway, managed with **GNU Stow**. Each top-level dir with dot-prefixed contents = Stow module: `alacritty`, `bash`, `btop`, `claude-code`, `git`, `lazyvim`, `local-bin`, `mise`, `mpv`, `omp`, `opencode`, `rubocop`, `steam`, `sway`, `tmux`.

Stow symlinks module contents into `$HOME`, mirroring dir structure. `sway/.config/sway/config` becomes `~/.config/sway/config`.

`nixos/` = system config, **not** a stow module (no dot-prefixed contents, `dotfiles-doctor` skips it). `/etc/nixos/configuration.nix` imports it next to the machine-local `hardware-configuration.nix`. Channels, no flakes, no home-manager: system packages and services there, user config here through stow.

`THIRD-PARTY.md` = files copied from other projects plus their licenses (Catppuccin themes, MIT). Copy something in = add it there with the license text.

## Common commands

```sh
# Apply a module (run from repo root ~/dotfiles)
stow <module>          # e.g. stow sway
stow -D <module>       # remove a module's symlinks

# System config changed
sudo nixos-rebuild switch            # build + activate
sudo nixos-rebuild switch --upgrade  # same, after pulling the channel

# After stowing mise
mise install
```

## Public repo: no secrets

**IMPORTANT:** This repo is **public**. Never add tokens, API keys, passwords, private SSH/GPG keys, any personal credential to any file here. If a config needs a secret (e.g. env var), reference it by variable name only, set the value outside this repo.

**No employer detail either.** Not company name, internal tool and repo names, internal paths, engine or service names, marketplace names. A comment explaining *why* a workaround exists needs no proper noun: "a work CLI hardcodes `asdf` calls" carries the same reasoning as naming the tool. Applies to code comments, this file, any `.md` here.

### History rewrites

Done once, 2026-08-20: employer name and internal tool names had reached 7 commits (tip of `develop`, two days old). Scrubbed with `git filter-repo --replace-text` plus `--invert-paths --path claude-code/.claude/settings.json`, force-pushed to both remotes. Every commit from `a5c3a3a` onward got new SHA; the 250 before untouched.

If it happens again:

```sh
# from a backup first: git bundle create ~/dotfiles-backup.bundle --all
git filter-repo --force --refs develop --replace-text expressions.txt
git push --force-with-lease origin develop
```

`--refs develop` keeps rewrite off other branches and stops filter-repo dropping `origin` remote (two push URLs, GitHub and GitLab mirror; both need the force push). Force push erases nothing: old commits stay reachable by SHA on GitHub until it GCs, so ask GitHub Support to purge cached views when the leak actually matters.

## Writing style: docs and comments

Applies to every `.md` here (**this file included**) and every code comment.

- **Compress.** caveman skill, level `full`: drop articles, filler, hedging, pleasantries. Fragments fine. Short synonyms. Prefer `=` and `:` over spelled-out copulas. All technical substance stays, only fluff goes. Never touch code blocks, command lines, API names, error strings, option names.
- **No em-dashes.** Colon, period, comma or parentheses instead. Same for ` -- ` used as a pause in a comment. A literal `--` inside a command is argument syntax, leave it: `mise exec -- bundle exec rubocop` breaks if reflowed.
- **No AI tells.** Drop "moreover", "furthermore", "additionally", "however", "it is worth noting". No one-line dramatic pauses. No filler adjectives ("crucial", "robust", "seamless", "comprehensive"), no "leverage" where "use" works.
- **Comments wrap at ~120, not 80.** Matches `colorcolumn = "120"` in `lazyvim/.config/nvim/lua/config/options.lua`. Code comments only. Markdown prose stays unwrapped, one line per paragraph, editor soft-wraps it.
- `README-pt-br.md` compresses the style, not the language. Portuguese articles carry grammar English ones do not, so its ratio is lower on purpose. Technical terms, code and CLI stay verbatim, untranslated.

One exception: `claude-code/.claude/` is prompt text, not documentation. Its skills use the em-dash as list separator the model reads, so rewording changes behaviour. Left as is, excluded from sweep.

Sweep before committing. Pattern is `\x{2014}` rather than literal em-dash so command does not match its own definition here:

```sh
git ls-files -z ':!claude-code/.claude' | xargs -0 grep -nP '\x{2014}'
```

Commit messages separate, see [Commit style](#commit-style) below.

## Commit style

Default branch = `develop` (not `main`/`master`). Branch `sway` = NixOS + Sway setup, notebook first; merges into `develop` once the desktop moves too.

Conventional Commits enforced via commit template (`git/.gitmessage`):

```
<type>(<scope>): <short summary>
```

Types: `build|chore|ci|docs|feat|fix|perf|refactor|style|test`

Examples from repo history:
```
feat(sway): add sway module
feat(lazyvim): rust develop
fix(lazyvim): treesitter identation bug in ruby
refactor(rubocop): consolidate into stow module and update configs
feat(tmux): migrate to XDG config path and add session persistence
docs(readme): update tmux install instructions for XDG path
```

## Key module notes

- **nixos** (`nixos/configuration.nix`): notebook (Intel UHD + RTX 3050). NVIDIA open module, PRIME offload (`prime-run`, Arch name kept so Steam launch options carry over), `powerManagement` for suspend. greetd autologins into `~/.config/sway/start`: LUKS passphrase already gates boot. `programs.nix-ld` so prebuilt binaries mise and Mason download run. `programs.fzf.keybindings` and NixOS bash completion replace what `bash/` used to source from `/usr/share`. Evaluate before trusting a change: `nix-instantiate '<nixpkgs/nixos>' -A system`. `system.stateVersion` never bumps.
- **sway** (`sway/.config/sway/`): whole desktop in one dir. waybar, mako, fuzzel, swaylock and the Quickshell panels (calendar, display, lock) start with explicit paths, stock `~/.config/<app>` never read. Plus `sway/.config/xdg-desktop-portal-wlr/sway` (screen-share picker). Scripts use `#!/usr/bin/env bash` (NixOS has no `/bin/bash`); menu reads `.desktop` files from `XDG_DATA_DIRS`, not `/usr/share`. `start` orders GPUs (`WLR_DRM_DEVICES`, iGPU first; NVIDIA second because HDMI/DP are wired to it). `display/reinit` = after-resume hook, external monitor stays black without it even with nvidia-suspend/resume. `session-env` imports the session env into systemd/D-Bus for portals; `/etc/sway/config.d` not included.
- **git**: work identity conditional, `[includeIf "gitdir:~/*-workspace/"]` at bottom of `.gitconfig`. Glob on purpose: matches the work checkout dir without naming the employer, which a literal path would. Target `~/.gitconfig-work` = symlink into `~/.private` (payload `gitwork`, ciphertext `gitconfig-work.age`), so work email never lands here. Missing target is not an error, git skips an include whose path does not exist, so a machine with no `~/.private` unlocked just falls through to the personal `[user]`. Same reasoning as `settings.json` in **claude-code** below.
- **alacritty**: terminal. Tabs, splits and persistence come from tmux. Opacity set live by `sway/.config/sway/opacity` (`alacritty msg config`), text size by `sway/.config/sway/display/ctl`, which edits `alacritty.toml` in place: shows in `git status`, intended.
- **lazyvim** (`lazyvim/.config/nvim/`): LazyVim-based Neovim config. Plugin specs in `lua/plugins/`. Lock file `lazy-lock.json`. Catppuccin Mocha with `transparent_background` (`lua/plugins/theme.lua`). `lua/config/clipboard.lua`: inside tmux or SSH every yank also goes out as OSC 52.
- **mise** (`mise/.config/mise/config.toml`): Node 22, Python 3.11, Ruby 3.4, Rust, Go, uv, agent CLIs. Run `mise install` after stowing. Ruby = jdx/ruby precompiled, runs through nix-ld.
- **bash** (`bash/`): `.bashrc` sources `~/.config/bash/{env,shell,aliases,init}` and binds `inputrc`. All written here, nothing sourced from a distro.
- **local-bin** (`local-bin/.local/bin/`): personal scripts on `PATH`. Two: `asdf`, shim forwarding to mise because a work CLI hardcodes `asdf` calls and has no mise backend; `dotfiles-doctor`, read-only health check, `--fix` applies safe repairs. Stow links this module **file by file**, not as dir: `~/.local/bin` holds unrelated real files (mise shims), none belonging in repo.

  `dotfiles-doctor` detail. Module list = dirs in repo root with dot-prefixed contents, new module covered free. Stow state from `stow -n -v <mod>`, three signals, verified against stow 2.4.1, none documented: rc 0 + no output = linked; rc 0 + `LINK:` lines = not linked; rc 1 + `WARNING! ... conflicts` = real file where symlink belongs. Conflicts never auto-fixed, file may hold changes worth keeping. Repo root resolved via `readlink -f "$0"`, so script works stowed or straight out of fresh clone. Checks: stow, commands `configuration.nix` should provide (missing = not rebuilt), mise (including `postinstall` Neovim hosts, which fail silently), external installs (TPM, uosc, lazy plugins), machine-local files (`~/.claude/settings.json`, image mime defaults, cedilla). Images must open in `imv-dir.desktop` (ships with `imv`, opens clicked file plus its dir so next/prev work), set in `~/.config/mimeapps.list` via `xdg-mime default`; `mimeapps.list` itself not tracked, apps rewrite it constantly. Cedilla: `<dead_acute> <c>` must map to ç in `xkbcli compile-compose` output. Fix = override at end of machine-local `~/.XCompose` (later definition beats system Compose pulled in by `include "%L"`). Capture xkbcli output before `grep -q`: early exit SIGPIPEs xkbcli and `pipefail` inverts the result. Gated on `xkb_variant intl` in the Sway config: built-in ABNT2 has real ç key, a us/intl external keyboard reaches `dead_acute`. Report-only: repair edits a file outside repo.
- **tmux**: needs TPM at `~/.local/share/tmux/plugins/tpm`, *not* under `~/.config/tmux`, which must hold only `tmux.conf` so stow links it as dir (a file-level link drifted out of repo once). Path set via `TMUX_PLUGIN_MANAGER_PATH` at bottom of `tmux.conf`. After stowing, install plugins inside tmux with `prefix + I`. Every binding carries `-N "description"`: that text is what `prefix + ?` (`tmux list-keys -N`) renders, so new binding without one shows as raw tmux command. Persistence = tmux-resurrect **only, hand-driven**: `prefix + Ctrl-s` saves, `prefix + Ctrl-r` restores, nothing on timer. tmux-continuum removed on purpose. With auto-restore off its auto-save was destructive: empty server opened after reboot would overwrite the snapshot you wanted five minutes later. Don't re-add it, and don't add `%if` server-gating in `tmux.conf`: since no server saves unless asked, start order no longer matters and extra servers from `sway/.config/sway/tmux-launch` (`iso-<pid>`) need no coordination. `@resurrect-processes` is `'false'` (sentinel checked by `restore_pane_processes_enabled()`, not a list), so restore rebuilds sessions, windows, layouts, cwds, pane contents but relaunches no programs. Cannot restore *some* programs: option is additive to built-in default list already containing nvim, vim, htop, and nothing subtracts from it. Old snapshots need no external cleanup: resurrect's `remove_old_backups()` runs every save, honouring `@resurrect-delete-backup-after` and always keeping 5 newest.
- **claude-code** (`claude-code/.claude/`): global Claude Code config: `CLAUDE.md` (English learning feedback instructions), custom skills (`skills/`), `statusline-command.sh`. Stow places it at `~/.claude/`. Stow links this module **file by file**, not as dir: `~/.claude/` already holds untracked runtime state (`plugins/`, `projects/`, `ide/`, `settings.local.json`), so that state stays out of repo on its own; no `.gitignore` entry does that work.
  - **`settings.json` deliberately not tracked here.** It was, until both keys Claude Code writes into it turned out to leak work detail into a public repo: `extraKnownMarketplaces` holds internal git URLs, and `enabledPlugins` names each plugin by its marketplace, so a work marketplace shows up by name. That second one is easy to miss, value looks like a harmless boolean. Repo history rewritten to drop the file, see [History rewrites](#history-rewrites).
  - File now machine-local as a **real file** at `~/.claude/settings.json`, not a symlink into this module. Encrypted copy in `~/.private` (`claude-settings.json.age`), the private repo, so it survives a machine rebuild. `~/.private/private unlock` decrypts straight to its live path; do that before re-registering marketplaces with `claude plugin marketplace add <url>`; registration itself stays machine-local in `~/.claude/plugins/known_marketplaces.json`.
  - Anything genuinely portable (model, statusline, tui) can go in a tracked `settings.local.json`-style file later if it earns one. Not worth a second file today.
