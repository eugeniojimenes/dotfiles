local wk = require("which-key")

wk.add({
  -- Top Pickers & Explorer
  { "<leader>/", function() Snacks.picker.grep() end, desc = "Grep" },
  { "<leader>e", function() Snacks.explorer() end, desc = "File Explorer" },
  { "<leader><space>", function() Snacks.picker.smart() end, desc = "Smart Find Files" },
  { "<leader>,", function() Snacks.picker.buffers() end, desc = "Buffer Picker" },

  -- buffers and windows
  { "<tab>", "<cmd>BufferLineCycleNext<cr>", desc = "Next Buffer" },
  { "<s-tab>", "<cmd>BufferLineCyclePrev<cr>", desc = "Prev Buffer" },
  { "[b", "<cmd>BufferLineCyclePrev<cr>", desc = "Prev Buffer" },
  { "]b", "<cmd>BufferLineCycleNext<cr>", desc = "Next Buffer" },
  { "[B", "<cmd>BufferLineMovePrev<cr>", desc = "Move buffer prev" },
  { "]B", "<cmd>BufferLineMoveNext<cr>", desc = "Move buffer next" },
  { "<C-s>", "<cmd>w<cr>", desc = "Save file on current buffer" },
  { "<C-q>", function() Snacks.bufdelete() end, desc = "Delete current buffer" },
  { "<C-x>", "<cmd>bd<cr>", desc = "Delete Buffer and Window" },
  { "<C-k>", "<cmd>wincmd k<cr>", desc = "goto up window" },
  { "<C-j>", "<cmd>wincmd j<cr>", desc = "goto down window" },
  { "<C-h>", "<cmd>wincmd h<cr>", desc = "goto left window" },
  { "<C-l>", "<cmd>wincmd l<cr>", desc = "goto right window" },
  -- { "<leader>,", function() Snacks.picker.buffers() end, desc = "Buffers" }, -- alredy mapped above
  { "<leader>b", group = "Buffers" },
  { "<leader>bd", function() Snacks.bufdelete() end, desc = "Delete current buffer" },
  { "<leader>bo", function() Snacks.bufdelete.other() end, desc = "Delete Other Buffers" },
  { "<leader>bD", "<cmd>bd<cr>", desc = "Delete Buffer and Window" },

  -- Resize window using <ctrl> arrow keys
  { "<C-Up>", "<cmd>resize +2<cr>", desc = "Increase Window Height" },
  { "<C-Down>", "<cmd>resize -2<cr>", desc = "Decrease Window Height" },
  { "<C-Left>", "<cmd>vertical resize -2<cr>", desc = "Decrease Window Width" },
  { "<C-Right>", "<cmd>vertical resize +2<cr>", desc = "Increase Window Width" },

  -- files
  { "<C-f>", function() Snacks.picker.pick("files") end, desc = "Find Files" },
  { "<leader><leader>", function() Snacks.picker.recent() end, desc = "Recent Files" },
  -- { "<leader><space>", function() Snacks.picker.smart() end, desc = "Smart Find Files" }, -- alredy mapped above
  -- { "<leader>e", function() Snacks.explorer() end, desc = "Explorer" }, -- alredy mapped above
  { "<leader>f", group = "Files" },
  { "<leader>fr", function() Snacks.picker.recent() end, desc = "Recent Files" },
  { "<leader>fg", function() Snacks.picker.grep() end, desc = "Grep Files" },
  { "<leader>fn", "<cmd>enew<cr>", desc = "New File" },

  -- git
  { "<leader>g",  group = "git" },
  { "<leader>gb", function() Snacks.picker.git_branches() end, desc = "Git Branches" },
  { "<leader>gg", function() Snacks.lazygit() end,             desc = "Lazygit" },
  -- { "<leader>gl", function() Snacks.lazygit.log_file() end,    desc = "Lazygit Log (cwd)" },
  { "<leader>gl", function() Snacks.picker.git_log() end,      desc = "Git Log" },
  { "<leader>gL", function() Snacks.picker.git_log_line() end, desc = "Git Log Line" },
  { "<leader>gs", function() Snacks.picker.git_status() end,   desc = "Git Status" },
  { "<leader>gS", function() Snacks.picker.git_stash() end,    desc = "Git Stash" },
  { "<leader>gd", function() Snacks.picker.git_diff() end,     desc = "Git Diff (Hunks)" },
  { "<leader>gf", function() Snacks.picker.git_log_file() end, desc = "Git Log File" },

  -- History
  { "<leader>:", function() Snacks.picker.command_history() end, desc = "Command History" },
  { "<leader>n", function() Snacks.picker.notifications() end, desc = "Notification History" },

  -- tabs
  { "<leader><tab>", group = "Tabs" },
  { "<leader><tab>l", "<cmd>tablast<cr>", desc = "Last Tab" },
  { "<leader><tab>o", "<cmd>tabonly<cr>", desc = "Close Other Tabs" },
  { "<leader><tab>f", "<cmd>tabfirst<cr>", desc = "First Tab" },
  { "<leader><tab><tab>", "<cmd>tabnew<cr>", desc = "New Tab" },
  { "<leader><tab>]", "<cmd>tabnext<cr>", desc = "Next Tab" },
  { "<leader><tab>d", "<cmd>tabclose<cr>", desc = "Close Tab" },
  { "<leader><tab>[", "<cmd>tabprevious<cr>", desc = "Previous Tab" },

  -- better indenting
  { "<", "<gv", mode = "v" },
  { ">", ">gv", mode = "v" },

  -- commenting
  { "gco", "o<esc>Vcx<esc><cmd>normal gcc<cr>fxa<bs>", desc = "Add Comment Below" },
  { "gcO", "O<esc>Vcx<esc><cmd>normal gcc<cr>fxa<bs>", desc = "Add Comment Above" },

  -- Clear search and stop snippet on escape
  { "<esc>", "<cmd>nohlsearch<cr>", desc = "Escape and Clear hlsearch" },
})

