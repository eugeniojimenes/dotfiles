# Dotfiles

[![License](https://img.shields.io/badge/License-MIT-lightgray)](/LICENSE)
[![Contributor Covenant](https://img.shields.io/badge/Contributor%20Covenant-2.0-lightblue)](/code_of_conduct.md)
[![Conventional Commits](https://img.shields.io/badge/Conventional%20Commits-1.0.0-yellow.svg)](https://conventionalcommits.org)
[![pt-br](https://img.shields.io/badge/lang-pt--br-green.svg)](./README-pt-br.md)
[![love](https://img.shields.io/badge/Build%20With-%F0%9F%96%A4-lightgreen)](https://eugeniojimenes.dev)

My personal config files (dotfiles) for NixOS with the Sway compositor. System config in `nixos/`, everything under `$HOME` managed with GNU Stow.

## Table of contents
- [Quickstart](#quickstart)
- [System config (NixOS)](#system-config-nixos)
- [Apply dotfiles with GNU Stow](#apply-dotfiles-with-gnu-stow)
  - [About each module](#about-each-module)
- [Health check](#health-check)
- [Cedilla with US keyboard layout](#cedilla-with-us-keyboard-layout)
- [License](#license)
- [Code of conduct](#code-of-conduct)

## Quickstart
Fresh NixOS install (graphical installer, no desktop):
```sh
nix-shell -p git --run 'git clone https://github.com/eugeniojimenes/dotfiles.git ~/dotfiles'
```
Then [System config](#system-config-nixos), then [Stow](#apply-dotfiles-with-gnu-stow).

## System config (NixOS)
`nixos/configuration.nix` = packages, services, Sway, NVIDIA, login. Not a stow module. `/etc/nixos/configuration.nix` imports it next to the machine's own `hardware-configuration.nix`:
```sh
echo '{ imports = [ ./hardware-configuration.nix /home/<user>/dotfiles/nixos/configuration.nix ]; }' |
  sudo tee /etc/nixos/configuration.nix
sudo nixos-rebuild boot && reboot
```
Day to day:
```sh
sudo nixos-rebuild switch            # after editing configuration.nix
sudo nixos-rebuild switch --upgrade  # update packages from the channel
sudo nixos-rebuild switch --rollback # back to the previous generation
```
Channels, no flakes, no home-manager: system state lives in `configuration.nix`, user config in the stow modules below. The file targets one notebook (Intel + NVIDIA PRIME); user name, hostname and GPU bus IDs are in it, adjust before using elsewhere.

## Apply dotfiles with GNU Stow
Stow manages symlinks from repo into `$HOME`. Move away anything a module would replace first (`~/.bashrc` on a fresh system).
```sh
cd ~/dotfiles
stow alacritty bash btop claude-code git lazyvim local-bin mise mpv omp opencode rubocop steam sway tmux
stow -D <module>   # remove a module's symlinks, files stay in the repo
```

### About each module:
1. **Alacritty**: `alacritty/.config/alacritty/`. JetBrainsMono Nerd Font, padding, keybindings, Catppuccin Mocha colors. Opacity and text size are set live from the Sway menu and display panel.

2. **Bash**: `bash/`. `.bashrc` loads `~/.config/bash/{env,shell,aliases,init}` and `inputrc`. Prompt by [starship](https://starship.rs/) (`bash/.config/starship.toml`).

3. **btop**: `btop/.config/btop/`. Catppuccin Mocha theme, transparent background.

4. **Claude Code**: `claude-code/.claude/`. Global Claude Code config: `CLAUDE.md` (instructions), custom skills (`skills/`), `statusline-command.sh`. Machine-local state (`settings.json`, `settings.local.json`, per-project memory) stays out of repo.

5. **Git**: `git/`. Colored output, `develop` as default branch, commit message template inspired by Conventional Commits.

6. **Neovim (LazyVim)**: `lazyvim/`. Catppuccin Mocha with transparent background. Inside tmux or SSH, yanks also go out as OSC 52. Clean start: `rm -rf ~/.local/share/nvim ~/.local/state/nvim`.

7. **mise** (tool version manager): `mise/.config/mise/`. Node, Python, Ruby, Rust, Go, uv and agent CLIs. Prebuilt binaries run on NixOS through `programs.nix-ld`.
  ```sh
  mise install
  ```

8. **mpv**: `mpv/.config/mpv/`. UI = [uosc](https://github.com/tomasklaen/uosc), installed by its own script, not tracked. `stow mpv` first, then:
  ```sh
  curl -fsSL https://raw.githubusercontent.com/tomasklaen/uosc/HEAD/installers/unix.sh | bash
  ```
  uosc updates itself from its menu (**Update uosc**). Notes in `mpv/.config/mpv/README.md`.

9. **RuboCop**: `rubocop/`. Global config (`~/.rubocop.yml`) with `rubocop-performance`, `rubocop-rails`, `rubocop-rspec`.

10. **Steam**: `steam/`. Game launchers in `~/.local/share/applications/`. Games on the NVIDIA GPU: launch option `prime-run %command%`.

11. **Sway**: `sway/.config/sway/`. Whole desktop in one directory: config, waybar, mako, fuzzel menu (`Super + Space`), Quickshell calendar, display panel and lock screen, wallpaper switcher (`~/Pictures/Wallpapers`), screenshots, Wi-Fi picker, screen-share picker (`sway/.config/xdg-desktop-portal-wlr/sway`). `Super + K` lists every keybinding. `start` puts the integrated GPU first so the dGPU only drives its own outputs.

12. **tmux**: `tmux/`. Prefix `Ctrl + \` (or `Ctrl + b`), `prefix + ?` lists bindings. Plugin manager outside `~/.config/tmux`:
  ```sh
  git clone https://github.com/tmux-plugins/tpm ~/.local/share/tmux/plugins/tpm
  ```
  Inside tmux, `prefix + I` installs plugins. Snapshots are manual: `prefix + Ctrl-s` saves, `prefix + Ctrl-r` restores sessions, layouts and cwds (no programs relaunched). `Super + Alt + Return` attaches to the main server when nothing is attached, else opens an independent one. Neovim sessions: `<leader>qs`.

13. **oh-my-pi (omp)**: `omp/.omp/`. Config and a TUI mode-badge extension for the oh-my-pi agent.

14. **OpenCode**: `opencode/.config/opencode/`. Model, plugins, context7 MCP, TUI settings.

## Health check
`dotfiles-doctor` checks stow state, commands from `configuration.nix`, mise tools, plugin installs and machine-local files. Read-only by default, prints the repair for each problem; `--fix` applies the safe ones.
```sh
dotfiles-doctor
dotfiles-doctor --fix
~/dotfiles/local-bin/.local/bin/dotfiles-doctor   # before local-bin is stowed
```
Stow conflicts (real file where a symlink belongs) are never auto-fixed: diff against the repo first.

## Cedilla with US keyboard layout
US international maps `'` + `c` to ć. Override at the end of `~/.XCompose` (machine-local, not in repo):
```sh
cat >>~/.XCompose <<'XC'
include "%L"

# Cedilla on us/intl: dead_acute + c gives ç, not ć. Later definition wins over the system Compose above.
<dead_acute> <c> : "ç" ccedilla
<dead_acute> <C> : "Ç" Ccedilla
XC
```
Restart apps to pick it up. Check: `xkbcli compile-compose | grep '<dead_acute> <c>'` prints ç. The built-in ABNT2 keyboard has its own ç key and needs nothing.

## License
Open source under MIT license. See [LICENSE](/LICENSE). Third-party files and their licenses: [THIRD-PARTY.md](/THIRD-PARTY.md).

## Code of conduct
I am committed to providing a friendly, safe, and welcoming environment for all. Please read and respect the [Code of Conduct](/code_of_conduct.md).
