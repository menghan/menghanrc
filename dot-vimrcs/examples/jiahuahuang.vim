" 自动补全命令时候使用菜单式匹配列表
set wildmenu
" 允许退格键删除
set backspace=2
" 启用鼠标
set mouse=a
" 文件类型
filetype on
filetype plugin on
filetype indent on
" 设置编码自动识别, 中文引号显示
"set fileencodings=utf-8,cp936,big5,euc-jp,euc-kr,latin1,ucs-bom
set fileencodings=utf-8,gbk,ucs-bom
set ambiwidth=double

" 移动长行
nnoremap <Down> gj
nnoremap <Up> gk

" 让编辑模式可以中文输入法下按：转到命令模式
nnoremap ： :

" 高亮
syntax on
" 设置高亮搜索
set hlsearch
" 输入字符串就显示匹配点
set incsearch
" 输入的命令显示出来，看的清楚些。
set showcmd

" 打开当前目录文件列表
map <F3> :e .<CR>

" Taglist
let Tlist_File_Fold_Auto_Close=1
set updatetime=1000
map <F4> :Tlist<CR>

" 按 F8 智能补全
inoremap <F8> <C-x><C-o>

" vim 自动补全 Python 代码
" 来自http://vim.sourceforge.net/scripts/script.php?script_id=850
autocmd FileType python set complete+=k~/.vim/tools/pydiction
autocmd FileType python set shiftwidth=4 tabstop=4 expandtab
" 自动使用新文件模板
autocmd BufNewFile *.py 0r ~/.vim/template/simple.py

autocmd FileType html set shiftwidth=4 tabstop=4 expandtab
autocmd BufNewFile *.html 0r ~/.vim/template/simple.html

"要在命令行上实现 Emacs 风格的编辑操作： >
" 至行首
:cnoremap <C-A>         <Home>
" 后退一个字符
:cnoremap <C-B>         <Left>
" 删除光标所在的字符
:cnoremap <C-D>         <Del>
" 至行尾
:cnoremap <C-E>         <End>
" 前进一个字符
:cnoremap <C-F>         <Right>
" 取回较新的命令行
:cnoremap <C-N>         <Down>
" 取回以前 (较旧的) 命令行
:cnoremap <C-P>         <Up>
" 后退一个单词
:cnoremap <Esc><C-B>    <S-Left>
" 前进一个单词
:cnoremap <Esc><C-F>    <S-Right>

"Format the statusline
"Nice statusbar
set laststatus=2
set statusline=
set statusline+=%2*%-3.3n%0*\ " buffer number
set statusline+=%f\ " file name
set statusline+=%h%1*%m%r%w%0* " flag
set statusline+=[
if v:version >= 600
set statusline+=%{strlen(&ft)?&ft:'none'}, " filetype
set statusline+=%{&encoding}, " encoding
endif
set statusline+=%{&fileformat}] " file format
if filereadable(expand("$VIM/vimfiles/plugin/vimbuddy.vim"))
set statusline+=\ %{VimBuddy()} " vim buddy
endif
set statusline+=%= " right align
"set statusline+=%2*0x%-8B\ " current char
set statusline+=0x%-8B\ " current char
set statusline+=%-14.(%l,%c%V%)\ %<%P " offset

