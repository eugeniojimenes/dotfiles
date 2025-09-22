return {
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter",
    opts = {
      suggestion = { enabled = true },
      panel = { enabled = true },
    },
  },
  {
    "saghen/blink.cmp",
    optional = true,
    dependencies = { "giuxtaposition/blink-cmp-copilot" },
    opts = {
      sources = {
        default = { "copilot" },
        providers = {
          copilot = {
            name = "copilot",
            module = "blink-cmp-copilot",
            score_offset = 100,
            async = true,
            transform_items = function(_, items)
              for _, item in ipairs(items) do
                item.kind_icon = ""
                item.kind_name = "Copilot"
              end
              return items
            end,
          },
        },
      },
    },
  },
  {
    "yetone/avante.nvim",
    event = "VeryLazy",
    version = false, -- Never set this value to "*"! Never!
    opts = {
      sources = {
        -- Add 'avante' to the list
        default = { "avante", "lsp", "path", "luasnip", "buffer" },
        providers = {
          avante = {
            module = "blink-cmp-avante",
            name = "Avante",
            opts = {
              -- options for blink-cmp-avante
            },
          },
        },
      },
      -- add any opts here
      -- for example
      provider = "copilot",
      behaviour = {
        auto_suggestions = false, -- Experimental stage
        auto_set_highlight_group = true,
        auto_set_keymaps = true,
        auto_apply_diff_after_generation = false,
        support_paste_from_clipboard = false,
        minimize_diff = true, -- Whether to remove unchanged lines when applying a code block
        enable_token_counting = true, -- Whether to enable token counting. Default to true.
        auto_approve_tool_permissions = false, -- Default: show permission prompts for all tools
        -- Examples:
        -- auto_approve_tool_permissions = true,                -- Auto-approve all tools (no prompts)
        -- auto_approve_tool_permissions = {"bash", "replace_in_file"}, -- Auto-approve specific tools only
      },
    },
    -- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
    build = "make",
    -- build = "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false" -- for windows
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      --- The below dependencies are optional,
      "Kaiser-Yang/blink-cmp-avante", -- replament for "hrsh7th/nvim-cmp", -- autocompletion for avante commands and mentions
      "folke/snacks.nvim", -- for input provider snacks
      "nvim-tree/nvim-web-devicons", -- or nvim-mini/mini.icons
      "zbirenbaum/copilot.lua", -- for providers='copilot'
      {
        "MeanderingProgrammer/render-markdown.nvim",
        opts = {
          file_types = { "markdown", "Avante" },
        },
        ft = { "markdown", "Avante" },
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
