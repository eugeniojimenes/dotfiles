# Dotfiles

[![License](https://img.shields.io/badge/License-MIT-lightgray)](/LICENSE)
[![Contributor Covenant](https://img.shields.io/badge/Contributor%20Covenant-2.0-lightblue)](/code_of_conduct.md)
[![Conventional Commits](https://img.shields.io/badge/Conventional%20Commits-1.0.0-yellow.svg)](https://conventionalcommits.org)
[![pt-br](https://img.shields.io/badge/lang-pt--br-green.svg)](./README-pt-br.md)
[![love](https://img.shields.io/badge/Build%20With-%F0%9F%96%A4-lightgreen)](https://eugeniojimenes.dev)

A curated set of my personal configuration files (dotfiles) for Arch-based systems, designed to be managed with GNU Stow. This setup currently targets an Omarchy-based environment, but most pieces work on any Arch install.


## Table of contents
- [Quickstart](#quickstart)
- [Omarchy customization](#omarchy-customization)
  - [Omarchy updates write into this repo](#omarchy-updates-write-into-this-repo)
  - [Omarchy 4 upgrade note](#omarchy-4-upgrade-note)
- [Packages required](#packages-required-by-my-dotfiles)
- [Apply dotfiles with GNU Stow](#apply-dotfiles-with-gnu-stow)
  - [About each module](#about-each-module)
  - [Unstow (remove symlinks)](#unstow-remove-symlinks)
- [Other tools and setups](#other-tools-and-setups)
  - [Lazygit and Lazydocker](#lazygit-and-lazydocker)
  - [Cedilla with US keyboard layout](#cedilla-with-us-keyboard-layout)
- [Optional: clear Neovim plugins](#optional-clear-neovim-plugins)
- [License](#license)
- [Code of conduct](#code-of-conduct)


## Quickstart
Prerequisites:
- Arch-based distro (or Omarchy)
- `git` and `stow` installed
- `yay` available if you want to install AUR packages

```sh
sudo pacman -S --needed git stow
```

Clone and enter this repository:
```sh
git clone https://github.com/eugeniojimenes/dotfiles.git ~/dotfiles
cd ~/dotfiles
```

## Omarchy customization
I use Omarchy to bootstrap the machine. See the official docs for getting started:
- https://omarchy.org/
- https://manuals.omamix.org/2/the-omarchy-manual/50/getting-started

Common customizations I do:

1) Remove apps/packages I don't use
```sh
# Example: remove gnome-keyring
omarchy-pkg-remove
# or directly via yay:
yay -Rs gnome-keyring

# Example: remove bundled web apps (twitter, youtube, etc.)
omarchy-webapp-remove
```

2) Install a couple of extra packages
```sh
# via Omarchy helper
omarchy-pkg-install
# or directly via yay:
yay -S google-chrome # `rocm-smi-lib` for AMD GPU required by `btop`
```

### Omarchy updates write into this repo
Every module here is stowed at the *directory* level (`~/.config/hypr` → `~/dotfiles/hypr/.config/hypr`), and Omarchy ships config changes by running `sed -i` / `cp` against `~/.config/...` in its migrations. Those writes resolve through the directory symlink and land on the **real files in this repo**, so after an `omarchy-update` a `git status` may show changes nobody here made. Review the diff and keep what's wanted — don't discard it reflexively.

The corollary: never point a file inside a stowed module at a path outside the repo. Omarchy's migrations are guarded by `[[ -f ... ]]`, which is false for a dangling symlink, so the update is skipped in silence and the two machines drift apart.

### Omarchy 4 upgrade note
Omarchy 4 moves the active theme from `~/.config/omarchy/current` to `~/.local/state/omarchy/current` (see the comments in `/usr/bin/omarchy-nvim-setup`). These files hardcode the 3.x path and need the new one after upgrading:

| File | Line |
|---|---|
| `hypr/.config/hypr/hyprland.conf` | `source = ~/.config/omarchy/current/theme/hyprland.conf` |
| `hypr/.config/hypr/hyprlock.conf` | `source = ...`, plus `path = ~/.config/omarchy/current/background` |
| `alacritty/.config/alacritty/alacritty.toml` | `general.import = [...]` |

Hyprland's `source =` and Alacritty's `general.import` can't probe two locations, so these are a manual edit. Omarchy's own migrations may rewrite them first — see the note above. Neovim needs nothing: `lazyvim/.config/nvim/lua/plugins/theme.lua` already tries both paths at runtime.

## Packages required by my dotfiles
```sh
## Bash customization and local bin (via mise):
sudo pacman -S usage # mise and starship packages is installed by omarchy
```

## Apply dotfiles with GNU Stow
Stow manages symlinks from this repo into your $HOME. I typically back up existing configs first.

```sh
cd ~/dotfiles

# Backup any existing configs (optional but recommended)
mv ~/.config/alacritty ~/.config/alacritty.bkp 2>/dev/null
mv ~/.bashrc ~/.bashrc.bkp 2>/dev/null
mv ~/.bash_profile ~/.bash_profile.bkp 2>/dev/null
mv ~/.config/starship.toml ~/.config/starship.toml.bkp 2>/dev/null
mv ~/.gitconfig ~/.gitconfig.bkp 2>/dev/null
mv ~/.config/hypr ~/.config/hypr.bkp 2>/dev/null
mv ~/.config/nvim ~/.config/nvim.bkp 2>/dev/null
mv ~/.config/mise ~/.config/mise.bkp 2>/dev/null
mv ~/.config/mpv ~/.config/mpv.bkp 2>/dev/null
mv ~/.rubocop.yml ~/.rubocop.yml.bkp 2>/dev/null
mv ~/.claude ~/.claude.bkp 2>/dev/null

# Stow the modules you want
stow alacritty
stow bash
stow claude-code
stow git
stow hypr
stow lazyvim
stow mise
stow mpv
stow rubocop
stow steam
stow tmux
stow omp
stow opencode
```

### Unstow (remove symlinks)
If you want to remove symlinks created by Stow (without deleting your files), use `-D`:
```sh
# From the repo root
cd ~/dotfiles
stow -D lazyvim
stow -D hypr
# ...and so on for any module you want to detach
```

### About each module:
1. **Alacritty**: setup is under `alacritty/.config/alacritty/`. Customizes font (JetBrainsMono Nerd Font), padding, keybindings, and imports the current Omarchy theme.

2. **Bash** (customized with Starship): setup is under `bash/`.
  I use `bash` with [starship](https://starship.rs/guide/).
  **Note:** As noted above in [Packages required by my dotfiles](#packages-required-by-my-dotfiles), ensure `starship` is installed.

3. **Claude Code**: setup is under `claude-code/.claude/`. Global Claude Code config — includes `CLAUDE.md` (instructions), custom skills (`skills/`), and persistent memory (`memory/`). Stow it to place at `~/.claude/`.

4. **Git**: setup is under `git/`.
  General configuration:
  - enables colored output,
  - sets `develop` as the default branch,
  - wires a commit message template inspired by Conventional Commits.

5. **Hyprland**: setup is under `hypr/.config/hypr/`.

6. **Neovim (LazyVim)**: setup is under `lazyvim/`. After stowing:
  ```sh
  # Optional: clear all local Neovim plugins/data before first run
  rm -rf ~/.local/share/nvim
  rm -rf ~/.local/state/nvim
  # After setup mise (described below):
  gem install neovim # for ruby support in Neovim
  yay -S tree-sitter-cli-git # official tree-sitter-cli package is often outdated
  ```

  **Relationship to Omarchy's Neovim config.** Omarchy ships its own LazyVim config through the `omarchy-nvim` package (`/usr/share/omarchy-nvim/config/`, seeded to `/etc/skel` for new users). Since this repo owns `~/.config/nvim`, `omarchy-nvim-setup` leaves it alone. Two of Omarchy's files are therefore **vendored** here as real files rather than symlinked — symlinking them outside the repo makes the config unreproducible on a second machine:

  - `lua/plugins/all-omarchy-themes.lua` — preloads every Omarchy colorscheme so theme hot-reloading switches instantly. Omarchy never refreshes this after install, so check for drift now and then:
    ```sh
    diff /usr/share/omarchy-nvim/config/lua/plugins/all-themes.lua \
         ~/dotfiles/lazyvim/.config/nvim/lua/plugins/all-omarchy-themes.lua
    ```
  - `plugin/after/transparency.lua` — strips highlight backgrounds. Omarchy patches this one in place via migrations, so it may show up in `git status` after an update.

  `lua/plugins/theme.lua` resolves the active theme at runtime instead of symlinking it, so the same commit works on Omarchy 3.x and 4.x. See [Omarchy 4 upgrade note](#omarchy-4-upgrade-note).

7. **mise** (tool version manager): setup is under `mise/.config/mise/`.
  This setup uses [mise](https://mise.jdx.dev/getting-started.html) for managing tool versions.

  - Global tools and versions are defined in ~/dotfiles/mise/.config/mise/config.toml.
  - As noted above in [Packages required by my dotfiles](#packages-required-by-my-dotfiles), ensure `mise` and `usage` are installed.

  ```sh
  # Install the declared tools
  mise install
  ```

8. **mpv**: setup is under `mpv/.config/mpv/`.

9. **RuboCop**: setup is under `rubocop/`. Global RuboCop config (`rubocop/.rubocop.yml` → `~/.rubocop.yml`). Enables the `rubocop-performance`, `rubocop-rails`, and `rubocop-rspec` plugins and a couple of extra cops.

10. **Steam**: setup is under `steam/`. Custom `.desktop` files for Steam and games, placed in `~/.local/share/applications/`.

11. **tmux**: setup is under `tmux/`.
  Install tmux and TPM, then stow:
  ```sh
  sudo pacman -S tmux
  mkdir -p ~/.config/tmux/plugins
  # Plugin manager
  git clone https://github.com/tmux-plugins/tpm ~/.config/tmux/plugins/tpm

  # Stow the tmux config
  cd ~/dotfiles
  stow tmux
  ```

  **NOTE:** Inside tmux, install plugins (tmux-resurrect, tmux-continuum, etc.) with `prefix + I` (with my prefix will be `CTRL+\ + I` or `CTRL+b + I`)

12. **oh-my-pi (omp)**: setup is under `omp/.omp/`. Config for the oh-my-pi agent — a TUI mode-badge extension (`agent/extensions/`). Stows to `~/.omp/`.

13. **OpenCode**: setup is under `opencode/.config/opencode/`. OpenCode config — model, plugins (ponytail, caveman), context7 MCP, and TUI settings. Stows to `~/.config/opencode/`.


## Other tools and setups

### Lazygit and Lazydocker
I'm using Lazygit and lazydocker for quick terminal-based git and docker management. These tools are installed by default with Omarchy, but if you need to install them manually:
```sh
sudo pacman -S lazygit lazydocker
```

**Note:** if you keep a personal Lazygit config, symlink it into `~/.config/lazygit/config.yml`. I personally use the default configuration.

### Cedilla with US keyboard layout
This is my personal workaround to type "ç" on an English (US, international with dead keys) keyboard layout. Please apply with caution and be aware that system files may be overwritten by updates.

1) Set your system keyboard layout to: English (US, international with dead keys).

For Hyprland, edit `~/.config/hypr/hyprland.conf` or `~/.config/hypr/input.conf`:
```conf
# Example for Brazilian and US keyboard layouts
input {
  kb_layout = br, us
  kb_variant = abnt2,intl
  kb_options = compose:caps,grp:alt_space_toggle
}
```

2) Edit the GTK immodules caches (paths vary by distro/versions):
```sh
sudo vim /usr/lib/gtk-3.0/3.0.0/immodules.cache
sudo vim /usr/lib/gtk-2.0/2.10.0/immodules.cache
```
Change the line:
```
"cedilla" "Cedilla" "gtk20" "/usr/share/locale" "az:ca:co:fr:gv:oc:pt:sq:tr:wa"
```
To:
```
"cedilla" "Cedilla" "gtk20" "/usr/share/locale" "az:ca:co:fr:gv:oc:pt:sq:tr:wa:en"
```

3) Replace "ć" with "ç" and "Ć" with "Ç" in `/usr/share/X11/locale/en_US.UTF-8/Compose`:
```sh
sudo cp /usr/share/X11/locale/en_US.UTF-8/Compose /usr/share/X11/locale/en_US.UTF-8/Compose.bak
sed 's/ć/ç/g' < /usr/share/X11/locale/en_US.UTF-8/Compose | sed 's/Ć/Ç/g' > Compose
sudo mv Compose /usr/share/X11/locale/en_US.UTF-8/Compose
```

4) Reboot the computer.


## Optional: clear Neovim plugins
If you want a clean Neovim start:
```sh
rm -rf ~/.local/share/nvim
rm -rf ~/.local/state/nvim
```

## License
This project is available as open source under the MIT license. See [LICENSE](/LICENSE).


## Code of conduct
I am committed to providing a friendly, safe, and welcoming environment for all. Please read and respect the [Code of Conduct](/code_of_conduct.md).
