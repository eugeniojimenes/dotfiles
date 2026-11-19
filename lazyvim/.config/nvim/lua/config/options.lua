require("config.clipboard")
---- Options are automatically loaded before lazy.nvim startup
---- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua

---- Options that I usually use, but which are also lazyvim's default
-- vim.opt.clipboard = "unnamedplus"
-- vim.opt.list = true
-- vim.opt.number = true
-- vim.opt.relativenumber = true
-- vim.opt.mouse = "a"
-- vim.g.autoformat = false

vim.opt.wrap = true
vim.opt.colorcolumn = "120"
vim.opt.listchars = { eol = "󱞥", trail = "", tab = ">-", nbsp = "~" }

-- No remote plugins (Python/Node/Ruby/Perl hosts): none in use, and the host packages came from npm, PyPI and RubyGems
-- with no release-age wait (mise postinstall). LSPs and formatters run as their own programs, unaffected.
vim.g.loaded_python3_provider = 0
vim.g.loaded_node_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_perl_provider = 0

-- tmux 3.7 holds a pane's synchronized output (termsync) but still moves the terminal cursor while it lasts: the cursor
-- flashes lines away in the explorer at each move. Fixed in tmux 3.8 (commit 57a13664cc); drop this once it ships.
if vim.env.TMUX then
  vim.o.termsync = false
end

---- For Ruby Language ----
-- NOTE: Temporarily bug fix for this issue: https://github.com/nvim-treesitter/nvim-treesitter/issues/3363
vim.cmd("autocmd FileType ruby setlocal indentkeys-=.")
-- LSP setup:
vim.g.lazyvim_ruby_lsp = "ruby_lsp" -- or "solargraph"
vim.g.lazyvim_ruby_formatter = "rubocop"
