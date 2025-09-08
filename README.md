# Dotfiles

[![License](https://img.shields.io/badge/License-MIT-lightgray)](/LICENSE)
[![Contributor Covenant](https://img.shields.io/badge/Contributor%20Covenant-2.0-lightblue)](/code_of_conduct.md)
[![Conventional Commits](https://img.shields.io/badge/Conventional%20Commits-1.0.0-yellow.svg)](https://conventionalcommits.org)
[![pt-br](https://img.shields.io/badge/lang-pt--br-green.svg)](./README-pt-br.md)
[![love](https://img.shields.io/badge/Build%20With-%F0%9F%96%A4-lightgreen)](https://callmarx.github.io)

A curated set of my personal configuration files (dotfiles) for Arch-based systems, designed to be managed with GNU Stow. This setup currently targets an Omarchy-based environment, but most pieces work on any Arch install.


## Table of contents
- [Quickstart](#quickstart)
- [Omarchy customization](#omarchy-customization)
- [Packages required](#packages-required-by-my-dotfiles)
- [Apply dotfiles with GNU Stow](#apply-dotfiles-with-gnu-stow)
  - [About each module](#about-each-module)
- [Unstow (remove symlinks)](#unstow-remove-symlinks)
- [Other tools and setups](#other-tools-and-setups)
  - [Lazygit](#lazygit)
  - [Zettelkasten (zk) notes](#zettelkasten-zk-notes)
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
git clone https://github.com/callmarx/dotfiles.git ~/dotfiles
cd ~/dotfiles
```

If you want the Omarchy-focused configuration, use the Omarchy branch if present:
```sh
git checkout feat/omarchy
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

## Packages required by my dotfiles
```sh
## Bash customization and local bin (via mise):
sudo pacman -S mise usage starship

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
mv ~/.tmux.conf ~/.tmux.conf.bkp 2>/dev/null

# Stow the modules you want
stow alacritty
stow bash
stow git
stow hypr
stow lazyvim
stow mise
stow mpv
stow tmux
# Optional isolated Neovim profile
# stow scratch-nvim
```

### About each module:
1. Neovim (LazyVim): setup is under `lazyvim/`. After stowing:
  ```sh
  # Optional: clear all local Neovim plugins/data before first run
  rm -rf ~/.local/share/nvim/*
  ```

2. (optional) Scratch Neovim
  A separate, isolated Neovim profile for testing or demos lives under `scratch-nvim/`.

  To use it:
  1. stow it to create `~/.config/scratch-nvim`:
  ```sh
  cd ~/dotfiles
  stow scratch-nvim
  ```

  2. Use `NVIM_APPNAME` to run it
  ```sh
  NVIM_APPNAME=scratch-nvim nvim
  ```

2. Hyprland: setup is under `./hypr/.config`.

3. mpv: setup is under `./mpv/.config/`.

4. tmux: setup is under `./tmux/`.
  Install tmux and plugins:
  ```sh
  sudo pacman -S tmux
  mkdir -p ~/.tmux/plugins
  # Plugin manager
  git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
  # Theme (pinned)
  git clone -b v2.1.3 https://github.com/catppuccin/tmux.git ~/.tmux/plugins/catppuccin

  # Then stow the tmux config (if you haven't yet)
  cd ~/dotfiles
  stow tmux
  ```

5. mise (tool version manager): setup is under `./mise/.config/mise/`.
  This setup uses [mise](https://mise.jdx.dev/getting-started.html) for managing tool versions.

  - Global tools and versions are defined in ~/dotfiles/mise/.config/mise/config.toml.
  - As noted above in [Packages required by my dotfiles](#packages-required-by-my-dotfiles), ensure `mise` and `usage` are installed.

  ```sh
  # Install the declared tools
  mise install
  ```

6. Bash (customized with Starship): setup is under `./bash/`.
  I use `bash` with [starship](https://starship.rs/guide/).
  **Note:** As noted above in [Packages required by my dotfiles](#packages-required-by-my-dotfiles), ensure `starship` is installed.

7. Git: setup is under `./git/`.
  General configuration:
  - enables colored output,
  - sets `develop` as the default branch,
  - wires a commit message template inspired by Conventional Commits.

## Unstow (remove symlinks)
If you want to remove symlinks created by Stow (without deleting your files), use `-D`:
```sh
# From the repo root
cd ~/dotfiles
stow -D lazyvim
stow -D hypr
# ...and so on for any module you want to detach
```


## Other tools and setups

### Lazygit
Install Lazygit:
```sh
sudo pacman -S lazygit
```

**Note:** if you keep a personal Lazygit config, symlink it into `~/.config/lazygit/config.yml`. I personally use the default configuration.

### Zettelkasten (zk) notes
I use [zk](https://github.com/zk-org/zk) for a Zettelkasten-style note system, often alongside Neovim.

Install:
```sh
sudo pacman -S zk bat
```

Helpful resources:
- Daily journal docs: https://github.com/mickael-menu/zk/blob/main/docs/daily-journal.md
- Getting started tips: https://github.com/zk-org/zk/blob/main/docs/tips/getting-started.md
- Video walkthrough that helped me: https://youtu.be/UzhZb7e4l4Y


### Cedilla with US keyboard layout
This is my personal workaround to type "ç" on an English (US, international with dead keys) layout. Please apply with caution, as system files may be overwritten by updates.

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
rm -rf ~/.local/share/nvim/*
```

## License
This project is available as open source under the MIT license. See [LICENSE](/LICENSE).


## Code of conduct
I am committed to providing a friendly, safe, and welcoming environment for all. Please read and respect the [Code of Conduct](/code_of_conduct.md).
