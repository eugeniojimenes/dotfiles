local lsp = vim.g.lazyvim_ruby_lsp
local formatter = vim.g.lazyvim_ruby_formatter

return {
  {
    "RRethy/nvim-treesitter-endwise",
    lazy = false,
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        ruby_lsp = {
          enabled = lsp == "ruby_lsp",
        },
        solargraph = {
          -- NOTE: This setup allows you to use solargraph as LSP and rubocop as fromatter.
          enabled = lsp == "solargraph",
          settings = {
            solargraph = {
              diagnostics = formatter == "solargraph",
              formatting = formatter == "solargraph",
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
