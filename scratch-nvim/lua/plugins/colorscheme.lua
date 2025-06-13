return {
  -- the colorscheme should be available when starting Neovim
  {
    "catppuccin/nvim",
    lazy = false, -- make sure we load this during startup if it is your main colorscheme
    priority = 1000, -- make sure to load this before all the other start plugins
    name = "catppuccin",

    config = function()
      require("catppuccin").setup({
        transparent_background = true,
      })
      -- load the colorscheme here
      vim.cmd.colorscheme "catppuccin-mocha"
    end
  }
}
