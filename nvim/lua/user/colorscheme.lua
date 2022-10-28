local colorscheme = "darkplus"

vim.g.onedarker_italic_keywords = false

vim.g.onedarker_italic_functions = false

vim.g.onedarker_italic_comments = true

vim.g.onedarker_italic_loops = false

vim.g.onedarker_italic_conditionals = false

local status_ok, _ = pcall(vim.cmd, "colorscheme " .. colorscheme)
if not status_ok then
  -- vim.notify("colorscheme " .. colorscheme .. " not found!")
  return
end

-- local status_ok, kanagawa = pcall(require, "kanagawa")
-- if not status_ok then
--   return
-- end

-- kanagawa.setup {
--   undercurl = true,           -- enable undercurls
--   commentStyle = { italic = true },
--   functionStyle = {},
--   keywordStyle = { italic = true },
--   statementStyle = { bold = true },
--   typeStyle = {},
--   variablebuiltinStyle = { italic = true },
--   specialReturn = true,       -- special highlight for the return keyword
--   specialException = true,    -- special highlight for exception handling keywords
--   transparent = false,        -- do not set background color
--   dimInactive = false,        -- dim inactive window `:h hl-NormalNC`
--   colors = {},
--   overrides = {},
-- }

-- -- set colorscheme after options
-- vim.cmd('colorscheme kanagawa')
