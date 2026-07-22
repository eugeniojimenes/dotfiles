local lsp = vim.g.lazyvim_ruby_lsp
local formatter = vim.g.lazyvim_ruby_formatter

-- Build an LSP `cmd` that runs a Ruby tool under the project's Ruby via `mise exec`.
-- nvim spawns LSPs outside mise's per-directory shell activation, so a bare `bundle`/
-- `ruby-lsp` would run under the wrong Ruby and fail to find the project bundle.
--   bundled  = the command to use inside a bundler project (e.g. { "bundle", "exec", "rubocop", "--lsp" })
--   fallback = the command to use when there's no Gemfile (e.g. { "rubocop", "--lsp" })
-- When a Gemfile is present but `mise` is unavailable, we'd silently drop to global
-- tooling (the failure that only showed up in lsp.log), so warn instead of hiding it.
local function mise_cmd(bundled, fallback)
  if vim.fn.filereadable(vim.fn.getcwd() .. "/Gemfile") ~= 1 then
    return fallback
  end
  if vim.fn.executable("mise") ~= 1 then
    vim.schedule(function()
      vim.notify(
        "[ruby] Gemfile found but `mise` is not on PATH — using global tooling, project bundle ignored",
        vim.log.levels.WARN
      )
    end)
    return fallback
  end
  return vim.list_extend({ "mise", "exec", "--" }, bundled)
end

-- True when we should run tooling through the project's bundle under the project Ruby.
local function use_bundle()
  return vim.fn.filereadable(vim.fn.getcwd() .. "/Gemfile") == 1 and vim.fn.executable("mise") == 1
end

return {
  {
    "RRethy/nvim-treesitter-endwise",
    lazy = false,
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        ruby_lsp = {
          enabled = lsp == "ruby_lsp",
          -- ruby-lsp composes its own `.ruby-lsp/` bundle from the project Gemfile, so it must run
          -- under the correct Ruby. Install per-Ruby with `mise exec -- gem install ruby-lsp`
          -- (it is intentionally not added to the project Gemfile).
          cmd = mise_cmd({ "ruby-lsp" }, { "ruby-lsp" }),
        },
        solargraph = {
          -- NOTE: This setup allows you to use solargraph as LSP and rubocop as fromatter.
          enabled = lsp == "solargraph",
          settings = {
            solargraph = {
              diagnostics = formatter == "solargraph",
              formatting = formatter == "solargraph",
            },
          },
        },
        rubocop = {
          enabled = formatter == "rubocop",
          -- Prefer the project's bundled rubocop so versions match Gemfile.lock (avoids conflicts
          -- between mason/global rubocop and the project's standard gem).
          cmd = mise_cmd({ "bundle", "exec", "rubocop", "--lsp" }, { "rubocop", "--lsp" }),
        },
        standardrb = {
          enabled = formatter == "standardrb",
        },
      },
    },
  },
  {
    -- Conform's rubocop *formatter* is separate from the LSP above. LazyVim points it at
    -- Mason's rubocop, and its default args force `--server`. The rubocop server daemon is
    -- shared per-project across every rubocop on the machine (Mason 1.86, global, bundled
    -- 1.84); a daemon started by the wrong version gets reused by every later call and crashes
    -- against the `standard` gem's rubocop pin ("Formatter failed"). Fix: run the bundled
    -- rubocop under the project Ruby and drop `--server` so the version always matches Gemfile.lock.
    -- ponytail: --no-server costs ~1s/save; to regain the daemon, keep mason/global rubocop off
    -- PATH for ruby projects so only the bundled version ever owns the server socket.
    "stevearc/conform.nvim",
    optional = true,
    opts = {
      formatters = {
        rubocop = {
          command = function()
            return use_bundle() and "mise" or "rubocop"
          end,
          args = function()
            local base = { "-a", "-f", "quiet", "--stderr", "--stdin", "$FILENAME" }
            if use_bundle() then
              return vim.list_extend({ "exec", "--", "bundle", "exec", "rubocop" }, base)
            end
            return base
          end,
        },
      },
    },
  },
}
