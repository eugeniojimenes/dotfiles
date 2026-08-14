#!/usr/bin/env bash
# Tmux launcher for the SUPER ALT + RETURN keybind.
#
# The test is "is any client attached to the default server?", not "does a session exist" -- that distinction is the
# whole point:
#
#   nothing attached -> attach to the primary server on the default socket, or start it. Reopening a terminal after
#                       closing the last one therefore lands back in the saved sessions instead of a fresh server,
#                       and on the first boot of the day tmux-continuum restores them.
#   already attached -> independent server on its own socket (iso-<pid>), with its own session list. It cannot see
#                       the primary's sessions and they cannot see it, so `prefix + s` in either one stays clean.
#
# This is safe for reboot restore, and needs no config gating. tmux-continuum decides *once, at plugin load*, whether
# to install its save hook, and skips it when another server is already running; continuum_restore.sh skips likewise.
# So an iso server never saves and never restores, while the primary keeps its hook and its 5-minute saves.
#
# That holds because the primary is normally the first server to start. If you kill it (`tmux kill-server` on the
# default socket) while an iso server is still alive, the next launch builds a new primary that continuum silently
# disables -- no save hook, no restore, no warning. Kill the iso servers first, then reopen.
#
# Closing an iso window leaves its server running with whatever was inside it, the same way the primary survives.
# `tmux -L iso-<pid> attach` gets it back, and `tmux -L iso-<pid> kill-server` disposes of it.
if tmux list-clients 2>/dev/null | grep -q .; then
  exec tmux -L "iso-$$" new-session
else
  tmux attach 2>/dev/null || exec tmux new
fi
