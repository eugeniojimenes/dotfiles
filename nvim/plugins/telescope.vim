" Plug 'nvim-lua/popup.nvim'
" Plug 'nvim-lua/plenary.nvim'
" Plug 'nvim-telescope/telescope.nvim'

" --> command: CTRL+p => Shortcut for :Telescope find_files (search for file's name)
nnoremap <c-p> :Telescope find_files<CR>
" --> command: CTRL+f => Shortcut for :Telescope live_grep (search inside files)
" It requires ripgrep: sudo pacman -S ripgrep
nnoremap <c-f> :Telescope live_grep<CR>
