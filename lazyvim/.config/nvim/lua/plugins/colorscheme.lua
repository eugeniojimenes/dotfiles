return {
  {
    "catppuccin/nvim",
    lazy = true,
    name = "catppuccin",
    opts ={
      transparent_background = true,
    },
  },
  -- {
  --   "akinsho/bufferline.nvim",
  --   init = function()
  --     local bufline = require("catppuccin.groups.integrations.bufferline")
  --     function bufline.get()
  --       return bufline.get_theme()
  --     end
  --   end,
  -- },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "catppuccin",
    },
  },
}
