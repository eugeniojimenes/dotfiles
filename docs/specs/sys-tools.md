# System tools

Files: `sway/.config/sway/bin/sys-tools`, opened by `Super + Shift + T` (`sway/.config/sway/config.d/30-apps`).

## Purpose

`sys-tools` shows btop and lazydocker as two windows of one tmux server on its own socket, `sys-tools`. The server is a viewer: it stays out of the primary tmux server's session list, it never saves a resurrect snapshot, and it goes away when either program quits.

## Acceptance criteria

1. The first run creates the server on socket `sys-tools` with a session `sys-tools`, a window `btop` running btop and a window `docker` running lazydocker, then attaches to it. Test: `tests/unit/sway/.config/sway/bin/sys-tools.bats: "first run: session with btop and lazydocker, kill on pane exit, no resurrect keys"`
2. The server gets a `pane-exited` hook that kills it, and `C-s` and `C-r` are unbound on it, so a stray save cannot overwrite the primary server's snapshot. Test: `tests/unit/sway/.config/sway/bin/sys-tools.bats: "first run: session with btop and lazydocker, kill on pane exit, no resurrect keys"`
3. A second run while the server exists only attaches to it. Test: `tests/unit/sway/.config/sway/bin/sys-tools.bats: "already running: reattach only"`
4. `Super + Shift + T` focuses the open window when there is one, and otherwise opens a terminal with app_id `sys-tools` running the script. Test: manual
5. Quitting btop or lazydocker closes the whole server and its window. Test: manual
6. The `sys-tools` session does not appear in `prefix + s` of the primary tmux server. Test: manual
