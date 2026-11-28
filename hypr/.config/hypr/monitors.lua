-- See https://wiki.hypr.land/Configuring/Basics/Monitors/
-- List current monitors and supported resolutions with: hyprctl monitors all

-- Straight 1x setup for low-resolution displays like 1080p or 1440p.
hl.env("GDK_SCALE", "1")
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })

-- Desktop setup.
hl.monitor({
  output = "desc:LG Electronics LG HDR WFHD 0x01010101",
  mode = "2560x1080@74.99",
  position = "auto-right",
  scale = 1,
})
hl.monitor({
  output = "desc:Samsung Electric Company SMT27A550",
  mode = "1920x1080@60",
  position = "auto-left",
  scale = 1,
})
