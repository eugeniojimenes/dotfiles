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

1. Omarchy defaults live in `$OMARCHY_PATH/default/` (`/usr/share/omarchy` since Omarchy 4; `~/.local/share/omarchy` now symlink to it). Load first, never edit.
2. User overrides live in this repo, sourced/applied **after** defaults, overwriting what needs change.

Applies to:
- **Hyprland** (`hypr/.config/hypr/`): **Lua since Omarchy 4**. Hyprland 0.56 loads `hyprland.lua` over `hyprland.conf`, so old hyprlang files dead, removed. `hyprland.lua` bootstraps Omarchy Lua module path, `require`s `default.hypr.omarchy`, then `require`s local overrides: `monitors.lua`, `input.lua`, `bindings.lua`, `looknfeel.lua`, `autostart.lua`. Lua overrides = *only* files this module carries. Add customizations only to these files.
  - **`input.lua` sets no `kb_layout`/`kb_variant`, on purpose.** Omarchy's `default/hypr/input.lua` reads
    `/etc/vconsole.conf` and derives both from `XKBLAYOUT`/`XKBVARIANT`, so per-machine layout is already
    solved by the platform: `localectl set-x11-keymap` per machine, nothing in repo. Desktop = us/intl,
    notebook = br,us with variant `,intl` (empty first slot). `abnt2` is an XKB model, not a `br` variant;
    base `br` already is ABNT2, and `abnt2,intl` compiles to byte-identical symbols, only relabelling the
    keymap, so it works while stating something false. Dead `input.conf.bkp` that carried it is deleted.
    Don't reintroduce a hostname or chassis branch here, vconsole already is the machine-local seam.
    `kb_options` is the exception, Omarchy ignores `XKBOPTIONS` and appends a group toggle only for
    non-Latin layouts. `br` is Latin, so `br,us` gets none; repo sets `grp:alt_space_toggle`, inert on a
    single-layout desktop. Six other settings the file used to carry (`repeat_rate`, `scroll_factor`, both
    `o.window` scroll rules) were byte-identical to Omarchy defaults and were dropped, same reasoning that
    removed `hyprsunset.conf`.
  - **One standalone hyprlang config left, `xdph.conf`.** Three others used to live here, all gone, each for own reason. Check before re-adding any:
    - `hypridle.conf`, `hyprlock.conf`: **`hypridle` and `hyprlock` not installed under Omarchy 4.** Idle and lock moved to `omarchy-shell` (`omarchy-system-lock` runs `omarchy-shell lock lock`; lock UI = `/usr/share/omarchy/shell/plugins/lock/LockView.qml`). Both files configured daemons that don't exist, so idle/lock policy they described never in force. Change lock behaviour through `omarchy-shell`, not by re-adding these.
    - `hyprsunset.conf`: Omarchy 4 ships default at `/usr/share/omarchy/config/hypr/`. Copy here byte-identical, overrode nothing. Re-add only for genuine difference, diff against shipped file first.
    - `xdph.conf`: **not layered, no default when file absent.** xdph hardcodes one path, `$XDG_CONFIG_HOME/hypr/xdph.conf`, opened with `allowMissingConfig`, and never reads `/usr/share/omarchy/config/hypr/xdph.conf`. That copy = seed for `/etc/skel` only: fresh user gets it, this repo's stow symlink then replaces it. So deleting file here falls back to xdph's compiled defaults, not Omarchy's values, silently. Omarchy's `allow_token_by_default` and `custom_picker_binary` sat inert until file came back. Every value spelled out in full, nothing merges.
      - `cursor_mode = 2` (EMBEDDED) = reason file is back. xdph advertises HIDDEN + EMBEDDED only, never METADATA; `SSession::cursorMode` starts HIDDEN, config default `0` = no override. Client asking METADATA falls back to session default. WebRTC apps (Chrome, Slack) send no `cursor_mode` at all, so shares went out cursorless; OBS asks EMBEDDED explicitly, hence cursor there only. Forcing default to EMBEDDED covers every client, explicit HIDDEN still wins.
      - Portal reads config at startup only. `systemctl --user restart xdg-desktop-portal-hyprland.service` after editing.
  - Two APIs: `hl.*` = raw Hyprland (`hl.config`, `hl.monitor`, `hl.env`, `hl.bind`, `hl.unbind`, `hl.dsp.*`); `o.*` = Omarchy sugar (`o.bind`, `o.window`, `o.launch_on_start`) defined in `$OMARCHY_PATH/default/hypr/helpers.lua`. Editor stubs at `/usr/share/hypr/stubs` (wired by `.luarc.json`).
  - Overrides load *after* defaults, but keybind not override: second `o.bind` on claimed key adds duplicate. **`hl.unbind("...")` first, then rebind.**
  - To cancel Omarchy *window rule*, remove tag it keyed on. Not rebind, not relaunch under different app-id. Omarchy tags window (`+floating-window`) then matches float/center/size rules on that tag; rule-applied tags dynamic (`*` in `hyprctl clients`) and re-evaluated, so override like `o.window("org.omarchy.btop", { tag = "-floating-window" })` in `looknfeel.lua` un-matches them. Hyprland has no "unfloat" rule, and custom app-id would dodge every *other* rule Omarchy keys on real one.
- **Bash** (`bash/.bashrc`): resolves `OMARCHY_PATH` (honouring `/etc/omarchy.conf`), then sources `$OMARCHY_PATH/default/bash/rc`; local additions follow.

**LazyVim is exception**: no source-then-override. Omarchy Neovim config ships as separate pacman package (`omarchy-nvim`, installs to `/usr/share/omarchy-nvim/config/`), nothing to `source` from Lua. Files from Omarchy **vendored as real files** in `lazyvim/.config/nvim/`: `lua/plugins/all-omarchy-themes.lua` and `plugin/after/transparency.lua`. Refresh by diffing against `/usr/share/omarchy-nvim/config/`, never by symlinking to it (root-owned, path already moved once).

**Never point file inside stowed module at path outside repo.** Modules stowed at dir level, so Omarchy migrations (`sed -i`, `cp` against `~/.config/...`) resolve through dir symlink and edit this repo's real files. Intended, shows in `git status` after update. *File*-level symlink escaping repo breaks that: migrations guarded by `[[ -f ... ]]`, false for dangling link, so update skipped silently and machines drift. `lua/plugins/theme.lua` shows alternative: resolve path at runtime.

## Public repo: no secrets

**IMPORTANT:** This repository is **public**. Never add tokens, API keys, passwords, private SSH/GPG keys, or any personal credentials to any file here. If a config requires a secret (e.g. an env var), reference it by variable name only and set the actual value outside this repo.

**No employer detail either.** Not the company name, internal tool and repo names, internal paths, engine or service names, marketplace names. A comment explaining *why* a workaround exists does not need the proper noun: "a work CLI hardcodes `asdf` calls" carries the same reasoning as naming the tool. Applies to code comments, this file, and any `.md` here.

### History rewrites

Done once, 2026-08-20: employer name and internal tool names had reached 7 commits (tip of `develop`, two days old). Scrubbed with `git filter-repo --replace-text` plus `--invert-paths --path claude-code/.claude/settings.json`, then force-pushed to both remotes. Every commit from `a5c3a3a` onward got a new SHA; the 250 before it were untouched.

If it happens again:

```sh
# from a backup first: git bundle create ~/dotfiles-backup.bundle --all
git filter-repo --force --refs develop --replace-text expressions.txt
git push --force-with-lease origin develop
```

`--refs develop` keeps the rewrite off the other branches and stops filter-repo dropping the `origin` remote (it has two push URLs, GitHub and the GitLab mirror; both need the force push). Force push does not erase anything: old commits stay reachable by SHA on GitHub until it GCs, so ask GitHub Support to purge cached views when the leak actually matters.

## Writing style: docs and comments

Applies to every `.md` here (**this file included**) and every code comment.

- **Compress.** caveman skill, level `full`: drop articles, filler, hedging, pleasantries.
  Fragments fine. Short synonyms. Prefer `=` and `:` over spelled-out copulas. All technical
  substance stays, only fluff goes. Never touch code blocks, command lines, API names, error
  strings, or option names.
- **No em-dashes.** Colon, period, comma or parentheses instead. Same for ` -- ` used as a pause
  in a comment. A literal `--` inside a command is argument syntax, leave it: `mise exec --
  bundle exec rubocop` breaks if reflowed.
- **No AI tells.** Drop "moreover", "furthermore", "additionally", "however", "it is worth
  noting". No one-line dramatic pauses. No filler adjectives ("crucial", "robust", "seamless",
  "comprehensive"), no "leverage" where "use" works.
- **Comments wrap at ~120, not 80.** Matches `colorcolumn = "120"` in
  `lazyvim/.config/nvim/lua/config/options.lua`. Code comments only. Markdown prose stays
  unwrapped, one line per paragraph, editor soft-wraps it.
- `README-pt-br.md` compresses the style, not the language. Portuguese articles carry grammar
  that English ones do not, so its ratio is lower on purpose. Technical terms, code and CLI stay
  verbatim, untranslated.

One exception: `claude-code/.claude/` is prompt text, not documentation. Its skills use the
em-dash as a list separator the model reads, so rewording changes behaviour. Left as is, and
excluded from the sweep.

Sweep before committing. Pattern is `\x{2014}` rather than a literal em-dash so the command does
not match its own definition in this file:

```sh
git ls-files -z ':!claude-code/.claude' | xargs -0 grep -nP '\x{2014}'
```

Commit messages are separate, see [Commit style](#commit-style) below.

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

- **alacritty**: not Omarchy 4 default. Quattro ships **foot**, installs `~/.local/share/applications/foot.desktop`, which `xdg-terminal-exec` picks. Every Omarchy launcher (`omarchy-launch-terminal`, `omarchy-launch-tui`) goes through it, so whole session silently moves to foot's `~/.config/foot/foot.ini` (font size 9). Reclaim with `omarchy-default-terminal alacritty`, which writes `~/.config/xdg-terminals.list`. That file machine-local and untracked; re-run command on fresh machine. See `TERMINAL-CHOICE.md` for why Alacritty.
- **lazyvim** (`lazyvim/.config/nvim/`): LazyVim-based Neovim config. Plugin specs in `lua/plugins/`. Lock file `lazy-lock.json`.
- **mise** (`mise/.config/mise/config.toml`): Manages Node 22, Python 3.11, Ruby 3.4, Rust (latest), uv (latest). Run `mise install` after stowing.
- **local-bin** (`local-bin/.local/bin/`): Personal scripts on `PATH`. Two: `asdf`, shim forwarding to mise because a work CLI hardcodes `asdf` calls and has no mise backend (see `NVIM-RUBY-LSP-FIX.md`); and `dotfiles-doctor`, read-only health check for a fresh install or a post-`omarchy update` machine, `--fix` applies the safe repairs. One module stow links **file by file**, not as dir: `~/.local/bin` already holds unrelated real files, including 115 MB `mise` binary and mise-generated tool shims, none belonging in repo. Opposite of tmux rule above, deliberate: nothing runs migrations against `~/.local/bin`, so no `sed -i` to resolve through dir link.

  `dotfiles-doctor` detail. Module list = directories in repo root, no hardcoded list, new module covered
  free. Stow state read from `stow -n -v <mod>`, three signals, verified against stow 2.4.1, none documented:
  rc 0 + no output = linked; rc 0 + `LINK:` lines = not linked; rc 1 + `WARNING! ... conflicts` = real file
  where symlink belongs, exactly the drift an Omarchy migration leaves. Conflicts never auto-fixed, file may
  hold changes worth keeping. Repo root resolved via `readlink -f "$0"`, so script works stowed or straight
  out of a fresh clone. Checks stop at stow, pacman, mise (including the `postinstall` Neovim hosts, which
  fail silently), external installs (TPM, uosc, lazy plugins), machine-local files (`~/.claude/settings.json`,
  `~/.config/xdg-terminals.list`). No repo-hygiene checks on purpose: `git status` after `omarchy update` is
  a diff to read, not a pass/fail. One system-file check does earn its place: the cedilla
  patch in `/usr/share/X11/locale/en_US.UTF-8/Compose`. `libx11` owns the file, so every update restores it
  and ç dies silently. Presence = SHA256 mismatch in `pacman -Qkk libx11`, which reports on **stderr** and
  exits 1 whenever any file is altered, so capture output first: piping into `grep` trips `pipefail` on a
  hit and inverts the result. Gated on `intl` appearing anywhere in `kb_variant`, not just first: pure ABNT2 has a real ç key on `<AC10>`
  and skips, but a `br,us` notebook reaches `dead_acute` through the group toggle and still needs the patch.
  Report-only, the repair needs sudo and nothing else in the script does.
  Second guard, `input` section: live `kb_layout`/`kb_variant` vs `/etc/vconsole.conf`. Omarchy's vconsole read
  is code, not documented interface (manual says hardcode in `input.lua`), and 4.0.0.alpha churns; omarchy
  issue #6878 is that seam failing. Accepts the `us,`/`,` prefix Omarchy prepends for non-Latin layouts, and
  stands down when `input.lua` sets `kb_layout` itself, so reverting to the manual's way costs no false alarm.
- **tmux**: Requires TPM at `~/.local/share/tmux/plugins/tpm`, *not* under `~/.config/tmux`, which must hold only `tmux.conf` so stow links it as dir (see migration warning above; this module drifted out of repo once from file-level link). Path set via `TMUX_PLUGIN_MANAGER_PATH` at bottom of `tmux.conf`. After stowing, install plugins inside tmux with `prefix + I`. Every binding carries `-N "description"`, matching Omarchy's own `tmux.conf`. That text is what `prefix + ?` and `omarchy-menu-tmux-keybindings` render, so new binding without one shows as raw tmux command. Persistence = tmux-resurrect **only, hand-driven**: `prefix + Ctrl-s` saves, `prefix + Ctrl-r` restores, nothing on timer. tmux-continuum removed on purpose. With auto-restore off its auto-save was destructive: empty server opened after reboot would overwrite snapshot you wanted five minutes later. Don't re-add it, and don't add `%if` server-gating in `tmux.conf`: since no server saves unless asked, start order no longer matters and extra servers from `hypr/.config/hypr/tmux-launch.sh` (`iso-<pid>`) and `hypr/.config/hypr/tmux-sys-tools.sh` (btop + lazydocker on socket `sys-tools`) need no coordination. sys-tools server = viewer, not workspace: at creation sets `pane-exited` hook to `kill-server`, so quitting either TUI closes whole thing, and unbinds `C-s`/`C-r` because resurrect loaded there too and saves to one directory for every server, so stray save in that window would overwrite primary's snapshot. `@resurrect-processes` is `'false'` (sentinel checked by `restore_pane_processes_enabled()`, not a list), so restore rebuilds sessions, windows, layouts, cwds, pane contents but relaunches no programs. Cannot restore *some* programs: option is additive to built-in default list already containing nvim, vim, htop, and nothing subtracts from that list. Old snapshots need no external cleanup: resurrect's `remove_old_backups()` runs every save, honouring `@resurrect-delete-backup-after` and always keeping 5 newest.
- **claude-code** (`claude-code/.claude/`): Global Claude Code config: `CLAUDE.md` (English learning feedback instructions), custom skills (`skills/`), `statusline-command.sh`. Stow it to place at `~/.claude/`. Stow links this module **file by file**, not as dir: `~/.claude/` already holds untracked runtime state (`plugins/`, `projects/`, `ide/`, `settings.local.json`), so that state stays out of repo on its own; no `.gitignore` entry does that work.
  - **`settings.json` deliberately not tracked here.** It was, until both keys Claude Code writes into it turned out to leak work detail into a public repo: `extraKnownMarketplaces` holds internal git URLs, and `enabledPlugins` names each plugin by its marketplace, so a work marketplace shows up by name. That second one is easy to miss, since the value looks like a harmless boolean. Repo history rewritten to drop the file, see [History rewrites](#history-rewrites).
  - File now lives machine-local as a **real file** at `~/.claude/settings.json`, not a symlink into this module. Encrypted copy in `~/.private` (`claude-settings.json.age`), which is the private repo, so it survives a machine rebuild. Restore it there before re-registering marketplaces with `claude plugin marketplace add <url>`; registration itself stays machine-local in `~/.claude/plugins/known_marketplaces.json`.
  - Anything genuinely portable (model, statusline, tui) can go in a tracked `settings.local.json`-style file later if it earns one. Not worth a second file today.