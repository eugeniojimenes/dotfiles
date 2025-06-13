return {
  {
    "akinsho/bufferline.nvim",
    version = "*",
    dependencies = {
      "nvim-tree/nvim-web-devicons",
    },
    -- event = "VeryLazy",
    opts = {
      options = {
        -- TODO: Enable mouse click on x to close buffer
        -- mode = "tabs",
        -- separator_style = "padded_slant",
      },
    },
  },
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
    },
  },
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    dependencies = {
      "MunifTanjim/nui.nvim",
      "rcarriga/nvim-notify",
    },
    opts = {
    },
  },
  -- {
  --   "echasnovski/mini.nvim",
  --   version = "*",
  --   opts = {
  --   },
  -- },
}
