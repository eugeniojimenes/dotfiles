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

---- For Ruby Language ----
-- NOTE: Temporarily bug fix for this issue: https://github.com/nvim-treesitter/nvim-treesitter/issues/3363
vim.cmd("autocmd FileType ruby setlocal indentkeys-=.")
-- LSP setup:
vim.g.lazyvim_ruby_lsp = "solargraph" -- or "ruby_lsp"
vim.g.lazyvim_ruby_formatter = "rubocop"
