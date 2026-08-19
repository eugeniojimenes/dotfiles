local lsp = vim.g.lazyvim_ruby_lsp
local formatter = vim.g.lazyvim_ruby_formatter

-- Build an LSP `cmd` that runs a Ruby tool under the project's Ruby via `mise exec`.
-- nvim spawns LSPs outside mise's per-directory shell activation, so a bare `bundle`/
-- `ruby-lsp` would run under the wrong Ruby and fail to find the project bundle.
--
-- No Gemfile probe here: lspconfig starts each server with its cwd set to that server's
-- `root_dir`, and `mise exec` resolves `.tool-versions` from its own cwd, so one static command
-- is correct for every project. The previous version read `vim.fn.getcwd()` once, when lazy.nvim
-- evaluated this spec, which meant launching nvim outside a project picked the fallback branch
-- for the whole session. Whether a project can run `bundle exec` is decided by `root_dir` below.
local function mise_cmd(cmd)
  if vim.fn.executable("mise") ~= 1 then
    vim.schedule(function()
      vim.notify(
        "[ruby] `mise` is not on PATH, using global tooling, project bundle ignored",
        vim.log.levels.WARN
      )
    end)
    return cmd
  end
  return vim.list_extend({ "mise", "exec", "--" }, cmd)
end

-- Both ruby_lsp and rubocop exit 1 immediately when the project bundle is incomplete, and nvim
-- only reports "quit with exit code 1"; the actual Bundler::GemNotFound is buried in lsp.log.
-- Check once in the background and say what to run.
local function warn_on_stale_bundle()
  if vim.fn.filereadable(vim.fn.getcwd() .. "/Gemfile") ~= 1 or vim.fn.executable("mise") ~= 1 then
    return
  end
  vim.system({ "mise", "exec", "--", "bundle", "check" }, { text = true }, function(out)
    if out.code == 0 then
      return
    end
    vim.schedule(function()
      vim.notify(
        "[ruby] project bundle is incomplete, so ruby_lsp and rubocop will not start.\n"
          .. "Run `bundle install`.\n\n"
          .. vim.trim((out.stdout or "") .. (out.stderr or "")),
        vim.log.levels.WARN
      )
    end)
  end)
end

warn_on_stale_bundle()

-- Resolve the project root, preferring `.git` over `Gemfile`, and refusing to resolve one at all
-- for read-only dependency sources. Two separate problems share this.
--
-- Jumping into an installed gem (`gd` on `include IdentityCache`) used to start a second pair of
-- Ruby servers rooted inside the gem, because an installed gem ships its own Gemfile and that is
-- one of lspconfig's root markers. Both died on arrival: the gem has no Gemfile.lock, which
-- ruby-lsp reports as `Project contains a Gemfile, but no Gemfile.lock` before exiting 78, and no
-- `.tool-versions`, so mise fell back to the global Ruby and rubocop exited 2.
--
-- `Gemfile` also matches the *nearest* one, which is wrong inside a monolith: a work repo carries
-- `engines/passwordless/Gemfile` and `engines/request_tracker/Gemfile`, so any buffer under
-- `engines/` claimed its own root and got its own ruby_lsp + rubocop pair: a second full index of
-- the same repo, and a rubocop that cannot load `.rubocop.yml`, whose `require:
-- ./rubocop/custom_cops` only resolves from the repo root. `.git` marks the real checkout, so try
-- it first and keep `Gemfile` for a bundler project that is not a git repo.
-- ponytail: matches the two paths bundler actually installs into; add more if a setup uses another.
local function project_root(bufnr)
  local fname = vim.api.nvim_buf_get_name(bufnr)
  if fname:find("/lib/ruby/gems/", 1, true) or fname:find("/vendor/bundle/", 1, true) then
    return nil
  end
  return vim.fs.root(bufnr, { ".git" }) or vim.fs.root(bufnr, { "Gemfile" })
end

local function project_root_dir(bufnr, on_dir)
  local root = project_root(bufnr)
  if root then
    on_dir(root)
  end
end

-- rubocop is launched as `bundle exec`, so it needs a Gemfile at the root it starts in. A Ruby
-- file in a git repo with no Gemfile gets no rubocop server rather than one that exits instantly.
local function bundler_root_dir(bufnr, on_dir)
  local root = project_root(bufnr)
  if root and vim.uv.fs_stat(root .. "/Gemfile") then
    on_dir(root)
  end
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
          cmd = mise_cmd({ "ruby-lsp" }),
          root_dir = project_root_dir,
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
          cmd = mise_cmd({ "bundle", "exec", "rubocop", "--lsp" }),
          root_dir = bundler_root_dir,
        },
        standardrb = {
          enabled = formatter == "standardrb",
        },
      },
    },
  },
  {
    -- LazyVim's ruby extra points conform at rubocop, which spawns a *second* `bundle exec rubocop`
    -- on every save, on top of the rubocop LSP already attached to the buffer, which advertises
    -- `document_formatting_provider: true` and autocorrects exactly the same way. Emptying the
    -- conform list leaves conform with no source for ruby, so LazyVim's LSP formatter (registered
    -- as primary at priority 1) becomes the active one. One rubocop process instead of two, and
    -- the daemon-version conflict that forced `--no-server` can no longer happen.
    "stevearc/conform.nvim",
    optional = true,
    opts = function(_, opts)
      opts.formatters_by_ft = opts.formatters_by_ft or {}
      opts.formatters_by_ft.ruby = {}
    end,
  },
}
