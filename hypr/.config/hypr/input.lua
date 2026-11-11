-- Keep only your personal input overrides here. Uncommented settings below
-- replace Omarchy's defaults.
-- See https://wiki.hypr.land/Configuring/Basics/Variables/#input
--
-- Global kb_layout and kb_variant are deliberately absent. Omarchy's default input.lua reads /etc/vconsole.conf
-- and derives both from XKBLAYOUT/XKBVARIANT, so each machine sets its own with `localectl set-x11-keymap`:
-- desktop = us/intl, notebook = br (built-in ABNT2). See "Keyboard layout per machine" in README.md.

hl.config({
  input = {
    -- shift:both_capslock_cancel is Omarchy's default and gives back a real Caps Lock, since Caps itself is the
    -- compose key. No grp: toggle: external keyboards get their own layout below instead of a second group.
    kb_options = "compose:caps,shift:both_capslock_cancel",

    -- Omarchy default is 250.
    repeat_delay = 600,
  },
})

-- External US keyboards: us/intl per device, so the notebook's built-in ABNT2 and a USB US keyboard each type
-- their own legends with no toggle. Same values as the desktop's vconsole, so inert there. Names from
-- `hyprctl devices`; a keyboard exposes several, the one without -system-control/-consumer-control suffix and
-- its numbered twin carry the keys. Keep each hl.device on one line: dotfiles-doctor greps `^\s*kb_layout`.
for _, name in ipairs({
  "kingston-hyperx-alloy-fps-mechanical-gaming-keyboard",
  "kingston-hyperx-alloy-fps-mechanical-gaming-keyboard-1",
}) do
  hl.device({ name = name, kb_layout = "us", kb_variant = "intl" })
end

-- Everything else this file used to carry (repeat_rate, touchpad.scroll_factor, both o.window scroll
-- rules) was byte-identical to Omarchy's defaults, so it overrode nothing.
