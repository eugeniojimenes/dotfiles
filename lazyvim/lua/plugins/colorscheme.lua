return {
  {
    "catppuccin/nvim",
    lazy = true,
    name = "catppuccin",
    opts ={
      transparent_background = true,
    },
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "catppuccin",
    },
  },
}
