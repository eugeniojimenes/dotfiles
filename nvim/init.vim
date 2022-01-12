"" Some Default Config:
set encoding=UTF-8
highlight ColorColumn ctermbg=gray
set colorcolumn=100
set nu relativenumber
set clipboard=unnamedplus
set title
set hidden
set noerrorbells
set shiftwidth=2
set softtabstop=2
set tabstop=2
set expandtab
set mouse=a
set scrolloff=8
set sidescrolloff=8
set splitright
set wildmenu
set wildmode=longest:full,full
set nowrap
set list
set listchars=tab:▸\ ,trail:·
set backup
set backupdir=~/.local/share/nvim/backupdir
set undodir=~/.config/nvim/undodir
set undofile
let mapleader=" "

"" Nvim Config Shortcut:
nmap <leader>ve :edit ~/.config/nvim/init.vim<cr>
nmap <leader>vc :edit ~/.config/nvim/coc-settings.json<cr>
nmap <leader>vr :source ~/.config/nvim/init.vim<cr>

nmap <leader>k :nohlsearch<CR>
nmap <leader>Q :bufdo bdelete<cr>

" Paste replace visual selection without copying it
vnoremap <leader>p "_dP

" Allow gf to open non-existent files
map gf :edit <cfile><cr>

"" Shift selection to right (Visual + >) or left (Visual + <) without exiting visual mode.
vnoremap < <gv
vnoremap > >gv

" Clear highlighted search.
nnoremap <C-L> :nohls<CR><C-L>

" Spell Check for specific files
autocmd FileType md,markdown,rst,text,yaml, setlocal spell spelllang=pt,en

"" Custom Functions:
" Looks for empty for empty and unnamed buffers then close its if find some.
function! CleanNoNameEmptyBuffers()
  let buffers = filter(range(1, bufnr('$')), 'buflisted(v:val) && empty(bufname(v:val)) && bufwinnr(v:val) < 0 && (getbufline(v:val, 1, "$") == [""])')
  if !empty(buffers)
    exe 'bd '.join(buffers, ' ')
  else
    echo 'No buffer deleted'
  endif
endfunction

" Classic function to clean unnecessary white spaces.
function! TrimWhitespace()
  let l:save = winsaveview()
  keeppatterns %s/\s\+$//e
  call winrestview(l:save)
endfun
" call this function when you save a file.
autocmd BufWritePre * :call TrimWhitespace()
call plug#begin('~/.vim/plugged')

" Plug 'elixir-editors/vim-elixir'
Plug 'gabrielelana/vim-markdown'
Plug 'leafgarland/typescript-vim'

" Plug 'pangloss/vim-javascript'
" Plug 'junegunn/fzf.vim'
" Plug 'gabesoft/vim-ags'

" Plug 'alvan/vim-closetag'
"" Closetag:
" let g:closetag_filenames = '*.html,*.xhtml,*.phtml,*.erb'

Plug 'elzr/vim-json'                  " source ~/.config/nvim/plugins/json.vim

Plug 'iamcco/markdown-preview.nvim', {'for': 'markdown', 'do': 'yarn install'} " source ~/.config/nvim/plugins/markdown.vim

Plug 'vim-airline/vim-airline'        " source ~/.config/nvim/plugins/airline.vim
Plug 'dense-analysis/ale'             " source ~/.config/nvim/plugins/airline.vim
Plug 'morhetz/gruvbox'                " source ~/.config/nvim/plugins/airline.vim
Plug 'ryanoasis/vim-devicons'         " source ~/.config/nvim/plugins/airline.vim

Plug 'neoclide/coc.nvim', { 'branch': 'release' } " source ~/.config/nvim/plugins/coc.vim

Plug 'preservim/nerdcommenter'        " source ~/.config/nvim/plugins/nerdtree.vim
Plug 'preservim/nerdtree'             " source ~/.config/nvim/plugins/nerdtree.vim
Plug 'Xuyuanp/nerdtree-git-plugin'    " source ~/.config/nvim/plugins/nerdtree.vim

Plug 'nvim-lua/popup.nvim'            " source ~/.config/nvim/plugins/telescope.vim
Plug 'nvim-lua/plenary.nvim'          " source ~/.config/nvim/plugins/telescope.vim
Plug 'nvim-telescope/telescope.nvim'  " source ~/.config/nvim/plugins/telescope.vim

Plug 'tpope/vim-fugitive'             " source ~/.config/nvim/plugins/fugitive.vim

Plug 'airblade/vim-gitgutter'
Plug 'roxma/nvim-yarp'
Plug 'roxma/vim-hug-neovim-rpc'
Plug 'slashmili/alchemist.vim'
Plug 'thaerkh/vim-indentguides'
Plug 'tpope/vim-endwise'
Plug 'tpope/vim-rails'

call plug#end()

source ~/.config/nvim/plugins/json.vim
source ~/.config/nvim/plugins/markdown.vim
source ~/.config/nvim/plugins/airline.vim
source ~/.config/nvim/plugins/coc.vim
source ~/.config/nvim/plugins/nerdtree.vim
source ~/.config/nvim/plugins/telescope.vim
source ~/.config/nvim/plugins/fugitive.vim


"" Buffers And Windows:
" Close the buffer without closing the window (doesn't close your :split).
nnoremap <leader>q :bp<CR>:bd #<CR>
" Walk over the listed buffers.
nnoremap <Tab> :bnext<CR>
" Walks backwards over the listed buffers.
nnoremap <S-Tab> :bprevious<CR>
" Walks over the tab-pages.
nnoremap <leader><tab> :tabNext<CR>
" Closes current tab-page (and delete eventual unnamed empty buffers)
nnoremap <leader>tc :tabclose<CR>:call CleanNoNameEmptyBuffers()<CR>
" NOTE: I only use tab-pages for fugitive plugin, so this command is more like a 'exit' to the
" fugitive features.

"" Prettier — An Opinionated Javascript Formatter
autocmd FileType javascript set formatprg=prettier\ --stdin


"" Vim-javascript
let g:javascript_plugin_jsdoc = 1
let g:javascript_plugin_ngdoc = 1
let g:javascript_plugin_flow = 1

"""""""""
" " Force ruby syntax for .jb files
" " Force Dockerfile syntax for Dockerfile.* files
" augroup filetypedetect
"   au! BufNewFile,BufRead *.jb setf ruby
"   au! BufNewFile,BufRead Dockerfile.* setf dockerfile
" augroup END

" " Force indentation for some languages to 2 spaces.
" autocmd FileType ruby setlocal ts=2 sts=2 sw=2 expandtab
" autocmd FileType javascript setlocal ts=2 sts=2 sw=2 expandtab
" autocmd FileType coffeescript setlocal ts=2 sts=2 sw=2 expandtab
" autocmd FileType sass setlocal ts=2 sts=2 sw=2 expandtab
" autocmd FileType yaml setlocal ts=2 sts=2 sw=2 expandtab
" autocmd FileType sql setlocal ts=2 sts=2 sw=2 expandtab
" autocmd FileType dockerfile setlocal ts=2 sts=2 sw=2 expandtab
" autocmd FileType typescript setlocal ts=2 sts=2 sw=2 expandtab
" " Make file needs TAB, so unindent it.
" autocmd FileType make set noexpandtab

"" Basic Tips:
" --> command: CTRL+u   => Moves cursor to 20 lines up.
" --> command: CTRL+d   => Moves cursor to 20 lines down.
" --> command: CTRL+wo  => Closes all buffers except the one you are.
" --> command: CTRL+wr  => Rotates your current buffers.
" --> command: CTRL+wv  => Splits vertical.
" --> command: CTRL+ws  => Splits horizontal.
" --> command: CTRL+o   => Go back in the 'jump list'. You can see yours with :jumps.
" --> command: CTRL+i   => Go forward in the 'jump list'.

"" Find And Replace Multiple:
" search for a word you want to replace (you can press '*' to search forwards word) and change the
" next found occurrence with 'cgn' once and then use vim’s most powerful command the '.' (dot).
" Using . you can apply the change to the next word or skip one word with 'n' which will jump to
" the next word.
"" Replacement for https://github.com/terryma/vim-multiple-cursors
"" Source: https://medium.com/@schtoeffel/you-don-t-need-more-than-one-cursor-in-vim-2c44117d51db
" Note: You can use coc-rename instead
