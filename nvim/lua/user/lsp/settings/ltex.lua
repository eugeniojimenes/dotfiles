-- Source: https://github.com/valentjn/ltex-ls
-- "Implements a language server according to the Language Server Protocol (LSP) and provides
-- grammar and spelling errors in markup documents (LATEX, Markdown, etc.). The documents are 
-- checked with LanguageTool."

return {
  cmd = { "ltex-ls" },
  filetypes = { "markdown", "text", "gitcommit" },
  flags = { debounce_text_changes = 300 },
  -- settings = {
  --   ltex = {
  --     language = "pt-BR"
  --   }
  -- }
}
