local opts = {
  cmd = { "ltex-ls" },
  filetypes = { "markdown", "text", "gitcommit" },
}
require("lvim.lsp.manager").setup("ltex", opts)
