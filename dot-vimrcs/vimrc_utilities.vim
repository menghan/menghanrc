function! Makeusaco()
	w
	if !filereadable('Makefile')
		let s:choice = confirm("No Makefile", "&Ok", 1)
		return
	endif
	silent !rm skytest.exe
	make
	if filereadable('skytest.exe')
		silent !./skytest.exe
	else
		let s:choice = confirm("Compile Error!", "&Neglect\n&View", 2)
		if s:choice == 2
			:copen
		endif
	endif
endfunction

function! USACO_Init()
	nnoremap <buffer> <F5> :call Makeusaco()<CR>
endfunction

function! UpdateLastModifyTime()
	for lineno in range(1, 10)
		let line = getline(lineno)
		let time = strftime("%c")
		if match(line, 'Last update:') >= 0
			let line = substitute(line, 'Last update: .*', 'Last update: ' . time, "g")
			silent call setline(lineno, line)
			break
		endif
	endfor
endfunction
autocmd BufWritePre * :call UpdateLastModifyTime()
