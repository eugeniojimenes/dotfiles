" Plug 'neoclide/coc.nvim', { 'branch': 'release' }

let g:coc_global_extensions = [
    \ 'coc-css',
    \ 'coc-diagnostic',
    \ 'coc-emmet',
    \ 'coc-git',
    \ 'coc-html',
    \ 'coc-json',
    \ 'coc-pairs',
    \ 'coc-sh',
    \ 'coc-snippets',
    \ 'coc-sql',
    \ 'coc-svg',
    \ 'https://github.com/rodrigore/coc-tailwind-intellisense',
    \ 'coc-tsserver',
    \ 'coc-solargraph',
\ ]
" Add CoC Prettier if prettier is installed
if isdirectory('./node_modules') && isdirectory('./node_modules/prettier')
  let g:coc_global_extensions += ['coc-prettier']
endif
" Add CoC ESLint if ESLint is installed
if isdirectory('./node_modules') && isdirectory('./node_modules/eslint')
  let g:coc_global_extensions += ['coc-eslint']
endif
" --> command: gd => Go to method/function/class definition.
nmap <silent> gd <Plug>(coc-definition)
" --> command: gy => Go to method/function/class type definition
"  OBS: Go to the type that defines a symbol. For an instance of a class, this will reveal the
"  class itself instead of where the instance is defined.
"  Source: https://medium.com/@nikolalsvk/i-am-looking-inside-the-coc-nvim-documentation-and-what-i-found-is-the-following-518d551eb770
nmap <silent> gy <Plug>(coc-type-definition)
" --> command: gi => Go to method/function/class implementation.
nmap <silent> gi <Plug>(coc-implementation)
" --> command: gr => Open two buffers to listing files that have one or more references and the
"  preview of these files.
nmap <silent> gr <Plug>(coc-references)
" --> command: <space>+rr => Use coc to rename variable, function, class etc on multiple files.
nmap <leader>rr <Plug>(coc-rename)
" --> command: <space>+ac => Remap keys for applying codeAction to the current buffer.
nmap <leader>ac  <Plug>(coc-codeaction)
" Apply AutoFix to problem on the current line.
" --> command: <space>+cf => Apply AutoFix to problem on the current line.
nmap <leader>cf  <Plug>(coc-fix-current)
" --> command: <space>+pf => Format current file with your prettier definition.
nmap <leader>pf   :CocCommand prettier.formatFile<CR>
" --> command: <space>+cr => Restart coc.
nnoremap <leader>cr :CocRestart<CR>
" --> command: <space>+k => Show documentation of method/function/class in a preview window with
"  the following custom function.
nnoremap <leader>k :call <SID>show_documentation()<CR>
function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  elseif (coc#rpc#ready())
    call CocActionAsync('doHover')
  else
    execute '!' . &keywordprg . " " . expand('<cword>')
  endif
endfunction
