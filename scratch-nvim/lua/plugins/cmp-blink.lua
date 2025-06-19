return {
  {
    "saghen/blink.cmp",
    dependencies = {
      "rafamadriz/friendly-snippets",
      -- "giuxtaposition/blink-cmp-copilot",
    },
    version = "1.*",
    opts = {
      keymap = {
        preset = "enter",
        ["<C-y>"] = { "select_and_accept" },
      },

      appearance = {
        nerd_font_variant = "mono",
      },

      completion = {
        menu = {
          border = nil,
          scrolloff = 1,
          scrollbar = false,
          draw = {
            columns = {
              { "kind_icon" },
              { "label",      "label_description", gap = 1 },
              { "kind" },
              { "source_name" },
            },
          },
        },
        documentation = {
          window = {
            border = nil,
            scrollbar = false,
            winhighlight = "Normal:BlinkCmpDoc,FloatBorder:BlinkCmpDocBorder,EndOfBuffer:BlinkCmpDoc",
          },
          auto_show = true,
          auto_show_delay_ms = 500,
        },
      },

      sources = {
        default = { "lsp", "path", "snippets", "buffer" },
        -- default = { "copilot", "lsp", "path", "snippets, "buffer" },
        -- providers = {
        --   copilot = {
        --     name = "copilot",
        --     module = "blink-cmp-copilot",
        --     kind = "Copilot",
        --     score_offset = 100,
        --     async = true,
        --   },
        -- },
      },

      fuzzy = { implementation = "prefer_rust_with_warning" },
    },
    opts_extend = { "sources.default" },
  },
  {
    "catppuccin/nvim",
    optional = true,
    opts = {
      integrations = { blink_cmp = true },
    },
  },
}
