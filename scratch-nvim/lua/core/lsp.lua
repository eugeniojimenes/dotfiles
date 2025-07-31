-- vim.lsp.enable({
--   "lua_ls",
--   "solargraph",
--   -- "vtsls",
--   "ts_ls",
--   "ruff",
--   "pyright",
-- })

vim.diagnostic.config({
  -- virtual_lines = true,
  virtual_text = true,
  underline = true,
  update_in_insert = false,
  severity_sort = true,
  float = {
    border = "rounded",
    source = true,
    -- source = "always", -- Display source of diagnostic (e.g., "LSP")
    -- border = "single", -- Add a border around the float window
    -- focusable = true, -- Allow the float window to be focused
    -- header = "Diagnostics:", -- Add a header to the float window
    -- prefix = " ", -- Add a prefix to each diagnostic message
    -- severity_sort = true, -- Sort diagnostics by severity
    -- format = function(diagnostic)
    --   return string.format("[%s] %s", diagnostic.severity, diagnostic.message)
    -- end,
  },
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = "󰅚 ",
      [vim.diagnostic.severity.WARN] = "󰀪 ",
      [vim.diagnostic.severity.INFO] = "󰋽 ",
      [vim.diagnostic.severity.HINT] = "󰌶 ",
    },
    numhl = {
      [vim.diagnostic.severity.ERROR] = "ErrorMsg",
      [vim.diagnostic.severity.WARN] = "WarningMsg",
    },
  },
})
