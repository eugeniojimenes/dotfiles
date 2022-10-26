" Plug 'preservim/nerdcommenter'
" Plug 'preservim/nerdtree'
" Plug 'Xuyuanp/nerdtree-git-plugin'

"" NERDTree:
autocmd StdinReadPre * let s:std_in=1
" --> Start NERDTree when Vim is started without file arguments
autocmd VimEnter * if argc() == 0 && !exists("s:std_in") | NERDTree | endif
" --> Start NERDTree when Vim starts with a directory argument
autocmd VimEnter * if argc() == 1 && isdirectory(argv()[0]) && !exists('s:std_in') |
      \ execute 'NERDTree' argv()[0] | wincmd p | enew | execute 'cd '.argv()[0] | endif
" --> Displays hidden files ('.env', '.git/', '.gitignore' etc)
let NERDTreeShowHidden=1
" --> disable NERDTree help text
let NERDTreeMinimalUI=1
" --> command: <space>+N => Open/close NERDTree
nnoremap <leader>N :NERDTreeToggle<CR>
" --> command: <space>+n => Go to NERDTree buffer
nnoremap <leader>n :NERDTreeFocus<CR>
"" Nerdcommenter:
" Align comments in selection
let g:NERDDefaultAlign = 'left'
let g:NERDSpaceDelims = 1
