-- Source: https://github.com/iamcco/markdown-preview.nvim
-- "Preview markdown on your modern browser with synchronised scrolling and flexible configuration" 
local status_ok, markdown_preview = pcall(require, "markdown-preview")
if not status_ok then
	return
end
markdown_preview.setup({})
vim.cmd[[
let g:mkdp_preview_options = {
  \ 'mkit': {},
  \ 'katex': {},
  \ 'uml': {},
  \ 'maid': {},
  \ 'disable_sync_scroll': 0,
  \ 'sync_scroll_type': 'middle',
  \ 'hide_yaml_meta': 0,
  \ 'sequence_diagrams': {},
  \ 'flowchart_diagrams': {},
  \ 'content_editable': v:false,
  \ 'disable_filename': 0,
  \ 'toc': {}
  \ }
]]
