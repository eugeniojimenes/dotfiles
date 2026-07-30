-- Load the current Omarchy theme's Neovim spec (colorscheme plugin + LazyVim opts).
--
-- Omarchy's own `omarchy-nvim-setup` symlinks this file at the active theme, but the
-- target moved between releases (3.x: ~/.config, 4.x: ~/.local/state), so a symlink
-- breaks on whichever machine is on the other version. Resolving at runtime works on
-- both, and `dofile` re-reads on every theme-hotreload cycle.
local candidates = {
  vim.env.HOME .. "/.local/state/omarchy/current/theme/neovim.lua", -- Omarchy 4.x
  vim.env.HOME .. "/.config/omarchy/current/theme/neovim.lua", -- Omarchy 3.x
}

for _, path in ipairs(candidates) do
  if (vim.uv or vim.loop).fs_stat(path) then
    return dofile(path)
  end
end

-- No Omarchy present (or no theme set yet): fall back to LazyVim's default.
return {}
