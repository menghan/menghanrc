"my html configure"

setlocal nu
setlocal shiftwidth=2
setlocal softtabstop=2
setlocal tabstop=2
setlocal expandtab

" "for makeprg
" if has('win32')
	" setlocal makeprg=\"D:\\Python25\\python.exe\ %\"
" else
	" setlocal makeprg=python\ %
" endif

nnoremap <buffer> <F5> :make<CR>
" setlocal foldcolumn=2
setlocal fdm=indent
