---- NOTE: Why did I not enable lang.markdown extra from lazyvim?
---        Because I just want the render-markdown.nvim plugin of it.
return {
  {
    "MeanderingProgrammer/render-markdown.nvim",
    opts = {
      code = {
        sign = false,
        width = "block",
        right_pad = 1,
      },
      -- heading = {
      --   sign = false,
      --   icons = {},
      -- },
      checkbox = {
        enabled = false,
      },
    },
    ft = { "markdown", "norg", "rmd", "org", "codecompanion" },
    config = function(_, opts)
      require("render-markdown").setup(opts)
      Snacks.toggle({
        name = "Render Markdown",
        get = require("render-markdown").get,
        set = require("render-markdown").set,
      }):map("<leader>um")
    end,
  },
  {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    build = function()
      require("lazy").load({ plugins = { "markdown-preview.nvim" } })
      vim.fn["mkdp#util#install"]()
    end,
    keys = {
      {
        "<leader>cp",
        ft = "markdown",
        "<cmd>MarkdownPreviewToggle<cr>",
        desc = "Markdown Preview",
      },
    },
    config = function()
      vim.g.mkdp_auto_close = 0
      vim.g.mkdp_combine_preview = 0
      vim.g.mkdp_theme = "dark"
      vim.g.mkdp_markdown_css = vim.fn.expand("~/.config/nvim/css/markdown.css")
      vim.g.mkdp_highlight_css = vim.fn.expand("~/.config/nvim/css/highlight.css")
      vim.g.mkdp_page_title = "「${name}」"
      vim.g.mkdp_preview_options = {
        mkit = {},
        katex = {},
        uml = {},
        maid = {},
        disable_sync_scroll = 0,
        sync_scroll_type = "middle",
        hide_yaml_meta = 1,
        sequence_diagrams = {},
        flowchart_diagrams = {},
        content_editable = false,
        disable_filename = 0,
        toc = {},
      }
      vim.cmd([[do FileType]])
    end,
  },
  -- {
  --   "selimacerbas/markdown-preview.nvim",
  --   dependencies = { "selimacerbas/live-server.nvim" },
  --   ft = { "markdown" },
  --   keys = {
  --     { "<leader>cp", "<cmd>MarkdownPreviewToggle<cr>", ft = "markdown", desc = "Markdown Preview" },
  --   },
  --   config = function()
  --     local mp = require("markdown_preview")
  --     mp.setup({
  --       -- all optional; sane defaults shown
  --       instance_mode = "multi", -- "takeover" (one tab) or "multi" (tab per instance)
  --       port = 0, -- 0 = auto (8421 for takeover, OS-assigned for multi)
  --       open_browser = true,
  --       debounce_ms = 300,
  --     })
  --     vim.api.nvim_create_user_command("MarkdownPreviewToggle", function()
  --       if mp._active_bufnr then
  --         mp.stop()
  --         mp._active_bufnr = nil
  --       else
  --         mp.start()
  --       end
  --     end, { desc = "Toggle markdown preview" })
  --   end,
  -- },
}
