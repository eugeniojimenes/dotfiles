" Plug 'vim-airline/vim-airline'
" Plug 'dense-analysis/ale'
" Plug 'morhetz/gruvbox'
" Plug 'ryanoasis/vim-devicons'

" Settings for vim-devicons, NerdFonts and vim-airline
set guifont=SourceCodePro\ Nerd\ Font\ Regular
let g:airline_powerline_fonts = 1
" Enable the list of buffers
let g:airline#extensions#tabline#enabled = 1
" Enable Ale with airline
let g:airline#extensions#ale#enabled = 1

" Gruvbox:
let g:gruvbox_italic=1
let g:gruvbox_contrast_dark='medium'
colorscheme gruvbox
set background=dark
