# AGENTS.md

Rules + commands for any agent in this repo. Reasons live in `docs/` (linked per rule). Path-scoped rules and task skills: `harness/` (see `harness/README.md` for which tool reads what).

## Repo

Personal dotfiles, NixOS + Sway, managed with GNU Stow. **Public**: GitHub `origin` with GitLab mirror, one push reaches both.

- Stow module = top-level dir with dot-prefixed contents: `alacritty`, `bash`, `btop`, `claude-code`, `git`, `lazyvim`, `local-bin`, `mise`, `mpv`, `opencode`, `rubocop`, `steam`, `sway`, `tmux`. Stow mirrors module tree into `$HOME`: `sway/.config/sway/config` = `~/.config/sway/config`.
- Anything inside a module gets linked into `$HOME`. Tests, docs, agent files never go inside a module.
- Not modules (no dot-prefixed contents, `dotfiles-doctor` skips): `nixos/`, `docs/`, `tests/`, `bin/`, `harness/`. Root dot-dirs (`.claude/`, `.agents/`, `.cursor/`, `.githooks/`) = project tooling, never stowed.
- `flake.nix` = one `nixosConfigurations.<hostname>` per machine, nixpkgs pinned in `flake.lock`. `nixos/common.nix` = every machine. `nixos/hosts/<hostname>/default.nix` = one machine, imports `../../common.nix` + `./hardware.nix`. `/etc/nixos` unused. No home-manager: system packages and services in `nixos/`, user config through stow.
- `claude-code/.claude/` = owner's **global** Claude Code config (stow module into `~/.claude/`). Not this project's harness. Do not edit unless asked.
- `THIRD-PARTY.md` = files copied from other projects + licenses (Catppuccin themes, MIT). Copy something in = add it there with license text.
- Human docs: `README.md` (install, use), `docs/` (how and why), `docs/specs/` (feature specs), `tests/manual.md` (hardware checklist).
- Screenshots and GIFs: files in public repo `eugeniojimenes/dotfiles-media`, never committed here (binary history). Here: manifest `docs/media.json` + image lines. Skill `update-media`.

## Commands

```sh
stow <module>            # from repo root ~/dotfiles
stow -D <module>         # remove a module's symlinks
bin/check                # all test layers, before every commit
bin/check static|unit|terms   # terms --cached = staged (pre-commit), --message FILE = commit-msg, --range REV... = pre-push
bin/manual-pass [-n] [--with TEXT] "<item>"...   # tests/manual.md items passed: last pass per host in tests/manual-passes.toml
nix develop              # shell with the check tools
nix fmt                  # format whole repo (treefmt.nix), static step `format` fails on drift
nix build .#nixosConfigurations.loc-nixos.config.system.build.toplevel
nix store diff-closures /run/current-system ./result
sudo nixos-rebuild switch --flake ~/dotfiles   # owner runs it; host picked by hostname
bin/update [--now]                             # all sources; nixpkgs release >= 2 days old (CVE >= 7 skips), bin/check, build, nvd diff; owner applies
mise install                                   # after stowing mise
dotfiles-doctor [--fix]                        # health check, --fix = safe repairs only
```

## Hard rules

- **No secrets** in any file: tokens, API keys, passwords, private SSH/GPG keys, any credential. Config needs a secret = reference env var by name, value set outside repo. `~/.private` = private repo holding them: name it, never its payload contents or the tool that writes it. See `docs/public-repo.md`.
- **No employer detail** anywhere: company name, internal tool and repo names, internal paths, engine or service names, marketplace names. Applies to code, comments, docs, harness, skills, examples, commit messages. Workaround comment needs no proper noun: "a work CLI hardcodes `asdf` calls".
- Hooks (pre-commit, commit-msg, pre-push) stay enabled (`git config core.hooksPath .githooks`; `dotfiles-doctor --fix` sets it). Never `git commit --no-verify` or `git push --no-verify` without owner approval for that commit or push. Hook refuses = fix cause. Tool wrote into stowed file = `git checkout <file>`.
- Term scan output = `file:line` only. Never print, write or guess `~/.private/forbidden-terms` content.
- `bin/check` passes before every commit.
- Flake sees git-tracked files only: `git add` new files before any `nix` command or `bin/check`.
- Owner runs `sudo` (rebuild, reboot) and approves every commit and push.
- Leak already committed = history rewrite, owner decides. Recipe: `docs/public-repo.md`.

## Area rules

Each rule lives in one file. Claude Code and Cursor load the file by path; other tools (Codex, OpenCode): read it before touching the area.

- `nixos/**`, `flake.nix`, `flake.lock` = `harness/rules/nixos.md`
- `sway/**` = `harness/rules/sway.md`
- `tests/**`, `docs/specs/**`, `bin/check`, any script you add or change = `harness/rules/tests.md`
- any `.md` = `harness/rules/writing.md`

Task skills (steps for recurring tasks): `harness/skills/<name>/SKILL.md`.

## Commits

- Default branch `develop` (not `main`/`master`). Branch `sway` = NixOS + Sway setup, notebook first; merges into `develop` once desktop moves too.
- Conventional Commits, template `git/.gitmessage`: `<type>(<scope>): <short summary>`. Types: `build|chore|ci|docs|feat|fix|perf|refactor|style|test`. Scope = module or area.
- Examples: `feat(sway): add sway module`, `feat(lazyvim): rust develop`, `fix(lazyvim): treesitter identation bug in ruby`, `refactor(rubocop): consolidate into stow module and update configs`, `feat(tmux): migrate to XDG config path and add session persistence`, `docs(readme): update tmux install instructions for XDG path`.
- Bug found on the way = own `fix(...)` commit.
- Agent is Claude: end message with `Co-Authored-By: Claude <model> <noreply@anthropic.com>`.

## Writing style

- Agent text (`AGENTS.md`, `CLAUDE.md`, `harness/rules/**`, `harness/skills/**`) and code comments: compressed, caveman `full`; comments wrap ~120. Human docs (`README*`, `docs/**`, `docs/specs/**`, `harness/README*`, `tests/manual.md`): plain English, full sentences, owner's rule in `harness/rules/writing.md`.
- No em-dash anywhere: docs, comments, commit messages (static step `em-dash`), except `claude-code/.claude/` (prompt text, left as is). Colon, period, comma or parentheses instead. Same for ` -- ` as a pause in a comment. Literal `--` in a command = argument syntax, keep: `mise exec -- bundle exec rubocop`.
- Comment markers = todo-comments.nvim keywords (default config), right after comment leader, once per block on its first line: `HACK:` workaround for someone else's bug or limit, `WARN:` gotcha / dead end / "never X", `TODO:` action tied to future event ("drop when X >= 1.2"), `FIX:` known bug still present, `PERF:` perf trade-off, `NOTE:` sparingly. Plain why-comment = no keyword. Never `ponytail:` / `shortcut:`.
- No AI tells anywhere, commit messages included: "moreover", "furthermore", "additionally", "however", "it is worth noting", one-line dramatic pauses, filler adjectives ("crucial", "robust", "seamless", "comprehensive"), "leverage" where "use" works.
- Human docs come in en + pt-br pairs, changed in the same commit (static step `doc-pairs`). English only: `docs/specs/`, agent text, code comments.
- **Code format**: `nix fmt` (treefmt.nix): nixfmt, shfmt (style from `.editorconfig`: 2 spaces, `case` indented, `&&`/`||` end the line), stylua (`lazyvim/.config/nvim/stylua.toml`), taplo, prettier (CSS/JSON/YAML/mjs/tsx; `.jsonc` without trailing commas). Not formatted: `hardware.nix`, `lazy-lock.json`, `lazyvim.json`. Run before commit; never hand-align code the formatter undoes.
- Bash script = `#!/usr/bin/env bash` (NixOS has no `/bin/bash`). POSIX script = `#!/bin/sh`.

## Specs and tests

- Spec `docs/specs/<feature>.md` when a change creates a script, a panel or a stow module, or changes behaviour of an existing one, same commit. Config tweak or small fix: test only.
- Touched script without tests gets one in same commit (static-only exception, layout: `harness/rules/tests.md`).
- Manual criterion = row in `tests/manual.md` under each host it applies to. Pass = `bin/manual-pass "<item>"...` (updates `tests/manual-passes.toml`), only on owner's word that the items passed. Agent drove the check (skill `manual-check`) = `--with agent-driven`.

## Machine-specific config

Notebook `loc-nixos` now, AMD desktop (two monitors, no hostname yet) later. True for one machine only = its host files (`nixos/hosts/<hostname>/`, `sway/.config/sway/hosts/<hostname>`), never shared ones. Notebook-only items in shared files, recheck when desktop arrives: `docs/machines.md`. New host = skill `new-host`.

## Modules

- **nixos**: layout in Repo above. Rules: `harness/rules/nixos.md`. Why: `docs/nixos.md`.
- **sway** (`sway/.config/sway/`): `config` = variables + `include config.d/*` (numbered, order matters) + `include hosts/$(hostname)` (last, missing skipped). `bin/` scripts, `apps/` app configs, `panels/` = Quickshell root: entry `<name>.qml` on top (bluetooth, calendar, display, lock, menu, network, power, recording, screensaver, sound; `menu` = Super+Space, tree in `menu/menu.mjs`; `share` = screen-share picker, started by `bin/share-picker`, rows in, pick out through files; `notifications` = always-running daemon with popups and the centre, opened over IPC by `notifications/toggle`; `PanelShell.keepAlive` keeps its process on close), `<name>/` beside it (toggle, `.mjs` logic, scripts), shared `common/` (`PanelShell`, `PanelCard`, `SectionLabel`, `Theme`, `AdvancedLink`, `Chip`), big panel split into `<name>/<Upper>.qml` components. `bin/start` = GPU order, `panels/display/reinit` = resume hook. Rules: `harness/rules/sway.md`. Why: `docs/sway.md`.
- **tmux**: plugins = nixpkgs `tmuxPlugins.*` linked to `/etc/tmux/plugins/<name>` (`nixos/common.nix`), `run-shell` at bottom of `tmux.conf`. No TPM (pulled repo HEAD, no release-age wait). New plugin = both places. `~/.config/tmux` holds only `tmux.conf` (dir-level link). `-N "description"` on every binding. Persistence = tmux-resurrect, manual only (`prefix + Ctrl-s` / `Ctrl-r`). Never re-add tmux-continuum, never add `%if` server gating. `sys-tools` server: `pane-exited` kills it, `C-s`/`C-r` unbound. Why: `docs/tmux.md`.
- **git**: work identity via `[includeIf "gitdir:~/*-workspace/"]` (glob, never a literal work path) to `~/.gitconfig-work` in `~/.private`. Why: `docs/git.md`.
- **alacritty**: opacity set live by `sway/.config/sway/bin/opacity`; text size by `sway/.config/sway/panels/display/ctl`, which edits `alacritty.toml` in place. Diff in `git status` from that = expected.
- **lazyvim** (`lazyvim/.config/nvim/`): LazyVim. Plugin specs `lua/plugins/`, lock `lazy-lock.json`. Catppuccin Mocha, `transparent_background` (`lua/plugins/theme.lua`). `lua/config/clipboard.lua`: in tmux or SSH every yank also goes out as OSC 52.
- **mise** (`mise/.config/mise/config.toml`): Node 22, Python 3.11, Ruby 3.4, Rust, Go, uv, agent CLIs. `mise install` after stowing. Ruby = jdx/ruby precompiled, runs through nix-ld.
- **bash**: `.bashrc` sources `~/.config/bash/{env,shell,aliases,init}`, binds `inputrc`. All written here, nothing sourced from a distro. `env` sources `~/.private/envs` (Sway starts no login shell). Startup files carry `#!/usr/bin/env bash` only so shellcheck and shfmt find them.
- **local-bin** (`local-bin/.local/bin/`): `asdf` = shim to mise (a work CLI hardcodes `asdf` calls, no mise backend); `dotfiles-doctor`. Stowed **file by file** (`~/.local/bin` holds unrelated real files). Doctor: stow conflicts never auto-fixed; repairs outside repo = report-only. Details: `docs/dotfiles-doctor.md`, spec `docs/specs/dotfiles-doctor.md`.
- **claude-code**: stowed **file by file** (`~/.claude/` holds untracked runtime state). `settings.json` never tracked (`extraKnownMarketplaces` and `enabledPlugins` leak work detail); real file at `~/.claude/settings.json`, encrypted copy in `~/.private`. Why: `docs/claude-code.md`.
- **mpv**: uosc + mpris = `mpvScripts.{uosc,mpris}` in the mpv wrapper (`nixos/common.nix`). Never its installer or Update menu (second copy in `~/.config/mpv/scripts`). Why: `docs/mpv.md`.
- Before first stow: `mkdir -p ~/.local/share ~/.local/bin ~/.claude`, else stow folds shared parents into a module.
