" Plug 'tpope/vim-fugitive'

" --> command: <space>+ga => Same as 'git add -A'.
nnoremap <leader>ga :tab Git add -A<CR>
" --> command: <space>+gc => Open a COMMIT_EDITMSG same as 'git commit --verbose' with editor
nnoremap <leader>gc :tab Git commit --verbose<CR>
" --> command: <space>+gsh => Same as 'git push'.
nnoremap <leader>gsh :tab Git push<CR>
" --> command: <space>+gll => Same as 'git pull'.
nnoremap <leader>gll :tab Git pull<CR>
" --> command: <space>+gg => Open a temporary buffer with uncommitted files that each can be expand
"  with '=' to show details (toggling).
nnoremap <leader>gg :tab Git<CR>
" --> command: <space>+gL => Open two temporary buffers with detailed commit history.
nnoremap <leader>gL :tabnew<CR>:Gclog<CR>
" --> command: <space>+gb => Open a temporary buffer with maps for additional triage. Press enter
"  on a line to view the commit where the line changed, or 'g?' to see other available maps. Omit
"  the filename argument will be blame the currently edited file in a vertical split.
nnoremap <leader>gb :tab Git blame<CR>
" --> command: <space>+gD => Open a staged version of the file side by side with the working tree
"  version. Use Vim's diff handling capabilities to apply changes to the staged version, and write
"  that buffer to stage the changes. You can also give an arbitrary ':Gedit' argument to diff
"  against older versions of the file.
nnoremap <leader>gD :tab Gvdiffsplit<CR>
