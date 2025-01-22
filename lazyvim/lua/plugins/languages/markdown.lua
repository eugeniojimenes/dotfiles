return {
  {
    "williamboman/mason.nvim",
    opts = { ensure_installed = { "ltex-ls" } },
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        ltex = {
          cmd = { "ltex-ls" },
          filetypes = { "markdown", "text", "gitcommit", "norg" },
        },
      },
    },
  },
}
