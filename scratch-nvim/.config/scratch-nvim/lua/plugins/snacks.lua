return {
  {
    "folke/snacks.nvim",
    dependencies = {
      "nvim-mini/mini.icons",
    },
    priority = 1000,
    lazy = false,
    opts = {
      bigfile = { enabled = true },
      dashboard = {
        enabled = true,
        sections = {
          { section = "header" },
          { icon = " ", title = "Keymaps", section = "keys", indent = 2, padding = 1 },
          { icon = " ", title = "Recent Files", section = "recent_files", indent = 2, padding = 1 },
          { icon = " ", title = "Projects", section = "projects", indent = 2, padding = 1 },
          { section = "startup" },
        },
      },
      explorer = { enabled = true },
      indent = { enabled = true },
      input = { enabled = true },
      git = { enabled = true },
      picker = {
        hidden = true, -- to show hidden files
        ignored = true, -- to show .gitignore files
        enabled = true,
      },
      notifier = { enabled = true },
      quickfile = { enabled = true },
      statuscolumn = { enabled = true },
      words = { enabled = true },
      scroll = { enabled = true },
      -- Disabled plugins:
      scratch = { enabled = false },
    },
  },
}
