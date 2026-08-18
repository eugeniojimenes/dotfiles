-- Keep only your personal input overrides here. Uncommented settings below
-- replace Omarchy's defaults.
-- See https://wiki.hypr.land/Configuring/Basics/Variables/#input

hl.config({
  input = {
    kb_layout = "us",
    kb_variant = "intl",
    kb_options = "compose:caps",

    -- Change speed of keyboard repeat.
    repeat_rate = 40,
    repeat_delay = 600,

    touchpad = {
      -- Control the speed of your scrolling.
      scroll_factor = 0.4,
    },
  },
})

-- Scroll faster in the terminal.
o.window("(Alacritty|kitty|foot)", { scroll_touchpad = 1.5 })
o.window("com.mitchellh.ghostty", { scroll_touchpad = 0.2 })
