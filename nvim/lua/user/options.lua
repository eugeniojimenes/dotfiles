local options = {
  backup = false,                          -- creates a backup file
  clipboard = "unnamedplus",               -- allows neovim to access the system clipboard
  cmdheight = 1,                           -- more space in the neovim command line for displaying messages
  colorcolumn = "100",                     -- set a light grey column at character 100
  completeopt = { "menuone", "noselect" }, -- mostly just for cmp
  conceallevel = 2,                        -- so that `` is visible in markdown files
  cursorline = true,                       -- highlight the current line
  expandtab = true,                        -- convert tabs to spaces
  fileencoding = "utf-8",                  -- the encoding written to a file
  guifont = "monospace:h17",               -- the font used in graphical neovim applications
  hlsearch = true,                         -- highlight all matches on previous search pattern
  ignorecase = false,                      -- use case sensitive in search patterns
  list = true,                             -- display invisible characters
  -- listchars = { tab = "▸ ", trail = "·" },
  -- mouse = "a",                             -- allow the mouse to be used in neovim
  number = true,                           -- set numbered lines
  numberwidth = 4,                         -- set number column width to 2 {default 4}
  pumheight = 10,                          -- pop up menu height
  relativenumber = true,                   -- set relative numbered lines
  scrolloff = 8,                           -- as you go down or up in lines it automatically scroll at 8 lines
  shiftwidth = 2,                          -- the number of spaces inserted for each indentation
  showmode = false,                        -- we don't need to see things like -- INSERT -- anymore
  showtabline = 2,                         -- always show tabs
  sidescrolloff = 8,                       -- as you go right or left in the line it automatically scroll horizontally at 8 characters
  signcolumn = "yes",                      -- always show the sign column, otherwise it would shift the text each time
  smartcase = true,                        -- smart case
  smartindent = true,                      -- make indenting smarter again
  splitbelow = true,                       -- force all horizontal splits to go below current window
  splitright = true,                       -- force all vertical splits to go to the right of current window
  swapfile = false,                        -- creates a swapfile
  tabstop = 2,                             -- insert 2 spaces for a tab
  termguicolors = true,                    -- set term gui colors (most terminals support this)
  timeoutlen = 500,                        -- time to wait for a mapped sequence to complete (in milliseconds)
  undofile = true,                         -- enable persistent undo
  updatetime = 300,                        -- faster completion (4000ms default)
  wildmenu = true,                         -- command line completion
  wildmode = "longest:full,full",
  wrap = false,                            -- display lines as one long line
  writebackup = false,                     -- if a file is being edited by another program (or was written to file while editing with another program), it is not allowed to be edited
}

for key, value in pairs(options) do
  vim.opt[key] = value
end

vim.opt.shortmess:append "c"               -- Don't pass messages to |ins-completion-menu|.

vim.cmd "set whichwrap+=<,>,[,],h,l"
vim.cmd [[set iskeyword+=-]]               -- consider '+', '=' and '-' as part of a word

