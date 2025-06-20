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

-- -- -- Fold settings
-- vim.opt.foldmethod = "expr"
-- vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
-- vim.opt.foldtext = "v:lua.vim.treesitter.foldtext()"

-- vim.api.nvim_create_autocmd("FileType", {
--   pattern = "ruby",
--   callback = function()
--     vim.opt_local.foldmethod = "expr"
--     vim.opt_local.foldexpr = "v:lua.vim.treesitter.foldexpr()"

--     -- Custom fold text to show line count
--     vim.opt_local.foldtext = [[substitute(getline(v:foldstart),'\t',repeat('\ ',&tabstop),'g').'  '.trim(getline(v:foldend)).' ('.(v:foldend-v:foldstart-1).' lines)']]

--     -- Configure folding ranges
--     vim.treesitter.query.set(
--       "ruby",
--       "folds",
--       [[
--         ((method) @fold)
--         ((class) @fold)
--         ((module) @fold)
--         ((block) @fold (#offset! @fold 0 0 0 -1))
--         ((do_block) @fold (#offset! @fold 0 0 0 -1))
--         ((if) @fold (#offset! @fold 0 0 0 -1))
--         ((begin) @fold (#offset! @fold 0 0 0 -1))
--         ((case) @fold (#offset! @fold 0 0 0 -1))
--         ((rescue) @fold (#offset! @fold 0 0 0 -1))
--         ((array) @fold (#offset! @fold 0 0 0 -1))
--         ((hash) @fold (#offset! @fold 0 0 0 -1))
--       ]]
--     )
--   end,
-- })
