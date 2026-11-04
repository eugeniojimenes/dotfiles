-- Change the default Omarchy look'n'feel.

-- https://wiki.hypr.land/Configuring/Basics/Variables/#general
hl.config({
  general = {
    -- Tighter outer gaps than the Omarchy default.
    gaps_out = 5,
    -- Tighter gap between tiled windows.
    gaps_in = 2,
  },
})

-- Tile btop like every other TUI. Omarchy floats it by app-id: default/hypr/apps/system.lua names
-- `org.omarchy.btop` in the list it tags `+floating-window`, and the float/center/size rules then
-- match on that tag. lazydocker is absent from the list, which is the whole reason one floats and
-- the other does not.
--
-- Hyprland has no "unfloat" rule, so drop the tag instead. Tags applied by a rule are dynamic
-- (`hyprctl clients` marks them with a `*`) and get re-evaluated, so removing one here, after
-- Omarchy's rules have run, un-matches the float rules that keyed on it.
o.window("org.omarchy.btop", { tag = "-floating-window" })

-- Stop terminal bells from stealing focus. tmux `bell-action any` forwards a bell from any window (nvim, a finished
-- Claude session) to Alacritty, which asks for attention via xdg-activation, and Omarchy's global
-- `misc.focus_on_activate = true` turns that into a focus switch. Window still gets marked urgent.
o.window("Alacritty", { focus_on_activate = false })
