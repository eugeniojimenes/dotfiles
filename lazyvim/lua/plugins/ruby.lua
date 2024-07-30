return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = { ensure_installed = { "ruby" } },
  },
  {
    "williamboman/mason.nvim",
    opts = { ensure_installed = { "ruby-lsp", "solargraph", "rubocop", "standardrb" } },
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        ruby_lsp = {
          enabled = false,
        },
        solargraph = {
          enabled = true,
          settings = {
            solargraph = {
              diagnostics = false,
              formatting = false
            },
          },
        },
        rubocop = {
          enabled = false,
        },
        standardrb = {
          enabled = true,
        },
      },
    },
  },
}
