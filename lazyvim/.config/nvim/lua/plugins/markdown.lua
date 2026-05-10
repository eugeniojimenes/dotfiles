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
    "selimacerbas/markdown-preview.nvim",
    dependencies = { "selimacerbas/live-server.nvim" },
    ft = { "markdown" },
    keys = {
      { "<leader>cp", "<cmd>MarkdownPreviewToggle<cr>", ft = "markdown", desc = "Markdown Preview" },
    },
    config = function()
      local mp = require("markdown_preview")
      mp.setup({
        -- all optional; sane defaults shown
        instance_mode = "takeover", -- "takeover" (one tab) or "multi" (tab per instance)
        port = 0, -- 0 = auto (8421 for takeover, OS-assigned for multi)
        open_browser = true,
        debounce_ms = 300,
      })
      vim.api.nvim_create_user_command("MarkdownPreviewToggle", function()
        if mp._active_bufnr then
          mp.stop()
          mp._active_bufnr = nil
        else
          mp.start()
        end
      end, { desc = "Toggle markdown preview" })
    end,
  },
}
