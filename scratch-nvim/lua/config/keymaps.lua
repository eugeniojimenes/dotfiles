-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local map = vim.keymap.set

-- buffers and windows
map("n", "<TAB>",      "<CMD>BufferLineCycleNext<CR>",          { desc = "Next Buffer" })      -- goes to the next buffer
map("n", "<S-TAB>",    "<CMD>BufferLineCyclePrev<CR>",          { desc = "Prev Buffer" })    -- goes to the next buffer
map("n", "[b",         "<CMD>BufferLineCyclePrev<CR>",          { desc = "Prev Buffer" })
map("n", "]b",         "<CMD>BufferLineCycleNext<CR>",          { desc = "Next Buffer" })
map("n", "[B",         "<CMD>BufferLineMovePrev<CR>",           { desc = "Move buffer prev" })
map("n", "]B",         "<CMD>BufferLineMoveNext<CR>",           { desc = "Move buffer next" })
map("n", "<C-s>",      "<CMD>w<CR>",                            { desc = "Save file on current buffer" })
map("n", "<C-q>",      function() Snacks.bufdelete() end,       { desc = "Delete current buffer" })
map("n", "<leader>bd", function() Snacks.bufdelete() end,       { desc = "Delete current buffer" })
map("n", "<leader>bo", function() Snacks.bufdelete.other() end, { desc = "Delete Other Buffers" })
map("n", "<leader>bD", "<CMD>bd<CR>",                           { desc = "Delete Buffer and Window" })
map("n", "<C-x>",      "<CMD>bd<CR>",                           { desc = "Delete Buffer and Window" })
map("n", "<C-k>",      "<CMD>wincmd k<CR>",                     { desc = "goto up window"})
map("n", "<C-j>",      "<CMD>wincmd j<CR>",                     { desc = "goto down window"})
map("n", "<C-h>",      "<CMD>wincmd h<CR>",                     { desc = "goto left window"})
map("n", "<C-l>",      "<CMD>wincmd l<CR>",                     { desc = "goto right window"})

-- Resize window using <ctrl> arrow keys
map("n", "<C-Up>",     "<CMD>resize +2<CR>",                    { desc = "Increase Window Height" })
map("n", "<C-Down>",   "<CMD>resize -2<CR>",                    { desc = "Decrease Window Height" })
map("n", "<C-Left>",   "<CMD>vertical resize -2<CR>",           { desc = "Decrease Window Width" })
map("n", "<C-Right>",  "<CMD>vertical resize +2<CR>",           { desc = "Increase Window Width" })

-- files
map("n", "<C-f>",            function() Snacks.picker.pick("files") end, { desc = "Find Files" })
map("n", "<leader><leader>", function() Snacks.picker.recent() end,      { desc = "Recent Files" })
map("n", "<leader>fb",       function() Snacks.picker.buffers() end,     { desc = "Buffers" })
map("n", "<leader>fg",       function() Snacks.picker.grep() end,        { desc = "Grep Files" })
map("n", "<leader>e",        function() Snacks.explorer() end,           { desc = "Explorer" })

-- better indenting
map("v", "<", "<gv")
map("v", ">", ">gv")

-- new file
map("n", "<leader>fn", "<CMD>enew<CR>", { desc = "New File" })

-- Clear search and stop snippet on escape
map("n", "<esc>", "<CMD>nohlsearch<CR>", { desc = "Escape and Clear hlsearch" })

