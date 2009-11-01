" vim:shiftwidth=2:tabstop=8:expandtab

if has('autocmd')
  " Remove ALL autocommands for the current group
  au! 

  " Mark .asm files MASM-type assembly
  au BufNewFile,BufReadPre *.asm let b:asmsyntax='masm'
endif


if has('gui_running')
  let do_syntax_sel_menu=1
endif

if has('gui_running') && $LANG !~ '\.'
  set encoding=utf-8
endif

set nocompatible
source $VIMRUNTIME/vimrc_example.vim
"source $VIMRUNTIME/ftplugin/man.vim

set autoindent
set nobackup
set showmatch
set formatoptions+=mM
set fileencodings=ucs-bom,utf-8,gbk
set statusline=%<%f\ %h%m%r%=%k[%{(&fenc==\"\")?&enc:&fenc}%{(&bomb?\",BOM\":\"\")}]\ %-14.(%l,%c%V%)\ %P
if has('mouse')
    set mouse=
endif
if has('multi_byte') && v:version > 601
  if v:lang =~? '^\(zh\)\|\(ja\)\|\(ko\)'
    set ambiwidth=double
  endif
endif

" Key mappings to ease browsing long lines
noremap  <C-J>       gj
noremap  <C-K>       gk
noremap  <Down>      gj
noremap  <Up>        gk
inoremap <Down> <C-O>gj
inoremap <Up>   <C-O>gk

" Key mappings for quick arithmetic inside Vim
nnoremap <silent> <Leader>ma yypV:!calcu '<C-R>"'<CR>k$
vnoremap <silent> <Leader>ma yo<ESC>pV:!calcu '<C-R>"'<CR>k$
nnoremap <silent> <Leader>mr yyV:!calcu '<C-R>"'<CR>$
vnoremap <silent> <Leader>mr ygvmaomb:r !calcu '<C-R>"'<CR>"ay$dd`bv`a"ap

" Key mapping to stop the search highlight
nmap <silent> <F2>      :nohlsearch<CR>
imap <silent> <F2> <C-O>:nohlsearch<CR>

" Key mapping for the taglist.vim plugin
nmap <F9>      :Tlist<CR>
imap <F9> <C-O>:Tlist<CR>

" Key mappings for the quickfix commands
nmap <F11> :cn<CR>
nmap <F12> :cp<CR>

" Non-GUI setting
if !has('gui_running')
  " Do not increase the windows width in the taglist.vim plugin
  if has('eval')
    let Tlist_Inc_Winwidth=0
  endif

  " Set text-mode menu
  if has('wildmenu')
    set wildmenu
    set cpoptions-=<
    set wildcharm=<C-Z>
    nmap <F10>      :emenu <C-Z>
    imap <F10> <C-O>:emenu <C-Z>
  endif
endif

if has('autocmd')
  function! SetFileEncodings(encodings)
    let b:my_fileencodings_bak=&fileencodings

    let &fileencodings=a:encodings
  endfunction

  function! RestoreFileEncodings()
    let &fileencodings=b:my_fileencodings_bak
    unlet b:my_fileencodings_bak
  endfunction

  function! CheckFileEncoding()
    if &modified && &fileencoding != ''
      exec 'e! ++enc=' . &fileencoding
    endif
  endfunction

  function! ConvertHtmlEncoding(encoding)
    if a:encoding ==? 'gb2312'
      return 'gbk'              " GB2312 imprecisely means GBK in HTML
    elseif a:encoding ==? 'iso-8859-1'
      return 'latin1'           " The canonical encoding name in Vim
    elseif a:encoding ==? 'utf8'
      return 'utf-8'            " Other encoding aliases should follow here
    else
      return a:encoding
    endif
  endfunction

  function! DetectHtmlEncoding()
    if &filetype != 'html'
      return
    endif
    normal m`
    normal gg
    if search('\c<meta http-equiv=\("\?\)Content-Type\1 content="text/html; charset=[-A-Za-z0-9_]\+">') != 0
      let reg_bak=@"
      normal y$
      let charset=matchstr(@", 'text/html; charset=\zs[-A-Za-z0-9_]\+')
      let charset=ConvertHtmlEncoding(charset)
      normal ``
      let @"=reg_bak
      if &fileencodings == ''
        let auto_encodings=',' . &encoding . ','
      else
        let auto_encodings=',' . &fileencodings . ','
      endif
      if charset !=? &fileencoding &&
         \(auto_encodings =~ ',' . &fileencoding . ',' || &fileencoding == '')
        silent! exec 'e ++enc=' . charset
      endif
    else
      normal ``
    endif
  endfunction

  function! GnuIndent()
    setlocal cinoptions=>4,n-2,{2,^-2,:2,=2,g0,h2,p5,t0,+2,(0,u0,w1,m1
    setlocal shiftwidth=2
    setlocal tabstop=8
  endfunction

  function! RemoveTrailingSpace()
    if $VIM_HATE_SPACE_ERRORS != '0' &&
          \(&filetype == 'c' || &filetype == 'cpp' || &filetype == 'vim')
      normal m`
      silent! :%s/\s\+$//e
      normal ``
    endif
  endfunction

  " Highlight space errors in C/C++ source files (Vim tip #935)
  if $VIM_HATE_SPACE_ERRORS != '0'
    let c_space_errors=1
  endif

  " Use Canadian spelling convention in engspchk (Vim script #195)
  let spchkdialect='can'

  " Show syntax highlighting attributes of character under cursor (Vim
  " script #383)
  map <Leader>a :call SyntaxAttr()<CR>

  " Automatically find scripts in the autoload directory
  au FuncUndefined * exec 'runtime autoload/' . expand('<afile>') . '.vim'

  " File type related autosetting
  au FileType c,cpp setlocal cinoptions=:0,g0,(0,w1 shiftwidth=4 tabstop=4
  au FileType diff  setlocal shiftwidth=4 tabstop=4
  au FileType html  setlocal autoindent indentexpr=
  au FileType changelog setlocal textwidth=76
  au FileType xml  setlocal smartindent shiftwidth=2 ts=2 et
"  set et nu sw=4 ts=4

  " Text file encoding autodetection
  au BufReadPre  *.gb               call SetFileEncodings('gbk')
  au BufReadPre  *.big5             call SetFileEncodings('big5')

  au BufReadPre  *.nfo              call SetFileEncodings('cp437')
  au BufReadPost *.gb,*.big5,*.nfo  call RestoreFileEncodings()
  au BufWinEnter *.txt              call CheckFileEncoding()

  " Detect charset encoding in an HTML file
  au BufReadPost *.htm* nested      call DetectHtmlEncoding()

  " Recognize standard C++ headers
  au BufEnter /usr/include/c++/*    setf cpp
  au BufEnter /usr/include/g++-3/*  setf cpp

  " Setting for files following the GNU coding standard
  au BufEnter /usr/*                call GnuIndent()

  " Remove trailing spaces for C/C++ and Vim files
  au BufWritePre *                  call RemoveTrailingSpace()
endif

set mps+=<:>
set nu

"set taglist plugin
""把方法列表放在屏幕的右侧， 于是在 .vimrc 中设置了

let Tlist_Use_Right_Window=1
"让当前不被编辑的文件的方法列表自动折叠起来， 这样可以节约一些屏幕空间，于是在 .vimrc 中设置了
let Tlist_File_Fold_Auto_Close=1
"
"
"以下为python语言设置
"
" 让 python 展开Tab，显示行号，缩进4, Tab宽度4
"autocmd FileType python set et nu sw=4 ts=4

if has("autocmd")

    " 自动检测文件类型并加载相应的设置
     filetype plugin indent on
    "
    " Python 文件的一般设置，比如不要 tab 等
    autocmd FileType python setlocal et | setlocal sta | setlocal sw=4
    "
    " Python Unittest 的一些设置
    " 可以让我们在编写 Python 代码及 unittest 测试时不需要离开 vim
    " 键入 :make 或者点击 gvim 工具条上的 make 按钮就自动执行测试用例
    autocmd FileType python compiler pyunit
    autocmd FileType python setlocal makeprg=python\ ./alltests.py
    autocmd BufNewFile,BufRead test*.py setlocal makeprg=python\ %
    "
    "Windows 环境改为如下形式
    " autocmd FileType python setlocal makeprg=\"C:\\Program\ Files\\Plone  2\\Python\\python\"\ ./alltests.py
    " autocmd BufNewFile,BufRead test*.py setlocal makeprg=\"C:\\Program\  Files\\Plone 2\\Python\\python\"\ %
    " 自动使用新文件模板
    autocmd BufNewFile test*.py 0r ~/.vim/skeleton/test.py
    autocmd BufNewFile alltests.py 0r ~/.vim/skeleton/alltests.py
    autocmd BufNewFile *.py 0r ~/.vim/skeleton/skeleton.py
    autocmd BufWritePre,FileWritePre *.py ks|call LastModify()|'s
    "要在写入一个文件时插入当前日期和时间
    fun LastModify()
      if line("$") > 20
        let l = 20
      else
        let l = line("$")
      endif
      exe "1," . l . "g/Last Changed: /s/Last Changed: .*/Last Changed: " . strftime("%Y-%m-%d %T")
    endfun


endif
"python auto-complete code
"Now you can simply hit Control-n (n=next) or Control-p (p=previous) to complete Python code.
"(type ":help completion" in vim for more details)
" Typing the following (in insert mode): os.lis<Ctrl-n> will expand to: os.listdir(
 " Python 自动补全功能，只需要反覆按 Ctrl-N 就行了,需要pydiction
if has("autocmd")
   "autocmd FileType python set complete+=k~/.vim/tools/pydiction
   autocmd FileType python set complete+=k~/.vim/tools/pydiction isk+=.,(
endif

"python语言设置结束
"
"模板设置
    autocmd BufNewFile *.xhtml 0r ~/.vim/skeleton/skeleton.xhtml
    autocmd BufNewFile *.c 0r ~/.vim/skeleton/skeleton.c
    autocmd BufWritePre,FileWritePre *.c ks|call LastModify()|'s

