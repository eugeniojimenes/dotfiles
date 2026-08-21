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
- [Health check](#health-check)
- [Other tools and setups](#other-tools-and-setups)
  - [Lazygit and Lazydocker](#lazygit-and-lazydocker)
  - [Keyboard layout per machine](#keyboard-layout-per-machine)
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
  - `input.lua` sets no `kb_layout` or `kb_variant`. Omarchy derives both from `/etc/vconsole.conf`, see [Keyboard layout per machine](#keyboard-layout-per-machine).
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

8. **mpv**: setup is under `mpv/.config/mpv/`. UI = [uosc](https://github.com/tomasklaen/uosc).

  Only `mpv.conf` tracked. uosc tree (`scripts/`, `fonts/`, its own `script-opts/uosc.conf`)
  gitignored, installed not vendored: ~18 MB, most of it prebuilt binaries with no checksum.
  `~/.config/mpv` = directory symlink into repo, so everything below writes into ignored paths,
  never shows in `git status`.

  Install. `stow mpv` first: installer runs `mkdir -p ~/.config/mpv`, real dir there blocks
  dir symlink stow needs.

  ```sh
  stow mpv
  curl -fsSL https://raw.githubusercontent.com/tomasklaen/uosc/HEAD/installers/unix.sh | bash
  ```

  Update. uosc updates itself. Open its menu in mpv (right click, or `menu` key), pick **Update
  uosc**. Runs same installer with `MPV_CONFIG_DIR` at `~/.config/mpv`, so needs `curl` and
  `unzip`. Curl line above does the same. To bind it:

  ```
  Ctrl+u script-binding uosc/update
  ```

  Omarchy installs mpv, makes it default video player, ships no mpv config, so nothing here layers
  over Omarchy default. Full notes in `mpv/.config/mpv/README.md`.

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


## Health check
`dotfiles-doctor` verifies fresh install, or existing machine after `omarchy update`. Read-only by default, prints exact repair for whatever it finds. `--fix` applies safe ones.

```sh
dotfiles-doctor          # report only
dotfiles-doctor --fix    # apply the safe repairs
```

Fresh clone: `local-bin` not stowed yet, call by path:
```sh
~/dotfiles/local-bin/.local/bin/dotfiles-doctor --fix
```

Checks:
- **stow**, per module. Three states: linked, not linked yet, or **conflict**. Conflict = real file where symlink belongs, what an Omarchy migration leaves behind (see [Omarchy updates write into this repo](#omarchy-updates-write-into-this-repo)). Never auto-fixed: file may hold changes worth keeping, diff against repo before deleting.
- **packages** from [Packages required](#packages-required-by-my-dotfiles), via `pacman -Qq`.
- **mise**: `mise ls --missing`, plus the three Neovim host packages the `postinstall` hooks in `config.toml` install (`gem`, `npm`, `pip`). Hooks fail silently, so a runtime can install with Neovim support missing.
- **external installs** no package manager owns: TPM and the plugins `tmux.conf` declares, uosc under `~/.config/mpv/scripts`, Neovim plugins counted against `lazy-lock.json`.
- **input**: live `kb_layout`/`kb_variant` against `/etc/vconsole.conf`, guarding the undocumented Omarchy fallback this repo leans on (see [Keyboard layout per machine](#keyboard-layout-per-machine)). Tolerates the `us,` group Omarchy prepends for non-Latin layouts. Skipped when `input.lua` sets the layout itself, or outside a Hyprland session.
- **machine-local files** absent on a fresh machine by design: `~/.claude/settings.json` (flagged if it is a *symlink*, which would put work marketplace names in this public repo), `~/.config/xdg-terminals.list` pinning Alacritty, and the cedilla Compose patch that `libx11` updates revert. The cedilla check runs only when `intl` appears anywhere in the variant list, so a pure ABNT2 machine stays quiet while a `br,us` notebook is still checked: its us group reaches `dead_acute` and needs the patch.

Exit code 1 on any failure, 0 when clean. No repo-hygiene checks (`git status`, uncommitted Omarchy migrations), review those by hand.

Module list = directories in repo root, so new module covered with no script edit.

## Other tools and setups

### Lazygit and Lazydocker
I'm using Lazygit and lazydocker for quick terminal-based git and docker management. These tools are installed by default with Omarchy, but if you need to install them manually:
```sh
sudo pacman -S lazygit lazydocker
```

**Note:** if you keep a personal Lazygit config, symlink it into `~/.config/lazygit/config.yml`. I personally use the default configuration.

### Keyboard layout per machine
Desktop = US international with dead keys. Notebook = ABNT2. One repo, no branching.

No layout in this repo. Omarchy's `default/hypr/input.lua` reads `/etc/vconsole.conf`: `kb_layout` from `XKBLAYOUT`, `kb_variant` from `XKBVARIANT`. Machine-local system config, so each machine answers for itself.

Set once per machine, then `hyprctl reload`:
```sh
# Desktop: US international with dead keys
sudo localectl set-x11-keymap us pc105+inet intl terminate:ctrl_alt_bksp

# Notebook: ABNT2 first, US international second
sudo localectl set-x11-keymap br,us pc105 ",intl" terminate:ctrl_alt_bksp
```

Pass all four arguments, `localectl` rewrites the whole X11 block and omitting model or options clears them. Read the machine's own `/etc/vconsole.conf` first, carry its model and options over, never copy another machine's. Conversion runs both ways unless `--no-convert`, so the console `KEYMAP` follows too (`br,us` lands on `br-abnt2`).

**Variant slot for `br` stays empty.** `abnt2` is an XKB *model*, not a `br` variant: `xkbcli list` gives `br` only `nodeadkeys`, `dvorak`, `nativo`, `nativo-us`, `thinkpad`, `thinkpad_nodeadkeys`, `nativo-epo`, `rus`. Base `br` already *is* ABNT2, including the 107th key `<AB11>` (`slash`/`question`) and the dedicated ç on `<AC10>`. Writing `abnt2,intl` compiles fine and produces byte-identical symbols, changing only the keymap label to `pc_br(abnt2)_inet(evdev)`, so it works while documenting something false. Model `abnt2` and `pc105` also compile byte-identical for `br`, so the model is not worth changing.

So `hypr/.config/hypr/input.lua` sets no `kb_layout`, no `kb_variant`. Still sets `kb_options`, which Omarchy does **not** read from `XKBOPTIONS`. Omarchy default = `compose:caps,shift:both_capslock_cancel`, plus a group toggle for non-Latin layouts only. `br` is Latin, so `br,us` gets no toggle unless this repo adds one. `grp:alt_space_toggle` is inert with a single layout, one value serves both machines.

Check what is live:
```sh
hyprctl getoption input:kb_layout
hyprctl getoption input:kb_variant
```

**This diverges from Omarchy's manual on purpose.** The [manual](https://omarchy.org/manual/keyboard-mouse-trackpad/) says to hardcode the layout in `input.lua` (`kb_layout = "us,dk"`), reachable from *Setup > Input* in the Omarchy menu (`Super + Space`), and never mentions vconsole or `localectl`. This repo takes the vconsole route so one committed file serves both machines. The fallback is real, `default/hypr/input.lua` reads `vconsole.XKBLAYOUT or "us"`, but it is Omarchy's code and not its documented interface, and this is Omarchy `4.0.0.alpha`. If a release drops that read, layout falls back to `us` silently. [Issue #6878](https://github.com/basecamp/omarchy/issues/6878) is the same seam failing in the wild: Quattro upgrades where vconsole carried only `KEYMAP` and no `XKBLAYOUT` lost their layout entirely. `localectl set-x11-keymap` writes both keys, so these machines sit in the good state those reporters lacked.

### Cedilla with US keyboard layout
Workaround to type "ç" on English (US, international with dead keys). That layout maps `'` + `c` to ć, not ç.

Layout itself needs nothing here, see [Keyboard layout per machine](#keyboard-layout-per-machine). One file to patch:

```sh
sudo cp /usr/share/X11/locale/en_US.UTF-8/Compose{,.bak}
sed 's/ć/ç/g; s/Ć/Ç/g' /usr/share/X11/locale/en_US.UTF-8/Compose.bak |
  sudo tee /usr/share/X11/locale/en_US.UTF-8/Compose >/dev/null
```

Log out and back in.

**How it reaches your apps.** Compose chain, each file including the next:
```
~/.XCompose
  include "%H/.local/share/omarchy/default/xcompose"
    include "%L"  ->  /usr/share/X11/locale/en_US.UTF-8/Compose  (patched above)
```
`%L` = locale Compose file. Omarchy seeds `~/.XCompose` with that include, so the patch reaches everything. fcitx5 runs by default under Omarchy, serves Wayland clients through its `waylandim` frontend; terminals read the same table through xkbcommon.

Verify without typing anything:
```sh
xkbcli compile-compose | grep '<dead_acute> <c>'
```
Patched prints `<dead_acute> <c> :  "ç" U0107`. Keysym stays `U0107`, which *is* ć, because the sed swaps the output string and not the name. Unpatched prints "ć".

**`libx11` owns that file, so every update restores it and ç breaks silently.** `dotfiles-doctor` catches it, keyed on the SHA256 mismatch `pacman -Qkk libx11` reports while the patch holds.

**Old GTK `immodules.cache` step dropped.** It added `:en` to the `cedilla` row in `/usr/lib/gtk-3.0/3.0.0/immodules.cache`, plus a gtk-2.0 twin. Neither does anything now: `GTK_IM_MODULE` is unset under Omarchy, so GTK apps go through Wayland text-input to fcitx5 and never load `im-cedilla.so`, and `/usr/lib/gtk-2.0/` no longer exists. No package owns `immodules.cache` either, so a gtk3 rebuild discards edits to it anyway.

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
