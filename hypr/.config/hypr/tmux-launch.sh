#!/usr/bin/env bash
# Tmux launcher for the SUPER ALT + RETURN keybind.
#
# First terminal  -> primary tmux server. tmux-continuum restores the saved
#                    sessions (see tmux.conf @continuum-restore).
# Later terminals -> isolated tmux server on a unique socket (iso-<pid>), with a
#                    single fresh session. It cannot see the primary server's
#                    sessions, and TMUX_ISO=1 disables continuum there so it
#                    neither restores old sessions nor overwrites the saved state.
if tmux has-session 2>/dev/null; then
  exec env TMUX_ISO=1 tmux -L "iso-$$" new-session
else
  tmux attach 2>/dev/null || exec tmux new
fi
