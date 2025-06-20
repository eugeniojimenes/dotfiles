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
      require('mini.comment').setup()
      require('mini.sessions').setup()
      local diff = require("mini.diff")
      diff.setup({
        -- Disabled by default
        source = diff.gen_source.none(),
      })
      -- TODO: Serach more about it!
      require('mini.git').setup() -- tpope/vim-fugitive alternative!!!
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
