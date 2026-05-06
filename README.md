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
  - [Lazygit and Lazydocker](#lazygit-and-lazydocker)
  - [Cedilla with US keyboard layout](#cedilla-with-us-keyboard-layout)
  - [English Notes logging (Claude Code)](#english-notes-logging-claude-code)
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
stow steam
stow tmux
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

7. **mise** (tool version manager): setup is under `mise/.config/mise/`.
  This setup uses [mise](https://mise.jdx.dev/getting-started.html) for managing tool versions.

  - Global tools and versions are defined in ~/dotfiles/mise/.config/mise/config.toml.
  - As noted above in [Packages required by my dotfiles](#packages-required-by-my-dotfiles), ensure `mise` and `usage` are installed.

  ```sh
  # Install the declared tools
  mise install
  ```

8. **mpv**: setup is under `mpv/.config/mpv/`.

9. **Steam**: setup is under `steam/`. Custom `.desktop` files for Steam and games, placed in `~/.local/share/applications/`.

10. **tmux**: setup is under `tmux/`.
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

### English Notes logging (Claude Code)
The `claude-code` module includes an automated logger for the "English Notes" feedback that Claude appends to every response. It captures each correction into a local SQLite database so I can review recurring patterns without asking Claude to recall them across sessions.

**How it works:**
- Claude appends an "English Notes" section after every reply (per `claude-code/.claude/CLAUDE.md`).
- Following that section, Claude emits a hidden JSON payload wrapped in an HTML comment (`<!-- english-notes ... -->`). The comment is invisible in the rendered chat but present in the session transcript. Each entry has the wrong/correct text, a canonical `rule_id` from `claude-code/.claude/english-rules.md`, the category, and a `pt_calque` flag for Portuguese-to-English literal mappings.
- A `Stop` hook (`claude-code/.claude/hooks/log-english-notes.sh`) parses that payload from the transcript and inserts each correction as a row in `~/.claude/english-notes.db`.
- The DB stays out of this repo (machine-local data only).

**Token cost:** the skinny rule index in `CLAUDE.md` adds ~350 tokens per turn (cached most of the time). The full taxonomy (`english-rules.md`) is read only by the bash hook — zero tokens for Claude.

**Manual setup steps:**

1) Stow the module (creates the `~/.claude/` symlinks):
```sh
cd ~/dotfiles
stow claude-code
```

2) Make sure `jq` and `sqlite3` are installed (Arch usually has both):
```sh
sudo pacman -S --needed jq sqlite
```

3) Initialize the database schema (idempotent — safe to re-run):
```sh
~/.claude/hooks/init-english-db.sh
```

The `Stop` hook is already registered in `claude-code/.claude/settings.json` (which stows into `~/.claude/settings.json`), so no manual edit is needed. Machine-specific overrides go in `~/.claude/settings.local.json`, which is not tracked here.

4) (Optional) Backfill historical English Notes from past Claude Code transcripts:
```sh
~/.claude/hooks/backfill-english-notes.sh
```
This regex-extracts notes from `~/.claude/projects/**/*.jsonl` and inserts them with `source='backfill'`. Best-effort parsing — older notes lack the JSON block, so most fields land in the `raw` column only.

**Querying the data:**
```sh
# Top recurring rules
~/.claude/bin/eng-stats top

# Portuguese-calque mistakes only
~/.claude/bin/eng-stats calques

# Free-text search
~/.claude/bin/eng-stats search worth

# By project / by month
~/.claude/bin/eng-stats by-project
~/.claude/bin/eng-stats by-month
```

Or query `~/.claude/english-notes.db` directly with `sqlite3`.


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
