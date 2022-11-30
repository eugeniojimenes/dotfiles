local status_ok, toggleterm = pcall(require, "toggleterm")
if not status_ok then
  return
end

toggleterm.setup {
  -- size = 20,
  size = function(term)
    if term.direction == "horizontal" then
      return 15
    elseif term.direction == "vertical" then
      return vim.o.columns * 0.5
    end
  end,
  open_mapping = [[<c-t>]],
  hide_numbers = true,
  shade_filetypes = {},
  shade_terminals = true,
  shading_factor = 2,
  start_in_insert = true,
  insert_mappings = true,
  persist_size = true,
  direction = "float",
  close_on_exit = true,
  shell = vim.o.shell,
  float_opts = {
    border = "curved",
    winblend = 0,
    highlights = {
      border = "Normal",
      background = "Normal",
    },
  },
}

function _G.set_terminal_keymaps()
  local opts = {buffer = 0}
  vim.keymap.set('t', '<esc>', [[<C-\><C-n>]], opts)
  -- vim.keymap.set('t', 'jk', [[<C-\><C-n>]], opts)
  vim.keymap.set('t', '<C-h>', [[<Cmd>wincmd h<CR>]], opts)
  vim.keymap.set('t', '<C-j>', [[<Cmd>wincmd j<CR>]], opts)
  vim.keymap.set('t', '<C-k>', [[<Cmd>wincmd k<CR>]], opts)
  vim.keymap.set('t', '<C-l>', [[<Cmd>wincmd l<CR>]], opts)
end
vim.cmd('autocmd! TermOpen term://* lua set_terminal_keymaps()')

local Terminal = require("toggleterm.terminal").Terminal

local lazygit = Terminal:new {
  cmd = "lazygit",
  hidden = true,
  direction = "float",
  float_opts = {
    border = "none",
    width = 100000,
    height = 100000,
  },
  on_open = function(_)
    vim.cmd "startinsert!"
    -- vim.cmd "set laststatus=0"
  end,
  on_close = function(_)
    -- vim.cmd "set laststatus=3"
  end,
  count = 99,
}
function _LAZYGIT_TOGGLE()
  lazygit:toggle()
end

local node = Terminal:new { cmd = "node", hidden = true }
function _NODE_TOGGLE()
  node:toggle()
end

local htop = Terminal:new { cmd = "htop" }
function _HTOP_TOGGLE()
  htop:toggle()
end

local python = Terminal:new { cmd = "python", hidden = true }
function _PYTHON_TOGGLE()
  python:toggle()
end

local rails = Terminal:new { cmd = "rails c" }
function _RAILS_TOGGLE()
  rails:toggle()
end

local float_term = Terminal:new {
  direction = "float",
  count = 1,
}
function _FLOAT_TERM()
  float_term:toggle()
end

local vertical_term = Terminal:new {
  direction = "vertical",
  count = 2,
}
function _VERTICAL_TERM()
  vertical_term:toggle()
end

local horizontal_term = Terminal:new {
  direction = "horizontal",
  count = 3,
}
function _HORIZONTAL_TERM()
  horizontal_term:toggle()
end
