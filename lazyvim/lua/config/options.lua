-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

vim.opt.wrap = true
vim.opt.clipboard = "unnamedplus"
vim.opt.colorcolumn = "120"
vim.g.clipboard = {
  name = 'WslClipboard',
  copy = {
    ["+"] = "clip.exe",
    ["*"] = "clip.exe",
  },
  paste = {
    ["+"] = 'powershell.exe -c [Console]::Out.Write($(Get-Clipboard -Raw).tostring().replace("`r", ""))',
    ["*"] = 'powershell.exe -c [Console]::Out.Write($(Get-Clipboard -Raw).tostring().replace("`r", ""))',
  },
  cache_enabled = 0,
}
vim.opt.list = true
vim.opt.listchars = { eol = "󱞥", trail = "", tab = ">-", nbsp = "~" }
vim.opt.relativenumber = true
vim.opt.mouse = ""

-- -- For Ruby language:
-- local function file_exists(filename)
--   local stat = vim.loop.fs_stat(filename)
--   return stat and stat.type == 'file'
-- end
-- vim.g.lazyvim_ruby_lsp = "solargraph"
-- if file_exists(".rubocop.yml") then
--   vim.g.lazyvim_ruby_formatter = "rubocop"
-- else
--   vim.g.lazyvim_ruby_formatter = "standardrb"
-- end
