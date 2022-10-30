local fn = vim.fn

-- Automatically install packer
local install_path = fn.stdpath "data" .. "/site/pack/packer/start/packer.nvim"
if fn.empty(fn.glob(install_path)) > 0 then
  PACKER_BOOTSTRAP = fn.system {
    "git",
    "clone",
    "--depth",
    "1",
    "https://github.com/wbthomason/packer.nvim",
    install_path,
  }
  print "Installing packer close and reopen Neovim..."
  vim.cmd [[packadd packer.nvim]]
end

-- Autocommand that reloads neovim whenever you save the plugins.lua file
vim.cmd [[
  augroup packer_user_config
    autocmd!
    autocmd BufWritePost plugins.lua source <afile> | PackerSync
  augroup end
]]

-- Use a protected call so we don't error out on first use
local status_ok, packer = pcall(require, "packer")
if not status_ok then
  return
end

-- Have packer use a popup window
packer.init {
  display = {
    open_fn = function()
      return require("packer.util").float { border = "rounded" }
    end,
  },
}

-- Install your plugins here
return packer.startup(function(use)
  -- Basics
  use "wbthomason/packer.nvim"        -- Have packer manage itself
  use "nvim-lua/popup.nvim"           -- An implementation of the Popup API from vim in Neovim
  use "nvim-lua/plenary.nvim"         -- Useful lua functions used ny lots of plugins
  use "windwp/nvim-autopairs"         -- Autopairs, integrates with both cmp and treesitter
  -- use {                               -- I still prefer this plugin for commenting :)
  --   "preservim/nerdcommenter",
  --   config = function()
  --     vim.g.NERDDefaultAlign = "left"
  --     vim.g.NERDSpaceDelims = 1
  --   end
  -- }
  use "gabesoft/vim-ags"              -- :Ags commands
  use "lewis6991/impatient.nvim"      -- Optimisations
  use "christianchiarulli/lua-dev.nvim"

  -- Pretty Icons (it requeres nerd-font!)
  use "kyazdani42/nvim-web-devicons"

  -- Startup
  use "goolord/alpha-nvim"
  
  -- Comment
  use "numToStr/Comment.nvim"

  -- File Explorer
  use "kyazdani42/nvim-tree.lua"

  -- Buffer Line
  use { 'akinsho/bufferline.nvim', tag = "v3.*" }
  use "moll/vim-bbye"

  -- Statusline
  use "nvim-lualine/lualine.nvim"

  -- Colorschemes
  use "lunarvim/onedarker.nvim"
  use "lunarvim/darkplus.nvim"
  use "folke/tokyonight.nvim"
  -- use "lunarvim/colorschemes"
  -- use "rebelot/kanagawa.nvim"

  -- Terminals (persist and toggle multiple terminals)
  use "akinsho/toggleterm.nvim"

  -- Indentation guides (all lines including empty lines)
  use "lukas-reineke/indent-blankline.nvim"

  -- Project Management
  use "ahmedkhalf/project.nvim"

  -- Completions (CMP)
  use "hrsh7th/nvim-cmp"             -- The completion plugin
  use "hrsh7th/cmp-buffer"           -- buffer completions
  use "hrsh7th/cmp-path"             -- path completions
  use "hrsh7th/cmp-cmdline"          -- cmdline completions
  use "saadparwaiz1/cmp_luasnip"     -- snippet completions
  use "hrsh7th/cmp-nvim-lsp"
  use "hrsh7th/cmp-nvim-lua"

  -- snippets
  use "L3MON4D3/LuaSnip"             --snippet engine
  use "rafamadriz/friendly-snippets" -- a bunch of snippets to use

  -- LSP
  use "neovim/nvim-lspconfig"        -- enable LSP
  -- use "williamboman/nvim-lsp-installer" -- simple to use language server installer
  use "jose-elias-alvarez/null-ls.nvim" -- for formatters and linters
  use "RRethy/vim-illuminate"        -- highlighting other uses of the word under the cursor using either LSP, Tree-sitter, or regex matching.
  use "williamboman/mason.nvim"
  use "williamboman/mason-lspconfig.nvim"
  use "SmiteshP/nvim-navic"
  use "https://git.sr.ht/~whynothugo/lsp_lines.nvim"
  use "ray-x/lsp_signature.nvim"

  -- Fuzzy Finder/Telescope
  use "nvim-telescope/telescope.nvim"
  -- use 'nvim-telescope/telescope-media-files.nvim'

  -- Treesitter
  use {
    "nvim-treesitter/nvim-treesitter",
    run = ":TSUpdate",
  }
  -- use "windwp/nvim-ts-autotag"
  -- use "JoosepAlviste/nvim-ts-context-commentstring"

  -- Git
  use "lewis6991/gitsigns.nvim"
  -- use "tpope/vim-fugitive"

  -- Debugging
  use "mfussenegger/nvim-dap"
  use "rcarriga/nvim-dap-ui"

  -- Markdown
  -- use {
  --   "preservim/vim-markdown",
  --   config = function()
  --     vim.g.vim_markdown_folding_disabled = 1
  --   end
  -- }
  -- use {
  --   "gabrielelana/vim-markdown",
  --   config = function()
  --     vim.g.markdown_enable_mappings = 0
  --     vim.g.markdown_enable_insert_mode_mappings = 0
  --   end
  -- }

  -- Automatically set up your configuration after cloning packer.nvim
  -- Put this at the end after all plugins
  if PACKER_BOOTSTRAP then
    require("packer").sync()
  end
end)
