# tmux

The config is a single file, `tmux/.config/tmux/tmux.conf`.

## Plugins

The plugins (tmux-sensible and tmux-resurrect) come from nixpkgs. `nixos/common.nix` links each one under `/etc/tmux/plugins/`, and the bottom of `tmux.conf` runs them with `run-shell`. Their versions are pinned by `flake.lock` and change only with a system update. TPM, used before, cloned each plugin from its repository and `bin/update` pulled the latest commit every time, with no waiting period, from repositories that had seen no activity for years. A plugin added later goes in both places.

The nixpkgs build of tmux-resurrect is from 2022 and still saves to `~/.tmux/resurrect` by default, so `tmux.conf` sets `@resurrect-dir` to `~/.local/share/tmux/resurrect`, the path newer versions use.

`~/.config/tmux` must hold only `tmux.conf` so that stow links the whole directory instead of the single file. A file-level link once drifted out of the repo without anyone noticing.

## Binding descriptions

Every binding carries `-N "description"`. That text is what `prefix + ?` shows, through `tmux list-keys -N`. A binding added without `-N` shows up in that list as a raw tmux command.

## Saving and restoring sessions

Persistence comes from tmux-resurrect only, and it runs by hand: `prefix + Ctrl-s` saves and `prefix + Ctrl-r` restores. Nothing saves on a timer.

tmux-continuum was removed. With automatic restore turned off, its automatic save was harmful: an empty server opened after a reboot would overwrite the snapshot you wanted to restore five minutes later. Do not add it back, and do not add `%if` blocks that gate the config on which server is running. Since no server saves unless asked, the order in which servers start no longer matters.

`@resurrect-processes` is set to `'false'`. That value is a sentinel checked by `restore_pane_processes_enabled()`, not a list of programs. A restore rebuilds sessions, windows, layouts, working directories and pane contents, but relaunches no programs. There is no way to restore only some programs: the option adds to a built-in default list that already contains nvim, vim and htop, and nothing removes entries from it.

Old snapshots need no cleanup. resurrect's `remove_old_backups()` runs on every save, honours `@resurrect-delete-backup-after` and always keeps the 5 newest files.

## Extra servers

Two scripts start tmux servers of their own, and none of them needs coordination with the main server because none saves on its own.

- `sway/.config/sway/bin/tmux-launch` (`Super + Alt + Return`) attaches to the main server when no client is attached to it. Otherwise it opens an independent server on the socket `iso-<pid>`.
- `sway/.config/sway/bin/sys-tools` (`Super + Shift + T`) runs btop and lazydocker on the socket `sys-tools`. It is a viewer. A `pane-exited` hook kills the server when either program quits, and `C-s` and `C-r` are unbound there so it never saves over the main snapshot.

## When tmux 3.8 arrives

The pinned nixpkgs ships tmux 3.7b. When `bin/update` moves to a nixpkgs with tmux 3.8 or later, `nvd diff` shows the new version, and the static step `tmux-config`, which loads `tmux.conf` in an isolated server, fails at once if a command or option is gone. Things to change or try then:

- `display-popup` no longer exists in 3.8, so the `?` binding that shows the key list breaks. Floating and modal panes replace popups: `new-pane -O` opens a modal pane, and `-C` closes it on a click outside.
- `lazyvim/.config/nvim/lua/config/options.lua` turns Neovim's `termsync` off inside tmux, because tmux 3.7 moves the cursor during a synchronized update and it flashes lines away in the Neovim explorer. tmux 3.8 fixes that (commit `57a13664cc`), so the block can go.
- 3.8 adds default bindings that may clash with this config: `C-b g` for moving and resizing floating panes, `C-b T` for the pane title, `C-b r` for a refresh, and `Tab` and `S-Tab` for `switch-mode`.
- 3.8 has built-in light and dark themes with new default colours, which can change how the status bar looks.
- `switch-mode` is a fast switcher for windows and sessions that could replace the `choose-tree` bindings on `w` and `s`.
