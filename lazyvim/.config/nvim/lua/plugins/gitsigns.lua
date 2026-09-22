-- Diff every buffer against the branch point instead of the git index, so opening any file shows the whole
-- branch delta the way a web PR/MR does: gutter signs on changed lines, line highlight, intra-line word diff.
-- Navigation stays normal, no review tab, no forge API, so it works the same on GitHub and GitLab.
--
-- Base = `git merge-base <default branch> HEAD`, not the branch tip. Three-dot semantics, same as the forge:
-- against the tip, commits landed on the default branch after you branched would show up as your changes.
-- `origin/HEAD` is the real answer where the clone has it; the fallback list covers clones that never set it
-- (`git clone --single-branch`, or an origin added by hand).
local function pr_base()
  local cwd = LazyVim.root.git()

  local function git(args)
    local out = vim.system(vim.list_extend({ "git", "-C", cwd }, args), { text = true }):wait()
    return out.code == 0 and vim.trim(out.stdout) or nil
  end

  local candidates = { git({ "symbolic-ref", "--short", "refs/remotes/origin/HEAD" }) }
  vim.list_extend(candidates, { "origin/develop", "origin/main", "origin/master" })

  for _, ref in ipairs(candidates) do
    if git({ "rev-parse", "--verify", "--quiet", ref }) then
      return git({ "merge-base", ref, "HEAD" })
    end
  end
end

return {
  {
    "lewis6991/gitsigns.nvim",
    opts = function()
      local base ---@type string? nil = gitsigns default (index), set = review mode on

      Snacks.toggle({
        name = "PR/MR Diff Base",
        get = function()
          return base ~= nil
        end,
        set = function(state)
          local gs = require("gitsigns")
          base = state and pr_base() or nil
          if state and not base then
            return Snacks.notify.warn("No base branch found (looked for origin/HEAD, develop, main, master)")
          end
          -- Toggles go in the callback, and no `gs.refresh()` here. `change_base` is async: it swaps the revision
          -- and re-diffs every attached buffer itself. A `refresh()` fired next to it races that, re-diffing buffers
          -- against the old revision, and `manager.update` is throttled per buffer, so the real update gets dropped
          -- and every buffer except the current one keeps showing the index diff.
          gs.change_base(base, true, function()
            gs.toggle_linehl(base ~= nil)
            gs.toggle_word_diff(base ~= nil)
          end)
        end,
      }):map("<leader>gv")

      -- Files changed list. `setqflist` diffs against whatever base is active, so with the toggle on it walks the
      -- whole repo and lists every hunk in the branch, files never opened included. Trouble groups them by file,
      -- which is as close to the web "Files changed" tab as this gets without a review-panel plugin.
      vim.keymap.set("n", "<leader>gV", function()
        require("gitsigns").setqflist("all", { open = false }, function()
          vim.schedule(function()
            vim.cmd("Trouble qflist open")
          end)
        end)
      end, { desc = "PR/MR Changed Files" })

      -- Companion to LazyVim's `<leader>ghp`, which is `preview_hunk_inline`. Inline preview draws removed lines
      -- as extmark `virt_lines`, and Neovim offers `virt_lines_overflow = 'scroll'|'trunc'` only, never wrap, so a
      -- long removed line runs off the right edge. The float clamps its width to the screen, wraps, and gitsigns
      -- grows its height to fit.
      vim.keymap.set("n", "<leader>ghP", function()
        require("gitsigns").preview_hunk()
      end, { desc = "Preview Hunk (float)" })
    end,
  },
}
