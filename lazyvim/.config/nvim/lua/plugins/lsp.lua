return {
  {
    "mason-org/mason.nvim",
    opts = {
      ensure_installed = {
        "clangd",
        "debugpy",
        "erb-formatter",
        "erb-lint",
        "eslint-lsp",
        "js-debug-adapter",
        "json-lsp",
        "lua-language-server",
        "prettier",
        "prisma-language-server",
        "pyright",
        -- NOTE: to use global ~/.rubocop.yml setup you need to install globally:
        --       `gem install rubocop rubocop-performance rubocop-rails rubocop-rspec`
        "rubocop",
        "ruff",
        "rust-analyzer",
        "shfmt",
        "solargraph",
        "stylua",
        "taplo",
        "vtsls",
      },
    },
  },
}
