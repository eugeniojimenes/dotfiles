return {
  {
    "akinsho/bufferline.nvim",
    version = "*",
    dependencies = {
      "nvim-tree/nvim-web-devicons",
    },
    opts = {
      options = {
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
    "folke/todo-comments.nvim",
    -- dependencies = { "nvim-lua/plenary.nvim" },
    opts = {
    },
    -- keys = {
    --     {
    --         "tn",
    --         function()
    --             require("todo-comments").jump_next()
    --         end,
    --         desc = "next marked comment",
    --     },
    --     {
    --         "tN",
    --         function()
    --             require("todo-comments").jump_prev()
    --         end,
    --         desc = "prev marked comment",
    --     },
    --     {
    --         "<leader>ft",
    --         ":lua Snacks.picker.todo_comments()<CR>",
    --         desc = "search todo comments",
    --     },
    -- },
    -- opts = {
    --     keywords = {
    --         FIX = { icon = " ", color = "#FF2D00", alt = { "FIXME", "BUG", "FIXIT", "ISSUE" } },
    --         TODO = { icon = " ", color = "#FF8C00" },
    --         HACK = { icon = " ", color = "#3498DB", alt = { "MYTH" } },
    --         WARN = { icon = " ", color = "warning", alt = { "WARNING", "XXX" } },
    --         NOTE = { icon = " ", color = "#98C379", alt = { "INFO", "HINT" } },
    --     },
    -- },
  },
}
