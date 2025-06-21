return {
  {
    "lewis6991/gitsigns.nvim",
    opts = {}
  },
  {
    "echasnovski/mini.nvim",
    event = "VeryLazy",
    version = "*",
    config = function()
      require('mini.bracketed').setup()
      require('mini.comment').setup()
      require('mini.git').setup() -- TODO: serach about it! tpope/vim-fugitive alternative!
      require('mini.pairs').setup()
      require('mini.sessions').setup() -- TODO: serach about it!
      -- local diff = require("mini.diff") -- TODO: serach about it!
      -- diff.setup({
      --   -- Disabled by default
      --   source = diff.gen_source.none(),
      -- })
    end,
  },
  -- {
  --   ---- Enable mini.diff for lualine
  --   "nvim-lualine/lualine.nvim",
  --   opts = function(_, opts)
  --     local x = opts.sections.lualine_x
  --     for _, comp in ipairs(x) do
  --       if comp[1] == "diff" then
  --         comp.source = function()
  --           local summary = vim.b.minidiff_summary
  --           return summary
  --             and {
  --               added = summary.add,
  --               modified = summary.change,
  --               removed = summary.delete,
  --             }
  --         end
  --         break
  --       end
  --     end
  --   end,
  -- },
}
