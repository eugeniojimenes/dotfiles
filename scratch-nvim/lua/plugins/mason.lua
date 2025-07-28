return {
  {
    "mason-org/mason.nvim",
    opts = {},
  },
  {
      "mason-org/mason-lspconfig.nvim",
      dependencies = {
          { "mason-org/mason.nvim", opts = {} },
          "neovim/nvim-lspconfig",
      },
      opts = {
        ensure_installed = {
          "lua_ls",
          "solargraph",
          -- "vtsls",
          "ts_ls",
          "ruff",
          "pyright",
          "tailwindcss",
          "eslint",
        },
      },
  }
}
