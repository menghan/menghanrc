"my python configure"

setlocal nu
setlocal shiftwidth=4
setlocal softtabstop=4
setlocal tabstop=4
setlocal expandtab
let python_highlight_all = 1

"Python iMaps
inoremap <buffer> $r return 
inoremap <buffer> $s self
inoremap <buffer> $c ##<cr>#<space><cr>#<esc>kla
inoremap <buffer> $f from 
inoremap <buffer> $i import 
inoremap <buffer> $p print 
inoremap <buffer> $d """<cr>"""<esc>O

"auto complete
if has('win32')
	"setlocal complete+=k~/$HOME/vimfiles/pydiction-0.5/pydiction isk+=.,(
else
	setlocal complete+=k~/.vim/pydiction-0.5/pydiction 
	" setlocal isk+=.,(
	setlocal isk+=.,
endif

"for makeprg
if has('win32')
	setlocal makeprg=\"D:\\Python25\\python.exe\ %\"
else
	setlocal makeprg=python\ -m\ py_compile\ %
endif

"for smart indent
setlocal smartindent cinwords=if,elif,else,for,while,try,except,finally,def,class
nnoremap <buffer> <F5> :make<CR>
" setlocal foldcolumn=2
setlocal fdm=indent
