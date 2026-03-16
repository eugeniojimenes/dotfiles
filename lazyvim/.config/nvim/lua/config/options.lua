-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

vim.opt.wrap = true
vim.opt.clipboard = "unnamedplus"
vim.opt.colorcolumn = "120"
vim.opt.list = true
vim.opt.listchars = { eol = "󱞥", trail = "", tab = ">-", nbsp = "~" }
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.mouse = "a"
vim.g.autoformat = false


---- For Ruby Language ----
-- NOTE: Temporarily bug fix for this issue: https://github.com/nvim-treesitter/nvim-treesitter/issues/3363
vim.cmd("autocmd FileType ruby setlocal indentkeys-=.")
-- LSP setup:
vim.g.lazyvim_ruby_lsp = "solargraph" -- or "ruby_lsp"
vim.g.lazyvim_ruby_formatter = "rubocop"
