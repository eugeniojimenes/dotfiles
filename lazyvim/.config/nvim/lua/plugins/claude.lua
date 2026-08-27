return {
  {
    "coder/claudecode.nvim",
    opts = {
      terminal = {
        -- Claude runs in its own tmux window, not a Neovim split.
        provider = "external",
        provider_opts = {
          external_terminal_cmd = function(cmd, env)
            -- `-e` is required: `tmux new-window` inherits the tmux *server* environment, not Neovim's, so
            -- jobstart(env=...) alone would drop the port and Claude would not find this instance's lock file.
            -- `-S` selects an existing window of that name instead of stacking duplicates on every toggle, and the
            -- lookup is per session, not per server. Literal `claude` therefore made every nvim in one tmux session
            -- share one window: second `<leader>ac` focused the first project's Claude, wrong cwd and wrong port.
            -- Name per cwd basename, matching `automatic-rename-format '#{b:pane_current_path}'` in tmux.conf. Ceiling:
            -- two nvim on the same directory in one session still collide, which is the sharing you want anyway.
            local window = "claude-" .. vim.fn.fnamemodify(vim.fn.getcwd(), ":t")
            return {
              "tmux",
              "new-window",
              "-S",
              "-n",
              window,
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
