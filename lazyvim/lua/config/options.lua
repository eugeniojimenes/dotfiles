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

-- Set ltex-ls language on the fly
vim.api.nvim_create_user_command(
  "LtexLang",
  function(lang)
    local language = lang.args
    local clients = vim.lsp.get_active_clients()

    for _, client in ipairs(clients) do
      if client.name == "ltex" then
        vim.api.nvim_notify("Set ltex-ls lang to " .. language, vim.log.levels.INFO,
          { title = "utils.functions", timeout = 2000 })
        client.config.settings.ltex.language = language
        vim.lsp.buf_notify(0, "workspace/didChangeConfiguration", { settings = client.config.settings })
        return
      end
    end
  end,
  { nargs = 1, desc = "Set ltex-ls language" }
)

-- -- Set solargraph to use rubocop on the fly
-- vim.api.nvim_create_user_command(
--   "SolargraphWithDiagnostics",
--   function()
--     local clients = vim.lsp.get_active_clients()
--     local solargraph_done = false
--     local standardrb_done = false
--
--     for _, client in ipairs(clients) do
--       if client.name == "solargraph" then
--         vim.api.nvim_notify("Set solargraph with rubocop diagnostics", vim.log.levels.INFO,
--           { title = "utils.functions", timeout = 2000 })
--         client.config.settings.solargraph.diagnostics = true
--         client.config.settings.solargraph.formatting = true
--         vim.lsp.buf_notify(0, "workspace/didChangeConfiguration", { settings = client.config.settings })
--         solargraph_done = true
--       end
--
--       if client.name == "standardrb" then
--         vim.api.nvim_notify("Disable Standardrb", vim.log.levels.INFO,
--           { title = "utils.functions", timeout = 2000 })
--         client.stop()
--         vim.lsp.buf_notify(0, "workspace/didChangeConfiguration", { settings = client.config.settings })
--         standardrb_done = true
--       end
--
--       if solargraph_done and standardrb_done then
--         return
--       end
--     end
--   end,
--   { nargs = 0, desc = "Set solargraph with rubocop" }
-- )
