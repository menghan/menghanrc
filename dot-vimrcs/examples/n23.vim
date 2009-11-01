"load snippest
" cd svnroot
" svn checkout http://snippetsemu.googlecode.com/svn/trunk/
snippetsemu-read-only
set runtimepath+=~/svnroot/snippetsemu-read-only
set runtimepath+=~/svnroot/snippetsemu-read-only/afte

au BufEnter * if &textwidth > 0 | exec 'match Todo /\%>' . &textwidth
. 'v.\+/' | endif
au BufRead,BufNewFile *.py,*.pyw,*.c,*.h set shiftwidth=4
au BufRead,BufNewFile *.py,*.pyw,*.c,*.h set softtabstop=4
au BufRead,BufNewFile *.py,*.pyw,*.c,*.h set tabstop=4
au BufRead,BufNewFile Makefile* set noexpandtab
highlight BadWhitespace ctermbg=red guibg=red
au BufRead,BufNewFile *.py,*.pyw match BadWhitespace /^\t\+/
au BufRead,BufNewFile *.py,*.pyw,*.c,*.h set textwidth=79
au BufNewFile *.py,*.pyw,*.c,*.h set fileformat=unix

