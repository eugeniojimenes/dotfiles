-- Keep only your personal input overrides here. Uncommented settings below
-- replace Omarchy's defaults.
-- See https://wiki.hypr.land/Configuring/Basics/Variables/#input
--
-- kb_layout and kb_variant are deliberately absent. Omarchy's default input.lua reads /etc/vconsole.conf
-- and derives both from XKBLAYOUT/XKBVARIANT, so each machine sets its own with `localectl set-x11-keymap`:
-- desktop = us/intl, notebook = br,us / abnt2,intl. See "Keyboard layout per machine" in README.md.

hl.config({
  input = {
    -- Omarchy ignores XKBOPTIONS, and appends a group toggle only for non-Latin layouts. `br` is Latin, so
    -- the notebook's br,us gets none without this. Inert on the single-layout desktop, so one value serves
    -- both. shift:both_capslock_cancel is Omarchy's default and gives back a real Caps Lock, since Caps
    -- itself is the compose key.
    kb_options = "compose:caps,shift:both_capslock_cancel,grp:alt_space_toggle",

    -- Omarchy default is 250.
    repeat_delay = 600,
  },
})

-- Everything else this file used to carry (repeat_rate, touchpad.scroll_factor, both o.window scroll
-- rules) was byte-identical to Omarchy's defaults, so it overrode nothing.
