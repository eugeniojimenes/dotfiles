local wk = require("which-key")
local snacks = require("snacks")


wk.add({
  -- Top Pickers & Explorer
  { "<leader>/", function() snacks.picker.grep() end, desc = "Grep" },
  { "<leader>e", function() snacks.explorer() end, desc = "File Explorer" },
  { "<leader><space>", function() snacks.picker.smart() end, desc = "Smart Find Files" },
  { "<leader>,", function() snacks.picker.buffers() end, desc = "Buffer Picker" },

  -- buffers and windows
  { "<tab>", "<cmd>BufferLineCycleNext<cr>", desc = "Next Buffer" },
  { "<s-tab>", "<cmd>BufferLineCyclePrev<cr>", desc = "Prev Buffer" },
  { "[b", "<cmd>BufferLineCyclePrev<cr>", desc = "Prev Buffer" },
  { "]b", "<cmd>BufferLineCycleNext<cr>", desc = "Next Buffer" },
  { "[B", "<cmd>BufferLineMovePrev<cr>", desc = "Move buffer prev" },
  { "]B", "<cmd>BufferLineMoveNext<cr>", desc = "Move buffer next" },
  { "<C-s>", "<cmd>w<cr>", desc = "Save file on current buffer" },
  { "<C-q>", function() snacks.bufdelete() end, desc = "Delete current buffer" },
  { "<C-x>", "<cmd>bd<cr>", desc = "Delete Buffer and Window" },
  { "<C-k>", "<cmd>wincmd k<cr>", desc = "goto up window" },
  { "<C-j>", "<cmd>wincmd j<cr>", desc = "goto down window" },
  { "<C-h>", "<cmd>wincmd h<cr>", desc = "goto left window" },
  { "<C-l>", "<cmd>wincmd l<cr>", desc = "goto right window" },
  -- { "<leader>,", function() snacks.picker.buffers() end, desc = "Buffers" }, -- alredy mapped above
  { "<leader>b", group = "Buffers" },
  { "<leader>bd", function() snacks.bufdelete() end, desc = "Delete current buffer" },
  { "<leader>bo", function() snacks.bufdelete.other() end, desc = "Delete Other Buffers" },
  { "<leader>bD", "<cmd>bd<cr>", desc = "Delete Buffer and Window" },

  -- Resize window using <ctrl> arrow keys
  { "<C-Up>", "<cmd>resize +2<cr>", desc = "Increase Window Height" },
  { "<C-Down>", "<cmd>resize -2<cr>", desc = "Decrease Window Height" },
  { "<C-Left>", "<cmd>vertical resize -2<cr>", desc = "Decrease Window Width" },
  { "<C-Right>", "<cmd>vertical resize +2<cr>", desc = "Increase Window Width" },

  -- files
  { "<C-f>", function() snacks.picker.pick("files") end, desc = "Find Files" },
  { "<leader><leader>", function() snacks.picker.recent() end, desc = "Recent Files" },
  -- { "<leader><space>", function() snacks.picker.smart() end, desc = "Smart Find Files" }, -- alredy mapped above
  -- { "<leader>e", function() snacks.explorer() end, desc = "Explorer" }, -- alredy mapped above
  { "<leader>f", group = "Files" },
  { "<leader>ff", function() snacks.picker.files() end, desc = "Find Files" },
  { "<leader>fg", function() snacks.picker.git_files() end, desc = "Find Git Files" },
  { "<leader>fr", function() snacks.picker.recent() end, desc = "Recent Files" },
  { "<leader>fn", "<cmd>enew<cr>", desc = "New File" },

  -- git
  { "<leader>g",  group = "git" },
  { "<leader>gb", function() snacks.picker.git_branches() end, desc = "Git Branches" },
  { "<leader>gB", function() snacks.gitbrowse() end,           desc = "Git Browse", mode = { "n", "v" } },
  { "<leader>gg", function() snacks.lazygit() end,             desc = "Lazygit" },
  { "<leader>gG", function() snacks.lazygit.log_file() end,    desc = "Lazygit Log (cwd)" },
  { "<leader>gl", function() snacks.picker.git_log() end,      desc = "Git Log" },
  { "<leader>gL", function() snacks.picker.git_log_line() end, desc = "Git Log Line" },
  { "<leader>gs", function() snacks.picker.git_status() end,   desc = "Git Status" },
  { "<leader>gS", function() snacks.picker.git_stash() end,    desc = "Git Stash" },
  { "<leader>gd", function() snacks.picker.git_diff() end,     desc = "Git Diff (Hunks)" },
  { "<leader>gf", function() snacks.picker.git_log_file() end, desc = "Git Log File" },

  -- Notifications
  { "<leader>n",  group = "Notifier" },
  { "<leader>nh", function() snacks.notifier.show_history() end, desc = "Notification History" },
  { "<leader>nu", function() snacks.notifier.hide() end,         desc = "Dismiss All Notifications" },

  -- search
  { "<leader>s",   group = "Search" },
  { "<leader>s\"", function() snacks.picker.registers() end, desc = "Registers" },
  { '<leader>s/',  function() snacks.picker.search_history() end, desc = "Search History" },
  { "<leader>sa",  function() snacks.picker.autocmds() end, desc = "Autocmds" },
  { "<leader>sb",  function() snacks.picker.lines() end, desc = "Buffer Lines" },
  { "<leader>sc",  function() snacks.picker.command_history() end, desc = "Command History" },
  { "<leader>sC",  function() snacks.picker.commands() end, desc = "Commands" },
  { "<leader>sd",  function() snacks.picker.diagnostics() end, desc = "Diagnostics" },
  { "<leader>sD",  function() snacks.picker.diagnostics_buffer() end, desc = "Buffer Diagnostics" },
  { "<leader>sh",  function() snacks.picker.help() end, desc = "Help Pages" },
  { "<leader>sH",  function() snacks.picker.highlights() end, desc = "Highlights" },
  { "<leader>si",  function() snacks.picker.icons() end, desc = "Icons" },
  { "<leader>sj",  function() snacks.picker.jumps() end, desc = "Jumps" },
  { "<leader>sk",  function() snacks.picker.keymaps() end, desc = "Keymaps" },
  { "<leader>sl",  function() snacks.picker.loclist() end, desc = "Location List" },
  { "<leader>sm",  function() snacks.picker.marks() end, desc = "Marks" },
  { "<leader>sM",  function() snacks.picker.man() end, desc = "Man Pages" },
  { "<leader>sp",  function() snacks.picker.lazy() end, desc = "Search for Plugin Spec" },
  { "<leader>sq",  function() snacks.picker.qflist() end, desc = "Quickfix List" },
  { "<leader>sR",  function() snacks.picker.resume() end, desc = "Resume" },
  { "<leader>ss",  function() snacks.picker.colorschemes() end, desc = "Colorschemes" },
  { "<leader>su",  function() snacks.picker.undo() end, desc = "Undo History" },

  -- History
  { "<leader>:", function() snacks.picker.command_history() end, desc = "Command History" },
  -- { "<leader>n", function() snacks.picker.notifications() end, desc = "Notification History" },

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

