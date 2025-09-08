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
vim.opt.laststatus = 3 -- Required by avante.nvim

-- -- For Ruby language:
vim.cmd("autocmd FileType ruby setlocal indentkeys-=.")
-- local function file_exists(filename)
--   local stat = vim.loop.fs_stat(filename)
--   return stat and stat.type == 'file'
-- end
vim.g.lazyvim_ruby_lsp = "solargraph"
-- vim.g.lazyvim_ruby_lsp = "ruby_lsp"
-- if file_exists(".rubocop.yml") then
vim.g.lazyvim_ruby_formatter = "rubocop"
-- else
-- vim.g.lazyvim_ruby_formatter = "standardrb"
-- end
