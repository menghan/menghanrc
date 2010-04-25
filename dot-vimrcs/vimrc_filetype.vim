" tex configure"
"
autocmd BufRead,BufNewFile *.tex set ft=latex

" mutt configure"
autocmd BufRead /tmp/mutt-* set tw=72

" bash/sh configure"
autocmd bufnewfile *.sh call setline(1,'#!/usr/bin/env bash') |
    \ call setline(2,'') |
    \ call setline(3,'') |
    \ exe "normal G" |
    \ exe "w" |
    \ exe "!chmod +x %"

" cscope config"
function ConfigCscope()
	nnoremap <buffer> <C-_>s :cs find s <C-R>=expand("<cword>")<CR><CR>
	nnoremap <buffer> <C-_>g :cs find g <C-R>=expand("<cword>")<CR><CR>
	nnoremap <buffer> <C-_>c :cs find c <C-R>=expand("<cword>")<CR><CR>
	nnoremap <buffer> <C-_>t :cs find t <C-R>=expand("<cword>")<CR><CR>
	nnoremap <buffer> <C-_>e :cs find e <C-R>=expand("<cword>")<CR><CR>
	nnoremap <buffer> <C-_>f :cs find f <C-R>=expand("<cfile>")<CR><CR>
	nnoremap <buffer> <C-_>i :cs find i ^<C-R>=expand("<cfile>")<CR>$<CR>
	nnoremap <buffer> <C-_>d :cs find d <C-R>=expand("<cword>")<CR><CR>
endfunction

if has("cscope")
	autocmd BufRead,BufNewFile  *.c,*.cpp,*.cc,*.h,*.hpp call ConfigCscope()
endif

" usaco configure"
autocmd BufRead,BufNewFile *.cpp let usacopath = expand("%:p:h") |
			\ if match(usacopath, 'usaco') >= 0|
			\ call USACO_Init() |
			\ endif
autocmd BufRead *.out nnoremap <buffer> <F5> :v/^DEBUG<CR>
