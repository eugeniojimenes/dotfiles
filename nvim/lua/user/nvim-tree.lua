-- following options are the default
-- each of these are documented in `:help nvim-tree.OPTION_NAME`

-- -- changed but this way isn't working. Source:
-- -- https://github.com/kyazdani42/nvim-tree.lua/issues/674
-- vim.renderer.icons.glyphs = {
--   default = "",
--   symlink = "",
--   git = {
--    unstaged = "✗",
--    staged = "✓",
--    unmerged = "",
--    renamed = "➜",
--    untracked = "★",
--    deleted = "",
--    ignored = "◌"
--   },
--   folder = {
--     default = "",
--     open = "",
--     empty = "",
--     empty_open = "",
--     symlink = "",
--   },
-- }

local status_ok, nvim_tree = pcall(require, "nvim-tree")
if not status_ok then
  return
end

local config_status_ok, nvim_tree_config = pcall(require, "nvim-tree.config")
if not config_status_ok then
  return
end

local tree_cb = nvim_tree_config.nvim_tree_callback

nvim_tree.setup {
  disable_netrw = true,
  hijack_netrw = true,
  open_on_setup = false,
  ignore_ft_on_setup = {
    "startify",
    "dashboard",
    "alpha",
  },
  auto_reload_on_write = true,
  open_on_tab = false,
  hijack_cursor = false,
  update_cwd = true,
  diagnostics = {
    enable = true,
    icons = {
      hint = "",
      info = "",
      warning = "",
      error = "",
    },
  },
  update_focused_file = {
    enable = false,
    update_cwd = false,
    ignore_list = {},
  },
  git = {
    enable = true,
    ignore = false,
    timeout = 500,
  },
  view = {
    width = 30,
    height = 30,
    hide_root_folder = false,
    side = "left",
    preserve_window_proportions = false,
    mappings = {
      custom_only = false,
      list = {
        { key = { "l", "<CR>" }, cb = tree_cb "edit" },
        { key = {"h", "x"}, cb = tree_cb "close_node" },
        { key = "v", cb = tree_cb "vsplit" },
      },
    },
    number = false,
    relativenumber = false,
  },
  actions = {
    open_file = {
      window_picker = {
        enable = false,
      }
    }
  }
}
