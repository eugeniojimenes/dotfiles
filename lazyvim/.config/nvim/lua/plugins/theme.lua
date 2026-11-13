-- Colorscheme: Catppuccin Mocha, same palette as Alacritty, btop and the Sway setup. Transparent background so the
-- terminal's opacity shows through; catppuccin's lualine theme follows it and clears the middle sections too.
-- Current line keeps only its number highlighted; the file tree still needs a visible selection.
return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    opts = {
      transparent_background = true,
      float = { transparent = true },
      custom_highlights = function(c)
        return {
          CursorLine = { bg = c.none },
          NeoTreeCursorLine = { bg = c.surface0 },
          SnacksPickerListCursorLine = { bg = c.surface0 },
        }
      end,
    },
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "catppuccin-mocha",
    },
  },
}
