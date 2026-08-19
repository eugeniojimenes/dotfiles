# Dotfiles

[![License](https://img.shields.io/badge/License-MIT-lightgray)](/LICENSE)
[![Contributor Covenant](https://img.shields.io/badge/Contributor%20Covenant-2.0-lightblue)](/code_of_conduct.md)
[![Conventional Commits](https://img.shields.io/badge/Conventional%20Commits-1.0.0-yellow.svg)](https://conventionalcommits.org)
[![pt-br](https://img.shields.io/badge/lang-pt--br-green.svg)](./README-pt-br.md)
[![love](https://img.shields.io/badge/Build%20With-%F0%9F%96%A4-lightgreen)](https://eugeniojimenes.dev)

My personal config files (dotfiles) for Arch-based systems, managed with GNU Stow. Targets Omarchy-based environment, but most pieces work on any Arch install.


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
- `yay` if want AUR packages

```sh
sudo pacman -S --needed git stow
```

Clone and enter repo:
```sh
git clone https://github.com/eugeniojimenes/dotfiles.git ~/dotfiles
cd ~/dotfiles
```

## Omarchy customization
Omarchy bootstraps machine. Official docs:
- https://omarchy.org/
- https://manuals.omamix.org/2/the-omarchy-manual/50/getting-started

Common customizations:

1) Remove unused apps/packages
```sh
# Example: remove gnome-keyring
omarchy-pkg-remove
# or directly via yay:
yay -Rs gnome-keyring

# Example: remove bundled web apps (twitter, youtube, etc.)
omarchy-webapp-remove
```

2) Install extra packages
```sh
# via Omarchy helper
omarchy-pkg-install
# or directly via yay:
yay -S google-chrome
yay -S rocm-smi-lib # required by `btop` to read an AMD GPU
```

### Omarchy updates write into this repo
Every module stowed at *directory* level (`~/.config/hypr` → `~/dotfiles/hypr/.config/hypr`). Omarchy ships config changes by running `sed -i` / `cp` against `~/.config/...` in migrations. Those writes resolve through directory symlink and land on **real files in this repo**. So after `omarchy-update`, `git status` may show changes nobody here made. Review diff, keep what wanted. No reflexive discard.

Corollary: never point file inside stowed module at path outside repo. Omarchy migrations guarded by `[[ -f ... ]]`, false for dangling symlink, so update skipped silent and two machines drift apart.

### Omarchy 4 upgrade note
**Theme path moved.** Omarchy 4 moves active theme from `~/.config/omarchy/current` to `~/.local/state/omarchy/current` (see comments in `/usr/bin/omarchy-nvim-setup`). These files hardcode 3.x path, need new one after upgrade:

| File | Line |
|---|---|
| `alacritty/.config/alacritty/alacritty.toml` | `general.import = [...]` |

Hyprland `source =` and Alacritty `general.import` can't probe two locations. Edit manually. Omarchy migrations may rewrite them first, see note above. Neovim needs nothing: `lazyvim/.config/nvim/lua/plugins/theme.lua` already tries both paths at runtime.

**Hyprland config moved to Lua.** Hyprland 0.56 loads `~/.config/hypr/hyprland.lua` over `hyprland.conf`. Quattro upgrade drops *empty template* `.lua` files next to your `.conf` files, through stow directory symlink, straight into repo. `.conf` files keep sitting there doing nothing, so every personal monitor/input/keybinding setting silently reverts to Omarchy default. This repo ported, dead `.conf` files deleted. See Hyprland section below.

**Default terminal moved to foot.** Quattro installs `~/.local/share/applications/foot.desktop`. With no `~/.config/xdg-terminals.list` present, `xdg-terminal-exec` picks it over Alacritty, so `SUPER + RETURN`, tmux launcher and every `omarchy-launch-tui` open foot at own font size. Fix:

```sh
omarchy-default-terminal alacritty
```

**Omarchy own path moved.** `~/.local/share/omarchy` now symlink to `/usr/share/omarchy`. `OMARCHY_PATH` (set from `/etc/omarchy.conf` when present) is value to use. `bash/.bashrc` resolves it before sourcing Omarchy rc.

## Packages required by my dotfiles
```sh
## Bash customization and local bin (via mise):
sudo pacman -S usage # mise and starship are already installed by Omarchy

## Tools used by the modules below (tmux, Neovim, git/docker TUIs):
sudo pacman -S tmux tree-sitter-cli lazygit lazydocker
```

## Apply dotfiles with GNU Stow
Stow manages symlinks from repo into $HOME. Back up existing configs first.

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
mv ~/.config/tmux ~/.config/tmux.bkp 2>/dev/null
mv ~/.config/opencode ~/.config/opencode.bkp 2>/dev/null
mv ~/.omp ~/.omp.bkp 2>/dev/null

# Stow the modules you want
stow alacritty
stow bash
stow claude-code
stow git
stow hypr
stow lazyvim
stow local-bin
stow mise
stow mpv
stow rubocop
stow steam
stow tmux
stow omp
stow opencode
```

### Unstow (remove symlinks)
Remove Stow symlinks without deleting files. Use `-D`:
```sh
# From the repo root
cd ~/dotfiles
stow -D lazyvim
stow -D hypr
# ...and so on for any module you want to detach
```

### About each module:
1. **Alacritty**: setup under `alacritty/.config/alacritty/`. Customizes font (JetBrainsMono Nerd Font), padding, keybindings, imports current Omarchy theme.

2. **Bash** (customized with Starship): setup under `bash/`.
  I use `bash` with [starship](https://starship.rs/guide/).
  **Note:** per [Packages required by my dotfiles](#packages-required-by-my-dotfiles), ensure `starship` installed.

3. **Claude Code**: setup under `claude-code/.claude/`. Global Claude Code config: `CLAUDE.md` (instructions), `settings.json`, custom skills (`skills/`), `statusline-command.sh`. Stow places at `~/.claude/`. Machine-local state (`settings.local.json`, per-project memory) stays out of repo.

4. **Git**: setup under `git/`.
  General config:
  - colored output,
  - `develop` as default branch,
  - commit message template inspired by Conventional Commits.

5. **Hyprland**: setup under `hypr/.config/hypr/`. Omarchy defaults never edited. Since Omarchy 4 config is **Lua**: `hyprland.lua` bootstraps Omarchy module path, `require`s `default.hypr.omarchy` (all defaults, from `$OMARCHY_PATH/default/hypr/`), then `require`s local files so they override.
  - Layered Lua overrides, loaded after defaults: `monitors.lua`, `input.lua`, `bindings.lua`, `looknfeel.lua`, `autostart.lua`.
  - No standalone hyprlang files. `hypridle.conf` and `hyprlock.conf` dropped: **Omarchy 4 installs neither `hypridle` nor `hyprlock`**, idle and lock now `omarchy-shell` job, so those files configured daemons that weren't there. `hyprsunset.conf` and `xdph.conf` dropped: Omarchy 4 *does* ship both at `/usr/share/omarchy/config/hypr/`, copies here byte-identical, overrode nothing.

  Put customizations in these files only. Never in Omarchy defaults.

  Two APIs in scope: `hl.*` is raw Hyprland (`hl.config`, `hl.monitor`, `hl.env`, `hl.unbind`, `hl.dsp.*`), `o.*` is Omarchy sugar (`o.bind`, `o.window`, `o.launch_on_start`), defined in `$OMARCHY_PATH/default/hypr/helpers.lua`. `.luarc.json` points lua-ls at `/usr/share/hypr/stubs` for completion.

  **Keybindings don't override, they stack.** Loading later doesn't replace key Omarchy already claimed. Second `o.bind` on same key just adds duplicate. Unbind first:

  ```lua
  hl.unbind("SUPER + SHIFT + M")
  o.bind("SUPER + M", "Music", { omarchy = "spotify" })
  o.bind("SUPER + SHIFT + M", "Move workspace to next monitor", hl.dsp.workspace.move({ monitor = "+1" }))
  ```

  Prefer the `{ omarchy = "browser" }` / `{ tui = "btop" }` launcher tables over hardcoding an executable, so `omarchy default browser` stays the single source of truth. List everything currently bound with `omarchy menu keybindings --print`.

6. **Neovim (LazyVim)**: setup is under `lazyvim/`. After stowing:
  ```sh
  # Optional: clear all local Neovim plugins/data before first run
  rm -rf ~/.local/share/nvim
  rm -rf ~/.local/state/nvim
  # After setup mise (described below):
  gem install neovim # for ruby support in Neovim
  sudo pacman -S tree-sitter-cli
  ```

  **Relationship to Omarchy's Neovim config.** Omarchy ships its own LazyVim config through the `omarchy-nvim` package (`/usr/share/omarchy-nvim/config/`, seeded to `/etc/skel` for new users). Since this repo owns `~/.config/nvim`, `omarchy-nvim-setup` leaves it alone. Two of Omarchy's files are therefore **vendored** here as real files rather than symlinked. Symlinking them outside the repo makes the config unreproducible on a second machine:

  - `lua/plugins/all-omarchy-themes.lua`: preloads every Omarchy colorscheme so theme hot-reloading switches instantly. Omarchy never refreshes this after install, so check for drift now and then:
    ```sh
    diff /usr/share/omarchy-nvim/config/lua/plugins/all-themes.lua \
         ~/dotfiles/lazyvim/.config/nvim/lua/plugins/all-omarchy-themes.lua
    ```
  - `plugin/after/transparency.lua`: strips highlight backgrounds. Omarchy patches this one in place via migrations, so it may show up in `git status` after an update.

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
  # Plugin manager. Note the path: NOT under ~/.config/tmux
  git clone https://github.com/tmux-plugins/tpm ~/.local/share/tmux/plugins/tpm

  # Stow the tmux config
  cd ~/dotfiles
  stow tmux
  ```

  **NOTE:** Inside tmux, install plugins (tmux-sensible, tmux-resurrect, etc.) with `prefix + I` (with my prefix will be `CTRL+\ + I` or `CTRL+b + I`). If you are updating an existing machine that still has tmux-continuum installed, drop it with `prefix + ALT + u`.

  TPM lives at `~/.local/share/tmux/plugins/` (set via `TMUX_PLUGIN_MANAGER_PATH` in `tmux.conf`) so that `~/.config/tmux/` holds nothing but `tmux.conf`. That lets stow link the **directory**, like every other module. A file-level link gets replaced by a regular copy the next time an Omarchy migration runs `sed -i` on `~/.config/tmux/tmux.conf`, which is exactly how this module silently drifted out of the repo once already.

  Snapshots are **manual on both ends**: `prefix + Ctrl-s` saves, `prefix + Ctrl-r` restores. There is no timer. tmux-continuum used to provide one and was removed: with auto-restore off, its auto-save only did damage, because the empty server you open after a reboot overwrites the snapshot you wanted. A restore rebuilds sessions, windows, pane layouts, each pane's cwd and its scrollback, but **starts no programs** (`@resurrect-processes 'false'`), so nothing reopens an editor you had already walked away from.

  `SUPER + ALT + RETURN` decides what to open by asking whether any client is currently **attached** to the primary server, not whether a session exists. With nothing attached it attaches to the primary, starting it if it isn't running yet, so closing every terminal and opening a new one lands back in your work rather than in a fresh server. With one already attached, it opens an **independent** server on its own socket, with its own session list. `SUPER + SHIFT + T` opens a third one on socket `sys-tools`, holding btop and lazydocker as two windows; quitting either of them closes the whole dashboard, and resurrect's keys are unbound there so it can never save over your real snapshot. None of them need to coordinate and start order is irrelevant, because no server writes a snapshot unless you tell it to. Old snapshots need no external cleanup: resurrect prunes them itself on every save, keeping `@resurrect-delete-backup-after` days' worth and never fewer than the 5 newest.

  Neovim buffers are **not** restored by resurrect. `@resurrect-strategy-nvim` only reads a `Session.vim` in the pane's cwd, and LazyVim stores sessions with persistence.nvim. Reopen them with `<leader>qs`.

12. **oh-my-pi (omp)**: setup is under `omp/.omp/`. Config for the oh-my-pi agent, a TUI mode-badge extension (`agent/extensions/`). Stows to `~/.omp/`.

13. **OpenCode**: setup is under `opencode/.config/opencode/`. OpenCode config: model, plugins (ponytail, caveman), context7 MCP, and TUI settings. Stows to `~/.config/opencode/`.


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

For Hyprland, edit `~/.config/hypr/input.lua`:
```lua
-- Example for Brazilian and US keyboard layouts
hl.config({
  input = {
    kb_layout = "br,us",
    kb_variant = "abnt2,intl",
    kb_options = "compose:caps,grp:alt_space_toggle",
  },
})
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

4) Reboot computer.


## Optional: clear Neovim plugins
Clean Neovim start:
```sh
rm -rf ~/.local/share/nvim
rm -rf ~/.local/state/nvim
```

## License
Open source under MIT license. See [LICENSE](/LICENSE).


## Code of conduct
I am committed to providing a friendly, safe, and welcoming environment for all. Please read and respect the [Code of Conduct](/code_of_conduct.md).
