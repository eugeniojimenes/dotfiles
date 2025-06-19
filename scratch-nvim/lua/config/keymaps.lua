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
  { "<leader>ff", function() Snacks.picker.files() end, desc = "Find Files" },
  { "<leader>fg", function() Snacks.picker.git_files() end, desc = "Find Git Files" },
  { "<leader>fr", function() Snacks.picker.recent() end, desc = "Recent Files" },
  { "<leader>fn", "<cmd>enew<cr>", desc = "New File" },

  -- git
  { "<leader>g",  group = "git" },
  { "<leader>gb", function() Snacks.picker.git_branches() end, desc = "Git Branches" },
  { "<leader>gg", function() Snacks.lazygit() end,             desc = "Lazygit" },
  { "<leader>gG", function() Snacks.lazygit.log_file() end,    desc = "Lazygit Log (cwd)" },
  { "<leader>gl", function() Snacks.picker.git_log() end,      desc = "Git Log" },
  { "<leader>gL", function() Snacks.picker.git_log_line() end, desc = "Git Log Line" },
  { "<leader>gs", function() Snacks.picker.git_status() end,   desc = "Git Status" },
  { "<leader>gS", function() Snacks.picker.git_stash() end,    desc = "Git Stash" },
  { "<leader>gd", function() Snacks.picker.git_diff() end,     desc = "Git Diff (Hunks)" },
  { "<leader>gf", function() Snacks.picker.git_log_file() end, desc = "Git Log File" },

  -- Notifications
  { "<leader>n",  group = "Notifier" },
  { "<leader>nh", function() Snacks.notifier.show_history() end, desc = "Notification History" },
  { "<leader>nu", function() Snacks.notifier.hide() end,         desc = "Dismiss All Notifications" },

  -- search
  { "<leader>s",   group = "Search" },
  { "<leader>s\"", function() Snacks.picker.registers() end, desc = "Registers" },
  { '<leader>s/',  function() Snacks.picker.search_history() end, desc = "Search History" },
  { "<leader>sa",  function() Snacks.picker.autocmds() end, desc = "Autocmds" },
  { "<leader>sb",  function() Snacks.picker.lines() end, desc = "Buffer Lines" },
  { "<leader>sc",  function() Snacks.picker.command_history() end, desc = "Command History" },
  { "<leader>sC",  function() Snacks.picker.commands() end, desc = "Commands" },
  { "<leader>sd",  function() Snacks.picker.diagnostics() end, desc = "Diagnostics" },
  { "<leader>sD",  function() Snacks.picker.diagnostics_buffer() end, desc = "Buffer Diagnostics" },
  { "<leader>sh",  function() Snacks.picker.help() end, desc = "Help Pages" },
  { "<leader>sH",  function() Snacks.picker.highlights() end, desc = "Highlights" },
  { "<leader>si",  function() Snacks.picker.icons() end, desc = "Icons" },
  { "<leader>sj",  function() Snacks.picker.jumps() end, desc = "Jumps" },
  { "<leader>sk",  function() Snacks.picker.keymaps() end, desc = "Keymaps" },
  { "<leader>sl",  function() Snacks.picker.loclist() end, desc = "Location List" },
  { "<leader>sm",  function() Snacks.picker.marks() end, desc = "Marks" },
  { "<leader>sM",  function() Snacks.picker.man() end, desc = "Man Pages" },
  { "<leader>sp",  function() Snacks.picker.lazy() end, desc = "Search for Plugin Spec" },
  { "<leader>sq",  function() Snacks.picker.qflist() end, desc = "Quickfix List" },
  { "<leader>sR",  function() Snacks.picker.resume() end, desc = "Resume" },
  { "<leader>ss",  function() Snacks.picker.colorschemes() end, desc = "Colorschemes" },
  { "<leader>su",  function() Snacks.picker.undo() end, desc = "Undo History" },

  -- History
  { "<leader>:", function() Snacks.picker.command_history() end, desc = "Command History" },
  -- { "<leader>n", function() Snacks.picker.notifications() end, desc = "Notification History" },

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

