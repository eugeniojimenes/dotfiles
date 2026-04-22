return {
  "folke/snacks.nvim",
  opts = {
    picker = {
      layout = { preset = "default" }, -- use the telescope layout preset
      formatters = {
        file = {
          truncate = "left",
          min_width = 60, -- minimum length of the truncated path
        },
      },
    },
    scroll = {
      enabled = false, -- Disable scrolling animations
    },
  },
}
