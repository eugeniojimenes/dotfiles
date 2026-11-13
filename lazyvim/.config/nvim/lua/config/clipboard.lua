-- Clipboard inside tmux or SSH: every yank also goes out as OSC 52, so tmux keeps it as a buffer and a remote client
-- receives it. Paste reads the Wayland clipboard when there is one (copies from other apps keep working), else asks
-- the terminal through OSC 52. Outside tmux and SSH, Neovim's own provider (wl-clipboard) is left alone.
if not (vim.env.TMUX or vim.env.SSH_TTY or vim.env.SSH_CONNECTION) then
  return
end

local osc52 = require("vim.ui.clipboard.osc52")
local wayland = vim.env.WAYLAND_DISPLAY and vim.fn.executable("wl-copy") == 1 and vim.fn.executable("wl-paste") == 1

local function wl(cmd, register)
  if register == "*" then
    table.insert(cmd, "--primary")
  end
  return cmd
end

local function copy(register)
  local emit = osc52.copy(register)
  return function(lines)
    if wayland then
      vim.fn.system(wl({ "wl-copy", "--sensitive", "--type", "text/plain" }, register), lines)
    end
    emit(lines)
  end
end

local function paste(register)
  if not wayland then
    return osc52.paste(register)
  end
  return function()
    local lines = vim.fn.systemlist(wl({ "wl-paste", "--no-newline" }, register), "", 1)
    return vim.v.shell_error == 0 and lines or {}
  end
end

vim.g.clipboard = {
  name = "tmux-ssh",
  copy = { ["+"] = copy("+"), ["*"] = copy("*") },
  paste = { ["+"] = paste("+"), ["*"] = paste("*") },
  cache_enabled = 0,
}
