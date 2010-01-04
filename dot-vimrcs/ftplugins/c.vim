"my c config

"functions
function! WMakeRun()
	w
	make
	if has('win32')
		!%<.exe
	endif
endfunction
nnoremap <buffer> <F5> :call WMakeRun()<CR>

setlocal completeopt=longest,menu
setlocal expandtab
setlocal number
setlocal shiftwidth=4
setlocal cino+=:0 "dont' indent case:
setlocal foldmethod=syntax
nnoremap <buffer> ,cn :cn<CR>
nnoremap <buffer> ,cp :cp<CR>

if !has('win32')
	setlocal path+=/usr/include
else
	setlocal tags+=$VIM/../../MinGW/include/tags
endif
if has('win32')
	if filereadable('Makefile')
		compile gcc | setlocal makeprg=\"D:\\Program\ Files\\MinGW\\bin\\mingw32-make.exe\"
	else
		compile gcc | setlocal makeprg=\"\"D:\\Program\ Files\\MinGW\\bin\\gcc.exe\"\ -g\ -Wall\ -o\ %<\ %\"
	endif
else
	if filereadable('Makefile') || filereadable('makefile')
		compile gcc | setlocal makeprg=make
	else
		compile gcc | setlocal makeprg=gcc\ -g\ -Wall\ -lm\ -o\ %<\ %
	endif
endif

"for cscope
if has("cscope")
	set csprg=/usr/bin/cscope
	set csto=0
	set cst
	set nocsverb
	" add any database in current directory
	if filereadable("cscope.out")
		cs add cscope.out
		" else add database pointed to by environment
	elseif $CSCOPE_DB != ""
		cs add $CSCOPE_DB
	endif
	set csverb
endif
