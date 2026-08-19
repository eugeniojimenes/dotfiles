-- Change the default Omarchy look'n'feel.

-- https://wiki.hypr.land/Configuring/Basics/Variables/#general
hl.config({
  general = {
    -- Tighter outer gaps than the Omarchy default.
    gaps_out = 5,
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
