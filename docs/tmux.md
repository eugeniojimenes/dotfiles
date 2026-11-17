# tmux

The config is a single file, `tmux/.config/tmux/tmux.conf`.

## Plugin manager

TPM lives in `~/.local/share/tmux/plugins/tpm`, not under `~/.config/tmux`. `~/.config/tmux` must hold only `tmux.conf` so that stow links the whole directory instead of the single file. A file-level link once drifted out of the repo without anyone noticing. The path is set through `TMUX_PLUGIN_MANAGER_PATH` at the bottom of `tmux.conf`. After stowing, install the plugins from inside tmux with `prefix + I`.

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
