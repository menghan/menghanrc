if has('unix')
	nnoremap <buffer> \rr :!perl -w %<CR>
	nnoremap <buffer> \rd :!perl -d %<CR>
endif
setlocal cindent
setlocal autoindent
setlocal nu
