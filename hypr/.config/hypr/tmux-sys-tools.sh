#!/usr/bin/env bash
# System-monitoring TUIs on their own tmux server: btop in one window, lazydocker in another.
#
# Own socket (-L sys-tools), so its session never shows up in the primary's `prefix + s` and vice
# versa. Same isolation as the iso-<pid> servers in tmux-launch.sh. Unlike those the socket
# name is fixed, so a second press reattaches instead of stacking a new server.
#
# This one is a viewer, not a workspace: it holds no state worth keeping, and quitting either TUI
# is meant to close the whole thing. So the two settings below, applied once at creation.
# They live on the server, so a later reattach inherits them.
#
#   pane-exited -> kill-server   quitting btop or lazydocker takes the server (and the window with
#                                it) down, instead of leaving a half-empty dashboard behind. It
#                                fires for *any* pane process ending, so closing a split you opened
#                                in here also closes the lot. Fine for a viewer, worth knowing.
#                                It does not fire while the session is being built.
#   unbind C-s / C-r             resurrect is loaded here too, via the shared tmux.conf, and it
#                                writes to one directory for every server. A stray `prefix + Ctrl-s`
#                                in this window would save the dashboard over the primary's
#                                snapshot. Nothing here is worth saving, so take the keys away.
#                                Nothing restores either: continuum is gone, these keys were the
#                                only trigger left.
tmux -L sys-tools has-session -t sys-tools 2>/dev/null ||
  tmux -L sys-tools new-session -d -s sys-tools -n btop btop \; \
    new-window -d -n docker lazydocker \; \
    set-hook -g pane-exited kill-server \; \
    unbind C-s \; unbind C-r

exec tmux -L sys-tools attach -t sys-tools
