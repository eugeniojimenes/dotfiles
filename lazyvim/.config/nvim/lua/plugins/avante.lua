-- return {
--   {
--     "yetone/avante.nvim",
--     event = "VeryLazy",
--     version = false, -- Never set this value to "*"! Never!
--     opts = {
--       selector = {
--         provider = "snacks",
--         -- Options override for custom providers
--         provider_opts = {},
--       },
--       sources = {
--         -- Add 'avante' to the list
--         default = { "avante", "lsp", "path", "luasnip", "buffer" },
--         providers = {
--           avante = {
--             module = "blink-cmp-avante",
--             name = "Avante",
--             opts = {
--               -- options for blink-cmp-avante
--             },
--           },
--         },
--       },
--       provider = "copilot",
--     },
--     -- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
--     build = "make",
--     -- build = "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false" -- for windows
--     dependencies = {
--       "nvim-treesitter/nvim-treesitter",
--       "nvim-lua/plenary.nvim",
--       "MunifTanjim/nui.nvim",
--       --- The below dependencies are optional,
--       "Kaiser-Yang/blink-cmp-avante", -- replament for "hrsh7th/nvim-cmp", -- autocompletion for avante commands and mentions
--       "folke/snacks.nvim", -- for input provider snacks
--       "nvim-tree/nvim-web-devicons", -- or echasnovski/mini.icons
--       "zbirenbaum/copilot.lua", -- for providers='copilot'
--       {
--         -- Make sure to set this up properly if you have lazy=true
--         "MeanderingProgrammer/render-markdown.nvim",
--         opts = {
--           file_types = { "markdown", "Avante" },
--         },
--         ft = { "markdown", "Avante" },
--       },
--     },
--   },
--   {
--     "folke/which-key.nvim",
--     opts = {
--       spec = {
--         {
--           mode = { "n" },
--           { "<leader>a", group = "AI Avante" },
--         },
--       },
--     },
--   },
-- }

return {
  {
    "yetone/avante.nvim",
    build = "make",
    event = "VeryLazy",
    version = false,
    opts = {
      provider = "copilot",
      hints = {
        enabled = false,
      },
    },
    dependencies = {
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      "zbirenbaum/copilot.lua",
      "nvim-tree/nvim-web-devicons",
      { "echasnovski/mini.pick", optional = true }, -- for file_selector provider mini.pick
      { "nvim-telescope/telescope.nvim", optional = true }, -- for file_selector provider telescope
      { "ibhagwan/fzf-lua", optional = true }, -- for file_selector provider fzf
      { "stevearc/dressing.nvim", optional = true }, -- for input provider dressing
      { "folke/snacks.nvim", optional = true }, -- for input provider snacks
      { "nvim-tree/nvim-web-devicons", optional = true }, -- or echasnovski/mini.icons
      -- {
      --   -- support for image pasting
      --   "HakonHarnes/img-clip.nvim",
      --   event = "VeryLazy",
      --   optional = true,
      --   opts = {
      --     -- recommended settings
      --     default = {
      --       embed_image_as_base64 = false,
      --       prompt_for_file_name = false,
      --       drag_and_drop = {
      --         insert_mode = true,
      --       },
      --       -- required for Windows users
      --       use_absolute_path = true,
      --     },
      --   },
      -- },
      {
        -- Make sure to set this up properly if you have lazy=true
        "MeanderingProgrammer/render-markdown.nvim",
        opts = {
          file_types = { "markdown", "Avante" },
        },
        ft = { "markdown", "Avante" },
      },
      {
        "saghen/blink.cmp",
        dependencies = {
          "Kaiser-Yang/blink-cmp-avante",
        },
        opts = {
          sources = {
            default = { "avante" },
            providers = { avante = { module = "blink-cmp-avante", name = "Avante" } },
          },
        },
      },
    },
  },
  {
    "folke/which-key.nvim",
    opts = {
      spec = {
        {
          mode = { "n" },
          { "<leader>a", group = "AI Avante" },
        },
      },
    },
  },
}
