-- Autocmds after LazyVim's own. See `lua/config/lazy.lua`.

-- Claude Code ctrl+g opens $EDITOR on /tmp/claude-<uid>/claude-prompt-<uuid>.md, cwd = project. persistence.nvim keys
-- session on cwd + branch, not files, and autosaves on VimLeavePre, so that throwaway nvim clobbers project session
-- with one holding only prompt file. `need = 1` filters nothing: temp file = real file buffer. shada write off for the
-- same reason, nothing there worth merging into main.shada. Read already happened at startup, history stays usable.
vim.api.nvim_create_autocmd("VimEnter", {
  once = true,
  callback = function()
    if vim.fn.expand("%:p"):match("/claude%-prompt%-") then
      require("persistence").stop()
      vim.o.shadafile = "NONE"
    end
  end,
})
