-- Personal keybinding overrides. Loaded after Omarchy's defaults, so any key
-- Omarchy already claims must be unbound before it can be rebound.
--
-- See current bindings and descriptions:
--   omarchy menu keybindings --print

-- Browser on SUPER + B, private window on SUPER + SHIFT + B. Omarchy 4 puts a
-- plain browser window on SUPER + SHIFT + B and private on SUPER + SHIFT + ALT + B.
-- Going through the omarchy launcher keeps `omarchy default browser` authoritative.
hl.unbind("SUPER + SHIFT + B")
o.bind("SUPER + B", "Browser", { omarchy = "browser" })
o.bind("SUPER + SHIFT + B", "Browser (private)", { omarchy = "browser --private" })

-- Music on SUPER + M so SUPER + SHIFT + M is free for the monitor move below.
hl.unbind("SUPER + SHIFT + M")
o.bind("SUPER + M", "Music", { omarchy = "spotify" })
o.bind("SUPER + SHIFT + M", "Move workspace to next monitor", hl.dsp.workspace.move({ monitor = "+1" }))

-- Editor without the shift, matching the terminal/browser row.
o.bind("SUPER + N", "Editor", { omarchy = "editor" })

-- TUIs.
o.bind("SUPER + SHIFT + T", "Activity monitor (btop)", { tui = "btop" })

o.bind("SUPER + SHIFT + L", "Lock screen", "omarchy-lock-screen")

-- ALT + TAB cycles workspaces, not windows.
hl.unbind("ALT + TAB")
hl.unbind("ALT + SHIFT + TAB")
o.bind("ALT + TAB", "Former workspace", hl.dsp.focus({ workspace = "previous" }))
o.bind("ALT + SHIFT + TAB", "Previous workspace", hl.dsp.focus({ workspace = "e-1" }))

-- Omarchy's tmux launcher runs `tmux attach`, which hangs a second client off
-- the same session: duplicated session list, and the window clamps to the
-- smallest attached client (aggressive-resize) so TUIs draw in a corner.
-- tmux-launch.sh attaches the primary server once, then gives every later
-- launch its own iso-<pid> socket.
hl.unbind("SUPER + ALT + RETURN")
o.bind("SUPER + ALT + RETURN", "Tmux", "omarchy-launch-terminal " .. os.getenv("HOME") .. "/.config/hypr/tmux-launch.sh")
