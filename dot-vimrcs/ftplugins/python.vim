"python configure

setlocal nu
setlocal shiftwidth=4
setlocal softtabstop=4
setlocal tabstop=4
setlocal expandtab
setlocal textwidth=0
setlocal autoindent
setlocal backspace=indent,eol,start
setlocal incsearch
setlocal ignorecase
setlocal ruler
setlocal wildmenu
setlocal commentstring=\ #\ %s
setlocal foldlevel=0
setlocal clipboard+=unnamed
setlocal smartindent cinwords=if,elif,else,for,while,try,except,finally,def,class
setlocal fdm=indent
syntax on

let python_highlight_all = 1

"syntax check
if has('unix')
	nnoremap <buffer> \rr :!python %<CR>
	nnoremap <buffer> \r6 :!python2.6 %<CR>
	nnoremap <buffer> \r3 :!python3.1 %<CR>
	nnoremap <buffer> \rs :!python -m py_compile %; rm -f %c<CR>
	nnoremap <buffer> \rp :set paste<CR>
	nnoremap <buffer> \rn :set nopaste<CR>
endif
