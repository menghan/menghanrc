" [ setting ]
colorscheme torte
syntax on
filetype on
filetype indent on
filetype plugin on

" set cursorcolumn
set nocompatible
set nobackup
" set cindent
set autoindent
set smartindent
set hidden
" set wildmode=list:full "auto complete
" set wildmenu
" set completeopt=longest,menu,preview
set backspace=indent,eol,start
set mouse=a "allow mouse
set clipboard+=unnamed "share the common clipboard with other applications
set titlestring=%F
set tags=./tags;
set helplang=cn
set grepprg=grep\ -nH\ $*
set guioptions=egmt "不显示工具条(T)和滚动条(r)
set winaltkeys=no "防止windows解释alt组合键
set showcmd
set showmatch " show matching brackets
set ignorecase smartcase
set nohlsearch " do not highlight searched for phrases
set incsearch " BUT do highlight as you type you search phrase
set ambiwidth=double
set display=lastline,uhex
" set fillchars=vert:\|,fold:-
" set formatoptions+=Mmn
set guitablabel=%{tabpagenr()}.%t\ %m
" set tabline
set wildignore=*.lo,*.o,*.obj,*.exe,*.pyc " tab complete now ignores these

" [diff options]
set diffopt=filler,vertical

" [ about status line ]
set ruler
set statusline=%k(%02n)%t%m%r%h%w\ \[%{&ff}:%{&fenc}:%Y]\ \[line=%04l/%04L\ col=%03c/%03{col(\"$\")-1}]\ [%p%%]
set laststatus=2

" [tab stop options]
set tabstop=8
set softtabstop=8
set smarttab " use tabs at the start of a line,spaces elsewhere
set shiftwidth=8

" Uncomment the following to have Vim jump to the last position when
" reopening a file
if has("autocmd")
  au BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$")
    \| exe "normal! g'\"" | endif
endif

" [ maps ]
"
"from vimtips
"about use ',x' to open file
noremap ,e :e <C-R>=expand("%:p:h") . "/" <CR><C-D>
noremap ,s :split <C-R>=expand("%:p:h") . "/" <CR><C-D>
noremap ,v :vsplit <C-R>=expand("%:p:h") . "/" <CR><C-D>
noremap ,t :tabnew <C-R>=expand("%:p:h") . "/" <CR><C-D>

"要在命令行上实现 Emacs 风格的编辑操作： >
cnoremap <C-A>         <Home>
cnoremap <C-B>         <Left>
cnoremap <C-D>         <Del>
cnoremap <C-E>         <End>
cnoremap <C-F>         <Right>

" [ insert mode movement ]
inoremap <C-L> <right>
inoremap <C-H> <left>
inoremap <C-J> <down>
inoremap <C-K> <up>
inoremap <C-A> <C-O>I
inoremap <C-E> <C-O>A

"do some useful map
nnoremap Y y$
nnoremap ]] ][
nnoremap ][ ]]

" [Up down move]
nnoremap    j       gj
nnoremap    k       gk
nnoremap    gj      j
nnoremap    gk      k

" [Misc]
nnoremap    J       gJ
nnoremap    gJ      J
nnoremap    -       _
nnoremap    _       -


" windows navigation maps
" goto upper/lower window and max it
nnoremap <C-J> <C-W>j<C-W>_
nnoremap <C-K> <C-W>k<C-W>_
nnoremap <c-h> gT
nnoremap <c-l> gt

" [Scroll up and down in Quickfix]
nnoremap    <c-n>   :cn<cr>
nnoremap    <c-p>   :cp<cr>

" [Easy indent in visual mode]
xnoremap    <   <gv
xnoremap    >   >gv

" [ goto neighbour ]
nnoremap ,h <C-W>h
nnoremap ,j <C-W>j
nnoremap ,k <C-W>k
nnoremap ,l <C-W>l
nnoremap ,q :q!<CR>
nnoremap ,w :up<CR>
nnoremap ,d :bd<CR>
nnoremap ,z <C-Z>
nnoremap ,co :copen<CR>

"still not understand
"run ex and normal command and redirect message to register *, use try-finally
"to ensure that redir END will always be executed
"command -nargs=* Mc redir @*> |try| exe "<args>" | finally | redir END | endtry
"command -nargs=* Mn redir @*> |try| normal "<args>" | finally | redir END | endtry

"don't load color's menu
let g:did_color_sample_pack = 1

" win32 configure
if has("win32")
	nnoremap ,exp :silent !start explorer "%:p:h"<CR>
	nnoremap ,cmd :silent !start cmd /K "cd /d %:p:h"<CR>
endif
