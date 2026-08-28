return {
  {
    "mason-org/mason.nvim",
    opts = {
      -- Mason writes each tool's binstub with a hardcoded shebang pointing at whichever interpreter
      -- was active at install time (its rubocop runs ruby 3.4.5). Prepending mason/bin then lets
      -- those binstubs shadow the project's own tools: inside `mise exec -- bundle exec rubocop`,
      -- bundler resolved mason's rubocop and died with Bundler::RubyVersionMismatch against a
      -- Gemfile pinned to ruby 3.1.6. Appending keeps mason as a fallback for projects that pin
      -- nothing, while a project-managed tool always wins.
      PATH = "append",
      ensure_installed = {
        "clangd",
        "debugpy",
        "eslint-lsp",
        "js-debug-adapter",
        "json-lsp",
        "lua-language-server",
        "marksman",
        "prettier",
        "prisma-language-server",
        "pyright",
        -- NOTE: to use global ~/.rubocop.yml setup you need to install globally:
        --       `gem install rubocop rubocop-performance rubocop-rails rubocop-rspec`
        "rubocop",
        "ruby-lsp",
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
