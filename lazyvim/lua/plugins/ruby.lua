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
              diagnostics = false, -- set `true` to use .rubocop.yml
              formatting = false   -- set `true` to use .rubocop.yml
            },
          },
        },
        rubocop = {
          enabled = false,
        },
        standardrb = {
          enabled = true, -- set `false` to use .rubocop.yml
        },
      },
    },
  },
}
