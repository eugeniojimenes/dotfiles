-- Read the docs: https://www.lunarvim.org/docs/configuration
-- Video Tutorials: https://www.youtube.com/watch?v=sFA9kX-Ud_c&list=PLhoH5vyxr6QqGu0i7tt_XoVK9v-KvZ3m6
-- Forum: https://www.reddit.com/r/lunarvim/
-- Discord: https://discord.com/invite/Xb9B4Ny

-- Options
vim.opt.wrap = true
vim.opt.clipboard = "unnamedplus"
vim.opt.colorcolumn = "120"
vim.g.clipboard = {
  name = 'WslClipboard',
  copy = {
    ["+"] = "clip.exe",
    ["*"] = "clip.exe",
  },
  paste = {
    ["+"] = 'powershell.exe -c [Console]::Out.Write($(Get-Clipboard -Raw).tostring().replace("`r", ""))',
    ["*"] = 'powershell.exe -c [Console]::Out.Write($(Get-Clipboard -Raw).tostring().replace("`r", ""))',
  },
  cache_enabled = 0,
}
-- vim.opt.listchars = { eol = "󱞥", trail = "󱁐", tab = ">-", nbsp = "~" }
vim.opt.list = true
vim.opt.listchars = { eol = "󱞥", trail = "", tab = ">-", nbsp = "~" }
vim.opt.relativenumber = true
vim.opt.mouse = ""

-- Plugins
lvim.plugins = {
  { "lunarvim/darkplus.nvim" },
  { "tpope/vim-fugitive" },
  {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    ft = { "markdown" },
    build = function() vim.fn["mkdp#util#install"]() end,
  },
  {
    "zk-org/zk-nvim",
    config = function()
      require("zk").setup({
        picker = "telescope",
        lsp = {
          config = {
            cmd = { "zk", "lsp" },
            name = "zk",
          },

          auto_attach = {
            enabled = true,
            filetypes = { "markdown" },
          },
        },
      })
    end
  },
  {
    "benfowler/telescope-luasnip.nvim",
    config = function()
      require("telescope").load_extension("luasnip")
    end,
  },
}

-- Colorscheme
lvim.colorscheme = "darkplus"

-- Telescope adjustments
lvim.builtin.telescope.defaults.layout_config.width = 0.95

-- Functions
-- -- NOTE: I only use tab-pages for fugitive plugin
vim.cmd[[
function! CleanNoNameEmptyBuffers()
  let buffers = filter(range(1, bufnr('$')), 'buflisted(v:val) && empty(bufname(v:val)) && bufwinnr(v:val) < 0 && (getbufline(v:val, 1, "$") == [""])')
  if !empty(buffers)
    exe 'bd '.join(buffers, ' ')
  else
    echo 'No buffer deleted'
  endif
endfunction
]]

-- Keymaps
lvim.keys.normal_mode["<TAB>"] = ":BufferLineCycleNext<CR>" -- goes to the next buffer
lvim.keys.normal_mode["<S-TAB>"] = ":BufferLineCyclePrev<CR>" -- goes to the previous buffer
lvim.keys.normal_mode["<C-L>"] = ":nohlsearch<CR><C-L>" -- Clear highlighted search.

lvim.builtin.which_key.mappings["ss"] = { ":Telescope luasnip<CR>", "Snippets available" } -- Search available snippets for current file

lvim.builtin.which_key.mappings["G"] = {
  name = "Git Fugitive",
  a = { "<cmd>Git add -A<cr>", "git add -A" },
  c = { "<cmd>tab Git commit --verbose<cr>", "Commit with editor" },
  h = { "<cmd>Git push<cr>", "git push" },
  l = { "<cmd>Git pull<cr>", "git pull" },
  -- Open a temporary buffer with uncommitted files that each can be expand with '=' to show details (toggling).
  s = { "<cmd>tab Git<cr>", "uncommitted files details" },
  L = { "<cmd>tabnew<cr><cmd>Gclog<cr>", "detailed commit history" },
  -- Open a temporary buffer with maps for additional triage. Press enter
  -- on a line to view the commit where the line changed, or 'g?' to see other available maps. Omit
  -- the filename argument will be blame the currently edited file in a vertical split.
  b = { "<cmd>tab Git blame<cr>", "Blame triage" },
}

-- Closes current tab-page (and delete eventual unnamed empty buffers)
-- NOTE: This command is more like a 'exit' to the fugitive features.
lvim.builtin.which_key.mappings["T"] = {
  "<cmd>tabclose<cr><cmd>call CleanNoNameEmptyBuffers()<cr>", "Close Tab buffers"
}

-- Window splits
lvim.builtin.which_key.mappings["v"] = { "<cmd>vsplit<cr>", "vsplit" }
lvim.builtin.which_key.mappings["h"] = { "<cmd>split<cr>", "split" }
lvim.builtin.which_key.mappings["P"] = { "<cmd>MarkdownPreviewToggle<CR>", "Markdown Toggle preview" }

-- set .erb files as html syntax and json.jbuilder files as ruby syntax
lvim.autocommands = {
  {
    "BufEnter",
    {
      pattern = { "*.erb", "*.eruby" },
      command = "set syntax=html",
    }
  },
  {
    "BufEnter",
    {
      pattern = { "*.json.jbuilder", "*.jbuilder", "*.rake" },
      command = "set ft=ruby",
    }
  },
  {
    "FileType",
    {
      pattern = { "*ruby" },
      command = "setlocal indentkeys-=.",
    }
  }
}
