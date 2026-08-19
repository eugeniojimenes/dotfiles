#!/usr/bin/env bash
# Tmux launcher for the SUPER ALT + RETURN keybind.
#
# The test is "is any client attached to the default server?", not "does a session exist" -- that distinction is the
# whole point:
#
#   nothing attached -> attach to the primary server on the default socket, or start it. Reopening a terminal after
#                       closing the last one therefore lands back in the live sessions instead of a fresh server.
#                       Across a reboot they are gone: nothing restores on its own, so the first launch of the day
#                       is a clean server. `prefix + Ctrl-r` pulls back the last snapshot you took with
#                       `prefix + Ctrl-s`, layout and cwds only -- resurrect relaunches no programs here.
#   already attached -> independent server on its own socket (iso-<pid>), with its own session list. It cannot see
#                       the primary's sessions and they cannot see it, so `prefix + s` in either one stays clean.
#
# No config gating is needed for any of this, and start order does not matter: with tmux-continuum gone, no server
# writes a snapshot unless you ask it to, so no server can clobber another's.
#
# Closing an iso window leaves its server running with whatever was inside it, the same way the primary survives.
# `tmux -L iso-<pid> attach` gets it back, and `tmux -L iso-<pid> kill-server` disposes of it.
if tmux list-clients 2>/dev/null | grep -q .; then
  exec tmux -L "iso-$$" new-session
else
  tmux attach 2>/dev/null || exec tmux new
fi
