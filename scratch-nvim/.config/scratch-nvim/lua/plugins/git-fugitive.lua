return {
  {
    "folke/which-key.nvim",
    opts = {
      spec = {
        { "<leader>G",  desc = "Git Fugitive" },
        { "<leader>Ga", "<cmd>Git add -A<cr>",               desc = "git add -A" },
        { "<leader>Gc", "<cmd>tab Git commit --verbose<cr>", desc = "Commit with editor" },
        { "<leader>Gh", "<cmd>Git push<cr>",                 desc = "git push" },
        { "<leader>Gl", "<cmd>Git pull<cr>",                 desc = "git pull" },
        { "<leader>Gg", "<cmd>tab Git<cr>",                  desc = "uncommitted files details" },
        { "<leader>GL", "<cmd>tabnew<cr><cmd>Gclog<cr>",     desc = "detailed commit history" },
        { "<leader>Gb", "<cmd>tab Git blame<cr>",            desc = "Blame triage" },
      },
    },
  },
  { "tpope/vim-fugitive" },
}
