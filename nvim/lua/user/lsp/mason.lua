-- Source: https://github.com/williamboman/mason.nvim
-- "Easily install and manage LSP servers, DAP servers, linters, and formatters."

local status_ok, mason = pcall(require, "mason")
if not status_ok then
  return
end

local status_ok_1, mason_lspconfig = pcall(require, "mason-lspconfig")
if not status_ok_1 then
  return
end

local servers = {
  "bashls",
  "clangd",
  "cssls",
  "cssmodules_ls",
  "emmet_ls",
  "html",
  "jsonls",
  "lemminx",
  "ltex",
  "pyright",
  -- "sorbet", -- Search for!!!
  "solargraph",
  "sumneko_lua",
  "tailwindcss",
  "tsserver",
  "yamlls",
  "zk" -- Search for!!!
}

local settings = {
  ui = {
    border = "rounded",
    icons = {
      package_installed = "◍",
      package_pending = "◍",
      package_uninstalled = "◍",
    },
  },
  log_level = vim.log.levels.INFO,
  max_concurrent_installers = 4,
}

mason.setup(settings)
mason_lspconfig.setup {
  ensure_installed = servers,
  automatic_installation = true,
}

local lspconfig_status_ok, lspconfig = pcall(require, "lspconfig")
if not lspconfig_status_ok then
  return
end

local opts = {}

for _, server in pairs(servers) do
  opts = {
    on_attach = require("user.lsp.handlers").on_attach,
    capabilities = require("user.lsp.handlers").capabilities,
  }

  server = vim.split(server, "@")[1]

  -- Apply custom settings if there are any for the server in user/lsp/settings folder
  -- IMPORTANT: The filename must be exactly the same of the server name!!!
	local has_custom_opts, server_custom_opts = pcall(require, "user.lsp.settings." .. server)
	if has_custom_opts then
		opts = vim.tbl_deep_extend("force", server_custom_opts, opts)
	end

  lspconfig[server].setup(opts)
end
