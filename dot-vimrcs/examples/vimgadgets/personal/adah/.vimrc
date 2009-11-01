" vim:expandtab shiftwidth=2 tabstop=8 textwidth=72

" Wu Yongwei's .vimrc for Vim 7
" Last Change: 2008-06-19 21:22:54

if v:version < 700
  echoerr 'This _vimrc requires Vim 7 or later.'
  quit
endif

if has('autocmd')
  " Remove ALL autocommands for the current group
  au!

  " Mark .asm files MASM-type assembly
  au BufNewFile,BufReadPre *.asm let b:asmsyntax='masm'
endif

if has('gui_running')
  " Always show file types in menu
  let do_syntax_sel_menu=1
endif

set nocompatible
set encoding=utf-8
source $VIMRUNTIME/vimrc_example.vim

if !has('gui_running') && !exists('$XTERM_SHELL') && exists('$TERM') && $TERM != 'rxvt'
  colorscheme xterm16
endif

set autoindent
set nobackup
set formatoptions+=mM
set fileencodings=ucs-bom,utf-8,gbk,latin1
set fileformats=unix,dos,mac
set statusline=%<%f\ %h%m%r%=%k[%{(&fenc==\"\")?&enc:&fenc}%{(&bomb?\",BOM\":\"\")}]\ %-14.(%l,%c%V%)\ %P
set dictionary+=~/.vim/words
set tags+=/usr/local/etc/systags
if has('mouse')
  set mouse=a
endif
if has('multi_byte')
  if v:lang =~? '^\(zh\)\|\(ja\)\|\(ko\)'
    set ambiwidth=double
  endif
endif

" Set British spelling convention for International English
if has('syntax')
  set spelllang=en_gb
endif

if has('eval')
  " Function to find the absolute path of a runtime file
  function! FindRuntimeFile(filename, ...)
    if a:0 != 0 && a:1 =~ 'w'
      let require_writable=1
    else
      let require_writable=0
    endif
    let runtimepaths=&runtimepath . ','
    while strlen(runtimepaths) != 0
      let filepath=substitute(runtimepaths, ',.*', '', '') . '/' . a:filename
      if filereadable(filepath)
        if !require_writable || filewritable(filepath)
          return filepath
        endif
      endif
      let runtimepaths=substitute(runtimepaths, '[^,]*,', '', '')
    endwhile
    return ''
  endfunction

  " Function to display the current character code in its 'file encoding'
  function! EchoCharCode()
    let char_enc=matchstr(getline('.'), '.', col('.') - 1)
    let char_fenc=iconv(char_enc, &encoding, &fileencoding)
    let i=0
    let len=len(char_fenc)
    let hex_code=''
    while i < len
      let hex_code.=printf('%.2x',char2nr(char_fenc[i]))
      let i+=1
    endwhile
    echo '<' . char_enc . '> Hex ' . hex_code . ' (' .
          \(&fileencoding != '' ? &fileencoding : &encoding) . ')'
  endfunction

  " Key mapping to display the current character in its 'file encoding'
  nnoremap <silent> gn :call EchoCharCode()<CR>

  " Function to switch the cursor position between the first column and the
  " first non-blank column
  function! GoToFirstNonBlankOrFirstColumn()
    let cur_col=col('.')
    normal! ^
    if cur_col != 1 && cur_col == col('.')
      normal! 0
    endif
  endfunction

  " Key mappings to make Home go to first non-blank column or first column
  nnoremap <silent> <Home>      :call GoToFirstNonBlankOrFirstColumn()<CR>
  inoremap <silent> <Home> <C-O>:call GoToFirstNonBlankOrFirstColumn()<CR>

  " Function to insert the current date
  function! InsertCurrentDate()
    let curr_date=strftime('%Y-%m-%d', localtime())
    silent! exec 'normal! gi' .  curr_date . "\<ESC>l"
  endfunction

  " Key mapping to insert the current date
  inoremap <silent> <C-\><C-D> <C-O>:call InsertCurrentDate()<CR>
endif

" Key mappings to ease browsing long lines
noremap  <C-J>         gj
noremap  <C-K>         gk
inoremap <M-Home> <C-O>g0
inoremap <M-End>  <C-O>g$

" Key mappings for quick arithmetic inside Vim (requires a calcu in path)
nnoremap <silent> <Leader>ma yypV:!calcu '<C-R>"'<CR>k$
vnoremap <silent> <Leader>ma yo<ESC>pV:!calcu '<C-R>"'<CR>k$
nnoremap <silent> <Leader>mr yyV:!calcu '<C-R>"'<CR>$
vnoremap <silent> <Leader>mr ygvmaomb:r !calcu '<C-R>"'<CR>"ay$dd`bv`a"ap

" Key mapping for confirmed exiting
nnoremap ZX :confirm qa<CR>

" Key mapping to stop the search highlight
nmap <silent> <F2>      :nohlsearch<CR>
imap <silent> <F2> <C-O>:nohlsearch<CR>

" Key mapping for the taglist.vim plug-in (Vim script #273)
nmap <F5>      :Tlist<CR>
imap <F5> <C-O>:Tlist<CR>

" Key mapping to toggle the display of status line for the last window
nmap <silent> <F6> :if &laststatus == 1<bar>
                     \set laststatus=2<bar>
                     \echo<bar>
                   \else<bar>
                     \set laststatus=1<bar>
                   \endif<CR>

" Key mappings for quickfix commands, tags, and buffers
nmap <F11>   :cn<CR>
nmap <F12>   :cp<CR>
nmap <M-F11> :copen<CR>
nmap <M-F12> :cclose<CR>
nmap <C-F11> :tn<CR>
nmap <C-F12> :tp<CR>
nmap <S-F11> :n<CR>
nmap <S-F12> :prev<CR>

" Function to turn each paragraph to a line (to work with, say, MS Word)
function! ParagraphToLine()
  normal! ma
  if &formatoptions =~ 'w'
    let reg_bak=@"
    normal! G$vy
    if @" =~ '\s'
      normal! o
    endif
    let @"=reg_bak
    silent! %s/\(\S\)$/\1\r/e
  else
    normal! Go
  endif
  silent! g/\S/,/^\s*$/j
  silent! %s/\s\+$//e
  normal! `a
endfunction

" Non-GUI setting
if !has('gui_running')
  " English messages only
  language messages C

  " Do not increase the windows width in taglist
  let Tlist_Inc_Winwidth=0

  " Set text-mode menu
  if has('wildmenu')
    set wildmenu
    set cpoptions-=<
    set wildcharm=<C-Z>
    nmap <F10>      :emenu <C-Z>
    imap <F10> <C-O>:emenu <C-Z>
  endif
endif

" Display window width and height in GUI
if has('gui_running') && has('statusline')
  let &statusline=substitute(
                 \&statusline, '%=', '%=%{winwidth(0)}x%{winheight(0)}  ', '')
  set laststatus=2
endif

" Key mapping to toggle spelling check
if has('syntax')
  nmap <silent> <F7>      :setlocal spell!<CR>
  imap <silent> <F7> <C-O>:setlocal spell!<CR>
  let spellfile_path=FindRuntimeFile('spell/en.' . &encoding . '.add', 'w')
  if spellfile_path != ''
    exec 'nmap <M-F7> :sp ' . spellfile_path . '<CR><bar><C-W>_'
  endif
endif

" Common abbreviations
iabbrev Br      Best regards,
iabbrev Btw     By the way,
iabbrev Yw      Yongwei

if has('autocmd')
  function! SetFileEncodings(encodings)
    let b:my_fileencodings_bak=&fileencodings
    let &fileencodings=a:encodings
  endfunction

  function! RestoreFileEncodings()
    let &fileencodings=b:my_fileencodings_bak
    unlet b:my_fileencodings_bak
  endfunction

  function! SetAmbiWidth()
    if     &fileencoding ==? 'cp936' || &fileencoding ==? 'euc-cn' ||
          \&fileencoding ==? 'cp950' || &fileencoding ==? 'euc-tw' ||
          \&fileencoding ==? 'cp932' || &fileencoding ==? 'euc-jp' ||
          \&fileencoding ==? 'cp949' || &fileencoding ==? 'euc-kr' ||
          \&fileencoding =~? '^gb[12k]' || &fileencoding ==? 'big5' ||
          \&fileencoding ==? 'sjis'
      setlocal ambiwidth=double
    elseif &fileencoding !=? 'utf-8'
      setlocal ambiwidth=single
    endif
  endfunction

  function! GnuIndent()
    setlocal cinoptions=>4,n-2,{2,^-2,:2,=2,g0,h2,p5,t0,+2,(0,u0,w1,m1
    setlocal shiftwidth=2
    setlocal tabstop=8
  endfunction

  function! UpdateLastChangeTime()
    let last_change_anchor='\(" Last Change:\s\+\)\d\{4}-\d\{2}-\d\{2} \d\{2}:\d\{2}:\d\{2}'
    let last_change_line=search('\%^\_.\{-}\(^\zs' . last_change_anchor . '\)', 'n')
    if last_change_line != 0
      let last_change_time=strftime('%Y-%m-%d %H:%M:%S', localtime())
      let last_change_text=substitute(getline(last_change_line), '^' . last_change_anchor, '\1', '') . last_change_time
      call setline(last_change_line, last_change_text)
    endif
  endfunction

  function! RemoveTrailingSpace()
    if $VIM_HATE_SPACE_ERRORS != '0' &&
          \(&filetype == 'c' || &filetype == 'cpp' || &filetype == 'vim')
      normal! m`
      silent! :%s/\s\+$//e
      normal! ``
    endif
  endfunction

  function! RemoveExtraCRs()
    normal m`
    silent! %s/$//
    normal ``
  endfunction

  " Use automatic encoding detection (Vim script #1708)
  let $FENCVIEW_TELLENC='tellenc'       " See <URL:http://wyw.dcweb.cn/>
  let fencview_auto_patterns='*.log,*.txt,*.tex,*.htm{l\=},*.asp'
                           \.',README,CHANGES,INSTALL'
  let fencview_html_filetypes='html,aspvbs'

  " File types to use function echoing (Vim script #1735)
  let EchoFuncLangsUsed=['c', 'cpp']

  " Keys for EchoFunc (Vim script #1735)
  let EchoFuncKeyPrev='<C-]>'
  let EchoFuncKeyNext='<C-\>'

  " Use Exuberant Ctags instead of the system default
  let Tlist_Ctags_Cmd='/usr/local/bin/ctags'

  " Do not use menu for NERD Commenter
  let NERDMenuMode=0
  " Prevent NERD Commenter from complaining about unknown file types
  let NERDShutUp=1

  " Highlight space errors in C/C++ source files (Vim tip #935)
  if $VIM_HATE_SPACE_ERRORS != '0'
    let c_space_errors=1
  endif

  " Tune for C highlighting
  let c_gnu=1
  let c_no_curly_error=1

  " Load doxygen syntax file for c/cpp/idl files
  let load_doxygen_syntax=1

  " Let TOhtml output <PRE> and style sheet
  let html_use_css=1

  " Show syntax highlighting attributes of character under cursor (Vim
  " script #383)
  map <Leader>a :call SyntaxAttr()<CR>

  " File type related autosetting
  au FileType c,cpp      setlocal cinoptions=:0,g0,(0,w1 shiftwidth=4 tabstop=4
  au FileType diff       setlocal shiftwidth=4 tabstop=4
  au FileType changelog  setlocal textwidth=76
  au FileType cvs        setlocal textwidth=72
  au FileType html,xhtml setlocal indentexpr=
  au FileType mail       setlocal expandtab softtabstop=2 textwidth=70

  " Detect file encoding based on file type
  au BufReadPre  *.gb               call SetFileEncodings('cp936')
  au BufReadPre  *.big5             call SetFileEncodings('cp950')
  au BufReadPre  *.nfo              call SetFileEncodings('cp437')
  au BufReadPost *.gb,*.big5,*.nfo  call RestoreFileEncodings()

  " Quickly exiting help files
  au BufRead *.txt      if &buftype=='help'|nmap <buffer> q <C-W>c|endif

  " Set ambiwidth depending on the fileencoding
  au BufEnter *                     call SetAmbiWidth()

  " Setting for files following the GNU coding standard
  au BufEnter /usr/*                call GnuIndent()

  " Automatically update change time
  au BufWritePre *vimrc,*.vim       call UpdateLastChangeTime()

  " Remove trailing spaces for C/C++ and Vim files
  au BufWritePre *                  call RemoveTrailingSpace()
endif
