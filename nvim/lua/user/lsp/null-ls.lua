-- Source: https://github.com/jose-elias-alvarez/null-ls.nvim
-- "Language server to inject LSP diagnostics, code actions, and more via Lua."

local null_ls_status_ok, null_ls = pcall(require, "null-ls")
if not null_ls_status_ok then
  return
end

-- https://github.com/jose-elias-alvarez/null-ls.nvim/tree/main/lua/null-ls/builtins/formatting
local formatting = null_ls.builtins.formatting
-- https://github.com/jose-elias-alvarez/null-ls.nvim/tree/main/lua/null-ls/builtins/diagnostics
local diagnostics = null_ls.builtins.diagnostics

null_ls.setup {
  debug = false,
  sources = {
    formatting.prettier.with { extra_args = { "--single-quote", "--jsx-single-quote" } }, -- Prettier is an opinionated code formatter for javascript, javascriptreact , typescript , typescriptreact , vue, css, scss , less, html, json, jsonc , yaml, markdown, graphql, handlebars
    formatting.black.with { extra_args = { "--fast" } }, -- The uncompromising Python code formatter
    formatting.stylua,    -- An opinionated code formatter for Lua
    formatting.shfmt,     -- A shell parser, formatter, and interpreter with bash support.
    formatting.rustywind.with { -- CLI for organizing Tailwind CSS classes
      filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact", "vue", "svelte", "html", "eruby" }
    },
    -- diagnostics.yamllint, -- A linter for YAML files.
    formatting.rubocop.with({   -- Ruby static code analyzer and formatter, based on the community Ruby style guide.
      -- NOTE: Using 'extra_args' doesn't work here because we need to replace the '-a' flag for '-A'
      args = { "-A", "-f", "quiet", "--stderr", "--stdin", "$FILENAME" },
    }),
    -- diagnostics.erb_lint.with { -- Lint your ERB files
    --   args ={ "--format", "json", "--stdin", "$FILENAME" },
    -- },
    -- diagnostics.rubocop,  -- The Ruby Linter/Formatter that Serves and Protects.
    -- formatting.erb_lint.with {  -- Lint your ERB files
    --   args ={ "--autocorrect", "--stdin", "$FILENAME" },
    -- },
  },
}

-- NOTES: It requires to install:
--   gem install rubocop rubocop-packaging rubocop-performance rubocop-rails rubocop-rspec erb_lint
--   npm install -g rustywind
--   pip install --user yamllint

