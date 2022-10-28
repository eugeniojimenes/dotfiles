-- Source: https://github.com/nvim-treesitter/nvim-treesitter
-- "Nvim-treesitter is based on three interlocking features: language parsers,
-- queries, and modules, where modules provide features – e.g., highlighting"

local status_ok, configs = pcall(require, "nvim-treesitter.configs")
if not status_ok then
  return
end

configs.setup {
  ensure_installed = {
    "lua", "bash", "make", "dockerfile", "regex",
    "html", "css", "scss", "json", "yaml",
    "markdown", "markdown_inline",
    "ruby", "python", "javascript", "typescript",
  }, -- one of "all", "maintained" (parsers with maintainers), or a list of languages
     -- NOTE: "embedded_template" is freezing in .html.erb files!!!
  sync_install = false, -- install languages synchronously (only applied to `ensure_installed`)
  ignore_install = { "" }, -- List of parsers to ignore installing
  autopairs = {
    enable = true,
  },
  highlight = {
    enable = true, -- false will disable the whole extension
    disable = { "" }, -- list of language that will be disabled
    additional_vim_regex_highlighting = true,
  },
  indent = { enable = true, disable = { "yaml" } },
  context_commentstring = {
    enable = true,
    enable_autocmd = false,
  },
}
