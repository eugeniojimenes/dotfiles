return {
  {
    "coder/claudecode.nvim",
    opts = {
      terminal = {
        -- Claude runs in its own tmux window, not a Neovim split.
        provider = "external",
        provider_opts = {
          external_terminal_cmd = function(cmd, env)
            -- `-e` is required: `tmux new-window` inherits the tmux *server*
            -- environment, not Neovim's, so jobstart(env=...) alone would drop
            -- the port and Claude would not find this instance's lock file.
            -- `-S -n claude` selects the existing window instead of stacking
            -- duplicates on every toggle.
            return {
              "tmux",
              "new-window",
              "-S",
              "-n",
              "claude",
              "-c",
              vim.fn.getcwd(),
              "-e",
              "CLAUDE_CODE_SSE_PORT=" .. env.CLAUDE_CODE_SSE_PORT,
              cmd,
            }
          end,
        },
      },
    },
  },
}
