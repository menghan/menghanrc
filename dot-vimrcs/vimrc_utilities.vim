" [UpdateTime() Update the timestamp in the header]
function! UpdateTime()
	for s:i in range(1,10)
		let s:tmp=getline(s:i)
		let s:time=strftime("%Y-%m-%d %H:%M:%S")
		if match(s:tmp,'\d\{4}-\d\{2}-\d\{2}\ \d\{2}:\d\{2}:\d\{2}')>=0
			let s:tmp=substitute(s:tmp,'\d\{4}-\d\{2}-\d\{2}\ \d\{2}:\d\{2}:\d\{2}',s:time,"g")
			silent call setline(s:i,s:tmp)
			break
		endif
	endfor
endfunction

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
	nnoremap <buffer> \id :! myindent.sh %<CR>:e<CR>
endfunction

