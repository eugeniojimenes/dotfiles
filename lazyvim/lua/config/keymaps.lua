-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local map = vim.keymap.set

map("n", "<TAB>", "<cmd>BufferLineCycleNext<cr>", { desc = "Next Buffer" })   -- goes to the next buffer
map("n", "<S-TAB>", "<cmd>BufferLineCyclePrev<cr>", { desc = "Prev Buffer" }) -- goes to the next buffer
