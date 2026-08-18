-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local map = vim.keymap.set

map("n", "<TAB>",   "<cmd>BufferLineCycleNext<cr>",    { desc = "Next Buffer" }) -- goes to the next buffer
map("n", "<S-TAB>", "<cmd>BufferLineCyclePrev<cr>",    { desc = "Prev Buffer" }) -- goes to the prev buffer
map("n", "<C-q>",   function() Snacks.bufdelete() end, { desc = "Delete current buffer" })
map("n", "<leader>bD", "<CMD>bd<CR>",                  { desc = "Delete Buffer and Window" })
map("n", "<C-x>",      "<CMD>bd<CR>",                  { desc = "Delete Buffer and Window" })


map("n", "<C-f>", function() Snacks.picker.pick("files") end, { desc = "Find Files" })

-- `gr` (LSP references) re-globs and re-parses every .rb in the workspace on each call —
-- 8824 files and ~25s in a work repo — because ruby-lsp deliberately does not keep references in
-- its index. For *methods* it then matches on the bare name (ReferenceFinder::MethodTarget), with
-- no receiver typing, so ripgrep is about as accurate and finishes in a tenth of a second. `gr`
-- stays on the LSP, which is genuinely semantic for constants; this is the fast sibling.
-- Shadows built-in `gR` (virtual replace mode).
map({ "n", "x" }, "gR", function() Snacks.picker.grep_word() end, { desc = "References (ripgrep)" })
