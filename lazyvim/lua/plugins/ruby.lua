local lsp = vim.g.lazyvim_ruby_lsp
local formatter = vim.g.lazyvim_ruby_formatter

return {
  {
    "williamboman/mason.nvim",
    opts = { ensure_installed = { "ruby-lsp", "solargraph", "rubocop", "standardrb" } },
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
    servers = {
      ruby_lsp = {
        enabled = lsp == "ruby_lsp",
      },
      solargraph = {
        enabled = lsp == "solargraph",
          settings = {
            solargraph = {
              diagnostics = formatter == "solargraph", -- set `true` to use .rubocop.yml
              formatting = formatter == "solargraph"   -- set `true` to use .rubocop.yml
            },
          },
      },
      rubocop = {
        enabled = formatter == "rubocop",
      },
      standardrb = {
        enabled = formatter == "standardrb",
      },
    },
    },
  },
}
