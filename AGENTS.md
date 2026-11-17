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

## Commands

```sh
stow <module>            # from repo root ~/dotfiles
stow -D <module>         # remove a module's symlinks
bin/check                # all test layers, before every commit
bin/check static|unit|terms
nix develop              # shell with the check tools
nix build .#nixosConfigurations.loc-nixos.config.system.build.toplevel
nix store diff-closures /run/current-system ./result
sudo nixos-rebuild switch --flake ~/dotfiles   # owner runs it; host picked by hostname
nix flake update                               # move flake.lock, then switch
mise install                                   # after stowing mise
dotfiles-doctor [--fix]                        # health check, --fix = safe repairs only
```

## Hard rules

- **No secrets** in any file: tokens, API keys, passwords, private SSH/GPG keys, any credential. Config needs a secret = reference env var by name, value set outside repo. `~/.private` = private repo holding them: name it, never its payload contents or the tool that writes it. See `docs/public-repo.md`.
- **No employer detail** anywhere: company name, internal tool and repo names, internal paths, engine or service names, marketplace names. Applies to code, comments, docs, harness, skills, examples, commit messages. Workaround comment needs no proper noun: "a work CLI hardcodes `asdf` calls".
- Pre-commit hook stays enabled (`git config core.hooksPath .githooks`; `dotfiles-doctor --fix` sets it). Never `git commit --no-verify` without owner approval for that commit. Hook refuses = fix cause. Tool wrote into stowed file = `git checkout <file>`.
- Term scan output = `file:line` only. Never print, write or guess `~/.private/forbidden-terms` content.
- `bin/check` passes before every commit.
- Flake sees git-tracked files only: `git add` new files before any `nix` command or `bin/check`.
- Owner runs `sudo` (rebuild, reboot) and approves every commit and push.
- Leak already committed = history rewrite, owner decides. Recipe: `docs/public-repo.md`.

## Commits

- Default branch `develop` (not `main`/`master`). Branch `sway` = NixOS + Sway setup, notebook first; merges into `develop` once desktop moves too.
- Conventional Commits, template `git/.gitmessage`: `<type>(<scope>): <short summary>`. Types: `build|chore|ci|docs|feat|fix|perf|refactor|style|test`. Scope = module or area.
- Examples: `feat(sway): add sway module`, `feat(lazyvim): rust develop`, `fix(lazyvim): treesitter identation bug in ruby`, `refactor(rubocop): consolidate into stow module and update configs`, `feat(tmux): migrate to XDG config path and add session persistence`, `docs(readme): update tmux install instructions for XDG path`.
- Bug found on the way = own `fix(...)` commit.
- Agent is Claude: end message with `Co-Authored-By: Claude <model> <noreply@anthropic.com>`.

## Writing style

Three audiences:

- **Agent text** (`AGENTS.md`, `CLAUDE.md`, `harness/rules/**`, `harness/skills/**`): compressed, caveman `full`. Drop articles, filler, hedging, pleasantries. Fragments fine. Short synonyms. `=` and `:` over spelled-out copulas. All technical substance stays. Never touch code blocks, command lines, API names, error strings, option names.
- **Human docs** (`README*`, `docs/**`, `docs/specs/**`, `harness/README*`, `tests/manual.md`), owner's rule verbatim: "Plain English, full sentences, no AI tell language. Avoid em dashes, "not just X but Y", bold labels on every bullet, filler openers, and words like "durable", "seam", "artifact" where a normal word works. Do not append a clause that vouches for a fact instead of explaining it, asserting that something is intentional, earned or no accident ("and not by luck", "by design"). State the fact, and give the reason in its own sentence when the reason matters. Do not hard wrap. One paragraph or bullet is one line, however long. Only code blocks keep their own line breaks." Owner exception: README module list keeps bold module names (main doc, scanned by eye).
- **Code comments**: compressed like agent text. Wrap at ~120 (`colorcolumn = "120"` in `lazyvim/.config/nvim/lua/config/options.lua`).

Everywhere:

- No em-dash. Colon, period, comma or parentheses instead. Same for ` -- ` as a pause in a comment. Literal `--` in a command = argument syntax, keep: `mise exec -- bundle exec rubocop`.
- No AI tells: "moreover", "furthermore", "additionally", "however", "it is worth noting", one-line dramatic pauses, filler adjectives ("crucial", "robust", "seamless", "comprehensive"), "leverage" where "use" works.
- Markdown never hard-wrapped.
- Exception: `claude-code/.claude/` = prompt text, em-dash is a list separator the model reads. Leave as is, excluded from sweep.
- Sweep (also a `bin/check static` step): `git ls-files -z ':!claude-code/.claude' | xargs -0 grep -nP -d skip '\x{2014}'` (`-d skip`: harness links are dirs)

Language pairs:

- Human docs come in pairs: `README.md` + `README-pt-br.md`, `docs/<x>.md` + `docs/<x>.pt-br.md`, `harness/README.md` + `harness/README.pt-br.md`. Change one = update other in same commit. `bin/check static` step `doc-pairs` warns on a missing pair.
- pt-br: technical terms, code, commands verbatim, untranslated. pt-br links point at pt-br pairs.
- English only: `docs/specs/`, agent text, code comments.

## Specs and tests

- Spec `docs/specs/<feature>.md` when a change creates a script, a panel or a stow module, or changes behaviour of an existing one. Config tweaks and small fixes: test only, no spec. Format + criterion-to-test mapping: `docs/specs/README.md`. Spec changes in same commit as behaviour.
- Touched script without tests gets one in same commit (`float`, `session-env` = static-only by decision).
- Layout: `tests/static.sh` (static layer), `tests/unit/<module path mirrored>/<script>.bats`, `tests/helpers/` (stubs), `tests/checks.nix` (flake checks), `tests/manual.md` (hardware, per host).
- Manual criterion = also listed in `tests/manual.md` under each host it applies to.

## Machine-specific config

Notebook `loc-nixos` now, AMD desktop (two monitors, no hostname yet) later. True for one machine only = its host files, never shared ones:

- `nixos/hosts/<hostname>/default.nix`: hostname, GPU driver + options (PRIME bus IDs, `i915` initrd, `xserver.videoDrivers`), CPU-vendor services (`thermald` = Intel). `hardware.nix` = generated, verbatim. New host = new dir + line in `flake.nix` (skill `new-host`).
- `sway/.config/sway/hosts/<hostname>`: `output` lines matched by `"make model serial"` from `swaymsg -t get_outputs -p`, never connector name (shifts with driver load order).
- Notebook-only items in shared files, recheck when desktop arrives: `docs/machines.md`.

## Modules

- **nixos**: format `nixfmt` (RFC 166), never on `hardware.nix`; lint `statix check -i nixos/hosts/*/hardware.nix .`: one block per top-level option, no repeated keys. Build first, refactor = `diff-closures` shows only version label. Never bump `system.stateVersion`. Store dedup = `nix.optimise.automatic`, not `auto-optimise-store`. Portals = sway package defaults; never Nautilus as FileChooser (25 s deadlock). GTK3 dark = `adw-gtk3-dark` (plain GTK3 has no `Adwaita-dark`). `programs.nix-ld` runs mise/Mason binaries. `prime-run` keeps Arch name (Steam launch options). greetd autologins into `~/.config/sway/bin/start` (LUKS passphrase gates boot). `programs.fzf.keybindings` + NixOS bash completion replace old `/usr/share` sourcing. Why: `docs/nixos.md`.
- **sway** (`sway/.config/sway/`): `config` = variables + `include config.d/*` (numbered, order matters) + `include hosts/$(hostname)` (last, missing skipped). `bin/` scripts, `apps/` app configs, `calendar/ display/ lock/ sound/ wifi/` Quickshell panels. Every app started by explicit path; stock `~/.config/<app>` never read. `#: <title>` above every binding (`bin/keybindings`, `Super + K`). Bash scripts `#!/usr/bin/env bash` (no `/bin/bash` on NixOS). Menu reads `.desktop` from `XDG_DATA_DIRS`. `/etc/sway/config.d` not included (`bin/session-env` does env import). `bin/start` = GPU order, `display/reinit` = resume hook. Plus `sway/.config/xdg-desktop-portal-wlr/sway`. Why: `docs/sway.md`.
- **tmux**: TPM at `~/.local/share/tmux/plugins/tpm`; `~/.config/tmux` holds only `tmux.conf` (dir-level link). `-N "description"` on every binding. Persistence = tmux-resurrect, manual only (`prefix + Ctrl-s` / `Ctrl-r`). Never re-add tmux-continuum, never add `%if` server gating. `sys-tools` server: `pane-exited` kills it, `C-s`/`C-r` unbound. Why: `docs/tmux.md`.
- **git**: work identity via `[includeIf "gitdir:~/*-workspace/"]` (glob, never a literal work path) to `~/.gitconfig-work` in `~/.private`. Why: `docs/git.md`.
- **alacritty**: opacity set live by `sway/.config/sway/bin/opacity`; text size by `sway/.config/sway/display/ctl`, which edits `alacritty.toml` in place. Diff in `git status` from that = expected.
- **lazyvim** (`lazyvim/.config/nvim/`): LazyVim. Plugin specs `lua/plugins/`, lock `lazy-lock.json`. Catppuccin Mocha, `transparent_background` (`lua/plugins/theme.lua`). `lua/config/clipboard.lua`: in tmux or SSH every yank also goes out as OSC 52.
- **mise** (`mise/.config/mise/config.toml`): Node 22, Python 3.11, Ruby 3.4, Rust, Go, uv, agent CLIs. `mise install` after stowing. Ruby = jdx/ruby precompiled, runs through nix-ld.
- **bash**: `.bashrc` sources `~/.config/bash/{env,shell,aliases,init}`, binds `inputrc`. All written here, nothing sourced from a distro. `env` sources `~/.private/envs` (Sway starts no login shell).
- **local-bin** (`local-bin/.local/bin/`): `asdf` = shim to mise (a work CLI hardcodes `asdf` calls, no mise backend); `dotfiles-doctor`. Stowed **file by file** (`~/.local/bin` holds unrelated real files). Doctor: stow conflicts never auto-fixed; repairs outside repo = report-only. Details: `docs/dotfiles-doctor.md`, spec `docs/specs/dotfiles-doctor.md`.
- **claude-code**: stowed **file by file** (`~/.claude/` holds untracked runtime state). `settings.json` never tracked (`extraKnownMarketplaces` and `enabledPlugins` leak work detail); real file at `~/.claude/settings.json`, encrypted copy in `~/.private`. Why: `docs/claude-code.md`.
- **mpv**: uosc installed by its own script, not tracked; `stow mpv` before installer. Why: `docs/mpv.md`.
- Before first stow: `mkdir -p ~/.local/share ~/.local/bin ~/.claude`, else stow folds shared parents into a module.
