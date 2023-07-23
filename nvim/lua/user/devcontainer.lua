-- Source:https://github.com/esensar/nvim-dev-container 
-- "provide functionality similar to VSCode's remote container development plugin and other functionality that enables development in docker container." 
local status_ok, devcontainer = pcall(require, "devcontainer")
if not status_ok then
	return
end
devcontainer.setup({
  generate_commands = true,
})
