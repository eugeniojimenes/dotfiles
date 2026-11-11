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
-- btop + lazydocker as two windows of one isolated tmux server. See tmux-sys-tools.sh.
-- Omarchy 4.5 moved standalone btop ("Activity") onto this key, so unbind it first or both open.
hl.unbind("SUPER + SHIFT + T")
o.bind(
  "SUPER + SHIFT + T",
  "System tools (btop + lazydocker)",
  "omarchy-launch-or-focus org.omarchy.sys-tools 'omarchy-launch-tui --app-id=org.omarchy.sys-tools "
    .. os.getenv("HOME")
    .. "/.config/hypr/tmux-sys-tools.sh'"
)

-- Omarchy's standalone lazydocker is redundant now that it lives in the window above.
hl.unbind("SUPER + SHIFT + D")

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
o.bind(
  "SUPER + ALT + RETURN",
  "Tmux",
  "omarchy-launch-terminal " .. os.getenv("HOME") .. "/.config/hypr/tmux-launch.sh"
)

-- Global workspaces 1-10 shared by every monitor, as before Omarchy 4.5. Its per-monitor blocks
-- (default/hypr/monitor-workspaces.lua: LG 1-10, Samsung 11-20) leave "guest" workspaces that SUPER + N
-- cannot reach. No setting turns them off, so: rebind the keys to raw dispatchers, stub the functions the
-- bar and Hyprland events still call, and drop the block file so the bar falls back to one shared row.
-- Upgrade check: these names come from monitor-workspaces.lua; a rename there brings the blocks back.
o.workspaces.reconcile = function() end
o.workspaces.focus = function(slot)
  return hl.dsp.focus({ workspace = tostring(slot) })
end
os.remove((os.getenv("XDG_STATE_HOME") or os.getenv("HOME") .. "/.local/state") .. "/omarchy/monitor-workspaces")

for workspace = 1, 10 do
  local key = "code:" .. tostring(workspace + 9)
  local id = tostring(workspace)
  hl.unbind("SUPER + " .. key)
  hl.unbind("SUPER + SHIFT + " .. key)
  hl.unbind("SUPER + SHIFT + ALT + " .. key)
  o.bind("SUPER + " .. key, "Switch to workspace " .. id, hl.dsp.focus({ workspace = id }))
  o.bind("SUPER + SHIFT + " .. key, "Move window to workspace " .. id, hl.dsp.window.move({ workspace = id }))
  o.bind(
    "SUPER + SHIFT + ALT + " .. key,
    "Move window silently to workspace " .. id,
    hl.dsp.window.move({ workspace = id, follow = false })
  )
end

for key, dir in pairs({ LEFT = "l", RIGHT = "r", UP = "u", DOWN = "d" }) do
  hl.unbind("SUPER + SHIFT + ALT + " .. key)
  o.bind(
    "SUPER + SHIFT + ALT + " .. key,
    "Move workspace to " .. key:lower() .. " monitor",
    hl.dsp.workspace.move({ monitor = dir })
  )
end
