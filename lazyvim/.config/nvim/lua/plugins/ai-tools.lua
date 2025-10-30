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
      behaviour = {
        auto_set_keymaps = false,
      },
    },
    cmd = {
      "AvanteAsk",
      "AvanteBuild",
      "AvanteChat",
      "AvanteClear",
      "AvanteEdit",
      "AvanteFocus",
      "AvanteHistory",
      "AvanteModels",
      "AvanteRefresh",
      "AvanteShowRepoMap",
      "AvanteStop",
      "AvanteSwitchProvider",
      "AvanteToggle",
    },
    keys = {
      { "<leader>A", nil, desc = "AI/Avante" },
      { "<leader>Aa", "<cmd>AvanteAsk<CR>", desc = "Ask Avante" },
      { "<leader>Ac", "<cmd>AvanteChat<CR>", desc = "Chat with Avante" },
      { "<leader>Ae", "<cmd>AvanteEdit<CR>", desc = "Edit Avante" },
      { "<leader>Af", "<cmd>AvanteFocus<CR>", desc = "Focus Avante" },
      { "<leader>Ah", "<cmd>AvanteHistory<CR>", desc = "Avante History" },
      { "<leader>Am", "<cmd>AvanteModels<CR>", desc = "Select Avante Model" },
      { "<leader>An", "<cmd>AvanteChatNew<CR>", desc = "New Avante Chat" },
      { "<leader>Ap", "<cmd>AvanteSwitchProvider<CR>", desc = "Switch Avante Provider" },
      { "<leader>Ar", "<cmd>AvanteRefresh<CR>", desc = "Refresh Avante" },
      { "<leader>As", "<cmd>AvanteStop<CR>", desc = "Stop Avante" },
      { "<leader>At", "<cmd>AvanteToggle<CR>", desc = "Toggle Avante" },
    },
    dependencies = {
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      "zbirenbaum/copilot.lua",
      { "nvim-mini/mini.pick", optional = true }, -- for file_selector provider mini.pick
      { "nvim-telescope/telescope.nvim", optional = true }, -- for file_selector provider telescope
      { "hrsh7th/nvim-cmp", optional = true }, -- autocompletion for avante commands and mentions
      { "ibhagwan/fzf-lua", optional = true }, -- for file_selector provider fzf
      { "stevearc/dressing.nvim", optional = true }, -- for input provider dressing
      { "folke/snacks.nvim", optional = true }, -- for input provider snacks
      { "nvim-tree/nvim-web-devicons", optional = true }, -- or nvim-mini/mini.icons
      {
        -- support for image pasting
        "HakonHarnes/img-clip.nvim",
        event = "VeryLazy",
        optional = true,
        opts = {
          -- recommended settings
          default = {
            embed_image_as_base64 = false,
            prompt_for_file_name = false,
            drag_and_drop = {
              insert_mode = true,
            },
            -- required for Windows users
            use_absolute_path = true,
          },
        },
      },
      {
        -- Make sure to set this up properly if you have lazy=true
        "MeanderingProgrammer/render-markdown.nvim",
        -- optional = true,
        opts = {
          file_types = { "markdown", "Avante" },
        },
        ft = { "markdown", "Avante" },
      },
      {
        "Kaiser-Yang/blink-cmp-avante",
        lazy = true,
        specs = {
          {
            "saghen/blink.cmp",
            optional = true,
            opts = {
              sources = {
                default = { "avante" },
                providers = { avante = { module = "blink-cmp-avante", name = "Avante" } },
              },
            },
          },
        },
      },
    },
  },
  {
    "coder/claudecode.nvim",
    dependencies = { "folke/snacks.nvim" },
    config = true,
    keys = {
      { "<leader>a", nil, desc = "AI/Claude Code" },
      { "<leader>ac", "<cmd>ClaudeCode<cr>", desc = "Toggle Claude" },
      { "<leader>af", "<cmd>ClaudeCodeFocus<cr>", desc = "Focus Claude" },
      { "<leader>ar", "<cmd>ClaudeCode --resume<cr>", desc = "Resume Claude" },
      { "<leader>aC", "<cmd>ClaudeCode --continue<cr>", desc = "Continue Claude" },
      { "<leader>am", "<cmd>ClaudeCodeSelectModel<cr>", desc = "Select Claude model" },
      { "<leader>ab", "<cmd>ClaudeCodeAdd %<cr>", desc = "Add current buffer" },
      { "<leader>as", "<cmd>ClaudeCodeSend<cr>", mode = "v", desc = "Send to Claude" },
      {
        "<leader>as",
        "<cmd>ClaudeCodeTreeAdd<cr>",
        desc = "Add file",
        ft = { "NvimTree", "neo-tree", "oil", "minifiles", "netrw" },
      },
      -- Diff management
      { "<leader>aa", "<cmd>ClaudeCodeDiffAccept<cr>", desc = "Accept diff" },
      { "<leader>ad", "<cmd>ClaudeCodeDiffDeny<cr>", desc = "Deny diff" },
    },
  },
}
