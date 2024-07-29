local function file_exists(filename)
  local stat = vim.loop.fs_stat(filename)
  return stat and stat.type == 'file'
end

if not file_exists(".rubocop.yml") then
  local linters = require "lvim.lsp.null-ls.linters"
  local opts = {
    cmd = { "solargraph", "stdio" },
    settings = {
      solargraph = {
        diagnostics = false,
        formatting = false
      },
    },
  }
  linters.setup { { command = "standardrb", filetypes = { "ruby" } } }
  require("lvim.lsp.manager").setup("solargraph", opts)
else
  require("lvim.lsp.manager").setup("solargraph")
end

-- solargraph.autoformat       default: false
-- solargraph.bundlerPath      default: "bundle"
-- solargraph.checkGemVersion  default: true
-- solargraph.commandPath      default: "solargraph"
-- solargraph.completion       default: true
-- solargraph.definitions      default: true
-- solargraph.diagnostics      default: false
-- solargraph.externalServer
-- solargraph.folding          default: true
-- solargraph.formatting       default: false
-- solargraph.hover            default: true
-- solargraph.logLevel         default: "warn"
-- solargraph.references       default: true
-- solargraph.rename           default: true
-- solargraph.symbols          default: true
-- solargraph.transport        default: "socket"
-- solargraph.useBundler       default: false
