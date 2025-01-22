return {
  {
    "williamboman/mason.nvim",
    opts = {
      ensure_installed = {
        "eslint-lsp",       -- LSP para JavaScript/TypeScript
        "typescript-language-server", -- LSP para TypeScript
        "prettier",         -- Formatter para JavaScript/TypeScript
      },
    },
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        tsserver = { -- LSP para TypeScript
          settings = {
            completions = {
              completeFunctionCalls = true, -- Autocompletar chamadas de função
            },
          },
        },
        eslint = { -- LSP para ESLint
          settings = {
            format = { enable = true }, -- Formatação automática com ESLint
          },
        },
      },
    },
  },
  {
    "jose-elias-alvarez/null-ls.nvim", -- Plugin para integração com ferramentas externas
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local null_ls = require("null-ls")
      null_ls.setup({
        sources = {
          null_ls.builtins.formatting.prettier, -- Formatação com Prettier
          null_ls.builtins.diagnostics.eslint,  -- Diagnóstico com ESLint
        },
      })
    end,
  },
}
