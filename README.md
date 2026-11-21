# Dotfiles

[![License](https://img.shields.io/badge/License-MIT-lightgray)](/LICENSE)
[![Contributor Covenant](https://img.shields.io/badge/Contributor%20Covenant-2.0-lightblue)](/code_of_conduct.md)
[![Conventional Commits](https://img.shields.io/badge/Conventional%20Commits-1.0.0-yellow.svg)](https://conventionalcommits.org)
[![pt-br](https://img.shields.io/badge/lang-pt--br-green.svg)](./README-pt-br.md)
[![love](https://img.shields.io/badge/Build%20With-%F0%9F%96%A4-lightgreen)](https://eugeniojimenes.dev)

My personal configuration for NixOS with the Sway compositor. The system itself (packages, services, login, one setup per machine) is a Nix flake. Everything under `$HOME` comes from GNU Stow modules that link the files into place.

## Table of contents
- [What is in here](#what-is-in-here)
- [Install on a new machine](#install-on-a-new-machine)
- [Using it as a base for your own](#using-it-as-a-base-for-your-own)
- [Daily use](#daily-use)
- [Modules](#modules)
- [Health check](#health-check)
- [Tests](#tests)
- [Cedilla with US keyboard layout](#cedilla-with-us-keyboard-layout)
- [Docs](#docs)
- [License](#license)
- [Code of conduct](#code-of-conduct)

## What is in here
- `flake.nix` and `nixos/` hold the system configuration. `nixos/common.nix` is shared by every machine, and `nixos/hosts/<hostname>/` holds what only that machine needs. There is no home-manager.
- Every top-level directory with dot-prefixed contents is a stow module. Stow mirrors the module's tree into `$HOME`, so `sway/.config/sway/config` becomes `~/.config/sway/config`. The list is in [Modules](#modules).
- `bin/check` and `tests/` run the tests. `docs/` explains how each part works and why.
- `AGENTS.md`, `CLAUDE.md`, `harness/` and the `.claude/`, `.agents/` and `.cursor/` directories hold instructions for AI coding agents. You can ignore them if you do not use one.

## Install on a new machine
1. Install NixOS with the graphical installer and pick no desktop. Create the user named in `nixos/common.nix`, or change that name first as described in [Using it as a base for your own](#using-it-as-a-base-for-your-own).

2. Clone the repo:
   ```sh
   nix-shell -p git --run 'git clone https://github.com/eugeniojimenes/dotfiles.git ~/dotfiles'
   ```

3. Prepare the host. A reinstall creates new disk UUIDs, so even a machine that already has its directory in `nixos/hosts/` needs its hardware config written again. A new machine also needs a `default.nix`, an entry in `flake.nix` and a Sway output file. [docs/machines.md](docs/machines.md) explains each one.
   ```sh
   cd ~/dotfiles
   mkdir -p nixos/hosts/<hostname>
   nixos-generate-config --show-hardware-config > nixos/hosts/<hostname>/hardware.nix
   # new machine only: write nixos/hosts/<hostname>/default.nix (start from hosts/loc-nixos),
   # add it to flake.nix and write sway/.config/sway/hosts/<hostname>
   git add nixos flake.nix sway   # a flake only sees files git tracks
   ```

4. Link the dotfiles before the first rebuild. The login manager starts Sway through `~/.config/sway/bin/start`, and that file only exists once the `sway` module is stowed. Move away any file a module would replace (`~/.bashrc` on a fresh system). Create the shared parent directories too: without them stow links `~/.local/share` as a whole into the `steam` module, and every app then writes its data into the repo.
   ```sh
   mkdir -p ~/.local/share ~/.local/bin ~/.claude
   nix-shell -p stow --run 'stow alacritty bash btop claude-code git lazyvim local-bin mise mpv opencode rubocop steam sway tmux'
   ```

5. Build the system and reboot into it. After the reboot greetd logs straight into Sway. The disk passphrase at boot already guards the machine, so there is no second password.
   ```sh
   sudo nixos-rebuild boot --flake ~/dotfiles#<hostname>
   reboot
   ```

6. Install what lives outside Nix: the language runtimes and CLIs from mise. Open Neovim once so lazy.nvim installs its plugins. The tmux plugins come with the system.
   ```sh
   mise install
   ```

7. Turn on the pre-commit hook, which refuses commits that hold a secret or a forbidden term: `git config core.hooksPath .githooks`.

8. With a US international keyboard, set up the cedilla as described in [Cedilla with US keyboard layout](#cedilla-with-us-keyboard-layout).

9. This step is for the owner only. Unlock the private repo with `~/.private/private unlock`. A fork skips it. The files in this repo that point there are all optional.

10. Run `dotfiles-doctor` to check the result. It lists anything still missing, and `dotfiles-doctor --fix` applies the safe repairs.

## Using it as a base for your own
The configuration is personal, so a fork needs a few edits before the install above.

- The user name `callmarx` is set once, as `user` at the top of `nixos/common.nix`. Use the name you picked in the installer, since changing it there creates a new user instead of renaming the existing one.
- Write your own host directory instead of reusing `nixos/hosts/loc-nixos/`. That one has NVIDIA PRIME bus IDs and Intel settings for one specific notebook.
- Time zone and console keymap are in `nixos/common.nix`. Keyboard layouts are in `sway/.config/sway/config.d/20-input`: every keyboard is US international by default, and the host file `sway/.config/sway/hosts/<hostname>` gives a built-in ABNT2 keyboard the Brazilian layout, matched by its name.
- Change the `[user]` section of `git/.gitconfig`. The work identity include points at a file that lives in my private repo, and git skips it when the file does not exist.
- The package list in `nixos/common.nix` is mine. Remove what you do not use.
- The `claude-code` module holds my global Claude Code instructions, which include English feedback for a Portuguese speaker. Leave it out of the `stow` command or replace its contents.
- Use your fork's URL in the clone step.

The term scan in `bin/check` and in the hook needs a list from my private repo. Without it the scan is skipped, so a fork needs nothing there.

## Daily use
```sh
sudo nixos-rebuild switch --flake ~/dotfiles                       # after editing nixos/, picks the host by hostname
bin/update                                                         # update everything, then the command it prints
sudo nixos-rebuild switch --rollback                               # back to the previous generation
stow <module>                                                      # link a module, from ~/dotfiles
stow -D <module>                                                   # remove its links, the files stay in the repo
```
A new file under `nixos/` needs `git add` before a rebuild sees it. Older generations are also in the boot menu.

`bin/update` (also System › Update in the Sway menu) updates the system, the mise tools and the Neovim plugins, and lists firmware updates. The tmux plugins come from nixpkgs with the system. The system takes the newest NixOS release that is at least 2 days old, or a newer one when it fixes a serious CVE on this machine, and it is tested, built and compared before you apply it with the command printed at the end. mise only installs releases that are at least 7 days old. [docs/nixos.md](docs/nixos.md#updating) explains why.

In Sway, `Super + Space` opens the menu and `Super + K` lists every key binding. In tmux, `prefix + ?` lists the bindings.

## Modules
- **Alacritty** (`alacritty/.config/alacritty/`): the terminal, with JetBrainsMono Nerd Font, padding, key bindings and Catppuccin Mocha colors. Opacity and text size change live from the Sway menu and the display panel.

- **Bash** (`bash/`): `.bashrc` loads `~/.config/bash/{env,shell,aliases,init}` and `inputrc`. The prompt is [starship](https://starship.rs/), configured in `bash/.config/starship.toml`.

- **btop** (`btop/.config/btop/`): Catppuccin Mocha theme with a transparent background.

- **Claude Code** (`claude-code/.claude/`): my global Claude Code config, with instructions in `CLAUDE.md`, custom skills in `skills/` and the status line script. Machine-local state such as `settings.json`, `settings.local.json` and per-project memory stays out of the repo. [docs/claude-code.md](docs/claude-code.md) explains why.

- **Git** (`git/`): colored output, `develop` as the default branch and a commit message template based on Conventional Commits. [docs/git.md](docs/git.md) covers the work identity.

- **Neovim** (`lazyvim/`): a LazyVim setup with Catppuccin Mocha and a transparent background. Inside tmux or over SSH, every yank also goes to the system clipboard through OSC 52. For a clean start, remove `~/.local/share/nvim` and `~/.local/state/nvim`.

- **local-bin** (`local-bin/.local/bin/`): personal scripts on `PATH`. `dotfiles-doctor` is the [health check](#health-check). `asdf` is a small shim that forwards to mise, because a work CLI calls `asdf` directly. Stow links this module file by file, since `~/.local/bin` also holds files that do not belong in the repo, such as the mise shims.

- **mise** (`mise/.config/mise/`): the version manager for Node, Python, Ruby, Rust, Go, uv and the agent CLIs. Their prebuilt binaries run on NixOS through `programs.nix-ld`.

- **mpv** (`mpv/.config/mpv/`): the video player, with the [uosc](https://github.com/tomasklaen/uosc) interface. uosc comes from nixpkgs through the mpv wrapper, pinned by `flake.lock`. [docs/mpv.md](docs/mpv.md) has the details.

- **OpenCode** (`opencode/.config/opencode/`): model, plugins, the context7 MCP server and TUI settings.

- **RuboCop** (`rubocop/`): the global `~/.rubocop.yml`, with `rubocop-performance`, `rubocop-rails` and `rubocop-rspec`.

- **Steam** (`steam/`): game launchers in `~/.local/share/applications/`. To run a game on the NVIDIA GPU, set its launch option to `prime-run %command%`.

- **Sway** (`sway/.config/sway/`): the whole desktop in one directory. It holds the Sway config, waybar (with the track that plays), a Quickshell menu that searches apps and settings together, a Quickshell notification daemon, the Quickshell calendar, display, sound (with a media card), power, network (cable and Wi-Fi) and Bluetooth panels, the lock screen, a wallpaper switcher for `~/Pictures/Wallpapers`, screenshots, screen recording, stay awake, night light, a power profile switch, clipboard history, a notice with a login window for public Wi-Fi login pages, an emoji picker and the screen-share picker (`bin/share-picker`, wired to the portal in `nixos/common.nix`). The config is split by topic in `config.d/`, scripts are in `bin/` and app configs in `apps/`. `bin/start` puts the integrated GPU first, so the NVIDIA GPU only drives the outputs wired to it. [docs/sway.md](docs/sway.md) has the details.

- **tmux** (`tmux/`): the prefix is `Ctrl + \` (or `Ctrl + b`). Snapshots are manual: `prefix + Ctrl-s` saves and `prefix + Ctrl-r` restores sessions, layouts and working directories, without relaunching programs. `Super + Alt + Return` attaches to the main server when nothing is attached to it, and otherwise opens an independent one. Neovim sessions are on `<leader>qs`. [docs/tmux.md](docs/tmux.md) has the details.

## Health check
`dotfiles-doctor` checks the stow state, the commands `nixos/common.nix` should provide, the mise tools, the plugin installs and the machine-local files. By default it only reads and prints the repair for each problem. `--fix` applies the safe ones.
```sh
dotfiles-doctor
dotfiles-doctor --fix
~/dotfiles/local-bin/.local/bin/dotfiles-doctor   # before local-bin is stowed
```
A stow conflict (a real file where a symlink belongs) is never fixed automatically. Compare the file with the repo first. [docs/dotfiles-doctor.md](docs/dotfiles-doctor.md) describes every check.

## Tests
`bin/check` runs the test layers through the flake checks. The tools come from the pinned nixpkgs, so nothing needs to be installed. Run it before every commit. The flake only sees tracked files, so `git add` new files first.
```sh
bin/check           # everything: static, unit, eval of each host, then the employer-term scan
bin/check static    # format (nix fmt would change nothing), shellcheck, statix, sway -C per host, qmllint, panels loaded in headless Sway, waybar JSON, tmux config loaded by the pinned tmux, Sway paths, the colour palette and the text format of panel texts, em-dash sweep, doc pairs, every spec criterion mapped to a test that exists, valid frontmatter in the agent rules and skills, stow dry run, gitleaks
bin/check unit      # bats tests in tests/unit/, scripts run against stubbed commands
bin/check terms     # local only: tracked files and paths against the term list in ~/.private, skipped when it is locked
nix develop         # shell with the same tools, to run one of them by hand
nix fmt             # format the repo: Nix, shell, Lua, TOML, CSS, JSON, YAML, JS (treefmt.nix, style in .editorconfig)
```
GitLab CI runs `nix flake check -L` on every push to `sway` and `develop`. That covers every layer except `terms`. Hardware and live-session checks are in [tests/manual.md](tests/manual.md). When items pass, `bin/manual-pass "<item>"...` records them in `tests/manual-passes.toml`, which keeps the last pass of each item per machine with the machine and the software versions it passed on (`-n` shows the result first, `--with` adds the peripherals used, or `agent-driven` when an agent ran the check), and the feature specs that list what each test covers are in [docs/specs/](docs/specs/README.md).

The pre-commit hook in `.githooks/` refuses a commit when a staged file or path holds a forbidden term (`bin/check terms --cached`) or the staged changes hold a secret (`gitleaks git --staged`). The commit-msg hook next to it does the same term check on the commit message, and the pre-push hook runs both scans on every commit about to be pushed, so commits rewritten by a rebase or a squash are checked too. It prints `file:line` and never the value. Git only runs it once the clone points at it, so enable it in each clone with `git config core.hooksPath .githooks` (`dotfiles-doctor --fix` does the same). The hook runs locally only, and CI runs the same scans through `bin/check`, except `terms`. To skip it once, use `git commit --no-verify`. [docs/public-repo.md](docs/public-repo.md) lists what each scan misses.

## Cedilla with US keyboard layout
The US international layout turns `'` followed by `c` into ć. To get ç, add an override at the end of `~/.XCompose`, which is machine-local and not in the repo:
```sh
cat >>~/.XCompose <<'XC'
include "%L"

# Cedilla on us/intl: dead_acute + c gives ç, not ć. Later definition wins over the system Compose above.
<dead_acute> <c> : "ç" ccedilla
<dead_acute> <C> : "Ç" Ccedilla
XC
```
Restart the apps to pick it up. To check, `xkbcli compile-compose | grep '<dead_acute> <c>'` should print ç. Chromium and Electron apps (Brave, Slack) ignore `~/.XCompose` and compose with a built-in table that gives ć, so they get their keys through fcitx5 instead, an input method that composes with the same library and reads that file. `nixos/common.nix` installs it with a keyboard-only config in `/etc/xdg/fcitx5`, and Sway starts it. The notebook's built-in ABNT2 keyboard has its own ç key and needs nothing.

## Docs
[docs/](docs/README.md) explains how each part works and why: NixOS, machines, Sway, tmux, git, the public repo rules, Claude Code, dotfiles-doctor and mpv. Each page also has a Portuguese version.

## License
Open source under the MIT license. See [LICENSE](/LICENSE). Third-party files and their licenses are listed in [THIRD-PARTY.md](/THIRD-PARTY.md).

## Code of conduct
I am committed to providing a friendly, safe and welcoming environment for all. Please read and respect the [Code of Conduct](/code_of_conduct.md).
