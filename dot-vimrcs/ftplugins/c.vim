"my c config


" setlocal completeopt=longest,menu
setlocal expandtab
setlocal number
setlocal shiftwidth=4
setlocal cino+=:0 "dont' indent case:
" setlocal cino+=g0 "indent c++ public private etc...
setlocal foldmethod=syntax
nnoremap <buffer> ,cn :cn<CR>
nnoremap <buffer> ,cp :cp<CR>
" nnoremap <buffer> <F5> :call WMakeRun()<CR>
" nnoremap <buffer> ,cpptg :silent !ctags -R --c++-kinds=+p --fields=+iaS --extra=+q .<CR>
" nnoremap <buffer> ,modeline m`Go/* vim:setlocal tw=0 sw=4 et ft=c fdm=syntax: */<ESC>'`
" if !has('win32')
" nnoremap <buffer> ,as :silent !astyle --style=kr -p --suffix=none %<CR>
" setlocal path+=/usr/include
" else
" nnoremap <buffer> ,as :silent !astyle.exe --style=kr -p --suffix=none %<CR>
" setlocal tags+=$VIM/../../MinGW/include/tags
" endif
nnoremap <buffer> ,tg :silent !ctags -R . && cscope -Rbkq<CR>
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

" "functions
" function! WMakeRun()
	" w
	" make
        " if has('win32')
            " !%<.exe
        " endif
" endfunction

" function! Filetype_c_cpp()
" endfunction

" function! Filetype_cpp()
	" if has('win32')
		" if filereadable('Makefile')
			" compile gcc | setlocal makeprg=\"D:\\Program\ Files\\MinGW\\bin\\mingw32-make.exe\"
		" else
			" compile gcc | setlocal makeprg=\"\"D:\\Program\ Files\\MinGW\\bin\\g++.exe\"\ -g\ -Wall\ -o\ %<\ %\"
		" endif
	" else
		" if filereadable('Makefile')
			" compile gcc | setlocal makeprg=make
		" else
			" compile gcc | setlocal makeprg=g++\ -g\ -Wall\ -o\ %<\ %
		" endif
	" endif
	" nnoremap <buffer> ,dbg O#ifdef DEBUG_SKY<ESC>o#endif<ESC>Ocout << "DEBUG: " << endl;<ESC>9hi
	" nnoremap <buffer> ,db0 Ousing namespace std;<CR>#define DEBUG_SKY<ESC>
" endfunction

" 不需要这里写
" "makefile
" autocmd BufRead,BufNewFile  Makefile*,makefile* setlocal noexpandtab

" "cpp/c/h
" autocmd BufRead,BufNewFile  *.c,*.cpp,*.cc,*.h,*.hpp call Filetype_c_cpp()
" autocmd BufRead,BufNewFile *.c,*.h call Filetype_c()
" autocmd BufRead,BufNewFile *.cpp,*.cc,*.hpp call Filetype_cpp()
" autocmd BufNewFile	    *.c,*.cpp,*.cc,*.h,*.hpp setlocal fileformat=unix

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
