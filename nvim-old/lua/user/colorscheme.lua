local status_ok, kanagawa = pcall(require, "kanagawa")
if not status_ok then
  return
end

kanagawa.setup {
  undercurl = true,           -- enable undercurls
  commentStyle = { italic = true },
  functionStyle = {},
  keywordStyle = { italic = true },
  statementStyle = { bold = true },
  typeStyle = {},
  variablebuiltinStyle = { italic = true },
  specialReturn = true,       -- special highlight for the return keyword
  specialException = true,    -- special highlight for exception handling keywords
  transparent = false,        -- do not set background color
  dimInactive = false,        -- dim inactive window `:h hl-NormalNC`
  colors = {},
  overrides = {},
}

-- set colorscheme after options
vim.cmd('colorscheme kanagawa')
