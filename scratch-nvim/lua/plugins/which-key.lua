return {
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      spec = {
        {
          mode = { "n" },
          { "<leader>sf",       function() Snacks.scratch() end,            desc = "Toggle Scratch Buffer" },
          { "<leader>S",        function() Snacks.scratch.select() end,     desc = "Select Scratch Buffer" },
          { "<leader>g",        group = "git" },
          { "<leader>gl",       function() Snacks.lazygit.log_file() end,   desc = "Lazygit Log (cwd)" },
          { "<leader>gg",       function() Snacks.lazygit() end,            desc = "Lazygit" },
          { "<leader>f",        group = "files" },
          { "<leader>b",        group = "buffers" },
        },
      },
    },
    keys = {
      {
        "<leader>?",
        function()
          require("which-key").show({ global = false })
        end,
        desc = "Buffer Local Keymaps (which-key)",
      },
    },
  },
}
