-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

local function is_wsl()
  local output = vim.fn.system("uname -r")
  return string.find(output, "WSL") ~= nil
end

-- vim.cmd("set expandtab")
vim.opt.expandtab = true
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2
vim.opt.undofile = true
vim.opt.undolevels = 10000
vim.opt.updatetime = 200 -- Save swap file and trigger CursorHold
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"
-- vim.opt.swapfile = true
vim.opt.wrap = true
vim.opt.clipboard = "unnamedplus"
vim.opt.colorcolumn = "120"
if is_wsl() then
  vim.g.clipboard = {
    name = "WslClipboard",
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
end
vim.opt.list = true
vim.opt.listchars = { eol = "󱞥", trail = "", tab = ">-", nbsp = "~" }
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.mouse = "a"

-- -- For Ruby language:
-- vim.cmd("autocmd FileType ruby setlocal indentkeys-=.")
-- local function file_exists(filename)
--   local stat = vim.loop.fs_stat(filename)
--   return stat and stat.type == 'file'
-- end
