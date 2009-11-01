" Vimball Archiver by Charles E. Campbell, Jr., Ph.D.
UseVimball
finish
plugin/netrwPlugin.vim	[[[1
159
" netrwPlugin.vim: Handles file transfer and remote directory listing across a network
"            PLUGIN SECTION
" Date:		Aug 10, 2008
" Maintainer:	Charles E Campbell, Jr <NdrOchip@ScampbellPfamily.AbizM-NOSPAM>
" GetLatestVimScripts: 1075 1 :AutoInstall: netrw.vim
" Copyright:    Copyright (C) 1999-2008 Charles E. Campbell, Jr. {{{1
"               Permission is hereby granted to use and distribute this code,
"               with or without modifications, provided that this copyright
"               notice is copied with it. Like anything else that's free,
"               netrw.vim, netrwPlugin.vim, and netrwSettings.vim are provided
"               *as is* and comes with no warranty of any kind, either
"               expressed or implied. By using this plugin, you agree that
"               in no event will the copyright holder be liable for any damages
"               resulting from the use of this software.
"
"  But be doers of the Word, and not only hearers, deluding your own selves {{{1
"  (James 1:22 RSV)
" =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
" Load Once: {{{1
if &cp || exists("g:loaded_netrwPlugin")
 finish
endif
let g:loaded_netrwPlugin = "v134"
if v:version < 702
 echohl WarningMsg | echo "***netrw*** you need vim version 7.2 for this version of netrw" | echohl None
 finish
endif
let s:keepcpo = &cpo
set cpo&vim

" ---------------------------------------------------------------------
" Public Interface: {{{1

" Local Browsing: {{{2
augroup FileExplorer
 au!
 au BufEnter * silent! call s:LocalBrowse(expand("<amatch>"))
 if has("win32") || has("win95") || has("win64") || has("win16")
  au BufEnter .* silent! call s:LocalBrowse(expand("<amatch>"))
 endif
augroup END

" Network Browsing Reading Writing: {{{2
augroup Network
 au!
 if has("win32") || has("win95") || has("win64") || has("win16")
  au BufReadCmd  file://*		exe "silent doau BufReadPre ".fnameescape(netrw#RFC2396(expand("<amatch>")))|exe 'e '.fnameescape(substitute(netrw#RFC2396(expand("<amatch>")),'file://\(.*\)','\1',""))|exe "bwipe ".fnameescape(expand("<amatch>"))|exe "silent doau BufReadPost ".fnameescape(netrw#RFC2396(expand("<amatch>")))
 else
  au BufReadCmd  file://*		exe "silent doau BufReadPre ".fnameescape(netrw#RFC2396(expand("<amatch>")))|exe 'e '.fnameescape(substitute(netrw#RFC2396(expand("<amatch>")),'file://\(.*\)','\1',""))|exe "bwipe ".fnameescape(expand("<amatch>"))|exe "silent doau BufReadPost ".fnameescape(netrw#RFC2396(expand("<amatch>")))
  au BufReadCmd  file://localhost/*	exe "silent doau BufReadPre ".fnameescape(netrw#RFC2396(expand("<amatch>")))|exe 'e '.fnameescape(substitute(netrw#RFC2396(expand("<amatch>")),'file://localhost/\(.*\)','\1',""))|exe "bwipe ".fnameescape(substitute(expand("<amatch>"),'file://\(\k\+@\)\=','',''))|exe "silent doau BufReadPost ".fnameescape(netrw#RFC2396(expand("<amatch>")))
 endif
 au BufReadCmd   ftp://*,rcp://*,scp://*,http://*,dav://*,davs://*,rsync://*,sftp://*	exe "silent doau BufReadPre ".fnameescape(expand("<amatch>"))|exe '2Nread '.fnameescape(expand("<amatch>"))|exe "silent doau BufReadPost ".fnameescape(expand("<amatch>"))
 au FileReadCmd  ftp://*,rcp://*,scp://*,http://*,dav://*,davs://*,rsync://*,sftp://*	exe "silent doau FileReadPre ".fnameescape(expand("<amatch>"))|exe 'Nread '.fnameescape(expand("<amatch>"))|exe "silent doau FileReadPost ".fnameescape(expand("<amatch>"))
 au BufWriteCmd  ftp://*,rcp://*,scp://*,dav://*,davs://*,rsync://*,sftp://*		exe "silent doau BufWritePre ".fnameescape(expand("<amatch>"))|exe 'Nwrite '.fnameescape(expand("<amatch>"))|exe "silent doau BufWritePost ".fnameescape(expand("<amatch>"))
 au FileWriteCmd ftp://*,rcp://*,scp://*,dav://*,davs://*,rsync://*,sftp://*		exe "silent doau FileWritePre ".fnameescape(expand("<amatch>"))|exe "'[,']".'Nwrite '.fnameescape(expand("<amatch>"))|exe "silent doau FileWritePost ".fnameescape(expand("<amatch>"))
 try
  au SourceCmd   ftp://*,rcp://*,scp://*,http://*,dav://*,davs://*,rsync://*,sftp://*	exe 'Nsource '.fnameescape(expand("<amatch>"))
 catch /^Vim\%((\a\+)\)\=:E216/
  au SourcePre   ftp://*,rcp://*,scp://*,http://*,dav://*,davs://*,rsync://*,sftp://*	exe 'Nsource '.fnameescape(expand("<amatch>"))
 endtry
augroup END

" Commands: :Nread, :Nwrite, :NetUserPass {{{2
com! -count=1 -nargs=*	Nread		call netrw#NetrwSavePosn()<bar>call netrw#NetRead(<count>,<f-args>)<bar>call netrw#NetrwRestorePosn()
com! -range=% -nargs=*	Nwrite		call netrw#NetrwSavePosn()<bar><line1>,<line2>call netrw#NetWrite(<f-args>)<bar>call netrw#NetrwRestorePosn()
com! -nargs=*		NetUserPass	call NetUserPass(<f-args>)
com! -nargs=*	        Nsource		call netrw#NetrwSavePosn()<bar>call netrw#NetSource(<f-args>)<bar>call netrw#NetrwRestorePosn()

" Commands: :Explore, :Sexplore, Hexplore, Vexplore {{{2
com! -nargs=* -bar -bang -count=0 -complete=dir	Explore		call netrw#Explore(<count>,0,0+<bang>0,<q-args>)
com! -nargs=* -bar -bang -count=0 -complete=dir	Sexplore	call netrw#Explore(<count>,1,0+<bang>0,<q-args>)
com! -nargs=* -bar -bang -count=0 -complete=dir	Hexplore	call netrw#Explore(<count>,1,2+<bang>0,<q-args>)
com! -nargs=* -bar -bang -count=0 -complete=dir	Vexplore	call netrw#Explore(<count>,1,4+<bang>0,<q-args>)
com! -nargs=* -bar       -count=0 -complete=dir	Texplore	call netrw#Explore(<count>,0,6        ,<q-args>)
com! -nargs=* -bar -bang			Nexplore	call netrw#Explore(-1,0,0,<q-args>)
com! -nargs=* -bar -bang			Pexplore	call netrw#Explore(-2,0,0,<q-args>)

" Commands: NetrwSettings {{{2
com! -nargs=0	NetrwSettings	call netrwSettings#NetrwSettings()
com! -bang	NetrwClean	call netrw#NetrwClean(<bang>0)

" Maps:
if !exists("g:netrw_nogx") && maparg('g','n') == ""
 if !hasmapto('<Plug>NetrwBrowseX')
  nmap <unique> gx <Plug>NetrwBrowseX
 endif
 nno <silent> <Plug>NetrwBrowseX :call netrw#NetrwBrowseX(expand("<cWORD>"),0)<cr>
endif

" ---------------------------------------------------------------------
" LocalBrowse: {{{2
fun! s:LocalBrowse(dirname)
  " unfortunate interaction -- debugging calls can't be used here;
  " the BufEnter event causes triggering when attempts to write to
  " the DBG buffer are made.
"  echomsg "dirname<".a:dirname.">"
  if has("amiga")
   " The check against '' is made for the Amiga, where the empty
   " string is the current directory and not checking would break
   " things such as the help command.
   if a:dirname != '' && isdirectory(a:dirname)
    silent! call netrw#LocalBrowseCheck(a:dirname)
   endif
  elseif isdirectory(a:dirname)
"   echomsg "dirname<".dirname."> isdir"
   silent! call netrw#LocalBrowseCheck(a:dirname)
  endif
  " not a directory, ignore it
endfun

" ---------------------------------------------------------------------
" NetrwStatusLine: {{{1
fun! NetrwStatusLine()
"  let g:stlmsg= "Xbufnr=".w:netrw_explore_bufnr." bufnr=".bufnr("%")." Xline#".w:netrw_explore_line." line#".line(".")
  if !exists("w:netrw_explore_bufnr") || w:netrw_explore_bufnr != bufnr("%") || !exists("w:netrw_explore_line") || w:netrw_explore_line != line(".") || !exists("w:netrw_explore_list")
   let &stl= s:netrw_explore_stl
   if exists("w:netrw_explore_bufnr")|unlet w:netrw_explore_bufnr|endif
   if exists("w:netrw_explore_line")|unlet w:netrw_explore_line|endif
   return ""
  else
   return "Match ".w:netrw_explore_mtchcnt." of ".w:netrw_explore_listlen
  endif
endfun

" ------------------------------------------------------------------------
" NetUserPass: set username and password for subsequent ftp transfer {{{1
"   Usage:  :call NetUserPass()			-- will prompt for userid and password
"	    :call NetUserPass("uid")		-- will prompt for password
"	    :call NetUserPass("uid","password") -- sets global userid and password
fun! NetUserPass(...)

 " get/set userid
 if a:0 == 0
"  call Dfunc("NetUserPass(a:0<".a:0.">)")
  if !exists("g:netrw_uid") || g:netrw_uid == ""
   " via prompt
   let g:netrw_uid= input('Enter username: ')
  endif
 else	" from command line
"  call Dfunc("NetUserPass(a:1<".a:1.">) {")
  let g:netrw_uid= a:1
 endif

 " get password
 if a:0 <= 1 " via prompt
"  call Decho("a:0=".a:0." case <=1:")
  let g:netrw_passwd= inputsecret("Enter Password: ")
 else " from command line
"  call Decho("a:0=".a:0." case >1: a:2<".a:2.">")
  let g:netrw_passwd=a:2
 endif
"  call Dret("NetUserPass")
endfun

" ------------------------------------------------------------------------
" Modelines And Restoration: {{{1
let &cpo= s:keepcpo
unlet s:keepcpo
" vim:ts=8 fdm=marker
autoload/netrw.vim	[[[1
8011
" netrw.vim: Handles file transfer and remote directory listing across
"            AUTOLOAD SECTION
" Date:		Oct 23, 2008
" Version:	134
" Maintainer:	Charles E Campbell, Jr <NdrOchip@ScampbellPfamily.AbizM-NOSPAM>
" GetLatestVimScripts: 1075 1 :AutoInstall: netrw.vim
" Copyright:    Copyright (C) 1999-2008 Charles E. Campbell, Jr. {{{1
"               Permission is hereby granted to use and distribute this code,
"               with or without modifications, provided that this copyright
"               notice is copied with it. Like anything else that's free,
"               netrw.vim, netrwPlugin.vim, and netrwSettings.vim are provided
"               *as is* and come with no warranty of any kind, either
"               expressed or implied. By using this plugin, you agree that
"               in no event will the copyright holder be liable for any damages
"               resulting from the use of this software.
"redraw!|call DechoSep()|call inputsave()|call input("Press <cr> to continue")|call inputrestore()
"
"  But be doers of the Word, and not only hearers, deluding your own selves {{{1
"  (James 1:22 RSV)
" =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
" Load Once: {{{1
if &cp || exists("g:loaded_netrw")
  finish
endif
let g:loaded_netrw = "v134"
if v:version < 702
 echohl WarningMsg
 echo "***warning*** this version of netrw needs vim 7.2"
 echohl Normal
 finish
endif
if !exists("s:NOTE")
 let s:NOTE    = 0
 let s:WARNING = 1
 let s:ERROR   = 2
endif

" sanity checks
if v:version < 700
 call netrw#ErrorMsg(s:WARNING,"you need vim version 7.0 or later for version ".g:loaded_netrw." of netrw",1)
 finish
endif

let s:keepcpo= &cpo
setlocal cpo&vim
"DechoTabOn
"call Decho("doing autoload/netrw.vim version ".g:loaded_netrw)

" ======================
"  Netrw Variables: {{{1
" ======================

" ---------------------------------------------------------------------
"  Netrw Constants: {{{2
if !exists("g:netrw_dirhist_cnt")
 let g:netrw_dirhist_cnt= 0
endif
if !exists("s:LONGLIST")
 let s:THINLIST = 0
 let s:LONGLIST = 1
 let s:WIDELIST = 2
 let s:TREELIST = 3
 let s:MAXLIST  = 4
endif

" ---------------------------------------------------------------------
" Default values for netrw's global protocol variables {{{2
if !exists("g:netrw_dav_cmd")
 if executable("cadaver")
  let g:netrw_dav_cmd	= "cadaver"
 elseif executable("curl")
  let g:netrw_dav_cmd	= "curl"
 else
  let g:netrw_dav_cmd   = ""
 endif
endif
if !exists("g:netrw_fetch_cmd")
 if executable("fetch")
  let g:netrw_fetch_cmd	= "fetch -o"
 else
  let g:netrw_fetch_cmd	= ""
 endif
endif
if !exists("g:netrw_ftp_cmd")
  let g:netrw_ftp_cmd	= "ftp"
endif
if !exists("g:netrw_http_cmd")
 if executable("elinks")
  let g:netrw_http_cmd = "elinks"
  if !exists("g:netrw_http_xcmd")
   let g:netrw_http_xcmd= "-dump >"
  endif
 elseif executable("links")
  let g:netrw_http_cmd = "links"
  if !exists("g:netrw_http_xcmd")
   let g:netrw_http_xcmd= "-dump >"
  endif
 elseif executable("curl")
  let g:netrw_http_cmd	= "curl"
  if !exists("g:netrw_http_xcmd")
   let g:netrw_http_xcmd= "-o"
  endif
 elseif executable("wget")
  let g:netrw_http_cmd	= "wget"
  if !exists("g:netrw_http_xcmd")
   let g:netrw_http_xcmd= "-q -O"
  endif
 elseif executable("fetch")
  let g:netrw_http_cmd	= "fetch"
  if !exists("g:netrw_http_xcmd")
   let g:netrw_http_xcmd= "-o"
  endif
 else
  let g:netrw_http_cmd	= ""
 endif
endif
if !exists("g:netrw_rcp_cmd")
  let g:netrw_rcp_cmd	= "rcp"
endif
if !exists("g:netrw_rsync_cmd")
  let g:netrw_rsync_cmd	= "rsync"
endif
if !exists("g:netrw_scp_cmd")
  let g:netrw_scp_cmd	= "scp -q"
endif
if !exists("g:netrw_sftp_cmd")
  let g:netrw_sftp_cmd	= "sftp"
endif
if !exists("g:netrw_ssh_cmd")
 let g:netrw_ssh_cmd= "ssh"
endif

if (has("win32") || has("win95") || has("win64") || has("win16"))
  \ && exists("g:netrw_use_nt_rcp")
  \ && g:netrw_use_nt_rcp
  \ && executable( $SystemRoot .'/system32/rcp.exe')
 let s:netrw_has_nt_rcp = 1
 let s:netrw_rcpmode    = '-b'
else
 let s:netrw_has_nt_rcp = 0
 let s:netrw_rcpmode    = ''
endif

" ---------------------------------------------------------------------
" Default values for netrw's global variables {{{2
" Cygwin Detection ------- {{{3
if !exists("g:netrw_cygwin")
 if has("win32") || has("win95") || has("win64") || has("win16")
  if &shell =~ '\%(\<bash\>\|\<zsh\>\)\%(\.exe\)\=$'
   let g:netrw_cygwin= 1
  else
   let g:netrw_cygwin= 0
  endif
 else
  let g:netrw_cygwin= 0
 endif
endif
" Default values - a-c ---------- {{{3
if !exists("g:netrw_alto")
 let g:netrw_alto= &sb
endif
if !exists("g:netrw_altv")
 let g:netrw_altv= &spr
endif
if !exists("g:netrw_browse_split")
 let g:netrw_browse_split= 0
endif
if !exists("g:netrw_chgwin")
 let g:netrw_chgwin    = -1
endif
if !exists("g:netrw_compress")
 let g:netrw_compress= "gzip"
endif
if !exists("g:netrw_ctags")
 let g:netrw_ctags= "ctags"
endif
if !exists("g:netrw_cursorline")
 let g:netrw_cursorline= 1
 let s:netrw_usercul   = &cursorline
 let s:netrw_usercuc   = &cursorcolumn
endif
" Default values - d-g ---------- {{{3
if !exists("g:netrw_dirhist_cnt")
 let g:netrw_dirhist_cnt= 0
endif
if !exists("g:netrw_decompress")
 let g:netrw_decompress= { ".gz" : "gunzip" , ".bz2" : "bunzip2" , ".zip" : "unzip" , ".tar" : "tar -xf"}
endif
if !exists("g:netrw_dirhistmax")
 let g:netrw_dirhistmax= 10
endif
if !exists("g:netrw_fastbrowse")
 let g:netrw_fastbrowse= 1
endif
if !exists("g:netrw_ftp_browse_reject")
 let g:netrw_ftp_browse_reject='^total\s\+\d\+$\|^Trying\s\+\d\+.*$\|^KERBEROS_V\d rejected\|^Security extensions not\|No such file\|: connect to address [0-9a-fA-F:]*: No route to host$'
endif
if !exists("g:netrw_ftp_list_cmd")
 if has("unix") || (exists("g:netrw_cygwin") && g:netrw_cygwin)
  let g:netrw_ftp_list_cmd     = "ls -lF"
  let g:netrw_ftp_timelist_cmd = "ls -tlF"
  let g:netrw_ftp_sizelist_cmd = "ls -slF"
 else
  let g:netrw_ftp_list_cmd     = "dir"
  let g:netrw_ftp_timelist_cmd = "dir"
  let g:netrw_ftp_sizelist_cmd = "dir"
 endif
endif
if !exists("g:netrw_ftpmode")
 let g:netrw_ftpmode= "binary"
endif
" Default values - h-lh ---------- {{{3
if !exists("g:netrw_hide")
 let g:netrw_hide= 1
endif
if !exists("g:netrw_ignorenetrc")
 if &shell =~ '\c\<\%(cmd\|4nt\)\.exe$'
  let g:netrw_ignorenetrc= 1
 else
  let g:netrw_ignorenetrc= 0
 endif
endif
if !exists("g:netrw_keepdir")
 let g:netrw_keepdir= 1
endif
if !exists("g:netrw_list_cmd")
 if g:netrw_scp_cmd =~ '^pscp' && executable("pscp")
  " provide a 'pscp' listing command
  if (has("win32") || has("win95") || has("win64") || has("win16")) && filereadable("c:\\private.ppk")
   let g:netrw_scp_cmd ="pscp -i C:\\private.ppk"
  endif
  let g:netrw_list_cmd= g:netrw_scp_cmd." -ls USEPORT HOSTNAME:"
 elseif executable(g:netrw_ssh_cmd)
  " provide a default listing command
  let g:netrw_list_cmd= g:netrw_ssh_cmd." USEPORT HOSTNAME ls -FLa"
 else
"  call Decho(g:netrw_ssh_cmd." is not executable")
  let g:netrw_list_cmd= ""
 endif
endif
if !exists("g:netrw_list_hide")
 let g:netrw_list_hide= ""
endif
" Default values - lh-lz ---------- {{{3
if !exists("g:netrw_localcopycmd")
 if has("win32") || has("win95") || has("win64") || has("win16")
  if g:netrw_cygwin
   let g:netrw_localcopycmd= "cp"
  else
   let g:netrw_localcopycmd= "copy"
  endif
 elseif has("unix") || has("macunix")
  let g:netrw_localcopycmd= "cp"
 else
  let g:netrw_localcopycmd= ""
 endif
endif
if !exists("g:netrw_local_mkdir")
 let g:netrw_local_mkdir= "mkdir"
endif
if !exists("g:netrw_localmovecmd")
 if has("win32") || has("win95") || has("win64") || has("win16")
  if g:netrw_cygwin
   let g:netrw_localmovecmd= "mv"
  else
   let g:netrw_localmovecmd= "move"
  endif
 elseif has("unix") || has("macunix")
  let g:netrw_localmovecmd= "mv"
 else
  let g:netrw_localmovecmd= ""
 endif
endif
if !exists("g:netrw_local_rmdir")
 let g:netrw_local_rmdir= "rmdir"
endif
if !exists("g:netrw_liststyle")
 let g:netrw_liststyle= s:THINLIST
endif
if g:netrw_liststyle < 0 || g:netrw_liststyle >= s:MAXLIST
 " sanity check
 let g:netrw_liststyle= s:THINLIST
endif
if g:netrw_liststyle == s:LONGLIST && g:netrw_scp_cmd !~ '^pscp'
 let g:netrw_list_cmd= g:netrw_list_cmd." -l"
endif
" Default values - m-r ---------- {{{3
if !exists("g:netrw_markfileesc")
 let g:netrw_markfileesc= '*./[\~'
endif
if !exists("g:netrw_maxfilenamelen")
 let g:netrw_maxfilenamelen= 32
endif
if !exists("g:netrw_menu")
 let g:netrw_menu= 1
endif
if !exists("g:netrw_mkdir_cmd")
 let g:netrw_mkdir_cmd= g:netrw_ssh_cmd." USEPORT HOSTNAME mkdir"
endif
if !exists("g:netrw_mousemaps")
 if exists("&mouse") && &mouse =~ '[anh]'
  let g:netrw_mousemaps= 1
 else
  let g:netrw_mousemaps= 0
 endif
endif
if !exists("g:netrw_retmap")
 let g:netrw_retmap= 0
endif
if !exists("g:netrw_preview")
 let g:netrw_preview= 0
endif
if !exists("g:netrw_scpport")
 let g:netrw_scpport= "-P"
endif
if !exists("g:netrw_sshport")
 let g:netrw_sshport= "-p"
endif
if !exists("g:netrw_rename_cmd")
 let g:netrw_rename_cmd= g:netrw_ssh_cmd." USEPORT HOSTNAME mv"
endif
if !exists("g:netrw_rm_cmd")
 let g:netrw_rm_cmd    = g:netrw_ssh_cmd." USEPORT HOSTNAME rm"
endif
if !exists("g:netrw_rmdir_cmd")
 let g:netrw_rmdir_cmd = g:netrw_ssh_cmd." USEPORT HOSTNAME rmdir"
endif
if !exists("g:netrw_rmf_cmd")
 let g:netrw_rmf_cmd    = g:netrw_ssh_cmd." USEPORT HOSTNAME rm -f"
endif
" Default values - s ---------- {{{3
 " set up shell quoting character
if exists("g:netrw_silent") && g:netrw_silent != 0
 let s:netrw_silentxfer= "silent "
else
 let s:netrw_silentxfer= ""
endif
if !exists("g:netrw_sort_by")
 " alternatives: date size
 let g:netrw_sort_by= "name"
endif
if !exists("g:netrw_sort_options")
 let g:netrw_sort_options= ""
endif
if !exists("g:netrw_sort_direction")
 " alternative: reverse  (z y x ...)
 let g:netrw_sort_direction= "normal"
endif
if !exists("g:netrw_sort_sequence")
 let g:netrw_sort_sequence= '[\/]$,\.h$,\.c$,\.cpp$,*,\.o$,\.obj$,\.info$,\.swp$,\.bak$,\~$'
endif
if !exists("g:netrw_special_syntax")
 let g:netrw_special_syntax= 0
endif
if !exists("g:netrw_ssh_browse_reject")
  let g:netrw_ssh_browse_reject='^total\s\+\d\+$'
endif
if !has("patch192")
 if !exists("g:netrw_use_noswf")
  let g:netrw_use_noswf= 1
 endif
else
  let g:netrw_use_noswf= 0
endif
" Default values - t-w ---------- {{{3
if !exists("g:netrw_timefmt")
 let g:netrw_timefmt= "%c"
endif
if !exists("g:netrw_xstrlen")
 let g:netrw_xstrlen= 1
endif
if !exists("g:NetrwTopLvlMenu")
 let g:NetrwTopLvlMenu= "Netrw."
endif
if !exists("g:netrw_use_errorwindow")
 let g:netrw_use_errorwindow= 1
endif
if !exists("g:netrw_win95ftp")
 let g:netrw_win95ftp= 1
endif
if !exists("g:netrw_winsize")
 let g:netrw_winsize= ""
endif
" ---------------------------------------------------------------------
" Default values for netrw's script variables: {{{2
if !exists("g:netrw_fname_escape")
 let g:netrw_fname_escape= ' ?&;%'
endif
if !exists("g:netrw_glob_escape")
  let g:netrw_glob_escape= '[]*?`{~$'
endif
if !exists("g:netrw_tmpfile_escape")
 let g:netrw_tmpfile_escape= ' &;'
endif
let s:netrw_map_escape = "<|\n\r\\\<C-V>\""

" BufEnter event ignored by decho when following variable is true
"  Has a side effect that doau BufReadPost doesn't work, so
"  files read by network transfer aren't appropriately highlighted.
"let g:decho_bufenter = 1	"Decho

" ==============================
"  Netrw Utility Functions: {{{1
" ==============================

" ------------------------------------------------------------------------
" s:NetrwOptionSave: save options and set to "standard" form {{{2
"  06/08/07 : removed call to NetrwSafeOptions(), either placed
"             immediately after NetrwOptionSave() calls in NetRead
"             and NetWrite, or after the s:NetrwEnew() call in
"             NetrwBrowse.
"             vt: normally its "w:" or "s:" (a variable type)
fun! s:NetrwOptionSave(vt)
"  call Dfunc("s:NetrwOptionSave(vt<".a:vt.">) win#".winnr()." buf#".bufnr("%")."<".bufname(bufnr("%")).">")

"  call Decho(a:vt."netrw_optionsave".(exists("{a:vt}netrw_optionsave")? ("=".{a:vt}netrw_optionsave) : " doesn't exist"))
  if !exists("{a:vt}netrw_optionsave")
   let {a:vt}netrw_optionsave= 1
  else
"   call Dret("s:NetrwOptionSave : options already saved")
   return
  endif
"  call Decho("fo=".&fo.(exists("&acd")? " acd=".&acd : " acd doesn't exist"))

  " Save current settings and current directory
  let s:yykeep          = @@
  if exists("&l:acd")
   let {a:vt}netrw_acdkeep  = &l:acd
  endif
  let {a:vt}netrw_aikeep    = &l:ai
  let {a:vt}netrw_awkeep    = &l:aw
  let {a:vt}netrw_cikeep    = &l:ci
  let {a:vt}netrw_cinkeep   = &l:cin
  let {a:vt}netrw_cinokeep  = &l:cino
  let {a:vt}netrw_comkeep   = &l:com
  let {a:vt}netrw_cpokeep   = &l:cpo
  if g:netrw_keepdir
   let {a:vt}netrw_dirkeep  = getcwd()
  endif
  let {a:vt}netrw_fokeep    = &l:fo           " formatoptions
  let {a:vt}netrw_gdkeep    = &l:gd           " gdefault
  let {a:vt}netrw_hidkeep   = &l:hidden
  let {a:vt}netrw_magickeep = &l:magic
  let {a:vt}netrw_repkeep   = &l:report
  let {a:vt}netrw_spellkeep = &l:spell
  let {a:vt}netrw_twkeep    = &l:tw           " textwidth
  let {a:vt}netrw_wigkeep   = &l:wig          " wildignore
  if has("win32") && !has("win95")
   let {a:vt}netrw_swfkeep  = &l:swf          " swapfile
  endif
  if &go =~ 'a' | silent! let {a:vt}netrw_regstar = @* | endif
  silent! let {a:vt}netrw_regslash= @/

"  call Dret("s:NetrwOptionSave : win#".winnr()." buf#".bufnr("%"))
endfun

" ------------------------------------------------------------------------
" s:NetrwOptionRestore: restore options {{{2
fun! s:NetrwOptionRestore(vt)
"  call Dfunc("s:NetrwOptionRestore(vt<".a:vt.">) win#".winnr()." buf#".bufnr("%"))
  if !exists("{a:vt}netrw_optionsave")
"   call Decho("ro=".&l:ro." ma=".&l:ma." mod=".&l:mod." wrap=".&l:wrap)
"   call Dret("s:NetrwOptionRestore : ".a:vt."netrw_optionsave doesn't exist")
   return
  endif
  unlet {a:vt}netrw_optionsave

  if exists("&acd")
   if exists("{a:vt}netrw_acdkeep")
"    call Decho("g:netrw_keepdir=".g:netrw_keepdir.": getcwd<".getcwd()."> acd=".&acd)
    let curdir = getcwd()
    let &l:acd = {a:vt}netrw_acdkeep
    unlet {a:vt}netrw_acdkeep
    if &l:acd
"     call Decho("exe keepjumps lcd ".fnameescape(curdir))  " NOTE: was g:netrw_fname_escape for some reason
     try
      if !exists("&l:acd") && !&l:acd
       exe 'keepjumps lcd '.fnameescape(curdir)
      endif
     catch /^Vim\%((\a\+)\)\=:E472/
      call netrw#ErrorMsg(s:ERROR,"unable to change directory to <".curdir."> (permissions?)",61)
     endtry
    endif
   endif
  endif
  if exists("{a:vt}netrw_aikeep")   |let &l:ai     = {a:vt}netrw_aikeep      |unlet {a:vt}netrw_aikeep   |endif
  if exists("{a:vt}netrw_awkeep")   |let &l:aw     = {a:vt}netrw_awkeep      |unlet {a:vt}netrw_awkeep   |endif
  if exists("{a:vt}netrw_cikeep")   |let &l:ci     = {a:vt}netrw_cikeep      |unlet {a:vt}netrw_cikeep   |endif
  if exists("{a:vt}netrw_cinkeep")  |let &l:cin    = {a:vt}netrw_cinkeep     |unlet {a:vt}netrw_cinkeep  |endif
  if exists("{a:vt}netrw_cinokeep") |let &l:cino   = {a:vt}netrw_cinokeep    |unlet {a:vt}netrw_cinokeep |endif
  if exists("{a:vt}netrw_comkeep")  |let &l:com    = {a:vt}netrw_comkeep     |unlet {a:vt}netrw_comkeep  |endif
  if exists("{a:vt}netrw_cpokeep")  |let &l:cpo    = {a:vt}netrw_cpokeep     |unlet {a:vt}netrw_cpokeep  |endif
  if exists("{a:vt}netrw_dirkeep") && isdirectory({a:vt}netrw_dirkeep) && g:netrw_keepdir
   let dirkeep = substitute({a:vt}netrw_dirkeep,'\\','/','g')
   if exists("{a:vt}netrw_dirkeep")  |exe "keepjumps lcd ".fnameescape(dirkeep)|unlet {a:vt}netrw_dirkeep  |endif
  endif
  if exists("{a:vt}netrw_fokeep")   |let &l:fo     = {a:vt}netrw_fokeep      |unlet {a:vt}netrw_fokeep   |endif
  if exists("{a:vt}netrw_gdkeep")   |let &l:gd     = {a:vt}netrw_gdkeep      |unlet {a:vt}netrw_gdkeep   |endif
  if exists("{a:vt}netrw_hidkeep")  |let &l:hidden = {a:vt}netrw_hidkeep     |unlet {a:vt}netrw_hidkeep  |endif
  if exists("{a:vt}netrw_magic")    |let &l:magic  = {a:vt}netrw_magic       |unlet {a:vt}netrw_magic    |endif
  if exists("{a:vt}netrw_repkeep")  |let &l:report = {a:vt}netrw_repkeep     |unlet {a:vt}netrw_repkeep  |endif
  if exists("{a:vt}netrw_spellkeep")|let &l:spell  = {a:vt}netrw_spellkeep   |unlet {a:vt}netrw_spellkeep|endif
  if exists("{a:vt}netrw_twkeep")   |let &l:tw     = {a:vt}netrw_twkeep      |unlet {a:vt}netrw_twkeep   |endif
  if exists("{a:vt}netrw_wigkeep")  |let &l:wig    = {a:vt}netrw_wigkeep     |unlet {a:vt}netrw_wigkeep  |endif
  if exists("s:yykeep")             |let  @@       = s:yykeep                |unlet s:yykeep             |endif
  if exists("{a:vt}netrw_swfkeep")
   if &directory == ""
    " user hasn't specified a swapfile directory;
    " netrw will temporarily set the swapfile directory
    " to the current directory as returned by getcwd().
    let &l:directory   = getcwd()
    silent! let &l:swf = {a:vt}netrw_swfkeep
    setlocal directory=
    unlet {a:vt}netrw_swfkeep
   elseif &l:swf != {a:vt}netrw_swfkeep
    " following line causes a Press ENTER in windows -- can't seem to work around it!!!
    silent! let &l:swf= {a:vt}netrw_swfkeep
    unlet {a:vt}netrw_swfkeep
   endif
  endif
  if exists("{a:vt}netrw_regstar") |silent! let @*= {a:vt}netrw_regstar |unlet {a:vt}netrw_regstar |endif
  if exists("{a:vt}netrw_regslash")|silent! let @/= {a:vt}netrw_regslash|unlet {a:vt}netrw_regslash|endif

"  call Decho("g:netrw_keepdir=".g:netrw_keepdir.": getcwd<".getcwd()."> acd=".&acd)
"  call Decho("fo=".&fo.(exists("&acd")? " acd=".&acd : " acd doesn't exist"))
"  call Decho("ro=".&l:ro." ma=".&l:ma." mod=".&l:mod." wrap=".&l:wrap)
"  call Dret("s:NetrwOptionRestore : win#".winnr()." buf#".bufnr("%"))
endfun

" ---------------------------------------------------------------------
" s:NetrwSafeOptions: sets options to help netrw do its job {{{2
fun! s:NetrwSafeOptions()
"  call Dfunc("s:NetrwSafeOptions() win#".winnr()." buf#".bufnr("%")."<".bufname(bufnr("%")).">")
"  call Decho("window's ft=".&ft)
  setlocal cino=
  setlocal com=
  setlocal cpo-=aA
  if exists("&acd") | setlocal noacd | endif
  setlocal nocin noai noci magic nospell nohid wig= noaw
  setlocal fo=nroql2
  setlocal tw=0
  setlocal report=10000
  setlocal isk+=@ isk+=* isk+=/
  if g:netrw_use_noswf && has("win32") && !has("win95")
   setlocal noswf
  endif
"  call Decho("fo=".&fo.(exists("&acd")? " acd=".&acd : " acd doesn't exist"))
"  call Dret("s:NetrwSafeOptions")
endfun

" ---------------------------------------------------------------------
" netrw#NetrwClean: remove netrw {{{2
" supports :NetrwClean  -- remove netrw from first directory on runtimepath
"          :NetrwClean! -- remove netrw from all directories on runtimepath
fun! netrw#NetrwClean(sys)
"  call Dfunc("netrw#NetrwClean(sys=".a:sys.")")

  if a:sys
   let choice= confirm("Remove personal and system copies of netrw?","&Yes\n&No")
  else
   let choice= confirm("Remove personal copy of netrw?","&Yes\n&No")
  endif
"  call Decho("choice=".choice)
  let diddel= 0
  let diddir= ""

  if choice == 1
   for dir in split(&rtp,',')
    if filereadable(dir."/plugin/netrwPlugin.vim")
"     call Decho("removing netrw-related files from ".dir)
     if s:NetrwDelete(dir."/plugin/netrwPlugin.vim")        |call netrw#ErrorMsg(1,"unable to remove ".dir."/plugin/netrwPlugin.vim",55)        |endif
     if s:NetrwDelete(dir."/autoload/netrwFileHandlers.vim")|call netrw#ErrorMsg(1,"unable to remove ".dir."/autoload/netrwFileHandlers.vim",55)|endif
     if s:NetrwDelete(dir."/autoload/netrwSettings.vim")    |call netrw#ErrorMsg(1,"unable to remove ".dir."/autoload/netrwSettings.vim",55)    |endif
     if s:NetrwDelete(dir."/autoload/netrw.vim")            |call netrw#ErrorMsg(1,"unable to remove ".dir."/autoload/netrw.vim",55)            |endif
     if s:NetrwDelete(dir."/syntax/netrw.vim")              |call netrw#ErrorMsg(1,"unable to remove ".dir."/syntax/netrw.vim",55)              |endif
     if s:NetrwDelete(dir."/syntax/netrwlist.vim")          |call netrw#ErrorMsg(1,"unable to remove ".dir."/syntax/netrwlist.vim",55)          |endif
     let diddir= dir
     let diddel= diddel + 1
     if !a:sys|break|endif
    endif
   endfor
  endif

   echohl WarningMsg
  if diddel == 0
   echomsg "netrw is either not installed or not removable"
  elseif diddel == 1
   echomsg "removed one copy of netrw from <".diddir.">"
  else
   echomsg "removed ".diddel." copies of netrw"
  endif
   echohl None

"  call Dret("netrw#NetrwClean")
endfun

" ------------------------------------------------------------------------
"  Netrw Transfer Functions: {{{1
" ===============================

" ------------------------------------------------------------------------
" netrw#NetRead: responsible for reading a file over the net {{{2
"   mode: =0 read remote file and insert before current line
"         =1 read remote file and insert after current line
"         =2 replace with remote file
"         =3 obtain file, but leave in temporary format
fun! netrw#NetRead(mode,...)
"  call Dfunc("netrw#NetRead(mode=".a:mode.",...) a:0=".a:0." ".g:loaded_netrw)

  " save options {{{3
  call s:NetrwOptionSave("w:")
  call s:NetrwSafeOptions()

  " interpret mode into a readcmd {{{3
  if     a:mode == 0 " read remote file before current line
   let readcmd = "0r"
  elseif a:mode == 1 " read file after current line
   let readcmd = "r"
  elseif a:mode == 2 " replace with remote file
   let readcmd = "%r"
  elseif a:mode == 3 " skip read of file (leave as temporary)
   let readcmd = "t"
  else
   exe a:mode
   let readcmd = "r"
  endif
  let ichoice = (a:0 == 0)? 0 : 1
"  call Decho("readcmd<".readcmd."> ichoice=".ichoice)

  " Get Temporary Filename {{{3
  let tmpfile= s:GetTempfile("")
  if tmpfile == ""
"   call Dret("netrw#NetRead : unable to get a tempfile!")
   return
  endif

  while ichoice <= a:0

   " attempt to repeat with previous host-file-etc
   if exists("b:netrw_lastfile") && a:0 == 0
"    call Decho("using b:netrw_lastfile<" . b:netrw_lastfile . ">")
    let choice = b:netrw_lastfile
    let ichoice= ichoice + 1

   else
    exe "let choice= a:" . ichoice
"    call Decho("no lastfile: choice<" . choice . ">")

    if match(choice,"?") == 0
     " give help
     echomsg 'NetRead Usage:'
     echomsg ':Nread machine:path                         uses rcp'
     echomsg ':Nread "machine path"                       uses ftp   with <.netrc>'
     echomsg ':Nread "machine id password path"           uses ftp'
     echomsg ':Nread dav://machine[:port]/path            uses cadaver'
     echomsg ':Nread fetch://machine/path                 uses fetch'
     echomsg ':Nread ftp://[user@]machine[:port]/path     uses ftp   autodetects <.netrc>'
     echomsg ':Nread http://[user@]machine/path           uses http  wget'
     echomsg ':Nread rcp://[user@]machine/path            uses rcp'
     echomsg ':Nread rsync://machine[:port]/path          uses rsync'
     echomsg ':Nread scp://[user@]machine[[:#]port]/path  uses scp'
     echomsg ':Nread sftp://[user@]machine[[:#]port]/path uses sftp'
     sleep 4
     break

    elseif match(choice,'^"') != -1
     " Reconstruct Choice if choice starts with '"'
"     call Decho("reconstructing choice")
     if match(choice,'"$') != -1
      " case "..."
      let choice=strpart(choice,1,strlen(choice)-2)
     else
       "  case "... ... ..."
      let choice      = strpart(choice,1,strlen(choice)-1)
      let wholechoice = ""

      while match(choice,'"$') == -1
       let wholechoice = wholechoice . " " . choice
       let ichoice     = ichoice + 1
       if ichoice > a:0
       	if !exists("g:netrw_quiet")
	 call netrw#ErrorMsg(s:ERROR,"Unbalanced string in filename '". wholechoice ."'",3)
	endif
"        call Dret("netrw#NetRead :2 getcwd<".getcwd().">")
        return
       endif
       let choice= a:{ichoice}
      endwhile
      let choice= strpart(wholechoice,1,strlen(wholechoice)-1) . " " . strpart(choice,0,strlen(choice)-1)
     endif
    endif
   endif

"   call Decho("choice<" . choice . ">")
   let ichoice= ichoice + 1

   " Determine method of read (ftp, rcp, etc) {{{3
   call s:NetrwMethod(choice)
   if !exists("b:netrw_method") || b:netrw_method < 0
"    call Dfunc("netrw#NetRead : unsupported method")
    return
   endif
   let tmpfile= s:GetTempfile(b:netrw_fname) " apply correct suffix

   " Check if NetrwBrowse() should be handling this request
"   call Decho("checking if NetrwBrowse() should handle choice<".choice."> with netrw_list_cmd<".g:netrw_list_cmd.">")
   if choice =~ "^.*[\/]$" && b:netrw_method != 5 && choice !~ '^http://'
"    call Decho("yes, choice matches '^.*[\/]$'")
    keepjumps call s:NetrwBrowse(0,choice)
"    call Dret("netrw#NetRead :3 getcwd<".getcwd().">")
    return
   endif

   " ============
   " Perform Protocol-Based Read {{{3
   " ===========================
   if exists("g:netrw_silent") && g:netrw_silent == 0 && &ch >= 1
    echo "(netrw) Processing your read request..."
   endif

   ".........................................
   " rcp:  NetRead Method #1 {{{3
   if  b:netrw_method == 1 " read with rcp
"    call Decho("read via rcp (method #1)")
   " ER: nothing done with g:netrw_uid yet?
   " ER: on Win2K" rcp machine[.user]:file tmpfile
   " ER: if machine contains '.' adding .user is required (use $USERNAME)
   " ER: the tmpfile is full path: rcp sees C:\... as host C
   if s:netrw_has_nt_rcp == 1
    if exists("g:netrw_uid") &&	( g:netrw_uid != "" )
     let uid_machine = g:netrw_machine .'.'. g:netrw_uid
    else
     " Any way needed it machine contains a '.'
     let uid_machine = g:netrw_machine .'.'. $USERNAME
    endif
   else
    if exists("g:netrw_uid") &&	( g:netrw_uid != "" )
     let uid_machine = g:netrw_uid .'@'. g:netrw_machine
    else
     let uid_machine = g:netrw_machine
    endif
   endif
"   call Decho("executing: !".g:netrw_rcp_cmd." ".s:netrw_rcpmode." ".shellescape(uid_machine.":".b:netrw_fname,1)." ".shellescape(tmpfile,1))
   exe s:netrw_silentxfer."!".g:netrw_rcp_cmd." ".s:netrw_rcpmode." ".shellescape(uid_machine.":".b:netrw_fname,1)." ".shellescape(tmpfile,1)
   let result           = s:NetrwGetFile(readcmd, tmpfile, b:netrw_method)
   let b:netrw_lastfile = choice

   ".........................................
   " ftp + <.netrc>:  NetRead Method #2 {{{3
   elseif b:netrw_method  == 2		" read with ftp + <.netrc>
"     call Decho("read via ftp+.netrc (method #2)")
     let netrw_fname= b:netrw_fname
     call s:SaveBufVars()|new|call s:RestoreBufVars()
     let filtbuf= bufnr("%")
     setlocal ff=unix
     put =g:netrw_ftpmode
"     call Decho("filter input: ".getline(line("$")))
     if exists("g:netrw_ftpextracmd")
      put =g:netrw_ftpextracmd
"      call Decho("filter input: ".getline(line("$")))
     endif
     call setline(line("$")+1,'get "'.netrw_fname.'" '.tmpfile)
"     call Decho("filter input: ".getline(line("$")))
     if exists("g:netrw_port") && g:netrw_port != ""
"      call Decho("executing: %!".g:netrw_ftp_cmd." -i ".shellescape(g:netrw_machine." ".g:netrw_port,1))
      exe s:netrw_silentxfer."%!".g:netrw_ftp_cmd." -i ".shellescape(g:netrw_machine." ".g:netrw_port,1)
     else
"      call Decho("executing: %!".g:netrw_ftp_cmd." -i ".shellescape(g:netrw_machine,1))
      exe s:netrw_silentxfer."%!".g:netrw_ftp_cmd." -i ".shellescape(g:netrw_machine,1)
     endif
     " If the result of the ftp operation isn't blank, show an error message (tnx to Doug Claar)
     if getline(1) !~ "^$" && !exists("g:netrw_quiet") && getline(1) !~ '^Trying '
      let debugkeep = &debug
      setlocal debug=msg
      call netrw#ErrorMsg(s:ERROR,getline(1),4)
      let &debug    = debugkeep
     endif
     call s:SaveBufVars()
     bd!
     if bufname("%") == "" && getline("$") == "" && line('$') == 1
      " needed when one sources a file in a nolbl setting window via ftp
      q!
     endif
     call s:RestoreBufVars()
     let result           = s:NetrwGetFile(readcmd, tmpfile, b:netrw_method)
     let b:netrw_lastfile = choice

   ".........................................
   " ftp + machine,id,passwd,filename:  NetRead Method #3 {{{3
   elseif b:netrw_method == 3		" read with ftp + machine, id, passwd, and fname
    " Construct execution string (four lines) which will be passed through filter
"    call Decho("read via ftp+mipf (method #3)")
    let netrw_fname= escape(b:netrw_fname,g:netrw_fname_escape)
    call s:SaveBufVars()|new|call s:RestoreBufVars()
    let filtbuf= bufnr("%")
    setlocal ff=unix
    if exists("g:netrw_port") && g:netrw_port != ""
     put ='open '.g:netrw_machine.' '.g:netrw_port
"     call Decho("filter input: ".getline('.'))
    else
     put ='open '.g:netrw_machine
"     call Decho("filter input: ".getline('.'))
    endif

    if exists("g:netrw_ftp") && g:netrw_ftp == 1
     put =g:netrw_uid
"     call Decho("filter input: ".getline('.'))
     put ='\"'.s:netrw_passwd.'\"'
"     call Decho("filter input: ".getline('.'))
    else
     put ='user \"'.g:netrw_uid.'\" \"'.s:netrw_passwd.'\"'
"     call Decho("filter input: ".getline('.'))
    endif

    if exists("g:netrw_ftpmode") && g:netrw_ftpmode != ""
     put =g:netrw_ftpmode
"     call Decho("filter input: ".getline('.'))
    endif
    if exists("g:netrw_ftpextracmd")
     put =g:netrw_ftpextracmd
"     call Decho("filter input: ".getline('.'))
    endif
    put ='get \"'.netrw_fname.'\" '.tmpfile
"    call Decho("filter input: ".getline('.'))

    " perform ftp:
    " -i       : turns off interactive prompting from ftp
    " -n  unix : DON'T use <.netrc>, even though it exists
    " -n  win32: quit being obnoxious about password
    norm! 1Gdd
"    call Decho("executing: %!".g:netrw_ftp_cmd." -i -n")
    exe s:netrw_silentxfer."%!".g:netrw_ftp_cmd." -i -n"
    " If the result of the ftp operation isn't blank, show an error message (tnx to Doug Claar)
    if getline(1) !~ "^$"
"     call Decho("error<".getline(1).">")
     if !exists("g:netrw_quiet")
      call netrw#ErrorMsg(s:ERROR,getline(1),5)
     endif
    endif
    call s:SaveBufVars()|bd!|call s:RestoreBufVars()
    let result           = s:NetrwGetFile(readcmd, tmpfile, b:netrw_method)
    let b:netrw_lastfile = choice

   ".........................................
   " scp: NetRead Method #4 {{{3
   elseif     b:netrw_method  == 4	" read with scp
"    call Decho("read via scp (method #4)")
    if exists("g:netrw_port") && g:netrw_port != ""
     let useport= " ".g:netrw_scpport." ".g:netrw_port
    else
     let useport= ""
    endif
"    call Decho("exe s:netrw_silentxfer.!".g:netrw_scp_cmd.useport." ".shellescape(g:netrw_machine.":".b:netrw_fname,1)." ".shellescape(tmpfile,1))
    exe s:netrw_silentxfer."!".g:netrw_scp_cmd.useport." ".shellescape(g:netrw_machine.":".b:netrw_fname,1)." ".shellescape(tmpfile,1)
    let result           = s:NetrwGetFile(readcmd, tmpfile, b:netrw_method)
    let b:netrw_lastfile = choice

   ".........................................
   " http: NetRead Method #5 (wget) {{{3
   elseif     b:netrw_method  == 5
"    call Decho("read via http (method #5)")
    if g:netrw_http_cmd == ""
     if !exists("g:netrw_quiet")
      call netrw#ErrorMsg(s:ERROR,"neither the wget nor the fetch command is available",6)
     endif
"     call Dret("netrw#NetRead :4 getcwd<".getcwd().">")
     return
    endif

    if match(b:netrw_fname,"#") == -1 || exists("g:netrw_http_xcmd")
     " using g:netrw_http_cmd (usually elinks, links, curl, wget, or fetch)
"     call Decho('using '.g:netrw_http_cmd.' (# not in b:netrw_fname<'.b:netrw_fname.">)")
     if exists("g:netrw_http_xcmd")
"      call Decho("exe ".s:netrw_silentxfer."!".g:netrw_http_cmd." ".shellescape("http://".g:netrw_machine.b:netrw_fname,1)." ".g:netrw_http_xcmd." ".shellescape(tmpfile,1))
      exe s:netrw_silentxfer."!".g:netrw_http_cmd." ".shellescape("http://".g:netrw_machine.b:netrw_fname,1)." ".g:netrw_http_xcmd." ".shellescape(tmpfile,1)
     else
"      call Decho("exe ".s:netrw_silentxfer."!".g:netrw_http_cmd." ".shellescape(tmpfile,1)." ".shellescape("http://".g:netrw_machine.b:netrw_fname,1))
      exe s:netrw_silentxfer."!".g:netrw_http_cmd." ".shellescape(tmpfile,1)." ".shellescape("http://".g:netrw_machine.b:netrw_fname,1)
     endif
     let result = s:NetrwGetFile(readcmd, tmpfile, b:netrw_method)

    else
     " wget/curl/fetch plus a jump to an in-page marker (ie. http://abc/def.html#aMarker)
"     call Decho(("wget/curl plus jump (# in b:netrw_fname<".b:netrw_fname.">)")
     let netrw_html= substitute(b:netrw_fname,"#.*$","","")
     let netrw_tag = substitute(b:netrw_fname,"^.*#","","")
"     call Decho("netrw_html<".netrw_html.">")
"     call Decho("netrw_tag <".netrw_tag.">")
"     call Decho("exe ".s:netrw_silentxfer."!".g:netrw_http_cmd." ".shellescape(tmpfile,1)." ".shellescape("http://".g:netrw_machine.netrw_html,1))
     exe s:netrw_silentxfer."!".g:netrw_http_cmd." ".shellescape(tmpfile,1)." ".shellescape("http://".g:netrw_machine.netrw_html,1)
     let result = s:NetrwGetFile(readcmd, tmpfile, b:netrw_method)
"     call Decho('<\s*a\s*name=\s*"'.netrw_tag.'"/')
     exe 'norm! 1G/<\s*a\s*name=\s*"'.netrw_tag.'"/'."\<CR>"
    endif
    let b:netrw_lastfile = choice
    setlocal ro

   ".........................................
   " dav: NetRead Method #6 {{{3
   elseif     b:netrw_method  == 6
"    call Decho("read via cadaver (method #6)")

    if !executable(g:netrw_dav_cmd)
     call netrw#ErrorMsg(s:ERROR,g:netrw_dav_cmd." is not executable",73)
"     call Dret("netrw#NetRead : ".g:netrw_dav_cmd." not executable")
     return
    endif
    if g:netrw_dav_cmd =~ "curl"
"     call Decho("exe ".s:netrw_silentxfer."!".g:netrw_dav_cmd." ".shellescape("dav://".g:netrw_machine.b:netrw_fname,1)." ".shellescape(tmpfile,1))
     exe s:netrw_silentxfer."!".g:netrw_dav_cmd." ".shellescape("dav://".g:netrw_machine.b:netrw_fname,1)." ".shellescape(tmpfile,1)
    else
     " Construct execution string (four lines) which will be passed through filter
     let netrw_fname= escape(b:netrw_fname,g:netrw_fname_escape)
     new
     setlocal ff=unix
     if exists("g:netrw_port") && g:netrw_port != ""
      put ='open '.g:netrw_machine.' '.g:netrw_port
     else
      put ='open '.g:netrw_machine
     endif
     put ='user '.g:netrw_uid.' '.s:netrw_passwd
     put ='get '.netrw_fname.' '.tmpfile
     put ='quit'

     " perform cadaver operation:
     norm! 1Gdd
"    call Decho("executing: %!".g:netrw_dav_cmd)
     exe s:netrw_silentxfer."%!".g:netrw_dav_cmd
     bd!
    endif
    let result           = s:NetrwGetFile(readcmd, tmpfile, b:netrw_method)
    let b:netrw_lastfile = choice

   ".........................................
   " rsync: NetRead Method #7 {{{3
   elseif     b:netrw_method  == 7
"    call Decho("read via rsync (method #7)")
"    call Decho("exe ".s:netrw_silentxfer."!".g:netrw_rsync_cmd." ".shellescape(g:netrw_machine.":".b:netrw_fname,1)." ".shellescape(tmpfile,1))
    exe s:netrw_silentxfer."!".g:netrw_rsync_cmd." ".shellescape(g:netrw_machine.":".b:netrw_fname,1)." ".shellescape(tmpfile,1)
    let result		 = s:NetrwGetFile(readcmd,tmpfile, b:netrw_method)
    let b:netrw_lastfile = choice

   ".........................................
   " fetch: NetRead Method #8 {{{3
   "    fetch://[user@]host[:http]/path
   elseif     b:netrw_method  == 8
"    call Decho("read via fetch (method #8)")
    if g:netrw_fetch_cmd == ""
     if !exists("g:netrw_quiet")
      call netrw#ErrorMsg(s:ERROR,"fetch command not available",7)
     endif
"     call Dret("NetRead")
    endif
    if exists("g:netrw_option") && g:netrw_option == ":http"
     let netrw_option= "http"
    else
     let netrw_option= "ftp"
    endif
"    call Decho("read via fetch for ".netrw_option)

    if exists("g:netrw_uid") && g:netrw_uid != "" && exists("s:netrw_passwd") && s:netrw_passwd != ""
"     call Decho("exe ".s:netrw_silentxfer."!".g:netrw_fetch_cmd." ".shellescape(tmpfile,1)." ".shellescape(netrw_option."://".g:netrw_uid.':'.s:netrw_passwd.'@'.g:netrw_machine."/".b:netrw_fname,1))
     exe s:netrw_silentxfer."!".g:netrw_fetch_cmd." ".shellescape(tmpfile,1)." ".shellescape(netrw_option."://".g:netrw_uid.':'.s:netrw_passwd.'@'.g:netrw_machine."/".b:netrw_fname,1)
    else
"     call Decho("exe ".s:netrw_silentxfer."!".g:netrw_fetch_cmd." ".shellescape(tmpfile,1)." ".shellescape(netrw_option."://".g:netrw_machine."/".b:netrw_fname,1))
     exe s:netrw_silentxfer."!".g:netrw_fetch_cmd." ".shellescape(tmpfile,1)." ".shellescape(netrw_option."://".g:netrw_machine."/".b:netrw_fname,1)
    endif

    let result		= s:NetrwGetFile(readcmd,tmpfile, b:netrw_method)
    let b:netrw_lastfile = choice
    setlocal ro

   ".........................................
   " sftp: NetRead Method #9 {{{3
   elseif     b:netrw_method  == 9
"    call Decho("read via sftp (method #9)")
"    call Decho("exe ".s:netrw_silentxfer."!".g:netrw_sftp_cmd." ".shellescape(g:netrw_machine.":".b:netrw_fname,1)." ".tmpfile)
    exe s:netrw_silentxfer."!".g:netrw_sftp_cmd." ".shellescape(g:netrw_machine.":".b:netrw_fname,1)." ".tmpfile
    let result		= s:NetrwGetFile(readcmd, tmpfile, b:netrw_method)
    let b:netrw_lastfile = choice

   ".........................................
   " Complain {{{3
   else
    call netrw#ErrorMsg(s:WARNING,"unable to comply with your request<" . choice . ">",8)
   endif
  endwhile

  " cleanup {{{3
  if exists("b:netrw_method")
"   call Decho("cleanup b:netrw_method and b:netrw_fname")
   unlet b:netrw_method
   unlet b:netrw_fname
  endif
  if s:FileReadable(tmpfile) && tmpfile !~ '.tar.bz2$' && tmpfile !~ '.tar.gz$' && tmpfile !~ '.zip' && tmpfile !~ '.tar' && readcmd != 't'
"   call Decho("cleanup by deleting tmpfile<".tmpfile.">")
   call s:NetrwDelete(fnameescape(tmpfile))
  endif
  call s:NetrwOptionRestore("w:")

"  call Dret("netrw#NetRead :5 getcwd<".getcwd().">")
endfun

" ------------------------------------------------------------------------
" netrw#NetWrite: responsible for writing a file over the net {{{2
fun! netrw#NetWrite(...) range
"  call Dfunc("netrw#NetWrite(a:0=".a:0.") ".g:loaded_netrw)

  " option handling
  let mod= 0
  call s:NetrwOptionSave("w:")
  call s:NetrwSafeOptions()

  " Get Temporary Filename {{{3
  let tmpfile= s:GetTempfile("")
  if tmpfile == ""
"   call Dret("netrw#NetWrite : unable to get a tempfile!")
   return
  endif

  if a:0 == 0
   let ichoice = 0
  else
   let ichoice = 1
  endif

  let curbufname= expand("%")
"  call Decho("curbufname<".curbufname.">")
  if &binary
   " For binary writes, always write entire file.
   " (line numbers don't really make sense for that).
   " Also supports the writing of tar and zip files.
"   call Decho("(write entire file) silent exe w! ".fnameescape(v:cmdarg)." ".fnameescape(tmpfile))
   silent exe "w! ".fnameescape(v:cmdarg)." ".fnameescape(tmpfile)
  elseif g:netrw_cygwin
   " write (selected portion of) file to temporary
   let cygtmpfile= substitute(tmpfile,'/cygdrive/\(.\)','\1:','')
"   call Decho("(write selected portion) silent exe ".a:firstline."," . a:lastline . "w! ".fnameescape(v:cmdarg)." ".fnameescape(cygtmpfile))
   silent exe a:firstline."," . a:lastline . "w! ".fnameescape(v:cmdarg)." ".fnameescape(cygtmpfile)
  else
   " write (selected portion of) file to temporary
"   call Decho("(write selected portion) silent exe ".a:firstline."," . a:lastline . "w! ".fnameescape(v:cmdarg)." ".fnameescape(tmpfile))
   silent exe a:firstline."," . a:lastline . "w! ".fnameescape(v:cmdarg)." ".fnameescape(tmpfile)
  endif

  if curbufname == ""
   " if the file is [No Name], and one attempts to Nwrite it, the buffer takes
   " on the temporary file's name.  Deletion of the temporary file during
   " cleanup then causes an error message.
   0file!
  endif

  " While choice loop: {{{3
  while ichoice <= a:0

   " Process arguments: {{{4
   " attempt to repeat with previous host-file-etc
   if exists("b:netrw_lastfile") && a:0 == 0
"    call Decho("using b:netrw_lastfile<" . b:netrw_lastfile . ">")
    let choice = b:netrw_lastfile
    let ichoice= ichoice + 1
   else
    exe "let choice= a:" . ichoice

    " Reconstruct Choice if choice starts with '"'
    if match(choice,"?") == 0
     echomsg 'NetWrite Usage:"'
     echomsg ':Nwrite machine:path                        uses rcp'
     echomsg ':Nwrite "machine path"                      uses ftp with <.netrc>'
     echomsg ':Nwrite "machine id password path"          uses ftp'
     echomsg ':Nwrite dav://[user@]machine/path           uses cadaver'
     echomsg ':Nwrite fetch://[user@]machine/path         uses fetch'
     echomsg ':Nwrite ftp://machine[#port]/path           uses ftp  (autodetects <.netrc>)'
     echomsg ':Nwrite rcp://machine/path                  uses rcp'
     echomsg ':Nwrite rsync://[user@]machine/path         uses rsync'
     echomsg ':Nwrite scp://[user@]machine[[:#]port]/path uses scp'
     echomsg ':Nwrite sftp://[user@]machine/path          uses sftp'
     sleep 4
     break

    elseif match(choice,"^\"") != -1
     if match(choice,"\"$") != -1
       " case "..."
      let choice=strpart(choice,1,strlen(choice)-2)
     else
      "  case "... ... ..."
      let choice      = strpart(choice,1,strlen(choice)-1)
      let wholechoice = ""

      while match(choice,"\"$") == -1
       let wholechoice= wholechoice . " " . choice
       let ichoice    = ichoice + 1
       if choice > a:0
       	if !exists("g:netrw_quiet")
	 call netrw#ErrorMsg(s:ERROR,"Unbalanced string in filename '". wholechoice ."'",13)
	endif
"        call Dret("netrw#NetWrite")
        return
       endif
       let choice= a:{ichoice}
      endwhile
      let choice= strpart(wholechoice,1,strlen(wholechoice)-1) . " " . strpart(choice,0,strlen(choice)-1)
     endif
    endif
   endif
   let ichoice= ichoice + 1
"   call Decho("choice<" . choice . "> ichoice=".ichoice)

   " Determine method of write (ftp, rcp, etc) {{{4
   call s:NetrwMethod(choice)
   if !exists("b:netrw_method") || b:netrw_method < 0
"    call Dfunc("netrw#NetWrite : unsupported method")
    return
   endif

   " =============
   " Perform Protocol-Based Write {{{4
   " ============================
   if exists("g:netrw_silent") && g:netrw_silent == 0 && &ch >= 1
    echo "(netrw) Processing your write request..."
"    call Decho("(netrw) Processing your write request...")
   endif

   ".........................................
   " rcp: NetWrite Method #1 {{{4
   if  b:netrw_method == 1
"    call Decho("write via rcp (method #1)")
    if s:netrw_has_nt_rcp == 1
     if exists("g:netrw_uid") &&  ( g:netrw_uid != "" )
      let uid_machine = g:netrw_machine .'.'. g:netrw_uid
     else
      let uid_machine = g:netrw_machine .'.'. $USERNAME
     endif
    else
     if exists("g:netrw_uid") &&  ( g:netrw_uid != "" )
      let uid_machine = g:netrw_uid .'@'. g:netrw_machine
     else
      let uid_machine = g:netrw_machine
     endif
    endif
"    call Decho("executing: !".g:netrw_rcp_cmd." ".s:netrw_rcpmode." ".shellescape(tmpfile,1)." ".shellescape(uid_machine.":".b:netrw_fname,1))
    exe s:netrw_silentxfer."!".g:netrw_rcp_cmd." ".s:netrw_rcpmode." ".shellescape(tmpfile,1)." ".shellescape(uid_machine.":".b:netrw_fname,1)
    let b:netrw_lastfile = choice

   ".........................................
   " ftp + <.netrc>: NetWrite Method #2 {{{4
   elseif b:netrw_method == 2
"    call Decho("write via ftp+.netrc (method #2)")
    let netrw_fname= b:netrw_fname
    new
"    call Decho("filter input window#".winnr())
    setlocal ff=unix
    put =g:netrw_ftpmode
"    call Decho("filter input: ".getline('$'))
    if exists("g:netrw_ftpextracmd")
     put =g:netrw_ftpextracmd
"     call Decho("filter input: ".getline("$"))
    endif
    call setline(line("$")+1,'put "'.tmpfile.'" "'.netrw_fname.'"')
"    call Decho("filter input: ".getline("$"))
    if exists("g:netrw_port") && g:netrw_port != ""
"     call Decho("executing: %!".g:netrw_ftp_cmd." -i ".shellescape(g:netrw_machine,1)." ".shellescape(g:netrw_port,1))
     exe s:netrw_silentxfer."%!".g:netrw_ftp_cmd." -i ".shellescape(g:netrw_machine,1)." ".shellescape(g:netrw_port,1)
    else
"     call Decho("filter input window#".winnr())
"     call Decho("executing: %!".g:netrw_ftp_cmd." -i ".shellescape(g:netrw_machine,1))
     exe s:netrw_silentxfer."%!".g:netrw_ftp_cmd." -i ".shellescape(g:netrw_machine,1)
    endif
    " If the result of the ftp operation isn't blank, show an error message (tnx to Doug Claar)
    if getline(1) !~ "^$"
     if !exists("g:netrw_quiet")
      call netrw#ErrorMsg(s:ERROR,getline(1),14)
     endif
     let mod=1
    endif
    bd!
    let b:netrw_lastfile = choice

   ".........................................
   " ftp + machine, id, passwd, filename: NetWrite Method #3 {{{4
   elseif b:netrw_method == 3
    " Construct execution string (four lines) which will be passed through filter
"    call Decho("read via ftp+mipf (method #3)")
    let netrw_fname= b:netrw_fname
    new
    setlocal ff=unix
    if exists("g:netrw_port") && g:netrw_port != ""
     put ='open '.g:netrw_machine.' '.g:netrw_port
"     call Decho("filter input: ".getline('.'))
    else
     put ='open '.g:netrw_machine
"     call Decho("filter input: ".getline('.'))
    endif
    if exists("g:netrw_ftp") && g:netrw_ftp == 1
     put =g:netrw_uid
"     call Decho("filter input: ".getline('.'))
     put ='\"'.s:netrw_passwd.'\"'
"     call Decho("filter input: ".getline('.'))
    else
     put ='user \"'.g:netrw_uid.'\" \"'.s:netrw_passwd.'\"'
"     call Decho("filter input: ".getline('.'))
    endif
    put ='put \"'.tmpfile.'\" \"'.netrw_fname.'\"'
"    call Decho("filter input: ".getline('.'))
    " save choice/id/password for future use
    let b:netrw_lastfile = choice

    " perform ftp:
    " -i       : turns off interactive prompting from ftp
    " -n  unix : DON'T use <.netrc>, even though it exists
    " -n  win32: quit being obnoxious about password
    norm! 1Gdd
"    call Decho("executing: %!".g:netrw_ftp_cmd." -i -n")
    exe s:netrw_silentxfer."%!".g:netrw_ftp_cmd." -i -n"
    " If the result of the ftp operation isn't blank, show an error message (tnx to Doug Claar)
    if getline(1) !~ "^$"
     if  !exists("g:netrw_quiet")
      call netrw#ErrorMsg(s:ERROR,getline(1),15)
     endif
     let mod=1
    endif
    bd!

   ".........................................
   " scp: NetWrite Method #4 {{{4
   elseif     b:netrw_method == 4
"    call Decho("write via scp (method #4)")
    if exists("g:netrw_port") && g:netrw_port != ""
     let useport= " ".g:netrw_scpport." ".fnameescape(g:netrw_port)
    else
     let useport= ""
    endif
"    call Decho("exe ".s:netrw_silentxfer."!".g:netrw_scp_cmd.useport." ".shellescape(tmpfile,1)." ".shellescape(g:netrw_machine.":".b:netrw_fname,1))
    exe s:netrw_silentxfer."!".g:netrw_scp_cmd.useport." ".shellescape(tmpfile,1)." ".shellescape(g:netrw_machine.":".b:netrw_fname,1)
    let b:netrw_lastfile = choice

   ".........................................
   " http: NetWrite Method #5 {{{4
   elseif     b:netrw_method == 5
"    call Decho("write via http (method #5)")
    if !exists("g:netrw_quiet")
     call netrw#ErrorMsg(s:ERROR,"currently <netrw.vim> does not support writing using http:",16)
    endif

   ".........................................
   " dav: NetWrite Method #6 (cadaver) {{{4
   elseif     b:netrw_method == 6
"    call Decho("write via cadaver (method #6)")

    " Construct execution string (four lines) which will be passed through filter
    let netrw_fname= escape(b:netrw_fname,g:netrw_fname_escape)
    new
    setlocal ff=unix
    if exists("g:netrw_port") && g:netrw_port != ""
     put ='open '.g:netrw_machine.' '.g:netrw_port
    else
     put ='open '.g:netrw_machine
    endif
    if exists("g:netrw_uid") && exists("s:netrw_passwd")
     put ='user '.g:netrw_uid.' '.s:netrw_passwd
    endif
    put ='put '.tmpfile.' '.netrw_fname

    " perform cadaver operation:
    norm! 1Gdd
"    call Decho("executing: %!".g:netrw_dav_cmd)
    exe s:netrw_silentxfer."%!".g:netrw_dav_cmd
    bd!
    let b:netrw_lastfile = choice

   ".........................................
   " rsync: NetWrite Method #7 {{{4
   elseif     b:netrw_method == 7
"    call Decho("write via rsync (method #7)")
"    call Decho("executing: !".g:netrw_rsync_cmd." ".shellescape(tmpfile,1)." ".shellescape(g:netrw_machine.":".b:netrw_fname,1))
    exe s:netrw_silentxfer."!".g:netrw_rsync_cmd." ".shellescape(tmpfile,1)." ".shellescape(g:netrw_machine.":".b:netrw_fname,1)
    let b:netrw_lastfile = choice

   ".........................................
   " sftp: NetWrite Method #9 {{{4
   elseif     b:netrw_method == 9
"    call Decho("read via sftp (method #9)")
    let netrw_fname= escape(b:netrw_fname,g:netrw_fname_escape)
    if exists("g:netrw_uid") &&  ( g:netrw_uid != "" )
     let uid_machine = g:netrw_uid .'@'. g:netrw_machine
    else
     let uid_machine = g:netrw_machine
    endif
    new
    setlocal ff=unix
    put ='put \"'.escape(tmpfile,'\').'\" '.netrw_fname
"    call Decho("filter input: ".getline('.'))
    norm! 1Gdd
"    call Decho("executing: %!".g:netrw_sftp_cmd.' '.shellescape(uid_machine,1))
    exe s:netrw_silentxfer."%!".g:netrw_sftp_cmd.' '.shellescape(uid_machine,1)
    bd!
    let b:netrw_lastfile= choice

   ".........................................
   " Complain {{{4
   else
    call netrw#ErrorMsg(s:WARNING,"unable to comply with your request<" . choice . ">",17)
   endif
  endwhile

  " Cleanup: {{{3
"  call Decho("cleanup")
  if s:FileReadable(tmpfile)
"   call Decho("tmpfile<".tmpfile."> readable, will now delete it")
   call s:NetrwDelete(tmpfile)
  endif
  call s:NetrwOptionRestore("w:")

  if a:firstline == 1 && a:lastline == line("$")
   " restore modifiability; usually equivalent to set nomod
   let &mod= mod
  endif

"  call Dret("netrw#NetWrite")
endfun

" ---------------------------------------------------------------------
" netrw#NetSource: source a remotely hosted vim script {{{2
" uses NetRead to get a copy of the file into a temporarily file,
"              then sources that file,
"              then removes that file.
fun! netrw#NetSource(...)
"  call Dfunc("netrw#NetSource() a:0=".a:0)
  if a:0 > 0 && a:1 == '?'
   " give help
   echomsg 'NetSource Usage:'
   echomsg ':Nsource dav://machine[:port]/path            uses cadaver'
   echomsg ':Nsource fetch://machine/path                 uses fetch'
   echomsg ':Nsource ftp://[user@]machine[:port]/path     uses ftp   autodetects <.netrc>'
   echomsg ':Nsource http://[user@]machine/path           uses http  wget'
   echomsg ':Nsource rcp://[user@]machine/path            uses rcp'
   echomsg ':Nsource rsync://machine[:port]/path          uses rsync'
   echomsg ':Nsource scp://[user@]machine[[:#]port]/path  uses scp'
   echomsg ':Nsource sftp://[user@]machine[[:#]port]/path uses sftp'
   sleep 4
  else
   let i= 1
   while i <= a:0
    call netrw#NetRead(3,a:{i})
"    call Decho("(netrw#NetSource) s:netread_tmpfile<".s:netrw_tmpfile.">")
    if s:FileReadable(s:netrw_tmpfile)
"     call Decho("(netrw#NetSource) exe so ".fnameescape(s:netrw_tmpfile))
     exe "so ".fnameescape(s:netrw_tmpfile)
"     call Decho("(netrw#NetSource) delete(".s:netrw_tmpfile.")")
     call delete(s:netrw_tmpfile)
     unlet s:netrw_tmpfile
    else
     call netrw#ErrorMsg(s:ERROR,"unable to source <".a:{i}.">!",48)
    endif
    let i= i + 1
   endwhile
  endif
"  call Dret("netrw#NetSource")
endfun

" ===========================================
" s:NetrwGetFile: Function to read temporary file "tfile" with command "readcmd". {{{2
"    readcmd == %r : replace buffer with newly read file
"            == 0r : read file at top of buffer
"            == r  : read file after current line
"            == t  : leave file in temporary form (ie. don't read into buffer)
fun! s:NetrwGetFile(readcmd, tfile, method)
"  call Dfunc("NetrwGetFile(readcmd<".a:readcmd.">,tfile<".a:tfile."> method<".a:method.">)")

  " readcmd=='t': simply do nothing
  if a:readcmd == 't'
"   call Decho("ro=".&l:ro." ma=".&l:ma." mod=".&l:mod." wrap=".&l:wrap)
"   call Dret("NetrwGetFile : skip read of <".a:tfile.">")
   return
  endif

  " get name of remote filename (ie. url and all)
  let rfile= bufname("%")
"  call Decho("rfile<".rfile.">")

  if exists("*NetReadFixup")
   " for the use of NetReadFixup (not otherwise used internally)
   let line2= line("$")
  endif

  if a:readcmd[0] == '%'
  " get file into buffer
"   call Decho("get file into buffer")

   " rename the current buffer to the temp file (ie. tfile)
   if g:netrw_cygwin
    let tfile= substitute(a:tfile,'/cygdrive/\(.\)','\1:','')
   else
    let tfile= a:tfile
   endif
"   call Decho("exe silent! keepalt file ".fnameescape(tfile))
   exe "silent! keepalt file ".fnameescape(tfile)

   " edit temporary file (ie. read the temporary file in)
   if     rfile =~ '\.zip$'
"    call Decho("handling remote zip file with zip#Browse(tfile<".tfile.">)")
    call zip#Browse(tfile)
   elseif rfile =~ '\.tar$'
"    call Decho("handling remote tar file with tar#Browse(tfile<".tfile.">)")
    call tar#Browse(tfile)
   elseif rfile =~ '\.tar\.gz'
"    call Decho("handling remote gzip-compressed tar file")
    call tar#Browse(tfile)
   elseif rfile =~ '\.tar\.bz2'
"    call Decho("handling remote bz2-compressed tar file")
    call tar#Browse(tfile)
   else
"    call Decho("edit temporary file")
    e!
   endif

   " rename buffer back to remote filename
"   call Decho("exe silent! keepalt file ".fnameescape(rfile))
   exe "silent! keepalt file ".fnameescape(rfile)
   if a:method == 5
    set ft=html
   else
    filetype detect
   endif
"   call Dredir("renamed buffer back to remote filename<".rfile."> : expand(%)<".expand("%").">","ls!")
   let line1 = 1
   let line2 = line("$")

  elseif s:FileReadable(a:tfile)
   " read file after current line
"   call Decho("read file<".a:tfile."> after current line")
   let curline = line(".")
   let lastline= line("$")
"   call Decho("exe<".a:readcmd." ".fnameescape(v:cmdarg)." ".fnameescape(a:tfile).">  line#".curline)
   exe a:readcmd." ".fnameescape(v:cmdarg)." ".fnameescape(a:tfile)
   let line1= curline + 1
   let line2= line("$") - lastline + 1

  else
   " not readable
"   call Decho("ro=".&l:ro." ma=".&l:ma." mod=".&l:mod." wrap=".&l:wrap)
"   call Decho("tfile<".a:tfile."> not readable")
   call netrw#ErrorMsg(s:WARNING,"file <".a:tfile."> not readable",9)
"   call Dret("NetrwGetFile : tfile<".a:tfile."> not readable")
   return
  endif

  " User-provided (ie. optional) fix-it-up command
  if exists("*NetReadFixup")
"   call Decho("calling NetReadFixup(method<".a:method."> line1=".line1." line2=".line2.")")
   call NetReadFixup(a:method, line1, line2)
"  else " Decho
"   call Decho("NetReadFixup() not called, doesn't exist  (line1=".line1." line2=".line2.")")
  endif

  if has("gui") && has("menu") && has("gui_running") && &go =~ 'm'
   " update the Buffers menu
   call s:UpdateBuffersMenu()
  endif

"  call Decho("readcmd<".a:readcmd."> cmdarg<".v:cmdarg."> tfile<".a:tfile."> readable=".s:FileReadable(a:tfile))

 " make sure file is being displayed
"  redraw!

"  call Decho("ro=".&l:ro." ma=".&l:ma." mod=".&l:mod." wrap=".&l:wrap)
"  call Dret("NetrwGetFile")
endfun

" ------------------------------------------------------------------------
" s:NetrwMethod:  determine method of transfer {{{2
" Input:
"   choice = url   [protocol:]//[userid@]hostname[:port]/[path-to-file]
" Output:
"  b:netrw_method= 1: rcp                                             
"                  2: ftp + <.netrc>                                  
"	           3: ftp + machine, id, password, and [path]filename 
"	           4: scp                                             
"	           5: http (wget)                                     
"	           6: dav
"	           7: rsync                                           
"	           8: fetch                                           
"	           9: sftp                                            
"  g:netrw_machine= hostname
"  b:netrw_fname  = filename
"  g:netrw_port   = optional port number (for ftp)
"  g:netrw_choice = copy of input url (choice)
fun! s:NetrwMethod(choice)
"   call Dfunc("NetrwMethod(a:choice<".a:choice.">)")

   " record current g:netrw_machine, if any
   " curmachine used if protocol == ftp and no .netrc
   if exists("g:netrw_machine")
    let curmachine= g:netrw_machine
"    call Decho("curmachine<".curmachine.">")
   else
    let curmachine= "N O T A HOST"
   endif

  " initialization
  let b:netrw_method  = 0
  let g:netrw_machine = ""
  let b:netrw_fname   = ""
  let g:netrw_port    = ""
  let g:netrw_choice  = a:choice

  " Patterns:
  " mipf     : a:machine a:id password filename	     Use ftp
  " mf	    : a:machine filename		     Use ftp + <.netrc> or g:netrw_uid s:netrw_passwd
  " ftpurm   : ftp://[user@]host[[#:]port]/filename  Use ftp + <.netrc> or g:netrw_uid s:netrw_passwd
  " rcpurm   : rcp://[user@]host/filename	     Use rcp
  " rcphf    : [user@]host:filename		     Use rcp
  " scpurm   : scp://[user@]host[[#:]port]/filename  Use scp
  " httpurm  : http://[user@]host/filename	     Use wget
  " davurm   : dav[s]://host[:port]/path             Use cadaver/curl
  " rsyncurm : rsync://host[:port]/path              Use rsync
  " fetchurm : fetch://[user@]host[:http]/filename   Use fetch (defaults to ftp, override for http)
  " sftpurm  : sftp://[user@]host/filename  Use scp
  let mipf     = '^\(\S\+\)\s\+\(\S\+\)\s\+\(\S\+\)\s\+\(\S\+\)$'
  let mf       = '^\(\S\+\)\s\+\(\S\+\)$'
  let ftpurm   = '^ftp://\(\([^/@]\{-}\)@\)\=\([^/#:]\{-}\)\([#:]\d\+\)\=/\(.*\)$'
  let rcpurm   = '^rcp://\%(\([^/@]\{-}\)@\)\=\([^/]\{-}\)/\(.*\)$'
  let rcphf    = '^\(\(\h\w*\)@\)\=\(\h\w*\):\([^@]\+\)$'
  let scpurm   = '^scp://\([^/#:]\+\)\%([#:]\(\d\+\)\)\=/\(.*\)$'
  let httpurm  = '^http://\([^/]\{-}\)\(/.*\)\=$'
  let davurm   = '^davs\=://\([^/]\+\)/\(.*/\)\([-_.~[:alnum:]]\+\)$'
  let rsyncurm = '^rsync://\([^/]\{-}\)/\(.*\)\=$'
  let fetchurm = '^fetch://\(\([^/@]\{-}\)@\)\=\([^/#:]\{-}\)\(:http\)\=/\(.*\)$'
  let sftpurm  = '^sftp://\([^/]\{-}\)/\(.*\)\=$'

"  call Decho("determine method:")
  " Determine Method
  " rcp://user@hostname/...path-to-file
  if match(a:choice,rcpurm) == 0
"   call Decho("rcp://...")
   let b:netrw_method  = 1
   let userid          = substitute(a:choice,rcpurm,'\1',"")
   let g:netrw_machine = substitute(a:choice,rcpurm,'\2',"")
   let b:netrw_fname   = substitute(a:choice,rcpurm,'\3',"")
   if userid != ""
    let g:netrw_uid= userid
   endif

  " scp://user@hostname/...path-to-file
  elseif match(a:choice,scpurm) == 0
"   call Decho("scp://...")
   let b:netrw_method  = 4
   let g:netrw_machine = substitute(a:choice,scpurm,'\1',"")
   let g:netrw_port    = substitute(a:choice,scpurm,'\2',"")
   let b:netrw_fname   = substitute(a:choice,scpurm,'\3',"")

  " http://user@hostname/...path-to-file
  elseif match(a:choice,httpurm) == 0
"   call Decho("http://...")
   let b:netrw_method = 5
   let g:netrw_machine= substitute(a:choice,httpurm,'\1',"")
   let b:netrw_fname  = substitute(a:choice,httpurm,'\2',"")

  " dav://hostname[:port]/..path-to-file..
  elseif match(a:choice,davurm) == 0
"   call Decho("dav://...")
   let b:netrw_method= 6
   if a:choice =~ '^s'
    let g:netrw_machine= 'https://'.substitute(a:choice,davurm,'\1/\2',"")
   else
    let g:netrw_machine= 'http://'.substitute(a:choice,davurm,'\1/\2',"")
   endif
   let b:netrw_fname  = substitute(a:choice,davurm,'\3',"")

  " rsync://user@hostname/...path-to-file
  elseif match(a:choice,rsyncurm) == 0
"   call Decho("rsync://...")
   let b:netrw_method = 7
   let g:netrw_machine= substitute(a:choice,rsyncurm,'\1',"")
   let b:netrw_fname  = substitute(a:choice,rsyncurm,'\2',"")

  " ftp://[user@]hostname[[:#]port]/...path-to-file
  elseif match(a:choice,ftpurm) == 0
"   call Decho("ftp://...")
   let userid	      = substitute(a:choice,ftpurm,'\2',"")
   let g:netrw_machine= substitute(a:choice,ftpurm,'\3',"")
   let g:netrw_port   = substitute(a:choice,ftpurm,'\4',"")
   let b:netrw_fname  = substitute(a:choice,ftpurm,'\5',"")
"   call Decho("g:netrw_machine<".g:netrw_machine.">")
   if userid != ""
    let g:netrw_uid= userid
   endif
   if exists("s:netrw_passwd") && curmachine != g:netrw_machine
    " if there's a change in hostname, require password re-entry
    unlet s:netrw_passwd
   endif
   if exists("g:netrw_uid") && exists("s:netrw_passwd")
    let b:netrw_method = 3
   else
    if s:FileReadable(expand("$HOME/.netrc")) && !g:netrw_ignorenetrc
     let b:netrw_method= 2
    else
     if !exists("g:netrw_uid") || g:netrw_uid == ""
      call NetUserPass()
     elseif !exists("s:netrw_passwd") || s:netrw_passwd == ""
      call NetUserPass(g:netrw_uid)
    " else just use current g:netrw_uid and s:netrw_passwd
     endif
     let b:netrw_method= 3
    endif
   endif

  elseif match(a:choice,fetchurm) == 0
"   call Decho("fetch://...")
   let b:netrw_method = 8
   let g:netrw_userid = substitute(a:choice,fetchurm,'\2',"")
   let g:netrw_machine= substitute(a:choice,fetchurm,'\3',"")
   let b:netrw_option = substitute(a:choice,fetchurm,'\4',"")
   let b:netrw_fname  = substitute(a:choice,fetchurm,'\5',"")

  " Issue an ftp : "machine id password [path/]filename"
  elseif match(a:choice,mipf) == 0
"   call Decho("(ftp) host id pass file")
   let b:netrw_method  = 3
   let g:netrw_machine = substitute(a:choice,mipf,'\1',"")
   let g:netrw_uid     = substitute(a:choice,mipf,'\2',"")
   let s:netrw_passwd  = substitute(a:choice,mipf,'\3',"")
   let b:netrw_fname   = substitute(a:choice,mipf,'\4',"")

  " Issue an ftp: "hostname [path/]filename"
  elseif match(a:choice,mf) == 0
"   call Decho("(ftp) host file")
   if exists("g:netrw_uid") && exists("s:netrw_passwd")
    let b:netrw_method  = 3
    let g:netrw_machine = substitute(a:choice,mf,'\1',"")
    let b:netrw_fname   = substitute(a:choice,mf,'\2',"")

   elseif s:FileReadable(expand("$HOME/.netrc"))
    let b:netrw_method  = 2
    let g:netrw_machine = substitute(a:choice,mf,'\1',"")
    let b:netrw_fname   = substitute(a:choice,mf,'\2',"")
   endif

  " sftp://user@hostname/...path-to-file
  elseif match(a:choice,sftpurm) == 0
"   call Decho("sftp://...")
   let b:netrw_method = 9
   let g:netrw_machine= substitute(a:choice,sftpurm,'\1',"")
   let b:netrw_fname  = substitute(a:choice,sftpurm,'\2',"")

  " Issue an rcp: hostname:filename"  (this one should be last)
  elseif match(a:choice,rcphf) == 0
"   call Decho("(rcp) [user@]host:file) rcphf<".rcphf.">")
   let b:netrw_method  = 1
   let userid          = substitute(a:choice,rcphf,'\2',"")
   let g:netrw_machine = substitute(a:choice,rcphf,'\3',"")
   let b:netrw_fname   = substitute(a:choice,rcphf,'\4',"")
"   call Decho('\1<'.substitute(a:choice,rcphf,'\1',"").">")
"   call Decho('\2<'.substitute(a:choice,rcphf,'\2',"").">")
"   call Decho('\3<'.substitute(a:choice,rcphf,'\3',"").">")
"   call Decho('\4<'.substitute(a:choice,rcphf,'\4',"").">")
   if userid != ""
    let g:netrw_uid= userid
   endif

  else
   if !exists("g:netrw_quiet")
    call netrw#ErrorMsg(s:WARNING,"cannot determine method (format: protocol://[user@]hostname[:port]/[path])",45)
   endif
   let b:netrw_method  = -1
  endif

  " remove any leading [:#] from port number
  if g:netrw_port != ""
    let g:netrw_port = substitute(g:netrw_port,'[#:]\+','','')
  endif

"  call Decho("a:choice       <".a:choice.">")
"  call Decho("b:netrw_method <".b:netrw_method.">")
"  call Decho("g:netrw_machine<".g:netrw_machine.">")
"  call Decho("g:netrw_port   <".g:netrw_port.">")
"  if exists("g:netrw_uid")		"Decho
"   call Decho("g:netrw_uid    <".g:netrw_uid.">")
"  endif					"Decho
"  if exists("s:netrw_passwd")		"Decho
"   call Decho("s:netrw_passwd <".s:netrw_passwd.">")
"  endif					"Decho
"  call Decho("b:netrw_fname  <".b:netrw_fname.">")
"  call Dret("NetrwMethod : b:netrw_method=".b:netrw_method)
endfun

" ------------------------------------------------------------------------
" NetReadFixup: this sort of function is typically written by the user {{{2
"               to handle extra junk that their system's ftp dumps
"               into the transfer.  This function is provided as an
"               example and as a fix for a Windows 95 problem: in my
"               experience, win95's ftp always dumped four blank lines
"               at the end of the transfer.
if has("win95") && exists("g:netrw_win95ftp") && g:netrw_win95ftp
 fun! NetReadFixup(method, line1, line2)
"   call Dfunc("NetReadFixup(method<".a:method."> line1=".a:line1." line2=".a:line2.")")

   " sanity checks -- attempt to convert inputs to integers
   let method = a:method + 0
   let line1  = a:line1 + 0
   let line2  = a:line2 + 0
   if type(method) != 0 || type(line1) != 0 || type(line2) != 0 || method < 0 || line1 <= 0 || line2 <= 0
"    call Dret("NetReadFixup")
    return
   endif

   if method == 3   " ftp (no <.netrc>)
    let fourblanklines= line2 - 3
    if fourblanklines >= line1
     exe "silent ".fourblanklines.",".line2."g/^\s*$/d"
    endif
   endif

"   call Dret("NetReadFixup")
 endfun
endif

" ---------------------------------------------------------------------
" NetUserPass: set username and password for subsequent ftp transfer {{{2
"   Usage:  :call NetUserPass()			-- will prompt for userid and password
"	    :call NetUserPass("uid")		-- will prompt for password
"	    :call NetUserPass("uid","password") -- sets global userid and password
fun! NetUserPass(...)

 " get/set userid
 if a:0 == 0
"  call Dfunc("NetUserPass(a:0<".a:0.">)")
  if !exists("g:netrw_uid") || g:netrw_uid == ""
   " via prompt
   let g:netrw_uid= input('Enter username: ')
  endif
 else	" from command line
"  call Dfunc("NetUserPass(a:1<".a:1.">) {")
  let g:netrw_uid= a:1
 endif

 " get password
 if a:0 <= 1 " via prompt
"  call Decho("a:0=".a:0." case <=1:")
  let s:netrw_passwd= inputsecret("Enter Password: ")
 else " from command line
"  call Decho("a:0=".a:0." case >1: a:2<".a:2.">")
  let s:netrw_passwd=a:2
 endif

"  call Dret("NetUserPass")
endfun

" ===========================================
"  Shared Browsing Support:    {{{1
" ===========================================

" ---------------------------------------------------------------------
" s:BrowserMaps: {{{2
fun! s:BrowserMaps(islocal)
"  call Dfunc("s:BrowserMaps(islocal=".a:islocal.") b:netrw_curdir<".b:netrw_curdir.">")
  if a:islocal
"   call Decho("make local maps")
   nnoremap <buffer> <silent> <cr>	:call netrw#LocalBrowseCheck(<SID>NetrwBrowseChgDir(1,<SID>NetrwGetWord()))<cr>
   nnoremap <buffer> <silent> -		:exe "norm! 0"<bar>call netrw#LocalBrowseCheck(<SID>NetrwBrowseChgDir(1,'../'))<cr>
   nnoremap <buffer> <silent> a		:call <SID>NetrwHide(1)<cr>
   nnoremap <buffer> <silent> mb	:<c-u>call <SID>NetrwBookHistHandler(0,b:netrw_curdir)<cr>
   nnoremap <buffer> <silent> mc	:<c-u>call <SID>NetrwMarkFileCopy(1)<cr>
   nnoremap <buffer> <silent> md	:<c-u>call <SID>NetrwMarkFileDiff(1)<cr>
   nnoremap <buffer> <silent> me	:<c-u>call <SID>NetrwMarkFileEdit(1)<cr>
   nnoremap <buffer> <silent> mf	:<c-u>call <SID>NetrwMarkFile(1,<SID>NetrwGetWord())<cr>
   nnoremap <buffer> <silent> mg	:<c-u>call <SID>NetrwMarkFileGrep(1)<cr>
   nnoremap <buffer> <silent> mh	:<c-u>call <SID>NetrwMarkHideSfx(1)<cr>
   nnoremap <buffer> <silent> mm	:<c-u>call <SID>NetrwMarkFileMove(1)<cr>
   nnoremap <buffer> <silent> mp	:<c-u>call <SID>NetrwMarkFilePrint(1)<cr>
   nnoremap <buffer> <silent> mr	:<c-u>call <SID>NetrwMarkFileRegexp(1)<cr>
   nnoremap <buffer> <silent> ms	:<c-u>call <SID>NetrwMarkFileSource(1)<cr>
   nnoremap <buffer> <silent> mT	:<c-u>call <SID>NetrwMarkFileTag(1)<cr>
   nnoremap <buffer> <silent> mt	:<c-u>call <SID>NetrwMarkFileTgt(1)<cr>
   nnoremap <buffer> <silent> mu	:<c-u>call <SID>NetrwUnMarkFile(1)<cr>
   nnoremap <buffer> <silent> mx	:<c-u>call <SID>NetrwMarkFileExe(1)<cr>
   nnoremap <buffer> <silent> mz	:<c-u>call <SID>NetrwMarkFileCompress(1)<cr>
   nnoremap <buffer> <silent> gb	:<c-u>call <SID>NetrwBookHistHandler(1,b:netrw_curdir)<cr>
   nnoremap <buffer> <silent> gh	:<c-u>call <SID>NetrwHidden(1)<cr>
   nnoremap <buffer> <silent> c		:exe "keepjumps lcd ".fnameescape(b:netrw_curdir)<cr>
   nnoremap <buffer> <silent> C		:let g:netrw_chgwin= winnr()<cr>
   nnoremap <buffer> <silent> d		:call <SID>NetrwMakeDir("")<cr>
   nnoremap <buffer> <silent> i		:call <SID>NetrwListStyle(1)<cr>
   nnoremap <buffer> <silent> o		:call <SID>NetrwSplit(3)<cr>
   nnoremap <buffer> <silent> O		:call <SID>NetrwObtain(1)<cr>
   nnoremap <buffer> <silent> p		:call <SID>NetrwPreview(<SID>NetrwBrowseChgDir(1,<SID>NetrwGetWord(),1))<cr>
   nnoremap <buffer> <silent> P		:call <SID>NetrwPrevWinOpen(1)<cr>
   nnoremap <buffer> <silent> qb	:<c-u>call <SID>NetrwBookHistHandler(2,b:netrw_curdir)<cr>
   nnoremap <buffer> <silent> mB	:<c-u>call <SID>NetrwBookHistHandler(6,b:netrw_curdir)<cr>
   nnoremap <buffer> <silent> qf	:<c-u>call <SID>NetrwFileInfo(1,<SID>NetrwGetWord())<cr>
   nnoremap <buffer> <silent> r		:let g:netrw_sort_direction= (g:netrw_sort_direction =~ 'n')? 'r' : 'n'<bar>exe "norm! 0"<bar>call <SID>NetrwRefresh(1,<SID>NetrwBrowseChgDir(1,'./'))<cr>
   nnoremap <buffer> <silent> s		:call <SID>NetrwSortStyle(1)<cr>
   nnoremap <buffer> <silent> S		:call <SID>NetSortSequence(1)<cr>
   nnoremap <buffer> <silent> t		:call <SID>NetrwSplit(4)<cr>
   nnoremap <buffer> <silent> u		:<c-u>call <SID>NetrwBookHistHandler(4,expand("%"))<cr>
   nnoremap <buffer> <silent> U		:<c-u>call <SID>NetrwBookHistHandler(5,expand("%"))<cr>
   nnoremap <buffer> <silent> v		:call <SID>NetrwSplit(5)<cr>
   nnoremap <buffer> <silent> x		:call netrw#NetrwBrowseX(<SID>NetrwBrowseChgDir(1,<SID>NetrwGetWord(),0),0)"<cr>
   nnoremap <buffer> <silent> %		:call <SID>NetrwOpenFile(1)<cr>
   if !hasmapto('<Plug>NetrwHideEdit')
    nmap <buffer> <unique> <c-h> <Plug>NetrwHideEdit
   endif
   nnoremap <buffer> <silent> <Plug>NetrwHideEdit	:call <SID>NetrwHideEdit(1)<cr>
   if !hasmapto('<Plug>NetrwRefresh')
    nmap <buffer> <unique> <c-l> <Plug>NetrwRefresh
   endif
   nnoremap <buffer> <silent> <Plug>NetrwRefresh		:call <SID>NetrwRefresh(1,<SID>NetrwBrowseChgDir(1,'./'))<cr>
   if s:didstarstar || !mapcheck("<s-down>","n")
    nnoremap <buffer> <silent> <s-down>	:Nexplore<cr>
   endif
   if s:didstarstar || !mapcheck("<s-up>","n")
    nnoremap <buffer> <silent> <s-up>	:Pexplore<cr>
   endif
   let mapsafecurdir = escape(b:netrw_curdir, s:netrw_map_escape)
   if g:netrw_mousemaps == 1
    nnoremap <buffer> <silent> <leftmouse>   <leftmouse>:call <SID>NetrwLeftmouse(1)<cr>
    nnoremap <buffer> <silent> <middlemouse> <leftmouse>:call <SID>NetrwPrevWinOpen(1)<cr>
    nnoremap <buffer> <silent> <s-leftmouse> <leftmouse>:call <SID>NetrwMarkFile(1,<SID>NetrwGetWord())<cr>
    exe 'nnoremap <buffer> <silent> <rightmouse>  <leftmouse>:call <SID>NetrwLocalRm("'.mapsafecurdir.'")<cr>'
    exe 'vnoremap <buffer> <silent> <rightmouse>  <leftmouse>:call <SID>NetrwLocalRm("'.mapsafecurdir.'")<cr>'
   endif
   exe 'nnoremap <buffer> <silent> <del>	:call <SID>NetrwLocalRm("'.mapsafecurdir.'")<cr>'
   exe 'vnoremap <buffer> <silent> <del>	:call <SID>NetrwLocalRm("'.mapsafecurdir.'")<cr>'
   exe 'nnoremap <buffer> <silent> D		:call <SID>NetrwLocalRm("'.mapsafecurdir.'")<cr>'
   exe 'vnoremap <buffer> <silent> D		:call <SID>NetrwLocalRm("'.mapsafecurdir.'")<cr>'
   exe 'nnoremap <buffer> <silent> R		:call <SID>NetrwLocalRename("'.mapsafecurdir.'")<cr>'
   exe 'vnoremap <buffer> <silent> R		:call <SID>NetrwLocalRename("'.mapsafecurdir.'")<cr>'
   exe 'nnoremap <buffer> <silent> <Leader>m	:call <SID>NetrwMakeDir("")<cr>'
   nnoremap <buffer> <F1>		:he netrw-quickhelp<cr>

  else " remote
"   call Decho("make remote maps")
   call s:RemotePathAnalysis(b:netrw_curdir)
   nnoremap <buffer> <silent> <cr>	:call <SID>NetrwBrowse(0,<SID>NetrwBrowseChgDir(0,<SID>NetrwGetWord()))<cr>
   nnoremap <buffer> <silent> <c-l>	:call <SID>NetrwRefresh(0,<SID>NetrwBrowseChgDir(0,'./'))<cr>
   nnoremap <buffer> <silent> -		:exe "norm! 0"<bar>call <SID>NetrwBrowse(0,<SID>NetrwBrowseChgDir(0,'../'))<cr>
   nnoremap <buffer> <silent> a		:call <SID>NetrwHide(0)<cr>
   nnoremap <buffer> <silent> mb	:<c-u>call <SID>NetrwBookHistHandler(0,b:netrw_curdir)<cr>
   nnoremap <buffer> <silent> mc	:<c-u>call <SID>NetrwMarkFileCopy(0)<cr>
   nnoremap <buffer> <silent> md	:<c-u>call <SID>NetrwMarkFileDiff(0)<cr>
   nnoremap <buffer> <silent> me	:<c-u>call <SID>NetrwMarkFileEdit(0)<cr>
   nnoremap <buffer> <silent> mf	:<c-u>call <SID>NetrwMarkFile(0,<SID>NetrwGetWord())<cr>
   nnoremap <buffer> <silent> mg	:<c-u>call <SID>NetrwMarkFileGrep(0)<cr>
   nnoremap <buffer> <silent> mh	:<c-u>call <SID>NetrwMarkHideSfx(0)<cr>
   nnoremap <buffer> <silent> mm	:<c-u>call <SID>NetrwMarkFileMove(0)<cr>
   nnoremap <buffer> <silent> mp	:<c-u>call <SID>NetrwMarkFilePrint(0)<cr>
   nnoremap <buffer> <silent> mr	:<c-u>call <SID>NetrwMarkFileRegexp(0)<cr>
   nnoremap <buffer> <silent> ms	:<c-u>call <SID>NetrwMarkFileSource(0)<cr>
   nnoremap <buffer> <silent> mT	:<c-u>call <SID>NetrwMarkFileTag(0)<cr>
   nnoremap <buffer> <silent> mt	:<c-u>call <SID>NetrwMarkFileTgt(0)<cr>
   nnoremap <buffer> <silent> mu	:<c-u>call <SID>NetrwUnMarkFile(0)<cr>
   nnoremap <buffer> <silent> mx	:<c-u>call <SID>NetrwMarkFileExe(0)<cr>
   nnoremap <buffer> <silent> mz	:<c-u>call <SID>NetrwMarkFileCompress(0)<cr>
   nnoremap <buffer> <silent> gb	:<c-u>call <SID>NetrwBookHistHandler(1,b:netrw_cur)<cr>
   nnoremap <buffer> <silent> gh	:<c-u>call <SID>NetrwHidden(0)<cr>
   nnoremap <buffer> <silent> C		:let g:netrw_chgwin= winnr()<cr>
   nnoremap <buffer> <silent> i		:call <SID>NetrwListStyle(0)<cr>
   nnoremap <buffer> <silent> o		:call <SID>NetrwSplit(0)<cr>
   nnoremap <buffer> <silent> O		:call <SID>NetrwObtain(0)<cr>
   nnoremap <buffer> <silent> p		:call <SID>NetrwPreview(<SID>NetrwBrowseChgDir(1,<SID>NetrwGetWord(),1))<cr>
   nnoremap <buffer> <silent> P		:call <SID>NetrwPrevWinOpen(0)<cr>
   nnoremap <buffer> <silent> qb	:<c-u>call <SID>NetrwBookHistHandler(2,b:netrw_curdir)<cr>
   nnoremap <buffer> <silent> mB	:<c-u>call <SID>NetrwBookHistHandler(6,b:netrw_curdir)<cr>
   nnoremap <buffer> <silent> qf	:<c-u>call <SID>NetrwFileInfo(0,<SID>NetrwGetWord())<cr>
   nnoremap <buffer> <silent> r		:let g:netrw_sort_direction= (g:netrw_sort_direction =~ 'n')? 'r' : 'n'<bar>exe "norm! 0"<bar>call <SID>NetrwBrowse(0,<SID>NetrwBrowseChgDir(0,'./'))<cr>
   nnoremap <buffer> <silent> s		:call <SID>NetrwSortStyle(0)<cr>
   nnoremap <buffer> <silent> S		:call <SID>NetSortSequence(0)<cr>
   nnoremap <buffer> <silent> t		:call <SID>NetrwSplit(1)<cr>
   nnoremap <buffer> <silent> u		:<c-u>call <SID>NetrwBookHistHandler(4,b:netrw_curdir)<cr>
   nnoremap <buffer> <silent> U		:<c-u>call <SID>NetrwBookHistHandler(5,b:netrw_curdir)<cr>
   nnoremap <buffer> <silent> v		:call <SID>NetrwSplit(2)<cr>
   nnoremap <buffer> <silent> x		:call netrw#NetrwBrowseX(<SID>NetrwBrowseChgDir(0,<SID>NetrwGetWord()),1)<cr>
   nnoremap <buffer> <silent> %		:call <SID>NetrwOpenFile(0)<cr>
   if !hasmapto('<Plug>NetrwHideEdit')
    nmap <buffer> <c-h> <Plug>NetrwHideEdit
   endif
   nnoremap <buffer> <silent> <Plug>NetrwHideEdit	:call <SID>NetrwHideEdit(0)<cr>
   if !hasmapto('<Plug>NetrwRefresh')
    nmap <buffer> <c-l> <Plug>NetrwRefresh
   endif

   let mapsafepath     = escape(s:path, s:netrw_map_escape)
   let mapsafeusermach = escape(s:user.s:machine, s:netrw_map_escape)

   nnoremap <buffer> <silent> <Plug>NetrwRefresh		:call <SID>NetrwRefresh(0,<SID>NetrwBrowseChgDir(0,'./'))<cr>
   if g:netrw_mousemaps == 1
    nnoremap <buffer> <silent> <leftmouse>   <leftmouse>:call <SID>NetrwLeftmouse(0)<cr>
    nnoremap <buffer> <silent> <middlemouse> <leftmouse>:call <SID>NetrwPrevWinOpen(0)<cr>
    nnoremap <buffer> <silent> <s-leftmouse> <leftmouse>:call <SID>NetrwMarkFile(0,<SID>NetrwGetWord())<cr>
    exe 'nnoremap <buffer> <silent> <rightmouse> <leftmouse>:call <SID>NetrwRemoteRm("'.mapsafeusermach.'","'.mapsafepath.'")<cr>'
    exe 'vnoremap <buffer> <silent> <rightmouse> <leftmouse>:call <SID>NetrwRemoteRm("'.mapsafeusermach.'","'.mapsafepath.'")<cr>'
   endif
   exe 'nnoremap <buffer> <silent> <del>	:call <SID>NetrwRemoteRm("'.mapsafeusermach.'","'.mapsafepath.'")<cr>'
   exe 'vnoremap <buffer> <silent> <del>	:call <SID>NetrwRemoteRm("'.mapsafeusermach.'","'.mapsafepath.'")<cr>'
   exe 'nnoremap <buffer> <silent> d	:call <SID>NetrwMakeDir("'.mapsafeusermach.'")<cr>'
   exe 'nnoremap <buffer> <silent> D	:call <SID>NetrwRemoteRm("'.mapsafeusermach.'","'.mapsafepath.'")<cr>'
   exe 'vnoremap <buffer> <silent> D	:call <SID>NetrwRemoteRm("'.mapsafeusermach.'","'.mapsafepath.'")<cr>'
   exe 'nnoremap <buffer> <silent> R	:call <SID>NetrwRemoteRename("'.mapsafeusermach.'","'.mapsafepath.'")<cr>'
   exe 'vnoremap <buffer> <silent> R	:call <SID>NetrwRemoteRename("'.mapsafeusermach.'","'.mapsafepath.'")<cr>'
   nnoremap <buffer> <F1>			:he netrw-quickhelp<cr>
  endif
  call s:SetRexDir(a:islocal,b:netrw_curdir)
"  call Dret("s:BrowserMaps")
endfun

" ---------------------------------------------------------------------
" s:ExplorePatHls: converts an Explore pattern into a regular expression search pattern {{{2
fun! s:ExplorePatHls(pattern)
"  call Dfunc("s:ExplorePatHls(pattern<".a:pattern.">)")
  let repat= substitute(a:pattern,'^**/\{1,2}','','')
"  call Decho("repat<".repat.">")
  let repat= escape(repat,'][.\')
"  call Decho("repat<".repat.">")
  let repat= '\<'.substitute(repat,'\*','\\(\\S\\+ \\)*\\S\\+','g').'\>'
"  call Dret("s:ExplorePatHls repat<".repat.">")
  return repat
endfun

" ---------------------------------------------------------------------
"  s:NetrwBookHistHandler: {{{2
"    0: (user: <mb>)   bookmark current directory
"    1: (user: <gb>)   change to the bookmarked directory
"    2: (user: <qb>)   list bookmarks
"    3: (browsing)     record current directory history
"    4: (user: <u>)    go up   (previous) bookmark
"    5: (user: <U>)    go down (next)     bookmark
"    6: (user: <mB>)   delete bookmark
fun! s:NetrwBookHistHandler(chg,curdir)
"  call Dfunc("NetrwBookHistHandler(chg=".a:chg." curdir<".a:curdir.">) cnt=".v:count." histcnt=".g:netrw_dirhist_cnt." histmax=".g:netrw_dirhistmax)

  if a:chg == 0
   " bookmark the current directory
"   call Decho("(user: <b>) bookmark the current directory")
   if !exists("g:netrw_bookmarklist")
    let g:netrw_bookmarklist= []
   endif
   if index(g:netrw_bookmarklist,a:curdir) == -1
    " curdir not currently in g:netrw_bookmarklist, so include it
    call add(g:netrw_bookmarklist,a:curdir)
    call sort(g:netrw_bookmarklist)
   endif
   echo "bookmarked the current directory"

  elseif a:chg == 1
   " change to the bookmarked directory
"   call Decho("(user: <".v:count."mb>) change to the bookmarked directory")
   if exists("g:netrw_bookmarklist[v:count-1]")
    exe "e ".fnameescape(g:netrw_bookmarklist[v:count-1])
   else
    echomsg "Sorry, bookmark#".v:count." doesn't exist!"
   endif

  elseif a:chg == 2
"   redraw!
   let didwork= 0
   " list user's bookmarks
"   call Decho("(user: <q>) list user's bookmarks")
   if exists("g:netrw_bookmarklist")
"    call Decho('list '.len(g:netrw_bookmarklist).' bookmarks')
    let cnt= 1
    for bmd in g:netrw_bookmarklist
"     call Decho("Netrw Bookmark#".cnt.": ".g:netrw_bookmarklist[cnt-1])
     echo "Netrw Bookmark#".cnt.": ".g:netrw_bookmarklist[cnt-1]
     let didwork = 1
     let cnt     = cnt + 1
    endfor
   endif

   " list directory history
   let cnt     = g:netrw_dirhist_cnt
   let first   = 1
   let histcnt = 0
   while ( first || cnt != g:netrw_dirhist_cnt )
"    call Decho("first=".first." cnt=".cnt." dirhist_cnt=".g:netrw_dirhist_cnt)
    let histcnt= histcnt + 1
    if exists("g:netrw_dirhist_{cnt}")
"     call Decho("Netrw  History#".histcnt.": ".g:netrw_dirhist_{cnt})
     echo "Netrw  History#".histcnt.": ".g:netrw_dirhist_{cnt}
     let didwork= 1
    endif
    let first = 0
    let cnt   = ( cnt - 1 ) % g:netrw_dirhistmax
    if cnt < 0
     let cnt= cnt + g:netrw_dirhistmax
    endif
   endwhile
   if didwork
    call inputsave()|call input("Press <cr> to continue")|call inputrestore()
   endif

  elseif a:chg == 3
   " saves most recently visited directories (when they differ)
"   call Decho("(browsing) record curdir history")
   if !exists("g:netrw_dirhist_cnt") || !exists("g:netrw_dirhist_{g:netrw_dirhist_cnt}") || g:netrw_dirhist_{g:netrw_dirhist_cnt} != a:curdir
    let g:netrw_dirhist_cnt                   = ( g:netrw_dirhist_cnt + 1 ) % g:netrw_dirhistmax
    let g:netrw_dirhist_{g:netrw_dirhist_cnt} = a:curdir
"    call Decho("save dirhist#".g:netrw_dirhist_cnt."<".g:netrw_dirhist_{g:netrw_dirhist_cnt}.">")
   endif

  elseif a:chg == 4
   " u: change to the previous directory stored on the history list
"   call Decho("(user: <u>) chg to prev dir from history")
   let g:netrw_dirhist_cnt= ( g:netrw_dirhist_cnt - 1 ) % g:netrw_dirhistmax
   if g:netrw_dirhist_cnt < 0
    let g:netrw_dirhist_cnt= g:netrw_dirhist_cnt + g:netrw_dirhistmax
   endif
   if exists("g:netrw_dirhist_{g:netrw_dirhist_cnt}")
"    call Decho("changedir u#".g:netrw_dirhist_cnt."<".g:netrw_dirhist_{g:netrw_dirhist_cnt}.">")
    if exists("w:netrw_liststyle") && w:netrw_liststyle == s:TREELIST && exists("b:netrw_curdir")
     setlocal ma noro
"     call Decho("setlocal ma noro")
     %d
     setlocal nomod
"     call Decho("setlocal nomod")
    endif
"    "    call Decho("exe e! ".fnameescape(g:netrw_dirhist_{g:netrw_dirhist_cnt}))
    exe "e! ".fnameescape(g:netrw_dirhist_{g:netrw_dirhist_cnt})
   else
    let g:netrw_dirhist_cnt= ( g:netrw_dirhist_cnt + 1 ) % g:netrw_dirhistmax
    echo "Sorry, no predecessor directory exists yet"
   endif

  elseif a:chg == 5
   " U: change to the subsequent directory stored on the history list
"   call Decho("(user: <U>) chg to next dir from history")
   let g:netrw_dirhist_cnt= ( g:netrw_dirhist_cnt + 1 ) % g:netrw_dirhistmax
   if exists("g:netrw_dirhist_{g:netrw_dirhist_cnt}")
"    call Decho("changedir U#".g:netrw_dirhist_cnt."<".g:netrw_dirhist_{g:netrw_dirhist_cnt}.">")
    if exists("w:netrw_liststyle") && w:netrw_liststyle == s:TREELIST && exists("b:netrw_curdir")
     setlocal ma noro
"     call Decho("setlocal ma noro")
     %d
"     call Decho("removed all lines from buffer (%d)")
     setlocal nomod
"     call Decho("setlocal nomod")
    endif
"    call Decho("exe e! ".fnameescape(g:netrw_dirhist_{g:netrw_dirhist_cnt}))
    exe "e! ".fnameescape(g:netrw_dirhist_{g:netrw_dirhist_cnt})
   else
    let g:netrw_dirhist_cnt= ( g:netrw_dirhist_cnt - 1 ) % g:netrw_dirhistmax
    if g:netrw_dirhist_cnt < 0
     let g:netrw_dirhist_cnt= g:netrw_dirhist_cnt + g:netrw_dirhistmax
    endif
    echo "Sorry, no successor directory exists yet"
   endif

  elseif a:chg == 6
   " delete the v:count'th bookmark
"   call Decho("delete bookmark#".v:count."<".g:netrw_bookmarklist[v:count-1].">")
   let savefile= s:NetrwHome()."/.netrwbook"
   if filereadable(savefile)
    call s:NetrwBookHistSave() " done here to merge bookmarks first
    call delete(savefile)
   endif
   call remove(g:netrw_bookmarklist,v:count-1)
  endif
  call s:NetrwBookmarkMenu()
"  call Dret("NetrwBookHistHandler")
endfun

" ---------------------------------------------------------------------
" s:NetrwBookHistRead: this function reads bookmarks and history {{{2
"                      Sister function: s:NetrwBookHistSave()
fun! s:NetrwBookHistRead()
"  call Dfunc("s:NetrwBookHistRead()")
  if !exists("s:netrw_initbookhist")
   let savefile= s:NetrwHome()."/.netrwbook"
   if filereadable(savefile)
"    call Decho("sourcing .netrwbook")
    exe "so ".savefile
   endif
   let savefile= s:NetrwHome()."/.netrwhist"
   if filereadable(savefile)
"    call Decho("sourcing .netrwhist")
    exe "so ".savefile
   endif
   let s:netrw_initbookhist= 1
   au VimLeave * call s:NetrwBookHistSave()
  endif
"  call Dret("s:NetrwBookHistRead")
endfun

" ---------------------------------------------------------------------
" s:NetrwBookHistSave: this function saves bookmarks and history {{{2
"                      Sister function: s:NetrwBookHistRead()
"                      I used to do this via viminfo but that appears to
"                      be unreliable for long-term storage
"                      COMBAK: does $HOME work under windows???
fun! s:NetrwBookHistSave()
"  call Dfunc("s:NetrwBookHistSave() dirhistmax=".g:netrw_dirhistmax)
  let savefile= s:NetrwHome()."/.netrwhist"
  1split
  enew
  setlocal noswf

  " save .netrwhist -- no attempt to merge
  file .netrwhist
  call setline(1,"let g:netrw_dirhistmax  =".g:netrw_dirhistmax)
  call setline(2,"let g:netrw_dirhist_cnt =".g:netrw_dirhist_cnt)
  let lastline = line("$")
  let cnt      = 1
  while cnt <= g:netrw_dirhist_cnt
   call setline((cnt+lastline),'let g:netrw_dirhist_'.cnt."='".g:netrw_dirhist_{cnt}."'")
   let cnt= cnt + 1
  endwhile
  exe "silent! w! ".savefile
  %d

  if exists("g:netrw_bookmarklist") && g:netrw_bookmarklist != []
   " merge and write .netrwbook
   let savefile= s:NetrwHome()."/.netrwbook"

   if filereadable(savefile)
    let booklist= deepcopy(g:netrw_bookmarklist)
    exe "silent so ".savefile
    for bdm in booklist
     if index(g:netrw_bookmarklist,bdm) == -1
      call add(g:netrw_bookmarklist,bdm)
     endif
    endfor
    call sort(g:netrw_bookmarklist)
    exe "silent! w! ".savefile
   endif

   " construct and save .netrwbook
   call setline(1,"let g:netrw_bookmarklist= ".string(g:netrw_bookmarklist))
   exe "silent! w! ".savefile
  endif
  let bgone= bufnr("%")
  q!
  exe bgone."bwipe!"

"  call Dret("s:NetrwBookHistSave")
endfun

" ---------------------------------------------------------------------
" s:NetrwBrowse: This function uses the command in g:netrw_list_cmd to provide a {{{2
"  list of the contents of a local or remote directory.  It is assumed that the
"  g:netrw_list_cmd has a string, USEPORT HOSTNAME, that needs to be substituted
"  with the requested remote hostname first.
fun! s:NetrwBrowse(islocal,dirname)
  if !exists("w:netrw_liststyle")|let w:netrw_liststyle= g:netrw_liststyle|endif
"  call Dfunc("s:NetrwBrowse(islocal=".a:islocal." dirname<".a:dirname.">) liststyle=".w:netrw_liststyle." ".g:loaded_netrw." buf#".bufnr("%")."<".bufname("%").">")
"  call Decho("tab#".tabpagenr()." win#".winnr())
"  call Dredir("ls!")
  if !exists("s:netrw_initbookhist")
   call s:NetrwBookHistRead()
  endif

  if exists("s:netrw_skipbrowse")
   unlet s:netrw_skipbrowse
"   call Decho("ro=".&l:ro." ma=".&l:ma." mod=".&l:mod." wrap=".&l:wrap)
"   call Dret("s:NetrwBrowse : s:netrw_skipbrowse=".s:netrw_skipbrowse)
   return
  endif
  if !exists("*shellescape")
   call netrw#ErrorMsg(s:ERROR,"netrw can't run -- your vim is missing shellescape()",69)
"   call Dret("s:NetrwBrowse : missing shellescape()")
   return
  endif
  if !exists("*fnameescape")
   call netrw#ErrorMsg(s:ERROR,"netrw can't run -- your vim is missing fnameescape()",70)
"   call Dret("s:NetrwBrowse : missing fnameescape()")
   return
  endif

  call s:NetrwOptionSave("w:")
  call s:NetrwSafeOptions()

  " re-instate any marked files
  if exists("s:netrwmarkfilelist_{bufnr('%')}")
"   call Decho("clearing marked files")
   exe "2match netrwMarkFile /".s:netrwmarkfilemtch_{bufnr("%")}."/"
  endif

  if a:islocal && exists("w:netrw_acdkeep") && w:netrw_acdkeep
"   call Decho("handle w:netrw_acdkeep:")
"   call Decho("keepjumps lcd ".fnameescape(a:dirname)." (due to w:netrw_acdkeep=".w:netrw_acdkeep." - acd=".&acd.")")
   exe 'keepjumps lcd '.fnameescape(a:dirname)
"   call Decho("getcwd<".getcwd().">")

  elseif !a:islocal && a:dirname !~ '[\/]$' && a:dirname !~ '^"'
   " looks like a regular file, attempt transfer
"   call Decho("attempt transfer as regular file<".a:dirname.">")

   " remove any filetype indicator from end of dirname, except for the {{{3
   " "this is a directory" indicator (/).
   " There shouldn't be one of those here, anyway.
   let path= substitute(a:dirname,'[*=@|]\r\=$','','e')
"   call Decho("new path<".path.">")
   call s:RemotePathAnalysis(a:dirname)

   " remote-read the requested file into current buffer {{{3
   mark '
   call s:NetrwEnew(a:dirname)
   setlocal ma noro
"   call Decho("setlocal ma noro")
   let b:netrw_curdir= a:dirname
"   call Decho("exe silent! keepalt file ".fnameescape(s:method."://".s:user.s:machine."/".s:path)." (bt=".&bt.")")
   exe "silent! keepalt file ".fnameescape(s:method."://".s:user.s:machine."/".s:path)
   exe "silent keepalt doau BufReadPre ".fnameescape(s:fname)
   silent call netrw#NetRead(2,s:method."://".s:user.s:machine."/".s:path)
   if s:path !~ '.tar.bz2$' && s:path !~ '.tar.gz'
    " netrw.vim and tar.vim have already handled decompression of the tarball; avoiding gzip.vim error
    exe "silent keepalt doau BufReadPost ".fnameescape(s:fname)
   endif

   " save certain window-oriented variables into buffer-oriented variables {{{3
   call s:SetBufWinVars()
   call s:NetrwOptionRestore("w:")
   setlocal ma nomod

"   call Decho("ro=".&l:ro." ma=".&l:ma." mod=".&l:mod." wrap=".&l:wrap)
"   call Dret("s:NetrwBrowse : file<".s:fname.">")
   return
  endif

  " use buffer-oriented WinVars if buffer ones exist but window ones don't {{{3
  call s:UseBufWinVars()

  " set up some variables {{{3
  let b:netrw_browser_active = 1
  let dirname                = a:dirname
  let s:last_sort_by         = g:netrw_sort_by

  " set up menu {{{3
  call s:NetrwMenu(1)

  " set up buffer {{{3
  let reusing= s:NetrwGetBuffer(a:islocal,dirname)
  " maintain markfile highlighting
  if exists("s:netrwmarkfilemtch_{bufnr('%')}") && s:netrwmarkfilemtch_{bufnr("%")} != ""
"   call Decho("bufnr(%)=".bufnr('%'))
"   call Decho("exe 2match netrwMarkFile /".s:netrwmarkfilemtch_{bufnr("%")}."/")
   exe "2match netrwMarkFile /".s:netrwmarkfilemtch_{bufnr("%")}."/"
  else
"   call Decho("2match none")
   2match none
  endif
  if reusing
   call s:NetrwOptionRestore("w:")
   setlocal noma nomod nowrap
"   call Decho("ro=".&l:ro." ma=".&l:ma." mod=".&l:mod." wrap=".&l:wrap)
"   call Dret("s:NetrwBrowse : re-using buffer")
   return
  endif

  " set b:netrw_curdir to the new directory name {{{3
"  call Decho("set b:netrw_curdir to the new directory name:")
   let b:netrw_curdir= dirname
  if b:netrw_curdir =~ '[/\\]$'
   let b:netrw_curdir= substitute(b:netrw_curdir,'[/\\]$','','e')
  endif
  if b:netrw_curdir == ''
   if has("amiga")
    " On the Amiga, the empty string connotes the current directory
    let b:netrw_curdir= getcwd()
   else
    " under unix, when the root directory is encountered, the result
    " from the preceding substitute is an empty string.
    let b:netrw_curdir= '/'
   endif
  endif
  if !a:islocal && b:netrw_curdir !~ '/$'
   let b:netrw_curdir= b:netrw_curdir.'/'
  endif
"  call Decho("b:netrw_curdir<".b:netrw_curdir.">")

  " ------------
  " (local only) {{{3
  " ------------
  if a:islocal
"   call Decho("local only:")

   " Set up ShellCmdPost handling.  Append current buffer to browselist
   call s:LocalFastBrowser()

  " handle g:netrw_keepdir: set vim's current directory to netrw's notion of the current directory {{{3
   if !g:netrw_keepdir
"    call Decho("handle g:netrw_keepdir=".g:netrw_keepdir.": getcwd<".getcwd()."> acd=".&acd)
"    call Decho("l:acd".(exists("&l:acd")? "=".&l:acd : " doesn't exist"))
    if !exists("&l:acd") || !&l:acd
"     call Decho('exe keepjumps lcd '.fnameescape(b:netrw_curdir))
     try
      exe 'keepjumps lcd '.fnameescape(b:netrw_curdir)
     catch /^Vim\%((\a\+)\)\=:E472/
      call netrw#ErrorMsg(s:ERROR,"unable to change directory to <".b:netrw_curdir."> (permissions?)",61)
      if exists("w:netrw_prvdir")
       let b:netrw_curdir= w:netrw_prvdir
      else
       call s:NetrwOptionRestore("w:")
       setlocal noma nomod nowrap
       let b:netrw_curdir= dirname
"       call Decho("ro=".&l:ro." ma=".&l:ma." mod=".&l:mod." wrap=".&l:wrap)
"       call Dret("s:NetrwBrowse : reusing buffer#".(exists("bufnum")? bufnum : 'N/A')."<".dirname."> getcwd<".getcwd().">")
       return
      endif
     endtry
    endif
   endif

  " --------------------------------
  " remote handling: {{{3
  " --------------------------------
  else
"   call Decho("remote only:")

   " analyze a:dirname and g:netrw_list_cmd {{{4
"   call Decho("b:netrw_curdir<".(exists("b:netrw_curdir")? b:netrw_curdir : "doesn't exist")."> a:dirname<".a:dirname.">")
   if a:dirname =~ "^NetrwTreeListing\>"
    let dirname= b:netrw_curdir
"    call Decho("(dirname was ".a:dirname.") dirname<".dirname.">")
   elseif exists("w:netrw_liststyle") && w:netrw_liststyle == s:TREELIST && exists("b:netrw_curdir")
    let dirname= substitute(b:netrw_curdir,'\\','/','g')
    if dirname !~ '/$'
     let dirname= dirname.'/'
    endif
    let b:netrw_curdir = dirname
"    call Decho("(liststyle is TREELIST) dirname<".dirname.">")
   else
    let dirname = substitute(a:dirname,'\\','/','g')
"    call Decho("(normal) dirname<".dirname.">")
   endif

   let dirpat  = '^\(\w\{-}\)://\(\w\+@\)\=\([^/]\+\)/\(.*\)$'
   if dirname !~ dirpat
    if !exists("g:netrw_quiet")
     call netrw#ErrorMsg(s:ERROR,"netrw doesn't understand your dirname<".dirname.">",20)
    endif
    call s:NetrwOptionRestore("w:")
    setlocal noma nomod nowrap
"    call Decho("ro=".&l:ro." ma=".&l:ma." mod=".&l:mod." wrap=".&l:wrap)
"    call Dret("s:NetrwBrowse : badly formatted dirname<".dirname.">")
    return
   endif
   let b:netrw_curdir= dirname
"   call Decho("b:netrw_curdir<".b:netrw_curdir."> (remote)")
  endif  " (additional remote handling)

  " -----------------------
  " Directory Listing: {{{3
  " -----------------------
  call s:BrowserMaps(a:islocal)
  call s:PerformListing(a:islocal)

  " The s:LocalBrowseShellCmdRefresh() function is called by an autocmd
  " installed by s:LocalFastBrowser() when g:netrw_fastbrowse <= 1 (ie. slow, medium speed).
  " However, s:NetrwBrowse() causes the ShellCmdPost event itself to fire once; setting
  " the variable below avoids that second refresh of the screen.  The s:LocalBrowseShellCmdRefresh()
  " function gets called due to that autocmd; it notices that the following variable is set
  " and skips the refresh and sets s:locbrowseshellcmd to zero. Oct 13, 2008
  let s:locbrowseshellcmd= 1

"  call Decho("ro=".&l:ro." ma=".&l:ma." mod=".&l:mod." wrap=".&l:wrap)
"  call Dret("s:NetrwBrowse : did PerformListing")
  return
endfun

" ---------------------------------------------------------------------
" s:NetrwFileInfo: supports qf (query for file information) {{{2
fun! s:NetrwFileInfo(islocal,fname)
"  call Dfunc("s:NetrwFileInfo(islocal=".a:islocal." fname<".a:fname.">)")
  if a:islocal
   if (has("unix") || has("macunix")) && executable("/bin/ls")
    if exists("b:netrw_curdir")
"     call Decho('using ls with b:netrw_curdir<'.b:netrw_curdir.'>')
     if b:netrw_curdir =~ '/$'
      echo system("/bin/ls -lsad ".shellescape(b:netrw_curdir.a:fname))
     else
      echo system("/bin/ls -lsad ".shellescape(b:netrw_curdir."/".a:fname))
     endif
    else
"     call Decho('using ls '.a:fname." using cwd<".getcwd().">")
     echo system("/bin/ls -lsad ".shellescape(a:fname))
    endif
   else
    " use vim functions to return information about file below cursor
"    call Decho("using vim functions to query for file info")
    if !isdirectory(a:fname) && !filereadable(a:fname) && a:fname =~ '[*@/]'
     let fname= substitute(a:fname,".$","","")
    else
     let fname= a:fname
    endif
    let t  = getftime(fname)
    let sz = getfsize(fname)
    echo a:fname.":  ".sz."  ".strftime(g:netrw_timefmt,getftime(fname))
"    call Decho(fname.":  ".sz."  ".strftime(g:netrw_timefmt,getftime(fname)))
   endif
  else
   echo "sorry, \"qf\" not supported yet for remote files"
  endif
"  call Dret("s:NetrwFileInfo")
endfun

" ---------------------------------------------------------------------
" s:NetrwGetBuffer: {{{2
"   returns 0=cleared buffer
"           1=re-used buffer
fun! s:NetrwGetBuffer(islocal,dirname)
"  call Dfunc("s:NetrwGetBuffer(islocal=".a:islocal." dirname<".a:dirname.">) liststyle=".g:netrw_liststyle)
  let dirname= a:dirname

  " re-use buffer if possible {{{3
"  call Decho("--re-use a buffer if possible--")
  if exists("w:netrw_liststyle") && w:netrw_liststyle == s:TREELIST
   " find NetrwTreeList buffer if there is one
   if exists("w:netrw_treebufnr") && w:netrw_treebufnr > 0
"    call Decho("  re-use w:netrw_treebufnr=".w:netrw_treebufnr)
    let eikeep= &ei
    set ei=all
    exe "b ".w:netrw_treebufnr
    let &ei= eikeep
"    call Dret("s:NetrwGetBuffer : bufnum#".w:netrw_treebufnr."<NetrwTreeListing>")
    return
   endif
   let bufnum= -1
"   call Decho("  liststyle=TREE but w:netrw_treebufnr doesn't exist")

  else
   " find buffer number of buffer named precisely the same as dirname {{{3
"   call Decho("--find buffer numnber of buffer named precisely the same as dirname--")
"   call Dredir("ls!")

   " get dirname and associated buffer number
   let bufnum  = bufnr(escape(dirname,'\'))
"   call Decho("  find buffer<".dirname.">'s number ")
"   call Decho("  bufnr(dirname<".escape(dirname,'\').">)=".bufnum)

   if bufnum < 0 && dirname !~ '/$'
    " trying appending a trailing /
"    call Decho("  try appending a trailing / to dirname<".dirname.">")
    let bufnum= bufnr(escape(dirname.'/','\'))
    if bufnum > 0
     let dirname= dirname.'/'
    endif
   endif

   if bufnum < 0 && dirname =~ '/$'
    " trying removing a trailing /
"    call Decho("  try removing a trailing / from dirname<".dirname.">")
    let bufnum= bufnr(escape(substitute(dirname,'/$','',''),'\'))
    if bufnum > 0
     let dirname= substitute(dirname,'/$','','')
    endif
   endif

"   call Decho("  findbuf1: bufnum=bufnr('".dirname."')=".bufnum." bufname(".bufnum.")<".bufname(bufnum)."> (initial)")
   " note: !~ was used just below, but that means using ../ to go back would match (ie. abc/def/  and abc/ matches)
   if bufnum > 0 && bufname(bufnum) != dirname && bufname(bufnum) != '.'
    " handle approximate matches
"    call Decho("  handling approx match: bufnum#%d<".bufname(bufnum)."> approx=dirname<".dirname.">")
    let ibuf    = 1
    let buflast = bufnr("$")
"    call Decho("  findbuf2: buflast=".buflast)
    while ibuf <= buflast
     let bname= substitute(bufname(ibuf),'\\','/','g')
     let bname= substitute(bname,'.\zs/$','','')
"     call Decho("  findbuf3: dirname<".dirname."> bufname(".ibuf.")<".bname.">")
     if bname != '' && dirname =~ '/'.bname.'/\=$' | break | endif
     if bname   =~ '^'.dirname.'/\=$' | break | endif
     if dirname =~ '^'.bname.'/$'     | break | endif
     let ibuf= ibuf + 1
    endwhile
    if ibuf > buflast
     let bufnum= -1
    else
     let bufnum= ibuf
    endif
"    call Decho("  findbuf4: bufnum=".bufnum." (ibuf=".ibuf." buflast=".buflast.")")
   endif
  endif

  " get enew buffer and name it -or- re-use buffer {{{3
"  call Decho("--get enew buffer and name it OR re-use buffer-- (bufnum=".bufnum.")")
  mark '
  if bufnum < 0 || !bufexists(bufnum)
   call s:NetrwEnew(dirname)
"   call Decho("  got enew buffer#".bufnr("%")." (altbuf<".expand("#").">)")
   " name the buffer
   if exists("w:netrw_liststyle") && w:netrw_liststyle == s:TREELIST
    " Got enew buffer; transform into a NetrwTreeListing
"    call Decho("--transform enew buffer#".bufnr("%")." into a NetrwTreeListing --")
    if !exists("s:netrw_treelistnum")
     let s:netrw_treelistnum= 1
    else
     let s:netrw_treelistnum= s:netrw_treelistnum + 1
    endif
    let w:netrw_treebufnr= bufnr("%")
"    call Decho("  exe silent! keepalt file NetrwTreeListing ".fnameescape(s:netrw_treelistnum))
    exe 'silent! keepalt file NetrwTreeListing\ '.fnameescape(s:netrw_treelistnum)
    nnoremap <silent> <buffer> [	:silent call <SID>TreeListMove('[')<cr>
    nnoremap <silent> <buffer> ]	:silent call <SID>TreeListMove(']')<cr>
    nnoremap <silent> <buffer> [[       :silent call <SID>TreeListMove('[')<cr>
    nnoremap <silent> <buffer> ]]       :silent call <SID>TreeListMove(']')<cr>
"    call Decho("  tree listing#".s:netrw_treelistnum." bufnr=".w:netrw_treebufnr)
   else
"    let v:errmsg= "" " Decho
    let escdirname= fnameescape(dirname)
"    call Decho("  errmsg<".v:errmsg."> bufnr(".escdirname.")=".bufnr(escdirname)."<".bufname(bufnr(escdirname)).">")
"    call Decho('  exe silent! keepalt file '.escdirname)
    exe 'silent! keepalt file '.escdirname
"    call Decho("  errmsg<".v:errmsg."> bufnr(".escdirname.")=".bufnr(escdirname)."<".bufname(bufnr(escdirname)).">")
   endif
"   call Decho("  named enew buffer#".bufnr("%")."<".bufname("%").">")

  else " Re-use the buffer
"   call Decho("--re-use buffer#".bufnum.": --")
   let eikeep= &ei
   set ei=all
   if getline(2) =~ '^" Netrw Directory Listing'
"    call Decho("  re-use buffer#".bufnum."<".((bufnum > 0)? bufname(bufnum) : "")."> using:  keepalt b ".bufnum)
    exe "keepalt b ".bufnum
   else
"    call Decho("  reusing buffer#".bufnum."<".((bufnum > 0)? bufname(bufnum) : "")."> using:  b ".bufnum)
    exe "b ".bufnum
   endif
   if bufname("%") == '.'
"    call Decho("exe silent! keepalt file ".fnameescape(getcwd()))
    exe "silent! keepalt file ".fnameescape(getcwd())
   endif
   let &ei= eikeep
   if line("$") <= 1
    call s:NetrwListSettings(a:islocal)
"    call Dret("s:NetrwGetBuffer 0 : re-using buffer#".bufnr("%").", but its empty, so refresh it")
    return 0
   elseif exists("w:netrw_liststyle") && w:netrw_liststyle == s:TREELIST
"    call Decho("--re-use tree listing--")
"    call Decho("  clear buffer<".expand("%")."> with :%d")
    silent %d
    call s:NetrwListSettings(a:islocal)
"    call Dret("s:NetrwGetBuffer 0 : re-using buffer#".bufnr("%").", but treelist mode always needs a refresh")
    return 0
   else
"    call Dret("s:NetrwGetBuffer 1 : buf#".bufnr("%"))
    return 1
   endif
  endif

  " do netrw settings: make this buffer not-a-file, modifiable, not line-numbered, etc {{{3
  "     fastbrowse  Local  Remote   Hiding a buffer implies it may be re-used (fast)
  "  slow   0         D      D      Deleting a buffer implies it will not be re-used (slow)
  "  med    1         D      H
  "  fast   2         H      H
"  call Decho("--do netrw settings: make this buffer not-a-file, modifiable, not line-numbered, etc--")
  let fname= expand("%")
  call s:NetrwListSettings(a:islocal)
"  call Decho("exe keepalt file ".fnameescape(fname))
  exe "keepalt file ".fnameescape(fname)

  " delete all lines from buffer {{{3
"  call Decho("--delete all lines from buffer--")
"  call Decho("  clear buffer<".expand("%")."> with :%d")
  keepalt silent! %d

"  call Dret("s:NetrwGetBuffer 0 : buf#".bufnr("%"))
  return 0
endfun

" ---------------------------------------------------------------------
" s:NetrwGetcwd: get the current directory. {{{2
"   Change backslashes to forward slashes, if any.
"   If doesc is true, escape certain troublesome characters
fun! s:NetrwGetcwd(doesc)
"  call Dfunc("NetrwGetcwd(doesc=".a:doesc.")")
  let curdir= substitute(getcwd(),'\\','/','ge')
  if curdir !~ '[\/]$'
   let curdir= curdir.'/'
  endif
  if a:doesc
   let curdir= fnameescape(curdir)
  endif
"  call Dret("NetrwGetcwd <".curdir.">")
  return curdir
endfun

" ---------------------------------------------------------------------
"  s:NetrwGetWord: it gets the directory/file named under the cursor {{{2
fun! s:NetrwGetWord()
"  call Dfunc("s:NetrwGetWord() line#".line(".")." liststyle=".g:netrw_liststyle." virtcol=".virtcol("."))
  call s:UseBufWinVars()

  " insure that w:netrw_liststyle is set up
  if !exists("w:netrw_liststyle")
   if exists("g:netrw_liststyle")
    let w:netrw_liststyle= g:netrw_liststyle
   else
    let w:netrw_liststyle= s:THINLIST
   endif
"   call Decho("w:netrw_liststyle=".w:netrw_liststyle)
  endif

  if exists("w:netrw_bannercnt") && line(".") < w:netrw_bannercnt
   " Active Banner support
"   call Decho("active banner handling")
   norm! 0
   let dirname= "./"
   let curline= getline('.')

   if curline =~ '"\s*Sorted by\s'
    norm s
    let s:netrw_skipbrowse= 1
    echo 'Pressing "s" also works'

   elseif curline =~ '"\s*Sort sequence:'
    let s:netrw_skipbrowse= 1
    echo 'Press "S" to edit sorting sequence'

   elseif curline =~ '"\s*Quick Help:'
    norm ?
    let s:netrw_skipbrowse= 1
    echo 'Pressing "?" also works'

   elseif curline =~ '"\s*\%(Hiding\|Showing\):'
    norm a
    let s:netrw_skipbrowse= 1
    echo 'Pressing "a" also works'

   elseif line("$") > w:netrw_bannercnt
    exe 'silent keepjumps '.w:netrw_bannercnt
   endif

  elseif w:netrw_liststyle == s:THINLIST
"   call Decho("thin column handling")
   norm! 0
   let dirname= getline('.')

  elseif w:netrw_liststyle == s:LONGLIST
"   call Decho("long column handling")
   norm! 0
   let dirname= substitute(getline('.'),'^\(\%(\S\+ \)*\S\+\).\{-}$','\1','e')

  elseif w:netrw_liststyle == s:TREELIST
"   call Decho("treelist handling")
   let dirname= substitute(getline('.'),'^\(| \)*','','e')

  else
"   call Decho("obtain word from wide listing")
   let dirname= getline('.')

   if !exists("b:netrw_cpf")
    let b:netrw_cpf= 0
    exe 'silent keepjumps '.w:netrw_bannercnt.',$g/^./if virtcol("$") > b:netrw_cpf|let b:netrw_cpf= virtcol("$")|endif'
"   call Decho("computed cpf=".b:netrw_cpf)
   endif

"   call Decho("buf#".bufnr("%")."<".bufname("%").">")
   let filestart = (virtcol(".")/b:netrw_cpf)*b:netrw_cpf
"   call Decho("filestart= ([virtcol=".virtcol(".")."]/[b:netrw_cpf=".b:netrw_cpf."])*b:netrw_cpf=".filestart."  bannercnt=".w:netrw_bannercnt)
"   call Decho("1: dirname<".dirname.">")
   if filestart == 0
    norm! 0ma
   else
    call cursor(line("."),filestart+1)
    norm! ma
   endif
   let rega= @a
   let eofname= filestart + b:netrw_cpf + 1
   if eofname <= col("$")
    call cursor(line("."),filestart+b:netrw_cpf+1)
    norm! "ay`a
   else
    norm! "ay$
   endif
   let dirname = @a
   let @a      = rega
"   call Decho("2: dirname<".dirname.">")
   let dirname= substitute(dirname,'\s\+$','','e')
"   call Decho("3: dirname<".dirname.">")
  endif

  " symlinks are indicated by a trailing "@".  Remove it before further processing.
  let dirname= substitute(dirname,"@$","","")

  " executables are indicated by a trailing "*".  Remove it before further processing.
  let dirname= substitute(dirname,"\*$","","")

"  call Dret("s:NetrwGetWord <".dirname.">")
  return dirname
endfun

" ---------------------------------------------------------------------
" s:NetrwListSettings: {{{2
fun! s:NetrwListSettings(islocal)
"  call Dfunc("s:NetrwListSettings(islocal=".a:islocal.")")
  let fname= bufname("%")
"  call Decho("setlocal bt=nofile nobl ma nonu nowrap noro")
  setlocal bt=nofile nobl ma nonu nowrap noro
"  call Decho("exe keepalt file ".fnameescape(fname))
  exe "keepalt file ".fnameescape(fname)
  if g:netrw_use_noswf
   setlocal noswf
  endif
"  call Dredir("ls!")
"  call Decho("exe setlocal ts=".g:netrw_maxfilenamelen)
  exe "setlocal ts=".g:netrw_maxfilenamelen
  setlocal isk+=.,~,-
  if g:netrw_fastbrowse > a:islocal
   setlocal bh=hide
  else
   setlocal bh=delete
  endif
"  call Dret("s:NetrwListSettings")
endfun

" ---------------------------------------------------------------------
"  s:NetrwListStyle: {{{2
"  islocal=0: remote browsing
"         =1: local browsing
fun! s:NetrwListStyle(islocal)
"  call Dfunc("NetrwListStyle(islocal=".a:islocal.") w:netrw_liststyle=".w:netrw_liststyle)
  let fname             = s:NetrwGetWord()
  if !exists("w:netrw_liststyle")|let w:netrw_liststyle= g:netrw_liststyle|endif
  let w:netrw_liststyle = (w:netrw_liststyle + 1) % s:MAXLIST
"  call Decho("fname<".fname.">")
"  call Decho("chgd w:netrw_liststyle to ".w:netrw_liststyle)
"  call Decho("b:netrw_curdir<".(exists("b:netrw_curdir")? b:netrw_curdir : "doesn't exist").">")

  if w:netrw_liststyle == s:THINLIST
   " use one column listing
"   call Decho("use one column list")
   let g:netrw_list_cmd = substitute(g:netrw_list_cmd,' -l','','ge')

  elseif w:netrw_liststyle == s:LONGLIST
   " use long list
"   call Decho("use long list")
   let g:netrw_list_cmd = g:netrw_list_cmd." -l"

  elseif w:netrw_liststyle == s:WIDELIST
   " give wide list
"   call Decho("use wide list")
   let g:netrw_list_cmd = substitute(g:netrw_list_cmd,' -l','','ge')

  elseif w:netrw_liststyle == s:TREELIST
"   call Decho("use tree list")
   let g:netrw_list_cmd = substitute(g:netrw_list_cmd,' -l','','ge')

  else
   call netrw#ErrorMsg(s:WARNING,"bad value for g:netrw_liststyle (=".w:netrw_liststyle.")",46)
   let g:netrw_liststyle = s:THINLIST
   let w:netrw_liststyle = g:netrw_liststyle
   let g:netrw_list_cmd  = substitute(g:netrw_list_cmd,' -l','','ge')
  endif
  setlocal ma noro
"  call Decho("setlocal ma noro")

  " clear buffer - this will cause NetrwBrowse/LocalBrowseCheck to do a refresh
"  call Decho("clear buffer<".expand("%")."> with :%d")
  %d

  " refresh the listing
  let svpos= netrw#NetrwSavePosn()
  call s:NetrwRefresh(a:islocal,s:NetrwBrowseChgDir(a:islocal,'./'))
  call netrw#NetrwRestorePosn(svpos)
  if w:netrw_liststyle != s:WIDELIST
   if g:netrw_cursorline == 2
    setlocal cursorline
    let &cursorcolumn= s:netrw_usercuc
   elseif g:netrw_cursorline
    setlocal cursorline
"    call Decho("setlocal cursorline")
   endif
  else
   if g:netrw_cursorline == 2
    setlocal cursorline cursorcolumn
"    call Decho("setlocal cursorline cursorcolumn")
   elseif g:netrw_cursorline
    let &cursorline= s:netrw_usercul
   endif
  endif

  " keep cursor on the filename
  silent keepjumps $
  let result= search('\%(^\%(|\+\s\)\=\|\s\{2,}\)\zs'.escape(fname,'.\[]*$^').'\%(\s\{2,}\|$\)','bc')
"  call Decho("search result=".result." w:netrw_bannercnt=".(exists("w:netrw_bannercnt")? w:netrw_bannercnt : 'N/A'))
  if result <= 0 && exists("w:netrw_bannercnt")
   exe "keepjumps ".w:netrw_bannercnt
  endif

"  call Dret("NetrwListStyle".(exists("w:netrw_liststyle")? ' : w:netrw_liststyle='.w:netrw_liststyle : ""))
endfun

" ---------------------------------------------------------------------
" s:NetrwBookmarkMenu: Uses menu priorities {{{2
"                      .2.[cnt] for bookmarks, and
"                      .3.[cnt] for history
"                      (see s:NetrwMenu())
fun! s:NetrwBookmarkMenu()
  if !exists("s:netrw_menucnt")
   return
  endif
"  call Dfunc("NetrwBookmarkMenu()  histcnt=".g:netrw_dirhist_cnt." menucnt=".s:netrw_menucnt)

  " the following test assures that gvim is running, has menus available, and has menus enabled.
  if has("gui") && has("menu") && has("gui_running") && &go =~ 'm' && g:netrw_menu
   if exists("g:NetrwTopLvlMenu")
"    call Decho("removing ".g:NetrwTopLvlMenu."Bookmarks menu item(s)")
    exe 'silent! unmenu '.g:NetrwTopLvlMenu.'Bookmarks'
    exe 'silent! unmenu '.g:NetrwTopLvlMenu.'Bookmarks\ and\ History.Bookmark\ Delete'
   endif
   if !exists("s:netrw_initbookhist")
    call s:NetrwBookHistRead()
   endif

   " show bookmarked places
   if exists("g:netrw_bookmarklist") && g:netrw_bookmarklist != []
    let cnt= 1
    for bmd in g:netrw_bookmarklist
"     call Decho('silent! menu '.g:NetrwMenuPriority.".2.".cnt." ".g:NetrwTopLvlMenu.'Bookmark.'.bmd.'	:e '.bmd)
     let bmd= escape(bmd,'. ')

     " show bookmarks for goto menu
     exe 'silent! menu '.g:NetrwMenuPriority.".2.".cnt." ".g:NetrwTopLvlMenu.'Bookmarks.'.bmd.'	:e '.bmd."\<cr>"

     " show bookmarks for deletion menu
     exe 'silent! menu '.g:NetrwMenuPriority.".8.2.".cnt." ".g:NetrwTopLvlMenu.'Bookmarks\ and\ History.Bookmark\ Delete.'.bmd.'	'.cnt."mB"
     let cnt= cnt + 1
    endfor

   endif

   " show directory browsing history
   let cnt     = g:netrw_dirhist_cnt
   let first   = 1
   let histcnt = 0
   while ( first || cnt != g:netrw_dirhist_cnt )
    let histcnt  = histcnt + 1
    let priority = g:netrw_dirhist_cnt + histcnt
    if exists("g:netrw_dirhist_{cnt}")
     let histdir= escape(g:netrw_dirhist_{cnt},'./&? ')
"     call Decho('silent! menu '.g:NetrwMenuPriority.".3.".priority." ".g:NetrwTopLvlMenu.'History.'.histdir.'	:e '.histdir)
     exe 'silent! menu '.g:NetrwMenuPriority.".3.".priority." ".g:NetrwTopLvlMenu.'History.'.histdir.'	:e '.histdir."\<cr>"
    endif
    let first = 0
    let cnt   = ( cnt - 1 ) % g:netrw_dirhistmax
    if cnt < 0
     let cnt= cnt + g:netrw_dirhistmax
    endif
   endwhile

  endif
"  call Dret("NetrwBookmarkMenu")
endfun

" ---------------------------------------------------------------------
"  s:NetrwBrowseChgDir: constructs a new directory based on the current {{{2
"                       directory and a new directory name.  Also, if the
"                       "new directory name" is actually a file,
"                       NetrwBrowseChgDir() edits the file.
fun! s:NetrwBrowseChgDir(islocal,newdir,...)
"  call Dfunc("s:NetrwBrowseChgDir(islocal=".a:islocal."> newdir<".a:newdir.">) a:0=".a:0." curpos<".string(getpos("."))."> b:netrw_curdir<".(exists("b:netrw_curdir")? b:netrw_curdir : "").">")

  if !exists("b:netrw_curdir")
   " Don't try to change-directory: this can happen, for example, when netrw#ErrorMsg has been called
   " and the current window is the NetrwMessage window.
"   call Decho("(NetrwBrowseChgDir) b:netrw_curdir doesn't exist!")
"   call Decho("getcwd<".getcwd().">")
"   call Dredir("ls!")
"   call Dret("s:NetrwBrowseChgDir")
   return
  endif

  call s:NetrwOptionSave("s:")
  call s:NetrwSafeOptions()
  let nbcd_curpos                = netrw#NetrwSavePosn()
  let s:nbcd_curpos_{bufnr('%')} = nbcd_curpos
  let dirname                    = substitute(b:netrw_curdir,'\\','/','ge')
  let newdir                     = a:newdir
  let dolockout                  = 0

  " set up o/s-dependent directory recognition pattern
  if has("amiga")
   let dirpat= '[\/:]$'
  else
   let dirpat= '[\/]$'
  endif
"  call Decho("dirname<".dirname.">  dirpat<".dirpat.">")

  if dirname !~ dirpat
   " apparently vim is "recognizing" that it is in a directory and
   " is removing the trailing "/".  Bad idea, so I put it back.
   let dirname= dirname.'/'
"   call Decho("adjusting dirname<".dirname.">")
  endif

  if newdir !~ dirpat
   " ------------
   " edit a file:
   " ------------
"   call Decho('case "handling a file": newdir<'.newdir.'> !~ dirpat<'.dirpat.">")
   if exists("w:netrw_liststyle") && w:netrw_liststyle == s:TREELIST && exists("w:netrw_treedict") && newdir !~ '^\(/\|\a:\)'
    let dirname= s:NetrwTreeDir()
    if dirname =~ '/$'
     let dirname= dirname.newdir
    else
     let dirname= s:NetrwTreeDir()."/".newdir
    endif
"    call Decho("tree listing")
   elseif newdir =~ '^\(/\|\a:\)'
    let dirname= newdir
   else
    let dirname= s:ComposePath(dirname,newdir)
   endif
"   call Decho("handling a file: dirname<".dirname."> (a:0=".a:0.")")
   " this lets NetrwBrowseX avoid the edit
   if a:0 < 1
"    call Decho("set up windows for editing<".fnameescape(dirname).">  didsplit=".(exists("s:didsplit")? s:didsplit : "doesn't exist"))
    call s:NetrwOptionRestore("s:")
    if !exists("s:didsplit")
     if     g:netrw_browse_split == 1
      new
      wincmd _
     elseif g:netrw_browse_split == 2
      rightb vert new
      wincmd |
     elseif g:netrw_browse_split == 3
      tabnew
     elseif g:netrw_browse_split == 4
      if s:NetrwPrevWinOpen(2) == 3
"       call Dret("s:NetrwBrowseChgDir")
       return
      endif
     else
      " handling a file, didn't split, so remove menu
"      call Decho("handling a file+didn't split, so remove menu")
      call s:NetrwMenu(0)
      " optional change to window
      if g:netrw_chgwin >= 1
       exe "keepjumps ".g:netrw_chgwin."wincmd w"
      endif
     endif
    endif
    " the point where netrw actually edits the (local) file
    " if its local only: LocalBrowseCheck() doesn't edit a file, but NetrwBrowse() will
    if a:islocal
"     call Decho("edit local file: exe e! ".fnameescape(dirname))
     exe "e! ".fnameescape(dirname)
    else
"     call Decho("remote file: NetrwBrowse will edit it")
    endif
    let dolockout= 1
   endif

  elseif newdir =~ '^/'
   " ---------------------------------
   " just go to the new directory spec
   " ---------------------------------
"   call Decho('case "just go to new directory spec": newdir<'.newdir.'>')
   let dirname= newdir
   call s:SetRexDir(a:islocal,dirname)
   call s:NetrwOptionRestore("s:")

  elseif newdir == './'
   " --------------------------
   " refresh the directory list
   " --------------------------
"   call Decho('case "refresh directory listing": newdir == "./"')
   call s:SetRexDir(a:islocal,dirname)

  elseif newdir == '../'
   " -------------------
   " go up one directory
   " -------------------
"   call Decho('case "go up one directory": newdir == "../"')

   if w:netrw_liststyle == s:TREELIST && exists("w:netrw_treedict")
    " force a refresh
"    call Decho("clear buffer<".expand("%")."> with :%d")
    setlocal noro ma
"    call Decho("setlocal noro ma")
    keepjumps %d
   endif

   if has("amiga")
    " amiga
"    call Decho('case "go up one directory": newdir == "../" and amiga')
    if a:islocal
     let dirname= substitute(dirname,'^\(.*[/:]\)\([^/]\+$\)','\1','')
     let dirname= substitute(dirname,'/$','','')
    else
     let dirname= substitute(dirname,'^\(.*[/:]\)\([^/]\+/$\)','\1','')
    endif
"    call Decho("amiga: dirname<".dirname."> (go up one dir)")

   else
    " unix or cygwin
"    call Decho('case "go up one directory": newdir == "../" and unix or cygwin')
    if a:islocal
     let dirname= substitute(dirname,'^\(.*\)/\([^/]\+\)/$','\1','')
     if dirname == ""
      let dirname= '/'
     endif
    else
     let dirname= substitute(dirname,'^\(\a\+://.\{-}/\{1,2}\)\(.\{-}\)\([^/]\+\)/$','\1\2','')
    endif
"    call Decho("unix: dirname<".dirname."> (go up one dir)")
   endif
   call s:SetRexDir(a:islocal,dirname)

  elseif exists("w:netrw_liststyle") && w:netrw_liststyle == s:TREELIST && exists("w:netrw_treedict")
"   call Decho('case liststyle is TREELIST and w:netrw_treedict exists')
   " force a refresh (for TREELIST, wait for NetrwTreeDir() to force the refresh)
   setlocal noro ma
"   call Decho("setlocal noro ma")
   if !(exists("w:netrw_liststyle") && w:netrw_liststyle == s:TREELIST && exists("b:netrw_curdir"))
"    call Decho("clear buffer<".expand("%")."> with :%d")
    keepjumps %d
   endif
   let treedir      = s:NetrwTreeDir()
   let s:treecurpos = nbcd_curpos
   let haskey= 0
"   call Decho("w:netrw_treedict<".string(w:netrw_treedict).">")

   " search treedict for tree dir as-is
   if has_key(w:netrw_treedict,treedir)
"    call Decho('....searched for treedir<'.treedir.'> : found it!')
    let haskey= 1
   else
"    call Decho('....searched for treedir<'.treedir.'> : not found')
   endif

   " search treedict for treedir with a / appended
   if !haskey && treedir !~ '/$'
    if has_key(w:netrw_treedict,treedir."/")
     let treedir= treedir."/"
"     call Decho('....searched.for treedir<'.treedir.'> found it!')
     let haskey = 1
    else
"     call Decho('....searched for treedir<'.treedir.'/> : not found')
    endif
   endif

   " search treedict for treedir with any trailing / elided
   if !haskey && treedir =~ '/$'
    let treedir= substitute(treedir,'/$','','')
    if has_key(w:netrw_treedict,treedir)
"     call Decho('....searched.for treedir<'.treedir.'> found it!')
     let haskey = 1
    else
"     call Decho('....searched for treedir<'.treedir.'> : not found')
    endif
   endif

   if haskey
    " close tree listing for selected subdirectory
"    call Decho("closing selected subdirectory<".dirname.">")
    call remove(w:netrw_treedict,treedir)
"    call Decho("removed     entry<".dirname."> from treedict")
"    call Decho("yielding treedict<".string(w:netrw_treedict).">")
    let dirname= w:netrw_treetop
   else
    " go down one directory
    let dirname= substitute(treedir,'/*$','/','')
"    call Decho("go down one dir: treedir<".treedir.">")
   endif
   call s:SetRexDir(a:islocal,dirname)

  else
   " go down one directory
   let dirname= s:ComposePath(dirname,newdir)
"   call Decho("go down one dir: dirname<".dirname."> newdir<".newdir.">")
   call s:SetRexDir(a:islocal,dirname)
  endif

  call s:NetrwOptionRestore("s:")
  if dolockout
"   call Decho("doing modification lockout settings: ma nomod noro")
   setlocal ma nomod noro
"   call Decho("setlocal ma nomod noro")
  endif

"  call Dret("s:NetrwBrowseChgDir <".dirname."> : curpos<".string(getpos(".")).">")
  return dirname
endfun

" ---------------------------------------------------------------------
" s:NetrwBrowseX:  allows users to write custom functions to operate on {{{2
"              files given their extension.  Passes 0=local, 1=remote
fun! netrw#NetrwBrowseX(fname,remote)
"  call Dfunc("NetrwBrowseX(fname<".a:fname."> remote=".a:remote.")")

  " set up the filename
  " (lower case the extension, make a local copy of a remote file)
  let exten= substitute(a:fname,'.*\.\(.\{-}\)','\1','e')
  if has("win32") || has("win95") || has("win64") || has("win16")
   let exten= substitute(exten,'^.*$','\L&\E','')
  endif
"  call Decho("exten<".exten.">")

  " seems kde systems often have gnome-open due to dependencies, even though
  " gnome-open's subsidiary display tools are largely absent.  Kde systems
  " usually have "kdeinit" running, though...  (tnx Mikolaj Machowski)
  if !exists("s:haskdeinit")
   if has("unix")
    let s:haskdeinit= system("ps -e") =~ 'kdeinit' 
    if v:shell_error
     let s:haskdeinit = 0
    endif
   else
    let s:haskdeinit= 0
   endif
"   call Decho("setting s:haskdeinit=".s:haskdeinit)
  endif

  if a:remote == 1
   " create a local copy
"   call Decho("a:remote=".a:remote.": create a local copy of <".a:fname.">")
   setlocal bh=delete
   call netrw#NetRead(3,a:fname)
   " attempt to rename tempfile
   let basename= substitute(a:fname,'^\(.*\)/\(.*\)\.\([^.]*\)$','\2','')
   let newname= substitute(s:netrw_tmpfile,'^\(.*\)/\(.*\)\.\([^.]*\)$','\1/'.basename.'.\3','')
"   call Decho("basename<".basename.">")
"   call Decho("newname <".newname.">")
   if rename(s:netrw_tmpfile,newname) == 0
    " renaming succeeded
    let fname= newname
   else
    " renaming failed
    let fname= s:netrw_tmpfile
   endif
  else
   let fname= a:fname
  endif
"  call Decho("fname<".fname.">")
"  call Decho("exten<".exten."> "."netrwFileHandlers#NFH_".exten."():exists=".exists("*netrwFileHandlers#NFH_".exten))

  " set up redirection
  if &srr =~ "%s"
   if (has("win32") || has("win95") || has("win64") || has("win16"))
    let redir= substitute(&srr,"%s","nul","")
   else
    let redir= substitute(&srr,"%s","/dev/null","")
   endif
  elseif (has("win32") || has("win95") || has("win64") || has("win16"))
   let redir= &srr . "nul"
  else
   let redir= &srr . "/dev/null"
  endif
"  call Decho("redir{".redir."} srr{".&srr."}")

  " extract any viewing options.  Assumes that they're set apart by quotes.
  if exists("g:netrw_browsex_viewer")
   if g:netrw_browsex_viewer =~ '\s'
    let viewer  = substitute(g:netrw_browsex_viewer,'\s.*$','','')
    let viewopt = substitute(g:netrw_browsex_viewer,'^\S\+\s*','','')." "
    let oviewer = ''
    let cnt     = 1
    while !executable(viewer) && viewer != oviewer
     let viewer  = substitute(g:netrw_browsex_viewer,'^\(\(^\S\+\s\+\)\{'.cnt.'}\S\+\)\(.*\)$','\1','')
     let viewopt = substitute(g:netrw_browsex_viewer,'^\(\(^\S\+\s\+\)\{'.cnt.'}\S\+\)\(.*\)$','\3','')." "
     let cnt     = cnt + 1
     let oviewer = viewer
"     call Decho("!exe: viewer<".viewer.">  viewopt<".viewopt.">")
    endwhile
   else
    let viewer  = g:netrw_browsex_viewer
    let viewopt = ""
   endif
"   call Decho("viewer<".viewer.">  viewopt<".viewopt.">")
  endif

  " execute the file handler
  if exists("g:netrw_browsex_viewer") && g:netrw_browsex_viewer == '-'
"   call Decho("g:netrw_browsex_viewer<".g:netrw_browsex_viewer.">")
   let ret= netrwFileHandlers#Invoke(exten,fname)

  elseif exists("g:netrw_browsex_viewer") && executable(viewer)
"   call Decho("g:netrw_browsex_viewer<".g:netrw_browsex_viewer.">")
"   call Decho("exe silent !".viewer." ".viewopt.shellescape(fname,1).redir)
   exe "silent !".viewer." ".viewopt.shellescape(fname,1).redir
   let ret= v:shell_error

  elseif has("win32") || has("win64")
"   call Decho('exe silent !start rundll32 url.dll,FileProtocolHandler '.shellescape(fname,1))
   exe 'silent !start rundll32 url.dll,FileProtocolHandler '.shellescape(fname,1)
   call inputsave()|call input("Press <cr> to continue")|call inputrestore()
   let ret= v:shell_error

  elseif has("unix") && executable("gnome-open") && !s:haskdeinit
"   call Decho("exe silent !gnome-open ".shellescape(fname,1)." ".redir)
   exe "silent !gnome-open ".shellescape(fname,1).redir
   let ret= v:shell_error

  elseif has("unix") && executable("kfmclient") && s:haskdeinit
"   call Decho("exe silent !kfmclient exec ".shellescape(fname,1)." ".redir)
   exe "silent !kfmclient exec ".shellescape(fname,1)." ".redir
   let ret= v:shell_error

  elseif has("macunix") && executable("open")
"   call Decho("exe silent !open ".shellescape(fname,1)." ".redir)
   exe "silent !open ".shellescape(fname,1)." ".redir
   let ret= v:shell_error

  else
   " netrwFileHandlers#Invoke() always returns 0
   let ret= netrwFileHandlers#Invoke(exten,fname)
  endif

  " if unsuccessful, attempt netrwFileHandlers#Invoke()
  if ret
   let ret= netrwFileHandlers#Invoke(exten,fname)
  endif

  " restoring redraw! after external file handlers
  redraw!

  " cleanup: remove temporary file,
  "          delete current buffer if success with handler,
  "          return to prior buffer (directory listing)
  "          Feb 12, 2008: had to de-activiate removal of
  "          temporary file because it wasn't getting seen.
"  if a:remote == 1 && fname != a:fname
"   call Decho("deleting temporary file<".fname.">")
"   call s:NetrwDelete(fname)
"  endif

  if a:remote == 1
   setlocal bh=delete bt=nofile
   if g:netrw_use_noswf
    setlocal noswf
   endif
   exe "norm! \<c-o>"
"   redraw!
  endif

"  call Dret("NetrwBrowseX")
endfun

" ---------------------------------------------------------------------
" netrw#Explore: launch the local browser in the directory of the current file {{{2
"          indx:  == -1: Nexplore
"                 == -2: Pexplore
"                 ==  +: this is overloaded:
"                      * If Nexplore/Pexplore is in use, then this refers to the
"                        indx'th item in the w:netrw_explore_list[] of items which
"                        matched the */pattern **/pattern *//pattern **//pattern
"                      * If Hexplore or Vexplore, then this will override
"                        g:netrw_winsize to specify the qty of rows or columns the
"                        newly split window should have.
"          dosplit==0: the window will be split iff the current file has been modified
"          dosplit==1: the window will be split before running the local browser
"          style == 0: Explore     style == 1: Explore!
"                == 2: Hexplore    style == 3: Hexplore!
"                == 4: Vexplore    style == 5: Vexplore!
"                == 6: Texplore
"DechoTabOn
fun! netrw#Explore(indx,dosplit,style,...)
"  call Dfunc("netrw#Explore(indx=".a:indx." dosplit=".a:dosplit." style=".a:style.",a:1<".a:1.">) &modified=".&modified." a:0=".a:0)
  if !exists("b:netrw_curdir")
   let b:netrw_curdir= getcwd()
"   call Decho("set b:netrw_curdir<".b:netrw_curdir."> (used getcwd)")
  endif
  let curfile= b:netrw_curdir
"  call Decho("curfile<".curfile.">")

  " save registers
  silent! let keepregstar = @*
  silent! let keepregplus = @+
  silent! let keepregslash= @/

  " if dosplit or file has been modified
  if a:dosplit || &modified || a:style == 6
"   call Decho("case: dosplit=".a:dosplit." modified=".&modified." a:style=".a:style)
   call s:SaveWinVars()
   let winsize= g:netrw_winsize
   if a:indx > 0
    let winsize= a:indx
   endif

   if a:style == 0      " Explore, Sexplore
"    call Decho("style=0: Explore or Sexplore")
    exe winsize."wincmd s"

   elseif a:style == 1  "Explore!, Sexplore!
"    call Decho("style=1: Explore! or Sexplore!")
    exe winsize."wincmd v"

   elseif a:style == 2  " Hexplore
"    call Decho("style=2: Hexplore")
    exe "bel ".winsize."wincmd s"

   elseif a:style == 3  " Hexplore!
"    call Decho("style=3: Hexplore!")
    exe "abo ".winsize."wincmd s"

   elseif a:style == 4  " Vexplore
"    call Decho("style=4: Vexplore")
    exe "lefta ".winsize."wincmd v"

   elseif a:style == 5  " Vexplore!
"    call Decho("style=5: Vexplore!")
    exe "rightb ".winsize."wincmd v"

   elseif a:style == 6  " Texplore
    call s:SaveBufVars()
"    call Decho("style  = 6: Texplore")
    tabnew
    call s:RestoreBufVars()
   endif
   call s:RestoreWinVars()
  endif
  norm! 0

  if a:0 > 0
"   call Decho("case [a:0=".a:0."]>0: a:1<".a:1.">")
   if a:1 =~ '^\~' && (has("unix") || (exists("g:netrw_cygwin") && g:netrw_cygwin))
    let dirname= substitute(a:1,'\~',expand("$HOME"),'')
"    call Decho("using dirname<".dirname.">  (case: ~ && unix||cygwin)")
   elseif a:1 == '.'
    let dirname= exists("b:netrw_curdir")? b:netrw_curdir : getcwd()
    if dirname !~ '/$'
     let dirname= dirname."/"
    endif
"    call Decho("using dirname<".dirname.">  (case: ".(exists("b:netrw_curdir")? "b:netrw_curdir" : "getcwd()").")")
   elseif a:1 =~ '\$'
    let dirname= expand(a:1)
   else
    let dirname= a:1
"    call Decho("using dirname<".dirname.">")
   endif
  else
   " clear explore
"   call Decho("clearing explore variables")
   2match none
   if exists("s:explore_match")        |unlet s:explore_match        |endif
   if exists("s:explore_indx")         |unlet s:explore_indx         |endif
   if exists("s:dirstarstar")          |unlet s:dirstarstar          |endif
   if exists("s:dirstarstar")          |unlet s:dirstarstar          |endif
   if exists("w:netrw_explore_indx")   |unlet w:netrw_explore_indx   |endif
   if exists("w:netrw_explore_listlen")|unlet w:netrw_explore_listlen|endif
   if exists("w:netrw_explore_list")   |unlet w:netrw_explore_list   |endif
   if exists("w:netrw_explore_bufnr")  |unlet w:netrw_explore_bufnr  |endif
"   redraw!
   echo " "
   echo " "
"   call Dret("netrw#Explore : cleared list")
   return
  endif

  if dirname =~ '/\*\*/'
   " handle .../**/.../filepat
"   call Decho("case Explore .../**/.../filepat")
   let prefixdir= substitute(dirname,'^\(.\{-}\)\*\*.*$','\1','')
   if prefixdir =~ '^/' || (prefixdir =~ '^\a:/' && (has("win32") || has("win95") || has("win64") || has("win16")))
    let b:netrw_curdir = prefixdir
   else
    let b:netrw_curdir= getcwd().'/'.prefixdir
   endif
   let dirname= substitute(dirname,'^.\{-}\(\*\*/.*\)$','\1','')
   let starpat= 4;
"   call Decho("pwd<".getcwd()."> dirname<".dirname.">")
"   call Decho("case Explore ../**/../filepat (starpat=".starpat.")")

  elseif dirname =~ '^\*//'
   " starpat=1: Explore *//pattern   (current directory only search for files containing pattern)
"   call Decho("case Explore *//pattern")
   let pattern= substitute(dirname,'^\*//\(.*\)$','\1','')
   let starpat= 1
"   call Decho("Explore *//pat: (starpat=".starpat.") dirname<".dirname."> -> pattern<".pattern.">")
   if &hls | let keepregslash= s:ExplorePatHls(pattern) | endif

  elseif dirname =~ '^\*\*//'
   " starpat=2: Explore **//pattern  (recursive descent search for files containing pattern)
"   call Decho("case Explore **//pattern")
   let pattern= substitute(dirname,'^\*\*//','','')
   let starpat= 2
"   call Decho("Explore **//pat: (starpat=".starpat.") dirname<".dirname."> -> pattern<".pattern.">")

  elseif dirname =~ '^\*/'
   " starpat=3: Explore */filepat   (search in current directory for filenames matching filepat)
   let starpat= 3
"   call Decho("case Explore */filepat (starpat=".starpat.")")

  elseif dirname=~ '^\*\*/'
   " starpat=4: Explore **/filepat  (recursive descent search for filenames matching filepat)
   let starpat= 4
"   call Decho("case Explore **/filepat (starpat=".starpat.")")
  else
   let starpat= 0
  endif

  if starpat == 0 && a:indx >= 0
   " [Explore Hexplore Vexplore Sexplore] [dirname]
"   call Decho("case dirname<".dirname."> a:indx=".a:indx.": Explore Hexplore Vexplore Sexplore")
   if dirname == ""
    let dirname= substitute(expand("%:p"),'^\(.*[/\\]\)[^/\\]*$','\1','e')
   endif
   if dirname =~ '^scp:' || dirname =~ '^ftp:'
"    call Decho("calling NetrwBrowse(0,dirname<".dirname.">)")
    call s:NetrwBrowse(0,dirname)
   else
    if dirname == ""|let dirname= getcwd()|endif
"    call Decho("calling LocalBrowseCheck(dirname<".dirname.">)")
    call netrw#LocalBrowseCheck(dirname)
   endif

"   call Decho("curfile<".curfile.">")
   if has("win32") || has("win95") || has("win64") || has("win16")
    call search('\<'.substitute(curfile,'^.*[/\\]','','e').'\>','cW')
   else
    call search('\<'.substitute(curfile,'^.*/','','e').'\>','cW')
   endif

  " starpat=1: Explore *//pattern  (current directory only search for files containing pattern)
  " starpat=2: Explore **//pattern (recursive descent search for files containing pattern)
  " starpat=3: Explore */filepat   (search in current directory for filenames matching filepat)
  " starpat=4: Explore **/filepat  (recursive descent search for filenames matching filepat)
  elseif a:indx <= 0
   " Nexplore, Pexplore, Explore: handle starpat
"   call Decho("case Nexplore, Pexplore, <s-down>, <s-up>: starpat=".starpat." a:indx=".a:indx)
   if !mapcheck("<s-up>","n") && !mapcheck("<s-down>","n") && exists("b:netrw_curdir")
"    call Decho("set up <s-up> and <s-down> maps")
    let s:didstarstar= 1
    nnoremap <buffer> <silent> <s-up>	:Pexplore<cr>
    nnoremap <buffer> <silent> <s-down>	:Nexplore<cr>
   endif

   if has("path_extra")
"    call Decho("starpat=".starpat.": has +path_extra")
    if !exists("w:netrw_explore_indx")
     let w:netrw_explore_indx= 0
    endif

    let indx = a:indx
"    call Decho("starpat=".starpat.": set indx= [a:indx=".indx."]")

    if indx == -1
     " Nexplore
"     call Decho("case Nexplore with starpat=".starpat.": (indx=".indx.")")
     if !exists("w:netrw_explore_list") " sanity check
      call netrw#ErrorMsg(s:WARNING,"using Nexplore or <s-down> improperly; see help for netrw-starstar",40)
      silent! let @* = keepregstar
      silent! let @+ = keepregstar
      silent! let @/ = keepregslash
"      call Dret("netrw#Explore")
      return
     endif
     let indx= w:netrw_explore_indx
     if indx < 0                        | let indx= 0                           | endif
     if indx >= w:netrw_explore_listlen | let indx= w:netrw_explore_listlen - 1 | endif
     let curfile= w:netrw_explore_list[indx]
"     call Decho("indx=".indx." curfile<".curfile.">")
     while indx < w:netrw_explore_listlen && curfile == w:netrw_explore_list[indx]
      let indx= indx + 1
"      call Decho("indx=".indx." (Nexplore while loop)")
     endwhile
     if indx >= w:netrw_explore_listlen | let indx= w:netrw_explore_listlen - 1 | endif
"     call Decho("Nexplore: indx= [w:netrw_explore_indx=".w:netrw_explore_indx."]=".indx)

    elseif indx == -2
     " Pexplore
"     call Decho("case Pexplore with starpat=".starpat.": (indx=".indx.")")
     if !exists("w:netrw_explore_list") " sanity check
      call netrw#ErrorMsg(s:WARNING,"using Pexplore or <s-up> improperly; see help for netrw-starstar",41)
      silent! let @* = keepregstar
      silent! let @+ = keepregstar
      silent! let @/ = keepregslash
"      call Dret("netrw#Explore")
      return
     endif
     let indx= w:netrw_explore_indx
     if indx < 0                        | let indx= 0                           | endif
     if indx >= w:netrw_explore_listlen | let indx= w:netrw_explore_listlen - 1 | endif
     let curfile= w:netrw_explore_list[indx]
"     call Decho("indx=".indx." curfile<".curfile.">")
     while indx >= 0 && curfile == w:netrw_explore_list[indx]
      let indx= indx - 1
"      call Decho("indx=".indx." (Pexplore while loop)")
     endwhile
     if indx < 0                        | let indx= 0                           | endif
"     call Decho("Pexplore: indx= [w:netrw_explore_indx=".w:netrw_explore_indx."]=".indx)

    else
     " Explore -- initialize
     " build list of files to Explore with Nexplore/Pexplore
"     call Decho("starpat=".starpat.": case Explore: initialize (indx=".indx.")")
     let w:netrw_explore_indx= 0
     if !exists("b:netrw_curdir")
      let b:netrw_curdir= getcwd()
     endif
"     call Decho("starpat=".starpat.": b:netrw_curdir<".b:netrw_curdir.">")

     " switch on starpat to build the w:netrw_explore_list of files
     if starpat == 1
      " starpat=1: Explore *//pattern  (current directory only search for files containing pattern)
"      call Decho("starpat=".starpat.": build *//pattern list")
"      call Decho("pattern<".pattern.">")
      exe "vimgrep /".pattern."/gj ".fnameescape(b:netrw_curdir)."/*"
      let w:netrw_explore_list = map(getqflist(),'bufname(v:val.bufnr)')
      if &hls | let keepregslash= s:ExplorePatHls(pattern) | endif

     elseif starpat == 2
      " starpat=2: Explore **//pattern (recursive descent search for files containing pattern)
"      call Decho("starpat=".starpat.": build **//pattern list")
      try
       exe "silent vimgrep /".pattern."/gj "."**/*"
      catch /^Vim\%((\a\+)\)\=:E480/
      	call netrw#ErrorMsg(s:WARNING,'no files matched pattern<'.pattern.'>',45)
       if &hls | let keepregslash= s:ExplorePatHls(pattern) | endif
       silent! let @* = keepregstar
       silent! let @+ = keepregstar
       silent! let @/ = keepregslash
"       call Dret("netrw#Explore : no files matched pattern")
       return
      endtry
      let s:netrw_curdir       = b:netrw_curdir
      let w:netrw_explore_list = getqflist()
      let w:netrw_explore_list = map(w:netrw_explore_list,'s:netrw_curdir."/".bufname(v:val.bufnr)')

     elseif starpat == 3
      " starpat=3: Explore */filepat   (search in current directory for filenames matching filepat)
"      call Decho("starpat=".starpat.": build */filepat list")
      let filepat= substitute(dirname,'^\*/','','')
      let filepat= substitute(filepat,'^[%#<]','\\&','')
"      call Decho("b:netrw_curdir<".b:netrw_curdir.">")
"      call Decho("filepat<".filepat.">")
      let w:netrw_explore_list= split(expand(b:netrw_curdir."/".filepat),'\n')
      if &hls | let keepregslash= s:ExplorePatHls(filepat) | endif

     elseif starpat == 4
      " starpat=4: Explore **/filepat  (recursive descent search for filenames matching filepat)
"      call Decho("starpat=".starpat.": build **/filepat list")
      let w:netrw_explore_list= split(expand(b:netrw_curdir."/".dirname),'\n')
      if &hls | let keepregslash= s:ExplorePatHls(dirname) | endif
     endif " switch on starpat to build w:netrw_explore_list

     let w:netrw_explore_listlen = len(w:netrw_explore_list)
"     call Decho("w:netrw_explore_list<".string(w:netrw_explore_list).">")
"     call Decho("w:netrw_explore_listlen=".w:netrw_explore_listlen)

     if w:netrw_explore_listlen == 0 || (w:netrw_explore_listlen == 1 && w:netrw_explore_list[0] =~ '\*\*\/')
      call netrw#ErrorMsg(s:WARNING,"no files matched",42)
      silent! let @* = keepregstar
      silent! let @+ = keepregstar
      silent! let @/ = keepregslash
"      call Dret("netrw#Explore : no files matched")
      return
     endif
    endif  " if indx ... endif

    " NetrwStatusLine support - for exploring support
    let w:netrw_explore_indx= indx
"    call Decho("explorelist<".join(w:netrw_explore_list,',')."> len=".w:netrw_explore_listlen)

    " wrap the indx around, but issue a note
    if indx >= w:netrw_explore_listlen || indx < 0
"     call Decho("wrap indx (indx=".indx." listlen=".w:netrw_explore_listlen.")")
     let indx                = (indx < 0)? ( w:netrw_explore_listlen - 1 ) : 0
     let w:netrw_explore_indx= indx
     call netrw#ErrorMsg(s:NOTE,"no more files match Explore pattern",43)
    endif

    exe "let dirfile= w:netrw_explore_list[".indx."]"
"    call Decho("dirfile=w:netrw_explore_list[indx=".indx."]= <".dirfile.">")
    let newdir= substitute(dirfile,'/[^/]*$','','e')
"    call Decho("newdir<".newdir.">")

"    call Decho("calling LocalBrowseCheck(newdir<".newdir.">)")
    call netrw#LocalBrowseCheck(newdir)
    if !exists("w:netrw_liststyle")
     let w:netrw_liststyle= g:netrw_liststyle
    endif
    if w:netrw_liststyle == s:THINLIST || w:netrw_liststyle == s:LONGLIST
     call search('^'.substitute(dirfile,"^.*/","","").'\>',"W")
    else
     call search('\<'.substitute(dirfile,"^.*/","","").'\>',"w")
    endif
    let w:netrw_explore_mtchcnt = indx + 1
    let w:netrw_explore_bufnr   = bufnr("%")
    let w:netrw_explore_line    = line(".")
    call s:SetupNetrwStatusLine('%f %h%m%r%=%9*%{NetrwStatusLine()}')
"    call Decho("explore: mtchcnt=".w:netrw_explore_mtchcnt." bufnr=".w:netrw_explore_bufnr." line#".w:netrw_explore_line)

   else
"    call Decho("your vim does not have +path_extra")
    if !exists("g:netrw_quiet")
     call netrw#ErrorMsg(s:WARNING,"your vim needs the +path_extra feature for Exploring with **!",44)
    endif
    silent! let @* = keepregstar
    silent! let @+ = keepregstar
    silent! let @/ = keepregslash
"    call Dret("netrw#Explore : missing +path_extra")
    return
   endif

  else
"   call Decho("case Explore newdir<".dirname.">")
   if exists("w:netrw_liststyle") && w:netrw_liststyle == s:TREELIST && dirname =~ '/'
    silent! unlet w:netrw_treedict
    silent! unlet w:netrw_treetop
   endif
   let newdir= dirname
   if !exists("b:netrw_curdir")
    call netrw#LocalBrowseCheck(getcwd())
   else
    call netrw#LocalBrowseCheck(s:NetrwBrowseChgDir(1,newdir))
   endif
  endif

  " visual display of **/ **// */ Exploration files
  if exists("w:netrw_explore_indx") && exists("b:netrw_curdir")
   if !exists("s:explore_prvdir") || s:explore_prvdir != b:netrw_curdir
    " only update match list if current directory isn't the same as before
    let s:explore_prvdir = b:netrw_curdir
    let s:explore_match  = ""
    let dirlen           = strlen(b:netrw_curdir)
    if b:netrw_curdir !~ '/$'
     let dirlen= dirlen + 1
    endif
    let prvfname= ""
    for fname in w:netrw_explore_list
"     call Decho("fname<".fname.">")
"COMBAK -- g:netrw_markfileesc."'".g:netrw_markfileesc."'"  ???
     if fname =~ '^'.b:netrw_curdir
      if s:explore_match == ""
       let s:explore_match= '\<'.escape(strpart(fname,dirlen),g:netrw_markfileesc).'\>'
      else
       let s:explore_match= s:explore_match.'\|\<'.escape(strpart(fname,dirlen),g:netrw_markfileesc).'\>'
      endif
     elseif fname !~ '^/' && fname != prvfname
      if s:explore_match == ""
       let s:explore_match= '\<'.escape(fname,g:netrw_markfileesc).'\>'
      else
       let s:explore_match= s:explore_match.'\|\<'.escape(fname,g:netrw_markfileesc).'\>'
      endif
     endif
     let prvfname= fname
    endfor
"    call Decho("explore_match<".s:explore_match.">")
    exe "2match netrwMarkFile /".s:explore_match."/"
   endif
   echo "<s-up>==Pexplore  <s-down>==Nexplore"
  else
   2match none
   if exists("s:explore_match")  | unlet s:explore_match  | endif
   if exists("s:explore_prvdir") | unlet s:explore_prvdir | endif
   echo " "
"   call Decho("cleared explore match list")
  endif

  silent! let @* = keepregstar
  silent! let @+ = keepregstar
  silent! let @/ = keepregslash
"  call Dret("netrw#Explore : @/<".@/.">")
endfun

" ---------------------------------------------------------------------
" s:NetrwHide: this function is invoked by the "a" map for browsing {{{2
"          and switches the hiding mode.  The actual hiding is done by
"          s:NetrwListHide().
"             g:netrw_hide= 0: show all
"                           1: show not-hidden files
"                           2: show hidden files only
fun! s:NetrwHide(islocal)
"  call Dfunc("NetrwHide(islocal=".a:islocal.") g:netrw_hide=".g:netrw_hide)
  let svpos= netrw#NetrwSavePosn()

  if exists("s:netrwmarkfilelist_{bufnr('%')}")
"   call Decho(((g:netrw_hide == 1)? "unhide" : "hide")." files in markfilelist<".string(s:netrwmarkfilelist_{bufnr("%")}).">")
"   call Decho("g:netrw_list_hide<".g:netrw_list_hide.">")

   " hide the files in the markfile list
   for fname in s:netrwmarkfilelist_{bufnr("%")}
"    call Decho("match(g:netrw_list_hide<".g:netrw_list_hide.'> fname<\<'.fname.'\>>)='.match(g:netrw_list_hide,'\<'.fname.'\>')." isk=".&isk)
    if match(g:netrw_list_hide,'\<'.fname.'\>') != -1
     " remove fname from hiding list
     let g:netrw_list_hide= substitute(g:netrw_list_hide,'..\<'.escape(fname,g:netrw_fname_escape).'\>..','','')
     let g:netrw_list_hide= substitute(g:netrw_list_hide,',,',',','g')
     let g:netrw_list_hide= substitute(g:netrw_list_hide,'^,\|,$','','')
"     call Decho("unhide: g:netrw_list_hide<".g:netrw_list_hide.">")
    else
     " append fname to hiding list
     if exists("g:netrw_list_hide") && g:netrw_list_hide != ""
      let g:netrw_list_hide= g:netrw_list_hide.',\<'.escape(fname,g:netrw_fname_escape).'\>'
     else
      let g:netrw_list_hide= '\<'.escape(fname,g:netrw_fname_escape).'\>'
     endif
"     call Decho("hide: g:netrw_list_hide<".g:netrw_list_hide.">")
    endif
   endfor
   call s:NetrwUnmarkList(bufnr("%"),b:netrw_curdir)
   let g:netrw_hide= 1

  else

   " switch between show-all/show-not-hidden/show-hidden
   let g:netrw_hide=(g:netrw_hide+1)%3
   exe "norm! 0"
   if g:netrw_hide && g:netrw_list_hide == ""
    call netrw#ErrorMsg(s:WARNING,"your hiding list is empty!",49)
"    call Dret("NetrwHide")
    return
   endif
  endif

  call s:NetrwRefresh(a:islocal,s:NetrwBrowseChgDir(a:islocal,'./'))
  call netrw#NetrwRestorePosn(svpos)
"  call Dret("NetrwHide")
endfun

" ---------------------------------------------------------------------
" s:NetrwHidden: invoked by "gh" {{{2
fun! s:NetrwHidden(islocal)
"  call Dfunc("s:NetrwHidden()")
  "  save current position
  let svpos= netrw#NetrwSavePosn()

  if g:netrw_list_hide =~ '\(^\|,\)\\(^\\|\\s\\s\\)\\zs\\.\\S\\+'
   " remove pattern from hiding list
   let g:netrw_list_hide= substitute(g:netrw_list_hide,'\(^\|,\)\\(^\\|\\s\\s\\)\\zs\\.\\S\\+','','')
  elseif strlen(g:netrw_list_hide) >= 1
   let g:netrw_list_hide= g:netrw_list_hide . ',\(^\|\s\s\)\zs\.\S\+'
  else
   let g:netrw_list_hide= '\(^\|\s\s\)\zs\.\S\+'
  endif

  " refresh screen and return to saved position
  call s:NetrwRefresh(a:islocal,s:NetrwBrowseChgDir(a:islocal,'./'))
  call netrw#NetrwRestorePosn(svpos)
"  call Dret("s:NetrwHidden")
endfun

" ---------------------------------------------------------------------
"  s:NetrwHome: this function determines a "home" for saving bookmarks and history {{{2
fun! s:NetrwHome()
"  call Dfunc("s:NetrwHome()")
  if exists("g:netrw_home")
   let home= g:netrw_home
  else
   " go to vim plugin home
   for home in split(&rtp,',') + ['']
    if isdirectory(home) && filewritable(home) | break | endif
     let basehome= substitute(home,'[/\\]\.vim$','','')
    if isdirectory(basehome) && filewritable(basehome)
     let home= basehome."/.vim"
     break
    endif
   endfor
   if home == ""
    " just pick the first directory
"    call Decho("just pick first directory in &rtp")
    let home= substitute(&rtp,',.*$','','')
   endif
   if (has("win32") || has("win95") || has("win64") || has("win16"))
    let home= substitute(home,'/','\\','g')
   endif
  endif
  " insure that the home directory exists
"  call Decho("picked home<".home.">")
  if !isdirectory(home)
   if exists("g:netrw_mkdir")
"    call Decho("home<".home."> isn't a directory -- making it now with g:netrw_mkdir<".g:netrw_mkdir.">")
"    call Decho("system(".g:netrw_mkdir." ".s:Escape(home).")")
    call system(g:netrw_mkdir." ".s:Escape(home))
   else
"    call Decho("home<".home."> isn't a directory -- making it now with mkdir()")
    call mkdir(home)
   endif
  endif
  let g:netrw_home= home
"  call Dret("s:NetrwHome <".home.">")
  return home
endfun

" ---------------------------------------------------------------------
" s:NetrwLeftmouse: handles the <leftmouse> when in a netrw browsing window {{{2
fun! s:NetrwLeftmouse(islocal)
"  call Dfunc("s:NetrwLeftmouse(islocal=".a:islocal.")")
  if a:islocal
   if exists("b:netrw_curdir")
    call netrw#LocalBrowseCheck(s:NetrwBrowseChgDir(1,s:NetrwGetWord()))
   endif
  else
   if exists("b:netrw_curdir")
    call s:NetrwBrowse(0,s:NetrwBrowseChgDir(0,s:NetrwGetWord()))
   endif
  endif
"  call Dret("s:NetrwLeftmouse")
endfun

" ---------------------------------------------------------------------
" s:NetrwListHide: uses [range]g~...~d to delete files that match comma {{{2
" separated patterns given in g:netrw_list_hide
fun! s:NetrwListHide()
"  call Dfunc("NetrwListHide() hide=".g:netrw_hide." listhide<".g:netrw_list_hide.">")

  " find a character not in the "hide" string to use as a separator for :g and :v commands
  " How-it-works: take the hiding command, convert it into a range.  Duplicate
  " characters don't matter.  Remove all such characters from the '/~...90'
  " string.  Use the first character left as a separator character.
  let listhide= g:netrw_list_hide
  let sep     = strpart(substitute('/~@#$%^&*{};:,<.>?|1234567890','['.escape(listhide,'-]^\').']','','ge'),1,1)
"  call Decho("sep=".sep)

  while listhide != ""
   if listhide =~ ','
    let hide     = substitute(listhide,',.*$','','e')
    let listhide = substitute(listhide,'^.\{-},\(.*\)$','\1','e')
   else
    let hide     = listhide
    let listhide = ""
   endif

   " Prune the list by hiding any files which match
   if g:netrw_hide == 1
"    call Decho("hiding<".hide."> listhide<".listhide.">")
    exe 'silent keepjumps '.w:netrw_bannercnt.',$g'.sep.hide.sep.'d'
   elseif g:netrw_hide == 2
"    call Decho("showing<".hide."> listhide<".listhide.">")
    exe 'silent keepjumps '.w:netrw_bannercnt.',$g'.sep.hide.sep.'s@^@ /-KEEP-/ @'
   endif
  endwhile
  if g:netrw_hide == 2
   exe 'silent keepjumps '.w:netrw_bannercnt.',$v@^ /-KEEP-/ @d'
   exe 'silent keepjumps '.w:netrw_bannercnt.',$s@^\%( /-KEEP-/ \)\+@@e'
  endif

"  call Dret("NetrwListHide")
endfun

" ---------------------------------------------------------------------
" NetrwHideEdit: allows user to edit the file/directory hiding list
fun! s:NetrwHideEdit(islocal)
"  call Dfunc("NetrwHideEdit(islocal=".a:islocal.")")

  " save current cursor position
  let svpos= netrw#NetrwSavePosn()

  " get new hiding list from user
  call inputsave()
  let newhide= input("Edit Hiding List: ",g:netrw_list_hide)
  call inputrestore()
  let g:netrw_list_hide= newhide
"  call Decho("new g:netrw_list_hide<".g:netrw_list_hide.">")

  " refresh the listing
  silent call s:NetrwRefresh(a:islocal,s:NetrwBrowseChgDir(a:islocal,"./"))

  " restore cursor position
  call netrw#NetrwRestorePosn(svpos)

"  call Dret("NetrwHideEdit")
endfun

" ---------------------------------------------------------------------
" NetSortSequence: allows user to edit the sorting sequence
fun! s:NetSortSequence(islocal)
"  call Dfunc("NetSortSequence(islocal=".a:islocal.")")

  let svpos= netrw#NetrwSavePosn()
  call inputsave()
  let newsortseq= input("Edit Sorting Sequence: ",g:netrw_sort_sequence)
  call inputrestore()

  " refresh the listing
  let g:netrw_sort_sequence= newsortseq
  call s:NetrwRefresh(a:islocal,s:NetrwBrowseChgDir(a:islocal,'./'))
  call netrw#NetrwRestorePosn(svpos)

"  call Dret("NetSortSequence")
endfun

" ---------------------------------------------------------------------
" s:NetrwMakeDir: this function makes a directory (both local and remote) {{{2
fun! s:NetrwMakeDir(usrhost)
"  call Dfunc("NetrwMakeDir(usrhost<".a:usrhost.">)")

  " get name of new directory from user.  A bare <CR> will skip.
  " if its currently a directory, also request will be skipped, but with
  " a message.
  call inputsave()
  let newdirname= input("Please give directory name: ")
  call inputrestore()
"  call Decho("newdirname<".newdirname.">")

  if newdirname == ""
"   call Dret("NetrwMakeDir : user aborted with bare <cr>")
   return
  endif

  if a:usrhost == ""
"   call Decho("local mkdir")

   " Local mkdir:
   " sanity checks
   let fullnewdir= b:netrw_curdir.'/'.newdirname
"   call Decho("fullnewdir<".fullnewdir.">")
   if isdirectory(fullnewdir)
    if !exists("g:netrw_quiet")
     call netrw#ErrorMsg(s:WARNING,"<".newdirname."> is already a directory!",24)
    endif
"    call Dret("NetrwMakeDir : directory<".newdirname."> exists previously")
    return
   endif
   if s:FileReadable(fullnewdir)
    if !exists("g:netrw_quiet")
     call netrw#ErrorMsg(s:WARNING,"<".newdirname."> is already a file!",25)
    endif
"    call Dret("NetrwMakeDir : file<".newdirname."> exists previously")
    return
   endif

   " requested new local directory is neither a pre-existing file or
   " directory, so make it!
   if exists("*mkdir")
    call mkdir(fullnewdir,"p")
   else
    let netrw_origdir= s:NetrwGetcwd(1)
    exe 'keepjumps lcd '.fnameescape(b:netrw_curdir)
"    call Decho("netrw_origdir<".netrw_origdir.">: lcd b:netrw_curdir<".fnameescape(b:netrw_curdir).">")
"    call Decho("exe silent! !".g:netrw_local_mkdir.' '.shellescape(newdirname,1))
    exe "silent! !".g:netrw_local_mkdir.' '.shellescape(newdirname,1)
    if !g:netrw_keepdir
     exe 'keepjumps lcd '.fnameescape(netrw_origdir)
"     call Decho("netrw_keepdir=".g:netrw_keepdir.": keepjumps lcd ".fnameescape(netrw_origdir)." getcwd<".getcwd().">")
    endif
   endif

   if v:shell_error == 0
    " refresh listing
"    call Decho("refresh listing")
    let svpos= netrw#NetrwSavePosn()
    call s:NetrwRefresh(1,s:NetrwBrowseChgDir(1,'./'))
    call netrw#NetrwRestorePosn(svpos)
   elseif !exists("g:netrw_quiet")
    call netrw#ErrorMsg(s:ERROR,"unable to make directory<".newdirname.">",26)
   endif
"   redraw!

  elseif !exists("b:netrw_method") || b:netrw_method == 4
   " Remote mkdir:
"   call Decho("remote mkdir")
   let mkdircmd  = s:MakeSshCmd(g:netrw_mkdir_cmd)
   let newdirname= substitute(b:netrw_curdir,'^\%(.\{-}/\)\{3}\(.*\)$','\1','').newdirname
"   call Decho("exe silent! !".mkdircmd." ".shellescape(newdirname,1))
   exe "silent! !".mkdircmd." ".shellescape(newdirname,1)
   if v:shell_error == 0
    " refresh listing
    let svpos= netrw#NetrwSavePosn()
    call s:NetrwRefresh(0,s:NetrwBrowseChgDir(0,'./'))
    call netrw#NetrwRestorePosn(svpos)
   elseif !exists("g:netrw_quiet")
    call netrw#ErrorMsg(s:ERROR,"unable to make directory<".newdirname.">",27)
   endif
"   redraw!

  elseif b:netrw_method == 2
   " COMBAK -- future work
   call netrw#ErrorMsg(s:ERROR,"making directories via ftp not currently supported",68)
  elseif b:netrw_method == 3
   " COMBAK -- future work
   call netrw#ErrorMsg(s:ERROR,"making directories via ftp not currently supported",68)
  endif

"  call Dret("NetrwMakeDir")
endfun

" ---------------------------------------------------------------------
" s:NetrwMarkFile: (invoked by mf) This function is used to both {{{2
"                  mark and unmark files.  If a markfile list exists,
"                  then the rename and delete functions will use it instead
"                  of whatever may happen to be under the cursor at that
"                  moment.  When the mouse and gui are available,
"                  shift-leftmouse may also be used to mark files.
"
"  Creates two lists
"    s:netrwmarkfilelist    -- holds complete paths to all marked files
"    s:netrwmarkfilelist_#  -- holds list of marked files in current-buffer's directory (#==bufnr())
"
"  Creates a marked file match string
"    s:netrwmarfilemtch_#   -- used with 2match to display marked files
"
"  Creates a buffer version of islocal
"    b:netrw_islocal
"
fun! s:NetrwMarkFile(islocal,fname)
"  call Dfunc("s:NetrwMarkFile(islocal=".a:islocal." fname<".a:fname.">)")
  let curbufnr= bufnr("%")
  let curdir  = b:netrw_curdir
  if exists("s:netrwmarkfilelist_{curbufnr}")
   " markfile list exists
"   call Decho("starting s:netrwmarkfilelist_{curbufnr}<".string(s:netrwmarkfilelist_{curbufnr}).">")
"   call Decho("starting s:netrwmarkfilemtch_{curbufnr}<".s:netrwmarkfilemtch_{curbufnr}.">")
   let b:netrw_islocal= a:islocal

   if index(s:netrwmarkfilelist_{curbufnr},a:fname) == -1
    " append filename to buffer's markfilelist
"    call Decho("append filename<".a:fname."> to local markfilelist_".curbufnr."<".string(s:netrwmarkfilelist_{curbufnr}).">")
    call add(s:netrwmarkfilelist_{curbufnr},a:fname)
    let s:netrwmarkfilemtch_{curbufnr}= s:netrwmarkfilemtch_{curbufnr}.'\|\<'.escape(a:fname,g:netrw_markfileesc."'".g:netrw_markfileesc."'").'\>'

   else
    " remove filename from buffer's markfilelist
"    call Decho("remove filename<".a:fname."> from local markfilelist_".curbufnr."<".string(s:netrwmarkfilelist_{curbufnr}).">")
    call filter(s:netrwmarkfilelist_{curbufnr},'v:val != a:fname')
    if s:netrwmarkfilelist_{curbufnr} == []
     " local markfilelist is empty; remove it entirely
"     call Decho("markfile list now empty")
     call s:NetrwUnmarkList(curbufnr,curdir)
    else
     " rebuild match list to display markings correctly
"     call Decho("rebuild s:netrwmarkfilemtch_".curbufnr)
     let s:netrwmarkfilemtch_{curbufnr}= ""
     let first                           = 1
     for fname in s:netrwmarkfilelist_{curbufnr}
      if first
       let s:netrwmarkfilemtch_{curbufnr}= s:netrwmarkfilemtch_{curbufnr}.'\<'.escape(fname,g:netrw_markfileesc."'".g:netrw_markfileesc."'").'\>'
      else
       let s:netrwmarkfilemtch_{curbufnr}= s:netrwmarkfilemtch_{curbufnr}.'\|\<'.escape(fname,g:netrw_markfileesc."'".g:netrw_markfileesc."'").'\>'
      endif
      let first= 0
     endfor
"     call Decho("ending s:netrwmarkfilelist_"curbufnr."<".string(s:netrwmarkfilelist_{curbufnr}).">")
"     call Decho("ending s:netrwmarkfilemtch_"curbufnr."<".s:netrwmarkfilemtch_{curbufnr}.">")
    endif
   endif

  else
   " initialize new markfilelist

"   call Decho("add fname<".a:fname."> to new markfilelist_".curbufnr)
   let s:netrwmarkfilelist_{curbufnr}= []
   call add(s:netrwmarkfilelist_{curbufnr},a:fname)
"   call Decho("ending s:netrwmarkfilelist_{curbufnr}<".string(s:netrwmarkfilelist_{curbufnr}).">")

   " build initial markfile matching pattern
   if a:fname =~ '/$'
    let s:netrwmarkfilemtch_{curbufnr}= '\<'.escape(a:fname,g:netrw_markfileesc)
   else
    let s:netrwmarkfilemtch_{curbufnr}= '\<'.escape(a:fname,g:netrw_markfileesc).'\>'
   endif
"   call Decho("ending s:netrwmarkfilemtch_".curbufnr."<".s:netrwmarkfilemtch_{curbufnr}.">")
  endif

  " handle global markfilelist
  if exists("s:netrwmarkfilelist")
   let dname= s:ComposePath(b:netrw_curdir,a:fname)
   if index(s:netrwmarkfilelist,dname) == -1
    " append new filename to global markfilelist
    call add(s:netrwmarkfilelist,s:ComposePath(b:netrw_curdir,a:fname))
"    call Decho("append filename<".a:fname."> to global markfilelist<".string(s:netrwmarkfilelist).">")
   else
    " remove new filename from global markfilelist
"    call Decho("filter(".string(s:netrwmarkfilelist).",'v:val != '.".dname.")")
    call filter(s:netrwmarkfilelist,'v:val != "'.dname.'"')
"    call Decho("ending s:netrwmarkfilelist  <".string(s:netrwmarkfilelist).">")
    if s:netrwmarkfilelist == []
     unlet s:netrwmarkfilelist
    endif
   endif
  else
   " initialize new global-directory markfilelist
   let s:netrwmarkfilelist= []
   call add(s:netrwmarkfilelist,s:ComposePath(b:netrw_curdir,a:fname))
"   call Decho("init s:netrwmarkfilelist<".string(s:netrwmarkfilelist).">")
  endif

  " set up 2match'ing to netrwmarkfilemtch list
  if exists("s:netrwmarkfilemtch_{curbufnr}") && s:netrwmarkfilemtch_{curbufnr} != ""
"   call Decho("exe 2match netrwMarkFile /".s:netrwmarkfilemtch_{curbufnr}."/")
   exe "2match netrwMarkFile /".s:netrwmarkfilemtch_{curbufnr}."/"
  else
"   call Decho("2match none")
   2match none
  endif
"  call Dret("s:NetrwMarkFile : netrwmarkfilelist_".curbufnr."<".(exists("s:netrwmarkfilelist_{curbufnr}")? string(s:netrwmarkfilelist_{curbufnr}) : " doesn't exist").">")
endfun

" ---------------------------------------------------------------------
" s:NetrwMarkFileCompress: (invoked by mz) This function is used to {{{2
"                          compress/decompress files using the programs
"                          in g:netrw_compress and g:netrw_uncompress,
"                          using g:netrw_compress_suffix to know which to
"                          do.  By default:
"                            g:netrw_compress        = "gzip"
"                            g:netrw_decompress      = { ".gz" : "gunzip" , ".bz2" : "bunzip2" , ".zip" : "unzip" , ".tar" : "tar -xf"}
fun! s:NetrwMarkFileCompress(islocal)
"  call Dfunc("s:NetrwMarkFileCompress(islocal=".a:islocal.")")
  let svpos    = netrw#NetrwSavePosn()
  let curdir   = b:netrw_curdir
  let curbufnr = bufnr("%")

  if exists("s:netrwmarkfilelist_{curbufnr}") && exists("g:netrw_compress") && exists("g:netrw_decompress")
   for fname in s:netrwmarkfilelist_{curbufnr}
    " for every filename in the marked list
    for sfx in sort(keys(g:netrw_decompress))
     if fname =~ '\'.sfx.'$'
      " fname has a suffix indicating that its compressed; apply associated decompression routine
      let exe= s:WinPath(g:netrw_decompress[sfx])
"      call Decho("fname<".fname."> is compressed so decompress with <".exe.">")
      if a:islocal
       if g:netrw_keepdir
        let fname= shellescape(s:ComposePath(curdir,fname))
       endif
      else
       let fname= shellescape(b:netrw_curdir.fname,1)
      endif
      if executable(exe)
       if a:islocal
	call system(exe." ".fname)
       else
        call s:RemoteSystem(exe." ".fname)
       endif
      else
       call netrw#ErrorMsg(s:WARNING,"unable to apply<".exe."> to file<".fname.">",50)
      endif
      break
     endif
    endfor
    if exists("exe")
     unlet exe
    elseif a:islocal
     " fname not a compressed file, so compress it
     call system(s:WinPath(g:netrw_compress)." ".shellescape(s:ComposePath(b:netrw_curdir,fname)))
    else
     " fname not a compressed file, so compress it
     call s:RemoteSystem(s:WinPath(g:netrw_compress)." ".shellescape(fname))
    endif
   endfor
   call s:NetrwUnmarkList(curbufnr,curdir)
   call s:NetrwRefresh(a:islocal,s:NetrwBrowseChgDir(a:islocal,'./'))
   call netrw#NetrwRestorePosn(svpos)
  endif
"  call Dret("s:NetrwMarkFileCompress")
endfun

" ---------------------------------------------------------------------
" s:NetrwMarkFileCopy: (invoked by mc) copy marked files to target {{{2
"                      If no marked files, then set up directory as the
"                      target.  Currently does not support copying entire
"                      directories.  Uses the local-buffer marked file list.
"                      Returns 1=success  (used by NetrwMarkFileMove())
"                              0=failure
fun! s:NetrwMarkFileCopy(islocal)
"  call Dfunc("s:NetrwMarkFileCopy(islocal=".a:islocal.") target<".(exists("s:netrwmftgt")? s:netrwmftgt : '---').">")

  " sanity checks
  if !exists("s:netrwmarkfilelist_{bufnr('%')}") || empty(s:netrwmarkfilelist_{bufnr('%')})
   call netrw#ErrorMsg(2,"there are no marked files in this window (:help netrw-mf)",66)
"   call Dret("s:NetrwMarkFileCopy 0")
   return 0
  endif
"  call Decho("sanity chk passed: s:netrwmarkfilelist_".bufnr('%')."<".string(s:netrwmarkfilelist_{bufnr('%')}))
  if !exists("s:netrwmftgt")
   call netrw#ErrorMsg(2,"your marked file target is empty! (:help netrw-mt)",67)
"   call Dret("s:NetrwMarkFileCopy 0")
   return 0
  endif
"  call Decho("sanity chk passed: s:netrwmftgt<".s:netrwmftgt.">")
  let curdir   = b:netrw_curdir
  let curbufnr = bufnr("%")

  if      a:islocal &&  s:netrwmftgt_islocal
   " Copy marked files, local directory to local directory
"   call Decho("copy from local to local")
   let args= join(map(deepcopy(s:netrwmarkfilelist_{bufnr('%')}),"shellescape(b:netrw_curdir.\"/\".v:val)"))
"   call Decho("system(".g:netrw_localcopycmd." ".args." ".shellescape(s:netrwmftgt).")")
   call system(s:WinPath(g:netrw_localcopycmd)." ".args." ".shellescape(s:netrwmftgt))

  elseif  a:islocal && !s:netrwmftgt_islocal
   " Copy marked files, local directory to remote directory
"   call Decho("copy from local to remote")
   call s:NetrwUpload(s:netrwmarkfilelist_{bufnr('%')},s:netrwmftgt)

  elseif !a:islocal &&  s:netrwmftgt_islocal
"   call Decho("copy from remote to local")
   call netrw#NetrwObtain(a:islocal,s:netrwmarkfilelist_{bufnr('%')},s:netrwmftgt)

  elseif !a:islocal && !s:netrwmftgt_islocal
"   call Decho("copy from remote to remote")
   let curdir = getcwd()
   let tmpdir = s:GetTempfile("")
   if tmpdir !~ '/'
    let tmpdir= curdir."/".tmpdir
   endif
   if exists("*mkdir")
    call mkdir(tmpdir)
   else
    exe "silent! !".g:netrw_local_mkdir.' '.shellescape(tmpdir,1)
   endif
   if isdirectory(tmpdir)
    exe "keepjumps lcd ".fnameescape(tmpdir)
    call netrw#NetrwObtain(a:islocal,s:netrwmarkfilelist_{bufnr('%')},tmpdir)
    let localfiles= map(deepcopy(s:netrwmarkfilelist_{bufnr('%')}),'substitute(v:val,"^.*/","","")')
    call s:NetrwUpload(localfiles,s:netrwmftgt)
    if getcwd() == tmpdir
     for fname in s:netrwmarkfilelist_{bufnr('%')}
      call s:NetrwDelete(fname)
     endfor
     exe "keepjumps lcd ".fnameescape(curdir)
     exe "silent !".g:netrw_local_rmdir." ".shellescape(tmpdir,1)
    else
     exe "keepjumps lcd ".fnameescape(curdir)
    endif
   endif
  endif

  " -------
  " cleanup
  " -------
"  call Decho("cleanup")

  " remove markings from local buffer
  call s:NetrwUnmarkList(curbufnr,curdir)

  " refresh buffers
  if !s:netrwmftgt_islocal
   call s:NetrwRefreshDir(s:netrwmftgt_islocal,s:netrwmftgt)
  endif
  if a:islocal
   call s:NetrwRefreshDir(a:islocal,b:netrw_curdir)
  endif
  if g:netrw_fastbrowse <= 1
   call s:LocalBrowseShellCmdRefresh()
  endif
  
"  call Dret("s:NetrwMarkFileCopy 1")
  return 1
endfun

" ---------------------------------------------------------------------
" s:NetrwMarkFileDiff: (invoked by md) This function is used to {{{2
"                      invoke vim's diff mode on the marked files.
"                      Either two or three files can be so handled.
"                      Uses the global marked file list.
fun! s:NetrwMarkFileDiff(islocal)
"  call Dfunc("s:NetrwMarkFileDiff(islocal=".a:islocal.") b:netrw_curdir<".b:netrw_curdir.">")
  let curbufnr= bufnr("%")

  if exists("s:netrwmarkfilelist_{curbufnr}")
   let cnt    = 0
   let curdir = b:netrw_curdir
   for fname in s:netrwmarkfilelist
    let cnt= cnt + 1
    if cnt == 1
"     call Decho("diffthis: fname<".fname.">")
     exe "e ".fnameescape(fname)
     diffthis
    elseif cnt == 2 || cnt == 3
     vsplit
     wincmd l
"     call Decho("diffthis: ".fname)
     exe "e ".fnameescape(fname)
     diffthis
    else
     break
    endif
   endfor
   call s:NetrwUnmarkList(curbufnr,curdir)
  endif

"  call Dret("s:NetrwMarkFileDiff")
endfun

" ---------------------------------------------------------------------
" s:NetrwMarkFileEdit: (invoked by me) put marked files on arg list and start editing them {{{2
"                       Uses global markfilelist
fun! s:NetrwMarkFileEdit(islocal)
"  call Dfunc("s:NetrwMarkFileEdit(islocal=".a:islocal.")")

  let curdir   = b:netrw_curdir
  let curbufnr = bufnr("%")
  if exists("s:netrwmarkfilelist_{curbufnr}")
   call s:SetRexDir(a:islocal,curdir)
   let flist= join(map(deepcopy(s:netrwmarkfilelist), "fnameescape(v:val)"))
   " unmark markedfile list
"   call s:NetrwUnmarkList(curbufnr,curdir)
   call s:NetrwUnmarkAll()
"   call Decho("exe silent args ".flist)
   exe "silent args ".flist
  endif
  
"  call Dret("s:NetrwMarkFileEdit")
endfun

" ---------------------------------------------------------------------
" s:NetrwMarkFileExe: (invoked by mx) execute arbitrary command on marked files, one at a time {{{2
"                     Uses the local marked-file list.
fun! s:NetrwMarkFileExe(islocal)
"  call Dfunc("s:NetrwMarkFileExe(islocal=".a:islocal.")")
  let svpos    = netrw#NetrwSavePosn()
  let curdir   = b:netrw_curdir
  let curbufnr = bufnr("%")

  if exists("s:netrwmarkfilelist_{curbufnr}")
   " get the command
   call inputsave()
   let cmd= input("Enter command: ","","file")
   call inputrestore()
"   call Decho("cmd<".cmd.">")

   " apply command to marked files.  Substitute: filename -> %
   " If no %, then append a space and the filename to the command
   for fname in s:netrwmarkfilelist_{curbufnr}
    if a:islocal
     if g:netrw_keepdir
      let fname= shellescape(s:WinPath(s:ComposePath(curdir,fname)))
     endif
    else
     let fname= shellescape(s:WinPath(b:netrw_curdir.fname))
    endif
    if cmd =~ '%'
     let xcmd= substitute(cmd,'%',fname,'g')
    else
     let xcmd= cmd.' '.fname
    endif
    if a:islocal
"     call Decho("local: xcmd<".xcmd.">")
     let ret= system(xcmd)
    else
"     call Decho("remote: xcmd<".xcmd.">")
     let ret= s:RemoteSystem(xcmd)
    endif
    if v:shell_error < 0
     call netrw#ErrorMsg(s:ERROR,"command<".xcmd."> failed, aborting",54)
     break
    else
     echo ret
    endif
   endfor

   " unmark marked file list
   call s:NetrwUnmarkList(curbufnr,curdir)

   " refresh the listing
   call s:NetrwRefresh(a:islocal,s:NetrwBrowseChgDir(a:islocal,'./'))
   call netrw#NetrwRestorePosn(svpos)
  else
   call netrw#ErrorMsg(s:ERROR,"no files marked!",59)
  endif
  
"  call Dret("s:NetrwMarkFileExe")
endfun

" ---------------------------------------------------------------------
" s:NetrwMarkHideSfx: (invoked by mh) (un)hide files having same suffix
"                  as the marked file(s) (toggles suffix presence)
"                  Uses the local marked file list.
fun! s:NetrwMarkHideSfx(islocal)
"  call Dfunc("s:NetrwMarkHideSfx(islocal=".a:islocal.")")
  let svpos    = netrw#NetrwSavePosn()
  let curbufnr = bufnr("%")

  " s:netrwmarkfilelist_{curbufnr}: the List of marked files
  if exists("s:netrwmarkfilelist_{curbufnr}")

   for fname in s:netrwmarkfilelist_{curbufnr}
"     call Decho("s:NetrwMarkFileCopy: fname<".fname.">")
     " construct suffix pattern
     if fname =~ '\.'
      let sfxpat= "^.*".substitute(fname,'^.*\(\.[^. ]\+\)$','\1','')
     else
      let sfxpat= '^\%(\%(\.\)\@!.\)*$'
     endif
     " determine if its in the hiding list or not
     let inhidelist= 0
     if g:netrw_list_hide != ""
      let itemnum = 0
      let hidelist= split(g:netrw_list_hide,',')
      for hidepat in hidelist
       if sfxpat == hidepat
        let inhidelist= 1
        break
       endif
       let itemnum= itemnum + 1
      endfor
     endif
"     call Decho("fname<".fname."> inhidelist=".inhidelist." sfxpat<".sfxpat.">")
     if inhidelist
      " remove sfxpat from list
      call remove(hidelist,itemnum)
      let g:netrw_list_hide= join(hidelist,",")
     elseif g:netrw_list_hide != ""
      " append sfxpat to non-empty list
      let g:netrw_list_hide= g:netrw_list_hide.",".sfxpat
     else
      " set hiding list to sfxpat
      let g:netrw_list_hide= sfxpat
     endif
    endfor

   " refresh the listing
   call s:NetrwRefresh(a:islocal,s:NetrwBrowseChgDir(a:islocal,'./'))
   call netrw#NetrwRestorePosn(svpos)
  else
   call netrw#ErrorMsg(s:ERROR,"no files marked!",59)
  endif

"  call Dret("s:NetrwMarkHideSfx")
endfun

" ---------------------------------------------------------------------
" s:NetrwMarkFileGrep: (invoked by mg) This function applies vimgrep to marked files {{{2
"                     Uses the global markfilelist
fun! s:NetrwMarkFileGrep(islocal)
"  call Dfunc("s:NetrwMarkFileGrep(islocal=".a:islocal.")")
  let svpos    = netrw#NetrwSavePosn()
  let curbufnr = bufnr("%")

  if exists("s:netrwmarkfilelist")
"  call Decho("s:netrwmarkfilelist".string(s:netrwmarkfilelist).">")
   let netrwmarkfilelist= join(map(deepcopy(s:netrwmarkfilelist), "fnameescape(v:val)"))
   call s:NetrwUnmarkAll()

   " ask user for pattern
   call inputsave()
   let pat= input("Enter pattern: ","")
   call inputrestore()
   if pat !~ '^\s'
    if pat !~ '^/'
     let pat= '/'.pat.'/'
    endif
    let pat= " ".pat
   endif

   " use vimgrep for both local and remote
"   call Decho("exe vimgrep".pat." ".netrwmarkfilelist)
   exe "vimgrep".pat." ".netrwmarkfilelist

   2match none
   call netrw#NetrwRestorePosn(svpos)
  endif

"  call Dret("s:NetrwMarkFileGrep")
endfun

" ---------------------------------------------------------------------
" s:NetrwMarkFileMove: (invoked by mm) execute arbitrary command on marked files, one at a time {{{2
"                      uses the global marked file list
"                      s:netrwmfloc= 0: target directory is remote
"                                  = 1: target directory is local
fun! s:NetrwMarkFileMove(islocal)
"  call Dfunc("s:NetrwMarkFileMove(islocal=".a:islocal.")")
  let curdir   = b:netrw_curdir
  let curbufnr = bufnr("%")

  " sanity check
  if !exists("s:netrwmarkfilelist_{bufnr('%')}") || empty(s:netrwmarkfilelist_{bufnr('%')})
   call netrw#ErrorMsg(2,"there are no marked files in this window (:help netrw-mf)",66)
"   call Dret("s:NetrwMarkFileMove")
   return
  endif
"  call Decho("sanity chk passed: s:netrwmarkfilelist_".bufnr('%')."<".string(s:netrwmarkfilelist_{bufnr('%')}))
  if !exists("s:netrwmftgt")
   call netrw#ErrorMsg(2,"your marked file target is empty! (:help netrw-mt)",67)
"   call Dret("s:NetrwMarkFileCopy 0")
   return 0
  endif
"  call Decho("sanity chk passed: s:netrwmftgt<".s:netrwmftgt.">")

  if      a:islocal &&  s:netrwmftgt_islocal
   " move: local -> local
"   call Decho("move from local to local")
"   call Decho("(s:NetrwMarkFileMove) local to local move")
   if executable(g:netrw_localmovecmd)
    for fname in s:netrwmarkfilelist_{bufnr("%")}
"     call Decho("system(".g:netrw_localmovecmd." ".shellescape(fname)." ".shellescape(s:netrwmftgt).")")
     let ret= system(g:netrw_localmovecmd." ".shellescape(fname)." ".shellescape(s:netrwmftgt))
     if v:shell_error < 0
      call netrw#ErrorMsg(s:ERROR,"command<".g:netrw_localmovecmd."> failed, aborting",54)
      break
     endif
    endfor
   else
    call netrw#ErrorMsg(s:ERROR,"command<".g:netrw_localmovecmd."> is not executable!",57)
   endif

  elseif  a:islocal && !s:netrwmftgt_islocal
   " move: local -> remote
"   call Decho("move from local to remote")
"   call Decho("copy")
   let mflist= s:netrwmarkfilelist_{bufnr("%")}
   call s:NetrwMarkFileCopy(a:islocal)
"   call Decho("remove")
   for fname in mflist
    let barefname = substitute(fname,'^\(.*/\)\(.\{-}\)$','\2','')
    let ok        = s:NetrwLocalRmFile(b:netrw_curdir,barefname,1)
   endfor
   unlet mflist

  elseif !a:islocal &&  s:netrwmftgt_islocal
   " move: remote -> local
"   call Decho("move from remote to local")
"   call Decho("copy")
   let mflist= s:netrwmarkfilelist_{bufnr("%")}
   call s:NetrwMarkFileCopy(a:islocal)
"   call Decho("remove")
   for fname in mflist
    let barefname = substitute(fname,'^\(.*/\)\(.\{-}\)$','\2','')
    let ok        = s:NetrwRemoteRmFile(b:netrw_curdir,barefname,1)
   endfor
   unlet mflist

  elseif !a:islocal && !s:netrwmftgt_islocal
   " move: remote -> remote
"   call Decho("move from remote to remote")
"   call Decho("copy")
   let mflist= s:netrwmarkfilelist_{bufnr("%")}
   call s:NetrwMarkFileCopy(a:islocal)
"   call Decho("remove")
   for fname in mflist
    let barefname = substitute(fname,'^\(.*/\)\(.\{-}\)$','\2','')
    let ok        = s:NetrwRemoteRmFile(b:netrw_curdir,barefname,1)
   endfor
   unlet mflist
  endif

  " -------
  " cleanup
  " -------
"  call Decho("cleanup")

  " remove markings from local buffer
  call s:NetrwUnmarkList(curbufnr,curdir)                   " remove markings from local buffer

  " refresh buffers
  if !s:netrwmftgt_islocal
   call s:NetrwRefreshDir(s:netrwmftgt_islocal,s:netrwmftgt)
  endif
  if a:islocal
   call s:NetrwRefreshDir(a:islocal,b:netrw_curdir)
  endif
  if g:netrw_fastbrowse <= 1
   call s:LocalBrowseShellCmdRefresh()
  endif
  
"  call Dret("s:NetrwMarkFileMove")
endfun

" ---------------------------------------------------------------------
" s:NetrwMarkFilePrint: (invoked by mp) This function prints marked files {{{2
"                       using the hardcopy command.  Local marked-file list only.
fun! s:NetrwMarkFilePrint(islocal)
"  call Dfunc("s:NetrwMarkFilePrint(islocal=".a:islocal.")")
  let curbufnr= bufnr("%")
  if exists("s:netrwmarkfilelist_{curbufnr}")
   let netrwmarkfilelist = s:netrwmarkfilelist_{curbufnr}
   let curdir            = b:netrw_curdir
   call s:NetrwUnmarkList(curbufnr,curdir)
   for fname in netrwmarkfilelist
    if a:islocal
     if g:netrw_keepdir
      let fname= s:ComposePath(curdir,fname)
     endif
    else
     let fname= curdir.fname
    endif
    1split
    " the autocmds will handle both local and remote files
"    call Decho("exe silent e ".escape(fname,' '))
    exe "silent e ".fnameescape(fname)
"    call Decho("hardcopy")
    hardcopy
    q
   endfor
   2match none
  endif
"  call Dret("s:NetrwMarkFilePrint")
endfun

" ---------------------------------------------------------------------
" s:NetrwMarkFileRegexp: (invoked by mr) This function is used to mark {{{2
"                        files when given a regexp (for which a prompt is
"                        issued).
fun! s:NetrwMarkFileRegexp(islocal)
"  call Dfunc("s:NetrwMarkFileRegexp(islocal=".a:islocal.")")

  " get the regular expression
  call inputsave()
  let regexp= input("Enter regexp: ","","file")
  call inputrestore()

  if a:islocal
   " get the matching list of files using local glob()
"   call Decho("handle local regexp")
   let dirname  = escape(b:netrw_curdir,g:netrw_glob_escape)
   let filelist = glob(s:ComposePath(dirname,regexp))
   if filelist != ""
    let filelist= filelist."\n"
   endif

  " mark the list of files
  while filelist != ""
   if filelist =~ '\n'
    let filename = substitute(filelist,'\n.*$','','e')
    let filelist = substitute(filelist,'^.\{-}\n\(.*\)$','\1','e')
   else
    let filename = filelist
    let filelist = ""
   endif
"   call Decho("filelist<".filelist.">")
"   call Decho("filename<".filename.">")
   call s:NetrwMarkFile(a:islocal,substitute(filename,'^.*/','',''))
  endwhile

  else
"   call Decho("handle remote regexp")

   " convert displayed listing into a filelist
   let eikeep = &ei
   let areg   = @a
   silent %y a
   set ei=all ma
"   call Decho("set ei=all ma")
   1split
   enew
   silent norm! "ap
   2
   let bannercnt= search('^" =====','W')
   exe "silent 1,".bannercnt."d"
   set bt=nofile
   if     g:netrw_liststyle == s:LONGLIST
    silent %s/\s\{2,}\S.*$//e
   elseif g:netrw_liststyle == s:WIDELIST
    silent %s/\s\{2,}/\r/ge
   elseif g:netrw_liststyle == s:TREELIST
    silent %s/^| //e
    silent! g/^ .*$/d
   endif
   " convert regexp into the more usual glob-style format
   let regexp= substitute(regexp,'\*','.*','g')
"   call Decho("regexp<".regexp.">")
   exe "silent! v/".escape(regexp,'/')."/d"
   let filelist= getline(1,line("$"))
   q!
   for filename in filelist
    call s:NetrwMarkFile(a:islocal,substitute(filename,'^.*/','',''))
   endfor
   unlet filelist
   let @a  = areg
   let &ei = eikeep
  endif

"  call Dret("s:NetrwMarkFileRegexp")
endfun

" ---------------------------------------------------------------------
" s:NetrwMarkFileSource: (invoked by ms) This function sources marked files {{{2
"                        Uses the local marked file list.
fun! s:NetrwMarkFileSource(islocal)
"  call Dfunc("s:NetrwMarkFileSource(islocal=".a:islocal.")")
  let curbufnr= bufnr("%")
  if exists("s:netrwmarkfilelist_{curbufnr}")
   let netrwmarkfilelist = s:netrwmarkfilelist_{bufnr("%")}
   let curdir            = b:netrw_curdir
   call s:NetrwUnmarkList(curbufnr,curdir)
   for fname in netrwmarkfilelist
    if a:islocal
     if g:netrw_keepdir
      let fname= s:ComposePath(curdir,fname)
     endif
    else
     let fname= curdir.fname
    endif
    " the autocmds will handle sourcing both local and remote files
"    call Decho("exe so ".fnameescape(fname))
    exe "so ".fnameescape(fname)
   endfor
   2match none
  endif
"  call Dret("s:NetrwMarkFileSource")
endfun

" ---------------------------------------------------------------------
" s:NetrwMarkFileTag: (invoked by mT) This function applies g:netrw_ctags to marked files {{{2
"                     Uses the global markfilelist
fun! s:NetrwMarkFileTag(islocal)
"  call Dfunc("s:NetrwMarkFileTag(islocal=".a:islocal.")")
  let svpos    = netrw#NetrwSavePosn()
  let curdir   = b:netrw_curdir
  let curbufnr = bufnr("%")

  if exists("s:netrwmarkfilelist")
"   call Decho("s:netrwmarkfilelist".string(s:netrwmarkfilelist).">")
   let netrwmarkfilelist= join(map(deepcopy(s:netrwmarkfilelist), "shellescape(v:val,".!a:islocal.")"))
   call s:NetrwUnmarkAll()

   if a:islocal
    if executable(g:netrw_ctags)
"     call Decho("call system(".g:netrw_ctags." ".netrwmarkfilelist.")")
     call system(g:netrw_ctags." ".netrwmarkfilelist)
    else
     call netrw#ErrorMsg(s:ERROR,"g:netrw_ctags<".g:netrw_ctags."> is not executable!",51)
    endif
   else
    let cmd   = s:RemoteSystem(g:netrw_ctags." ".netrwmarkfilelist)
    call netrw#NetrwObtain(a:islocal,"tags")
    let curdir= b:netrw_curdir
    1split
    e tags
    let path= substitute(curdir,'^\(.*\)/[^/]*$','\1/','')
"    call Decho("curdir<".curdir."> path<".path.">")
    exe '%s/\t\(\S\+\)\t/\t'.escape(path,"/\n\r\\").'\1\t/e'
    wq!
   endif
   2match none
   call s:NetrwRefresh(a:islocal,s:NetrwBrowseChgDir(a:islocal,'./'))
   call netrw#NetrwRestorePosn(svpos)
  endif

"  call Dret("s:NetrwMarkFileTag")
endfun

" ---------------------------------------------------------------------
" s:NetrwMarkFileTgt:  (invoked by mt) This function sets up a marked file target {{{2
"   Sets up two variables, 
"     s:netrwmftgt : holds the target directory
"     s:netrwmftgt_islocal : 0=target directory is remote
"                    1=target directory is local
fun! s:NetrwMarkFileTgt(islocal)
"  call Dfunc("s:NetrwMarkFileTgt(islocal=".a:islocal.")")
  let svpos  = netrw#NetrwSavePosn()
  let curdir = b:netrw_curdir
  let hadtgt = exists("s:netrwmftgt")
  if !exists("w:netrw_bannercnt")
   let w:netrw_bannercnt= b:netrw_bannercnt
  endif

  " set up target
  if line(".") < w:netrw_bannercnt
   " if cursor in banner region, use b:netrw_curdir for the target
   let s:netrwmftgt= b:netrw_curdir
"   call Decho("inbanner: s:netrwmftgt<".s:netrwmftgt.">")

  else
   " get word under cursor.
   "  * If directory, use it for the target.
   "  * If file, use b:netrw_curdir for the target
   let curword= s:NetrwGetWord()
   let tgtdir = s:ComposePath(curdir,curword)
   if a:islocal && isdirectory(tgtdir)
    let s:netrwmftgt = tgtdir
"    call Decho("local isdir: s:netrwmftgt<".s:netrwmftgt.">")
   elseif !a:islocal && tgtdir =~ '/$'
    let s:netrwmftgt = tgtdir
"    call Decho("remote isdir: s:netrwmftgt<".s:netrwmftgt.">")
   else
    let s:netrwmftgt = curdir
"    call Decho("isfile: s:netrwmftgt<".s:netrwmftgt.">")
   endif
  endif
  if a:islocal
   " simplify the target (eg. /abc/def/../ghi -> /abc/ghi)
   let s:netrwmftgt= simplify(s:netrwmftgt)
"   call Decho("simplify: s:netrwmftgt<".s:netrwmftgt.">")
  endif
  if g:netrw_cygwin
   let s:netrwmftgt= substitute(system("cygpath ".shellescape(s:netrwmftgt)),'\n$','','')
   let s:netrwmftgt= substitute(s:netrwmftgt,'\n$','','')
  endif
  let s:netrwmftgt_islocal= a:islocal

  if g:netrw_fastbrowse <= 1
   call s:LocalBrowseShellCmdRefresh()
  endif
  call s:NetrwRefresh(a:islocal,s:NetrwBrowseChgDir(a:islocal,'./'))
  call netrw#NetrwRestorePosn(svpos)
  if !hadtgt
   norm! j
  endif

"  call Dret("s:NetrwMarkFileTgt : netrwmftgt<".(exists("s:netrwmftgt")? s:netrwmftgt : "").">")
endfun

" ---------------------------------------------------------------------
" s:NetrwOpenFile: query user for a filename and open it {{{2
fun! s:NetrwOpenFile(islocal)
"  call Dfunc("s:NetrwOpenFile(islocal=".a:islocal.")")
  call inputsave()
  let fname= input("Enter filename: ")
  call inputrestore()
  if fname !~ '[/\\]'
   if exists("b:netrw_curdir")
    if exists("g:netrw_quiet")
     let netrw_quiet_keep = g:netrw_quiet
    endif
    let g:netrw_quiet    = 1
    if b:netrw_curdir =~ '/$'
     exe "e ".fnameescape(b:netrw_curdir.fname)
    else
     exe "e ".fnameescape(b:netrw_curdir."/".fname)
    endif
    if exists("netrw_quiet_keep")
     let g:netrw_quiet= netrw_quiet_keep
    else
     unlet g:netrw_quiet
    endif
   endif
  else
   exe "e ".fnameescape(fname)
  endif
"  call Dret("s:NetrwOpenFile")
endfun

" ---------------------------------------------------------------------
" s:NetrwUnmarkList: delete local marked file lists and remove their contents from the global marked-file list {{{2
fun! s:NetrwUnmarkList(curbufnr,curdir)
"  call Dfunc("s:NetrwUnmarkList(curbufnr=".a:curbufnr." curdir<".a:curdir.">)")

  "  remove all files in local marked-file list from global list
  if exists("s:netrwmarkfilelist_{a:curbufnr}")
   for mfile in s:netrwmarkfilelist_{a:curbufnr}
    let dfile = s:ComposePath(a:curdir,mfile)       " prepend directory to mfile
    let idx   = index(s:netrwmarkfilelist,dfile)    " get index in list of dfile
    call remove(s:netrwmarkfilelist,idx)            " remove from global list
   endfor
   if s:netrwmarkfilelist == []
    unlet s:netrwmarkfilelist
   endif
 
   " getting rid of the local marked-file lists is easy
   unlet s:netrwmarkfilelist_{a:curbufnr}
  endif
  if exists("s:netrwmarkfilemtch_{a:curbufnr}")
   unlet s:netrwmarkfilemtch_{a:curbufnr}
  endif
  2match none
"  call Dret("s:NetrwUnmarkList")
endfun

" ---------------------------------------------------------------------
" s:NetrwUnmarkAll: remove the global marked file list and all local ones {{{2
fun! s:NetrwUnmarkAll()
"  call Dfunc("s:NetrwUnmarkAll()")
  if exists("s:netrwmarkfilelist")
   unlet s:netrwmarkfilelist
  endif
  silent call s:NetrwUnmarkAll2()
  2match none
"  call Dret("s:NetrwUnmarkAll")
endfun

" ---------------------------------------------------------------------
" s:NetrwUnmarkAll2: {{{2
fun! s:NetrwUnmarkAll2()
"  call Dfunc("s:NetrwUnmarkAll2()")
  redir => netrwmarkfilelist_let
  let
  redir END
  let netrwmarkfilelist_list= split(netrwmarkfilelist_let,'\n')          " convert let string into a let list
  call filter(netrwmarkfilelist_list,"v:val =~ '^s:netrwmarkfilelist_'") " retain only those vars that start as s:netrwmarkfilelist_ 
  call map(netrwmarkfilelist_list,"substitute(v:val,'\\s.*$','','')")    " remove what the entries are equal to
  for flist in netrwmarkfilelist_list
   let curbufnr= substitute(flist,'s:netrwmarkfilelist_','','')
   unlet s:netrwmarkfilelist_{curbufnr}
   unlet s:netrwmarkfilemtch_{curbufnr}
  endfor
"  call Dret("s:NetrwUnmarkAll2")
endfun

" ---------------------------------------------------------------------
" s:NetrwUnMarkFile: {{{2
fun! s:NetrwUnMarkFile(islocal)
"  call Dfunc("s:NetrwUnMarkFile(islocal=".a:islocal.")")
  let svpos    = netrw#NetrwSavePosn()
  let curbufnr = bufnr("%")

  " unmark marked file list (although I expect s:NetrwUpload()
  " to do it, I'm just making sure)
  if exists("s:netrwmarkfilelist_{bufnr('%')}")
"   call Decho("unlet'ing: s:netrwmarkfile[list|mtch]_".bufnr("%"))
   unlet s:netrwmarkfilelist
   unlet s:netrwmarkfilelist_{curbufnr}
   unlet s:netrwmarkfilemtch_{curbufnr}
   2match none
  endif

"  call s:NetrwRefresh(a:islocal,s:NetrwBrowseChgDir(a:islocal,'./'))
  call netrw#NetrwRestorePosn(svpos)
"  call Dret("s:NetrwUnMarkFile")
endfun

" ---------------------------------------------------------------------
" s:NetrwMenu: generates the menu for gvim and netrw {{{2
fun! s:NetrwMenu(domenu)

  if !exists("g:NetrwMenuPriority")
   let g:NetrwMenuPriority= 80
  endif

  if has("menu") && has("gui_running") && &go =~ 'm' && g:netrw_menu
"   call Dfunc("NetrwMenu(domenu=".a:domenu.")")

   if !exists("s:netrw_menu_enabled") && a:domenu
"    call Decho("initialize menu")
    let s:netrw_menu_enabled= 1
    exe 'silent! menu '.g:NetrwMenuPriority.'.1     '.g:NetrwTopLvlMenu.'Help<tab><F1>	<F1>'
    exe 'silent! menu '.g:NetrwMenuPriority.'.5     '.g:NetrwTopLvlMenu.'-Sep1-	:'
    exe 'silent! menu '.g:NetrwMenuPriority.'.6     '.g:NetrwTopLvlMenu.'Go\ Up\ Directory<tab>-	-'
    exe 'silent! menu '.g:NetrwMenuPriority.'.7     '.g:NetrwTopLvlMenu.'Apply\ Special\ Viewer<tab>x	x'
    exe 'silent! menu '.g:NetrwMenuPriority.'.8.1   '.g:NetrwTopLvlMenu.'Bookmarks\ and\ History.Bookmark\ Current\ Directory<tab>mb	mb'
    exe 'silent! menu '.g:NetrwMenuPriority.'.8.4   '.g:NetrwTopLvlMenu.'Bookmarks\ and\ History.Goto\ Prev\ Dir\ (History)<tab>u	u'
    exe 'silent! menu '.g:NetrwMenuPriority.'.8.5   '.g:NetrwTopLvlMenu.'Bookmarks\ and\ History.Goto\ Next\ Dir\ (History)<tab>U	U'
    exe 'silent! menu '.g:NetrwMenuPriority.'.8.6   '.g:NetrwTopLvlMenu.'Bookmarks\ and\ History.List<tab>qb	qb'
    exe 'silent! menu '.g:NetrwMenuPriority.'.9.1   '.g:NetrwTopLvlMenu.'Browsing\ Control.Edit\ File\ Hiding\ List<tab><ctrl-h>'."	\<c-h>'"
    exe 'silent! menu '.g:NetrwMenuPriority.'.9.2   '.g:NetrwTopLvlMenu.'Browsing\ Control.Edit\ Sorting\ Sequence<tab>S	S'
    exe 'silent! menu '.g:NetrwMenuPriority.'.9.3   '.g:NetrwTopLvlMenu.'Browsing\ Control.Quick\ Hide/Unhide\ Dot\ Files<tab>'."gh	gh"
    exe 'silent! menu '.g:NetrwMenuPriority.'.9.4   '.g:NetrwTopLvlMenu.'Browsing\ Control.Refresh\ Listing<tab>'."<ctrl-l>	\<c-l>"
    exe 'silent! menu '.g:NetrwMenuPriority.'.9.5   '.g:NetrwTopLvlMenu.'Browsing\ Control.Settings/Options<tab>:NetrwSettings	'.":NetrwSettings\<cr>"
    exe 'silent! menu '.g:NetrwMenuPriority.'.10    '.g:NetrwTopLvlMenu.'Delete\ File/Directory<tab>D	D'
    exe 'silent! menu '.g:NetrwMenuPriority.'.11.1  '.g:NetrwTopLvlMenu.'Edit\ File/Dir.In\ Current\ Window<tab><cr>	'."\<cr>"
    exe 'silent! menu '.g:NetrwMenuPriority.'.11.2  '.g:NetrwTopLvlMenu.'Edit\ File/Dir.Preview\ File/Directory<tab>p	p'
    exe 'silent! menu '.g:NetrwMenuPriority.'.11.3  '.g:NetrwTopLvlMenu.'Edit\ File/Dir.In\ Previous\ Window<tab>P	P'
    exe 'silent! menu '.g:NetrwMenuPriority.'.11.4  '.g:NetrwTopLvlMenu.'Edit\ File/Dir.In\ New\ Window<tab>o	o'
    exe 'silent! menu '.g:NetrwMenuPriority.'.11.5  '.g:NetrwTopLvlMenu.'Edit\ File/Dir.In\ New\ Vertical\ Window<tab>v	v'
    exe 'silent! menu '.g:NetrwMenuPriority.'.12.1  '.g:NetrwTopLvlMenu.'Explore.Directory\ Name	:Explore '
    exe 'silent! menu '.g:NetrwMenuPriority.'.12.2  '.g:NetrwTopLvlMenu.'Explore.Filenames\ Matching\ Pattern\ (curdir\ only)<tab>:Explore\ */	:Explore */'
    exe 'silent! menu '.g:NetrwMenuPriority.'.12.2  '.g:NetrwTopLvlMenu.'Explore.Filenames\ Matching\ Pattern\ (+subdirs)<tab>:Explore\ **/	:Explore **/'
    exe 'silent! menu '.g:NetrwMenuPriority.'.12.3  '.g:NetrwTopLvlMenu.'Explore.Files\ Containing\ Pattern\ (curdir\ only)<tab>:Explore\ *//	:Explore *//'
    exe 'silent! menu '.g:NetrwMenuPriority.'.12.4  '.g:NetrwTopLvlMenu.'Explore.Files\ Containing\ Pattern\ (+subdirs)<tab>:Explore\ **//	:Explore **//'
    exe 'silent! menu '.g:NetrwMenuPriority.'.12.4  '.g:NetrwTopLvlMenu.'Explore.Next\ Match<tab>:Nexplore	:Nexplore<cr>'
    exe 'silent! menu '.g:NetrwMenuPriority.'.12.4  '.g:NetrwTopLvlMenu.'Explore.Prev\ Match<tab>:Pexplore	:Pexplore<cr>'
    exe 'silent! menu '.g:NetrwMenuPriority.'.13    '.g:NetrwTopLvlMenu.'Make\ Subdirectory<tab>d	d'
    exe 'silent! menu '.g:NetrwMenuPriority.'.14.1  '.g:NetrwTopLvlMenu.'Marked\ Files.Mark\ File<tab>mf	mf'
    exe 'silent! menu '.g:NetrwMenuPriority.'.14.2  '.g:NetrwTopLvlMenu.'Marked\ Files.Mark\ Files\ by\ Regexp<tab>mr	mr'
    exe 'silent! menu '.g:NetrwMenuPriority.'.14.3  '.g:NetrwTopLvlMenu.'Marked\ Files.Hide-Show-List\ Control<tab>a	a'
    exe 'silent! menu '.g:NetrwMenuPriority.'.14.4  '.g:NetrwTopLvlMenu.'Marked\ Files.Copy\ To\ Target<tab>mc	mc'
    exe 'silent! menu '.g:NetrwMenuPriority.'.14.5  '.g:NetrwTopLvlMenu.'Marked\ Files.Delete<tab>D	D'
    exe 'silent! menu '.g:NetrwMenuPriority.'.14.6  '.g:NetrwTopLvlMenu.'Marked\ Files.Diff<tab>md	md'
    exe 'silent! menu '.g:NetrwMenuPriority.'.14.7  '.g:NetrwTopLvlMenu.'Marked\ Files.Edit<tab>me	me'
    exe 'silent! menu '.g:NetrwMenuPriority.'.14.8  '.g:NetrwTopLvlMenu.'Marked\ Files.Exe\ Cmd<tab>mx	mx'
    exe 'silent! menu '.g:NetrwMenuPriority.'.14.9  '.g:NetrwTopLvlMenu.'Marked\ Files.Move\ To\ Target<tab>mm	mm'
    exe 'silent! menu '.g:NetrwMenuPriority.'.14.10 '.g:NetrwTopLvlMenu.'Marked\ Files.Obtain<tab>O	O'
    exe 'silent! menu '.g:NetrwMenuPriority.'.14.11 '.g:NetrwTopLvlMenu.'Marked\ Files.Print<tab>mp	mp'
    exe 'silent! menu '.g:NetrwMenuPriority.'.14.12 '.g:NetrwTopLvlMenu.'Marked\ Files.Replace<tab>R	R'
    exe 'silent! menu '.g:NetrwMenuPriority.'.14.13 '.g:NetrwTopLvlMenu.'Marked\ Files.Set\ Target<tab>mt	mt'
    exe 'silent! menu '.g:NetrwMenuPriority.'.14.14 '.g:NetrwTopLvlMenu.'Marked\ Files.Tag<tab>mT	mT'
    exe 'silent! menu '.g:NetrwMenuPriority.'.14.15 '.g:NetrwTopLvlMenu.'Marked\ Files.Zip/Unzip/Compress/Uncompress<tab>mz	mz'
    exe 'silent! menu '.g:NetrwMenuPriority.'.15    '.g:NetrwTopLvlMenu.'Obtain\ File<tab>O	O'
    exe 'silent! menu '.g:NetrwMenuPriority.'.16.1  '.g:NetrwTopLvlMenu.'Style.Listing\ Style\ (thin-long-wide-tree)<tab>i	i'
    exe 'silent! menu '.g:NetrwMenuPriority.'.16.2  '.g:NetrwTopLvlMenu.'Style.Normal-Hide-Show<tab>a	a'
    exe 'silent! menu '.g:NetrwMenuPriority.'.16.3  '.g:NetrwTopLvlMenu.'Style.Reverse\ Sorting\ Order<tab>'."r	r"
    exe 'silent! menu '.g:NetrwMenuPriority.'.16.4  '.g:NetrwTopLvlMenu.'Style.Sorting\ Method\ (name-time-size)<tab>s	s'
    exe 'silent! menu '.g:NetrwMenuPriority.'.17    '.g:NetrwTopLvlMenu.'Rename\ File/Directory<tab>R	R'
    exe 'silent! menu '.g:NetrwMenuPriority.'.18    '.g:NetrwTopLvlMenu.'Set\ Current\ Directory<tab>c	c'
    call s:NetrwBookmarkMenu() " provide some history!  uses priorities 2,3, reserves 4, 8.2.x
    let s:netrw_menucnt= 28

   elseif !a:domenu
    let s:netrwcnt = 0
    let curwin     = winnr()
    windo if getline(2) =~ "Netrw" | let s:netrwcnt= s:netrwcnt + 1 | endif
    exe curwin."wincmd w"

    if s:netrwcnt <= 1
"     call Decho("clear menus")
     exe 'silent! unmenu '.g:NetrwTopLvlMenu
"     call Decho('exe silent! unmenu '.g:NetrwTopLvlMenu.'*')
     silent! unlet s:netrw_menu_enabled
    endif
   endif
"   call Dret("NetrwMenu")
  endif

endfun

" ---------------------------------------------------------------------
" s:NetrwObtain: obtain file under cursor or from markfile list {{{2
"                Used by the O maps (as <SID>NetrwObtain())
fun! s:NetrwObtain(islocal)
"  call Dfunc("NetrwObtain(islocal=".a:islocal.")")

  if exists("s:netrwmarkfilelist_{bufnr('%')}")
   let islocal= s:netrwmarkfilelist_{bufnr('%')}[1] !~ '^\a\+://'
   call netrw#NetrwObtain(islocal,s:netrwmarkfilelist_{bufnr('%')})
   call s:NetrwUnmarkList(bufnr('%'),b:netrw_curdir)
  else
   call netrw#NetrwObtain(a:islocal,expand("<cWORD>"))
  endif

"  call Dret("NetrwObtain")
endfun

" ---------------------------------------------------------------------
" netrw#NetrwObtain: {{{2
"   netrw#NetrwObtain(islocal,fname[,tgtdirectory])
"     islocal=0  obtain from remote source
"            =1  obtain from local source
"     fname  :   a filename or a list of filenames
"     tgtdir :   optional place where files are to go  (not present, uses getcwd())
fun! netrw#NetrwObtain(islocal,fname,...)
"  call Dfunc("netrw#NetrwObtain(islocal=".a:islocal." fname<".((type(a:fname) == 1)? a:fname : string(a:fname)).">) a:0=".a:0)
  " NetrwStatusLine support - for obtaining support

  if type(a:fname) == 1
   let fnamelist= [ a:fname ]
  elseif type(a:fname) == 3
   let fnamelist= a:fname
  else
   call netrw#ErrorMsg(s:ERROR,"attempting to use NetrwObtain on something not a filename or a list",62)
"   call Dret("netrw#NetrwObtain")
   return
  endif
"  call Decho("fnamelist<".string(fnamelist).">")
  if a:0 > 0
   let tgtdir= a:1
  else
   let tgtdir= getcwd()
  endif
"  call Decho("tgtdir<".tgtdir.">")

  if exists("b:netrw_islocal") && b:netrw_islocal
   " obtain a file from local b:netrw_curdir to (local) tgtdir
"   call Decho("obtain a file from local ".b:netrw_curdir." to ".tgtdir)
   if exists("b:netrw_curdir") && getcwd() != b:netrw_curdir
    let topath= s:ComposePath(tgtdir,"")
    if (has("win32") || has("win95") || has("win64") || has("win16"))
     " transfer files one at time
"     call Decho("transfer files one at a time")
     for fname in fnamelist
"      call Decho("system(".g:netrw_localcopycmd." ".shellescape(fname)." ".shellescape(topath).")")
      call system(g:netrw_localcopycmd." ".shellescape(fname)." ".shellescape(topath))
     endfor
    else
     " transfer files with one command
"     call Decho("transfer files with one command")
     let filelist= join(map(deepcopy(fnamelist),"shellescape(v:val)"))
"     call Decho("system(".g:netrw_localcopycmd." ".filelist." ".shellescape(topath).")")
     call system(g:netrw_localcopycmd." ".filelist." ".shellescape(topath))
    endif
   elseif !exists("b:netrw_curdir")
    call netrw#ErrorMsg(s:ERROR,"local browsing directory doesn't exist!",36)
   else
    call netrw#ErrorMsg(s:WARNING,"local browsing directory and current directory are identical",37)
   endif

  else
   " obtain files from remote b:netrw_curdir to local tgtdir
"   call Decho("obtain a file from remote ".b:netrw_curdir." to ".tgtdir)
   if type(a:fname) == 1
    call s:SetupNetrwStatusLine('%f %h%m%r%=%9*Obtaining '.a:fname)
   endif
   call s:NetrwMethod(b:netrw_curdir)

   if b:netrw_method == 4
    " obtain file using scp
"    call Decho("obtain via scp (method#4)")
    if exists("g:netrw_port") && g:netrw_port != ""
     let useport= " ".g:netrw_scpport." ".g:netrw_port
    else
     let useport= ""
    endif
    if b:netrw_fname =~ '/'
     let path= substitute(b:netrw_fname,'^\(.*/\).\{-}$','\1','')
    else
     let path= ""
    endif
    let filelist= join(map(deepcopy(fnamelist),'shellescape(g:netrw_machine.":".path.v:val,1)'))
"    call Decho("exe ".s:netrw_silentxfer."!".g:netrw_scp_cmd.shellescape(useport,1)." ".filelist." ".shellescape(tgtdir,1))
    exe s:netrw_silentxfer."!".g:netrw_scp_cmd.shellescape(useport,1)." ".filelist." ".shellescape(tgtdir,1)

   elseif b:netrw_method == 2
    " obtain file using ftp + .netrc
"     call Decho("obtain via ftp+.netrc (method #2)")
     call s:SaveBufVars()|silent keepjumps new|call s:RestoreBufVars()
     let tmpbufnr= bufnr("%")
     setlocal ff=unix
     if exists("g:netrw_ftpmode") && g:netrw_ftpmode != ""
      put =g:netrw_ftpmode
"      call Decho("filter input: ".getline('$'))
     endif

     if exists("b:netrw_fname") && b:netrw_fname != ""
      call setline(line("$")+1,'cd "'.b:netrw_fname.'"')
"      call Decho("filter input: ".getline('$'))
     endif

     if exists("g:netrw_ftpextracmd")
      put =g:netrw_ftpextracmd
"      call Decho("filter input: ".getline('$'))
     endif
     for fname in fnamelist
      call setline(line("$")+1,'get "'.fname.'"')
"      call Decho("filter input: ".getline('$'))
     endfor
     if exists("g:netrw_port") && g:netrw_port != ""
"      call Decho("executing: %!".g:netrw_ftp_cmd." -i ".shellescape(g:netrw_machine,1)." ".shellescape(g:netrw_port,1))
      exe s:netrw_silentxfer."%!".g:netrw_ftp_cmd." -i ".shellescape(g:netrw_machine,1)." ".shellescape(g:netrw_port,1)
     else
"      call Decho("executing: %!".g:netrw_ftp_cmd." -i ".shellescape(g:netrw_machine,1))
      exe s:netrw_silentxfer."%!".g:netrw_ftp_cmd." -i ".shellescape(g:netrw_machine,1)
     endif
     " If the result of the ftp operation isn't blank, show an error message (tnx to Doug Claar)
     if getline(1) !~ "^$" && !exists("g:netrw_quiet") && getline(1) !~ '^Trying '
      let debugkeep= &debug
      setlocal debug=msg
      call netrw#ErrorMsg(s:ERROR,getline(1),4)
      let &debug= debugkeep
     endif

   elseif b:netrw_method == 3
    " obtain with ftp + machine, id, passwd, and fname (ie. no .netrc)
"    call Decho("obtain via ftp+mipf (method #3)")
    call s:SaveBufVars()|silent keepjumps new|call s:RestoreBufVars()
    let tmpbufnr= bufnr("%")
    setlocal ff=unix

    if exists("g:netrw_port") && g:netrw_port != ""
     put ='open '.g:netrw_machine.' '.g:netrw_port
"     call Decho("filter input: ".getline('$'))
    else
     put ='open '.g:netrw_machine
"     call Decho("filter input: ".getline('$'))
    endif

    if exists("g:netrw_ftp") && g:netrw_ftp == 1
     put =g:netrw_uid
"     call Decho("filter input: ".getline('$'))
     put ='\"'.s:netrw_passwd.'\"'
"     call Decho("filter input: ".getline('$'))
    else
     put ='user \"'.g:netrw_uid.'\" \"'.s:netrw_passwd.'\"'
"     call Decho("filter input: ".getline('$'))
    endif

    if exists("g:netrw_ftpmode") && g:netrw_ftpmode != ""
     put =g:netrw_ftpmode
"     call Decho("filter input: ".getline('$'))
    endif

    if exists("b:netrw_fname") && b:netrw_fname != ""
     call setline(line("$")+1,'cd "'.b:netrw_fname.'"')
"     call Decho("filter input: ".getline('$'))
    endif

    if exists("g:netrw_ftpextracmd")
     put =g:netrw_ftpextracmd
"     call Decho("filter input: ".getline('$'))
    endif

    if exists("g:netrw_ftpextracmd")
     put =g:netrw_ftpextracmd
"     call Decho("filter input: ".getline('$'))
    endif
    for fname in fnamelist
     call setline(line("$")+1,'get "'.fname.'"')
    endfor
"    call Decho("filter input: ".getline('$'))

    " perform ftp:
    " -i       : turns off interactive prompting from ftp
    " -n  unix : DON'T use <.netrc>, even though it exists
    " -n  win32: quit being obnoxious about password
    norm! 1Gdd
"    call Decho("executing: %!".g:netrw_ftp_cmd." -i -n")
    exe s:netrw_silentxfer."%!".g:netrw_ftp_cmd." -i -n"
    " If the result of the ftp operation isn't blank, show an error message (tnx to Doug Claar)
    if getline(1) !~ "^$"
"     call Decho("error<".getline(1).">")
     if !exists("g:netrw_quiet")
      call netrw#ErrorMsg(s:ERROR,getline(1),5)
     endif
    endif
   elseif !exists("b:netrw_method") || b:netrw_method < 0
"    call Dfunc("netrw#NetrwObtain : unsupported method")
    return
   endif

   " restore status line
   if type(a:fname) == 1 && exists("s:netrw_users_stl")
    call s:SetupNetrwStatusLine(s:netrw_users_stl)
   endif

  endif

  " cleanup
  if exists("tmpbufnr")
   if bufnr("%") != tmpbufnr
    exe tmpbufnr."bw!"
   else
    q!
   endif
  endif

"  call Dret("netrw#NetrwObtain")
endfun

" ---------------------------------------------------------------------
" s:NetrwPrevWinOpen: open file/directory in previous window.  {{{2
"   If there's only one window, then the window will first be split.
"   Returns:
"     choice = 0 : didn't have to choose
"     choice = 1 : saved modified file in window first
"     choice = 2 : didn't save modified file, opened window
"     choice = 3 : cancel open
fun! s:NetrwPrevWinOpen(islocal)
"  call Dfunc("NetrwPrevWinOpen(islocal=".a:islocal.")")

  " grab a copy of the b:netrw_curdir to pass it along to newly split windows
  let curdir    = b:netrw_curdir

  " get last window number and the word currently under the cursor
  let lastwinnr = winnr("$")
  let curword   = s:NetrwGetWord()
  let choice    = 0
"  call Decho("lastwinnr=".lastwinnr." curword<".curword.">")

  let didsplit  = 0
  if lastwinnr == 1
   " if only one window, open a new one first
"   call Decho("only one window, so open a new one (g:netrw_alto=".g:netrw_alto.")")
   if g:netrw_preview
"    call Decho("exe ".(g:netrw_alto? "top " : "bot ")."vert ".g:netrw_winsize."wincmd s")
    exe (g:netrw_alto? "top " : "bot ")."vert ".g:netrw_winsize."wincmd s"
   else
"    call Decho("exe ".(g:netrw_alto? "bel " : "abo ").g:netrw_winsize."wincmd s")
    exe (g:netrw_alto? "bel " : "abo ").g:netrw_winsize."wincmd s"
   endif
   let didsplit  = 1

  else
   call s:SaveBufVars()
"   call Decho("wincmd p")
   wincmd p
   call s:RestoreBufVars()
   " if the previous window's buffer has been changed (is modified),
   " and it doesn't appear in any other extant window, then ask the
   " user if s/he wants to abandon modifications therein.
   let bnr    = winbufnr(0)
   let bnrcnt = 0
   if &mod
"    call Decho("detected: prev window's buffer has been modified: bnr=".bnr." winnr#".winnr())
    let eikeep= &ei
    set ei=all
    windo if winbufnr(0) == bnr | let bnrcnt=bnrcnt+1 | endif
    exe bnr."wincmd p"
    let &ei= eikeep
"    call Decho("bnr=".bnr." bnrcnt=".bnrcnt." buftype=".&bt." winnr#".winnr())
    if bnrcnt == 1
     let bufname= bufname(winbufnr(winnr()))
     let choice= confirm("Save modified file<".bufname.">?","&Yes\n&No\n&Cancel")
"     call Decho("bufname<".bufname."> choice=".choice." winnr#".winnr())

     if choice == 1
      " Yes -- write file & then browse
      let v:errmsg= ""
      silent w
      if v:errmsg != ""
       call netrw#ErrorMsg(s:ERROR,"unable to write <".bufname.">!",30)
       if didsplit
       	q
       else
       	wincmd p
       endif
"       call Dret("NetrwPrevWinOpen ".choice." : unable to write <".bufname.">")
       return choice
      endif

     elseif choice == 2
      " No -- don't worry about changed file, just browse anyway
      setlocal nomod
      call netrw#ErrorMsg(s:WARNING,bufname." changes to ".bufname." abandoned",31)
      wincmd p

     else
      " Cancel -- don't do this
      if didsplit
       q
      else
       wincmd p
      endif
"      call Dret("NetrwPrevWinOpen ".choice." : cancelled")
      return choice
     endif
    endif
   endif
  endif

  " restore b:netrw_curdir (window split/enew may have lost it)
  let b:netrw_curdir= curdir
  if a:islocal < 2
   if a:islocal
    call netrw#LocalBrowseCheck(s:NetrwBrowseChgDir(a:islocal,curword))
   else
    call s:NetrwBrowse(a:islocal,s:NetrwBrowseChgDir(a:islocal,curword))
   endif
  endif
"  call Dret("NetrwPrevWinOpen ".choice)
  return choice
endfun

" ---------------------------------------------------------------------
" s:NetrwUpload: load fname to tgt (used by NetrwMarkFileCopy()) {{{2
"                Always assumed to be local -> remote
"                call s:NetrwUpload(filename, target)
"                call s:NetrwUpload(filename, target, fromdirectory)
fun! s:NetrwUpload(fname,tgt,...)
"  call Dfunc("s:NetrwUpload(fname<".((type(a:fname) == 1)? a:fname : string(a:fname))."> tgt<".a:tgt.">) a:0=".a:0)

  if a:tgt =~ '^\a\+://'
   let tgtdir= substitute(a:tgt,'^\a\+://[^/]\+/\(.\{-}\)$','\1','')
  else
   let tgtdir= substitute(a:tgt,'^\(.*\)/[^/]*$','\1','')
  endif
"  call Decho("tgtdir<".tgtdir.">")

  if a:0 > 0
   let fromdir= a:1
  else
   let fromdir= getcwd()
  endif
"  call Decho("fromdir<".fromdir.">")

  if type(a:fname) == 1
   " handle uploading a single file using NetWrite
"   call Decho("handle uploading a single file via NetWrite")
   1split
"   call Decho("exe e ".fnameescape(a:fname))
   exe "e ".fnameescape(a:fname)
"   call Decho("now locally editing<".expand("%").">, has ".line("$")." lines")
   if a:tgt =~ '/$'
    let wfname= substitute(a:fname,'^.*/','','')
"    call Decho("exe w! ".fnameescape(wfname))
    exe "w! ".fnameescape(a:tgt.wfname)
   else
"    call Decho("writing local->remote: exe w ".fnameescape(a:tgt))
    exe "w ".fnameescape(a:tgt)
"    call Decho("done writing local->remote")
   endif
   q!

  elseif type(a:fname) == 3
   " handle uploading a list of files via scp
"   call Decho("handle uploading a list of files via scp")
   let curdir= getcwd()
   if a:tgt =~ '^scp:'
    exe "keepjumps silent lcd ".fnameescape(fromdir)
    let filelist= deepcopy(s:netrwmarkfilelist_{bufnr('%')})
    let args    = join(map(filelist,"shellescape(v:val, 1)"))
    if exists("g:netrw_port") && g:netrw_port != ""
     let useport= " ".g:netrw_scpport." ".g:netrw_port
    else
     let useport= ""
    endif
    let machine = substitute(a:tgt,'^scp://\([^/:]\+\).*$','\1','')
    let tgt     = substitute(a:tgt,'^scp://[^/]\+/\(.*\)$','\1','')
"    call Decho("exe ".s:netrw_silentxfer."!".g:netrw_scp_cmd.shellescape(useport,1)." ".args." ".shellescape(machine.":".tgt,1))
    exe s:netrw_silentxfer."!".g:netrw_scp_cmd.shellescape(useport,1)." ".args." ".shellescape(machine.":".tgt,1)
    exe "keepjumps silent lcd ".fnameescape(curdir)

   elseif a:tgt =~ '^ftp:'
    call s:NetrwMethod(a:tgt)

    if b:netrw_method == 2
     " handle uploading a list of files via ftp+.netrc
     let netrw_fname = b:netrw_fname
     silent keepjumps new
"     call Decho("filter input window#".winnr())

     put =g:netrw_ftpmode
"     call Decho("filter input: ".getline('$'))

     if exists("g:netrw_ftpextracmd")
      put =g:netrw_ftpextracmd
"      call Decho("filter input: ".getline('$'))
     endif

     call setline(line("$")+1,'lcd "'.fromdir.'"')
"     call Decho("filter input: ".getline('$'))

     call setline(line("$")+1,'cd "'.tgtdir.'"')
"     call Decho("filter input: ".getline('$'))

     for fname in a:fname
      call setline(line("$")+1,'put "'.fname.'"')
"      call Decho("filter input: ".getline('$'))
     endfor

     if exists("g:netrw_port") && g:netrw_port != ""
"      call Decho("executing: ".s:netrw_silentxfer."%!".g:netrw_ftp_cmd." -i ".shellescape(g:netrw_machine,1)." ".shellescape(g:netrw_port,1))
      exe s:netrw_silentxfer."%!".g:netrw_ftp_cmd." -i ".shellescape(g:netrw_machine,1)." ".shellescape(g:netrw_port,1)
     else
"      call Decho("filter input window#".winnr())
"      call Decho("executing: ".s:netrw_silentxfer."%!".g:netrw_ftp_cmd." -i ".shellescape(g:netrw_machine,1))
      exe s:netrw_silentxfer."%!".g:netrw_ftp_cmd." -i ".shellescape(g:netrw_machine,1)
     endif
     " If the result of the ftp operation isn't blank, show an error message (tnx to Doug Claar)
     silent g/Local directory now/d
     if getline(1) !~ "^$" && !exists("g:netrw_quiet") && getline(1) !~ '^Trying '
      call netrw#ErrorMsg(s:ERROR,getline(1),14)
     else
      bw!|q
     endif

    elseif b:netrw_method == 3
     " upload with ftp + machine, id, passwd, and fname (ie. no .netrc)
     let netrw_fname= b:netrw_fname
     call s:SaveBufVars()|silent keepjumps new|call s:RestoreBufVars()
     let tmpbufnr= bufnr("%")
     setlocal ff=unix

     if exists("g:netrw_port") && g:netrw_port != ""
      put ='open '.g:netrw_machine.' '.g:netrw_port
"      call Decho("filter input: ".getline('$'))
     else
      put ='open '.g:netrw_machine
"      call Decho("filter input: ".getline('$'))
     endif

     if exists("g:netrw_ftp") && g:netrw_ftp == 1
      put =g:netrw_uid
"      call Decho("filter input: ".getline('$'))
      call setline(line("$")+1,'"'.s:netrw_passwd.'"')
"      call Decho("filter input: ".getline('$'))
     else
      put ='user \"'.g:netrw_uid.'\" \"'.s:netrw_passwd.'\"'
"      call Decho("filter input: ".getline('$'))
     endif

     call setline(line("$")+1,'lcd "'.fromdir.'"')
"     call Decho("filter input: ".getline('$'))

     if exists("b:netrw_fname") && b:netrw_fname != ""
      call setline(line("$")+1,'cd "'.b:netrw_fname.'"')
"      call Decho("filter input: ".getline('$'))
     endif

     if exists("g:netrw_ftpextracmd")
      put =g:netrw_ftpextracmd
"      call Decho("filter input: ".getline('$'))
     endif

     for fname in a:fname
      call setline(line("$")+1,'put "'.fname.'"')
"      call Decho("filter input: ".getline('$'))
     endfor

     " perform ftp:
     " -i       : turns off interactive prompting from ftp
     " -n  unix : DON'T use <.netrc>, even though it exists
     " -n  win32: quit being obnoxious about password
     norm! 1Gdd
"     call Decho("executing: ".s:netrw_silentxfer."%!".g:netrw_ftp_cmd." -i -n")
     exe s:netrw_silentxfer."%!".g:netrw_ftp_cmd." -i -n"
     " If the result of the ftp operation isn't blank, show an error message (tnx to Doug Claar)
     silent g/Local directory now/d
     if getline(1) !~ "^$" && !exists("g:netrw_quiet") && getline(1) !~ '^Trying '
      let debugkeep= &debug
      setlocal debug=msg
      call netrw#ErrorMsg(s:ERROR,getline(1),15)
      let &debug = debugkeep
      let mod    = 1
     else
      bw!|q
     endif
    elseif !exists("b:netrw_method") || b:netrw_method < 0
"     call Dfunc("netrw#NetrwUpload : unsupported method")
     return
    endif
   else
    call netrw#ErrorMsg(s:ERROR,"can't obtain files with protocol from<".a:tgt.">",63)
   endif
  endif

"  call Dret("s:NetrwUpload")
endfun

" ---------------------------------------------------------------------
" s:NetrwPreview: {{{2
fun! s:NetrwPreview(path) range
"  call Dfunc("NetrwPreview(path<".a:path.">)")
  call s:NetrwOptionSave("s:")
  call s:NetrwSafeOptions()
  if has("quickfix")
   if !isdirectory(a:path)
    exe (g:netrw_preview? "vert " : "")."pedit ".fnameescape(a:path)
   elseif !exists("g:netrw_quiet")
    call netrw#ErrorMsg(s:WARNING,"sorry, cannot preview a directory such as <".a:path.">",38)
   endif
  elseif !exists("g:netrw_quiet")
   call netrw#ErrorMsg(s:WARNING,"sorry, to preview your vim needs the quickfix feature compiled in",39)
  endif
  call s:NetrwOptionRestore("s:")
"  call Dret("NetrwPreview")
endfun

" ---------------------------------------------------------------------
" s:NetrwRefresh: {{{2
fun! s:NetrwRefresh(islocal,dirname)
"  call Dfunc("NetrwRefresh(islocal<".a:islocal.">,dirname=".a:dirname.") hide=".g:netrw_hide." sortdir=".g:netrw_sort_direction)
  " at the current time (Mar 19, 2007) all calls to NetrwRefresh() call NetrwBrowseChgDir() first.
  " NetrwBrowseChgDir() may clear the display; hence a NetrwSavePosn() may not work if its placed here.
  " Also, NetrwBrowseChgDir() now does a NetrwSavePosn() itself.
  setlocal ma noro
"  call Decho("setlocal ma noro")
"  call Decho("clear buffer<".expand("%")."> with :%d")
  %d
  if a:islocal
   call netrw#LocalBrowseCheck(a:dirname)
  else
   call s:NetrwBrowse(a:islocal,a:dirname)
  endif
  call netrw#NetrwRestorePosn()

  " restore file marks
  if exists("s:netrwmarkfilemtch_{bufnr('%')}") && s:netrwmarkfilemtch_{bufnr("%")} != ""
"   call Decho("exe 2match netrwMarkFile /".s:netrwmarkfilemtch_{bufnr("%")}."/")
   exe "2match netrwMarkFile /".s:netrwmarkfilemtch_{bufnr("%")}."/"
  else
"   call Decho("2match none")
   2match none
  endif

"  redraw!
"  call Dret("NetrwRefresh")
endfun

" ---------------------------------------------------------------------
" s:NetrwRefreshDir: refreshes a directory by name {{{2
"                    Called by NetrwMarkFileCopy()
"                    Interfaces to s:NetrwRefresh() and s:LocalBrowseShellCmdRefresh()
fun! s:NetrwRefreshDir(islocal,dirname)
"  call Dfunc("s:NetrwRefreshDir(islocal=".a:islocal." dirname<".a:dirname.">) fastbrowse=".g:netrw_fastbrowse)
  if g:netrw_fastbrowse == 0
   " slowest mode (keep buffers refreshed, local or remote)
"   call Decho("slowest mode: keep buffers refreshed, local or remote")
   let tgtwin= bufwinnr(a:dirname)
"   call Decho("tgtwin= bufwinnr(".a:dirname.")=".tgtwin)

   if tgtwin > 0
    " tgtwin is being displayed, so refresh it
    let curwin= winnr()
"    call Decho("refresh tgtwin#".tgtwin." (curwin#".curwin.")")
    exe tgtwin."wincmd w"
    call s:NetrwRefresh(a:islocal,s:NetrwBrowseChgDir(a:islocal,'./')) 
    exe curwin."wincmd w"

   elseif bufnr(a:dirname) > 0
    let bn= bufnr(a:dirname)
"    call Decho("bd bufnr(".a:dirname.")=".bn)
    exe "silent bd ".bn
   endif

  elseif g:netrw_fastbrowse <= 1
"   call Decho("medium-speed mode: refresh local buffers only")
   call s:LocalBrowseShellCmdRefresh()
  endif
"  call Dret("s:NetrwRefreshDir")
endfun

" ---------------------------------------------------------------------
" s:NetrwSetSort: sets up the sort based on the g:netrw_sort_sequence {{{2
"          What this function does is to compute a priority for the patterns
"          in the g:netrw_sort_sequence.  It applies a substitute to any
"          "files" that satisfy each pattern, putting the priority / in
"          front.  An "*" pattern handles the default priority.
fun! s:NetrwSetSort()
"  call Dfunc("SetSort() bannercnt=".w:netrw_bannercnt)
  if w:netrw_liststyle == s:LONGLIST
   let seqlist  = substitute(g:netrw_sort_sequence,'\$','\\%(\t\\|\$\\)','ge')
  else
   let seqlist  = g:netrw_sort_sequence
  endif
  " sanity check -- insure that * appears somewhere
  if seqlist == ""
   let seqlist= '*'
  elseif seqlist !~ '\*'
   let seqlist= seqlist.',*'
  endif
  let priority = 1
  while seqlist != ""
   if seqlist =~ ','
    let seq     = substitute(seqlist,',.*$','','e')
    let seqlist = substitute(seqlist,'^.\{-},\(.*\)$','\1','e')
   else
    let seq     = seqlist
    let seqlist = ""
   endif
   let sepchr= "\<Char-0xff>"
   if priority < 10
    let spriority= "00".priority.sepchr
   elseif priority < 100
    let spriority= "0".priority.sepchr
   else
    let spriority= priority.sepchr
   endif
"   call Decho("priority=".priority." spriority<".spriority."> seq<".seq."> seqlist<".seqlist.">")

   " sanity check
   if w:netrw_bannercnt > line("$")
    " apparently no files were left after a Hiding pattern was used
"    call Dret("SetSort : no files left after hiding")
    return
   endif
   if seq == '*'
    let starpriority= spriority
   else
    exe 'silent keepjumps '.w:netrw_bannercnt.',$g/'.seq.'/s/^/'.spriority.'/'
    " sometimes multiple sorting patterns will match the same file or directory.
    " The following substitute is intended to remove the excess matches.
    exe 'silent keepjumps '.w:netrw_bannercnt.',$g/^\d\{3}'.sepchr.'\d\{3}\//s/^\d\{3}'.sepchr.'\(\d\{3}\/\).\@=/\1/e'
   endif
   let priority = priority + 1
  endwhile
  if exists("starpriority")
   exe 'silent keepjumps '.w:netrw_bannercnt.',$v/^\d\{3}'.sepchr.'/s/^/'.starpriority.'/'
  endif

  " Following line associated with priority -- items that satisfy a priority
  " pattern get prefixed by ###/ which permits easy sorting by priority.
  " Sometimes files can satisfy multiple priority patterns -- only the latest
  " priority pattern needs to be retained.  So, at this point, these excess
  " priority prefixes need to be removed, but not directories that happen to
  " be just digits themselves.
  exe 'silent keepjumps '.w:netrw_bannercnt.',$s/^\(\d\{3}'.sepchr.'\)\%(\d\{3}'.sepchr.'\)\+\ze./\1/e'

"  call Dret("SetSort")
endfun

" =====================================================================
" s:NetrwSortStyle: change sorting style (name - time - size) and refresh display {{{2
fun! s:NetrwSortStyle(islocal)
"  call Dfunc("s:NetrwSortStyle(islocal=".a:islocal.") netrw_sort_by<".g:netrw_sort_by.">")
  call s:NetrwSaveWordPosn()
  let svpos= netrw#NetrwSavePosn()

  let g:netrw_sort_by= (g:netrw_sort_by =~ 'n')? 'time' : (g:netrw_sort_by =~ 't')? 'size' : 'name'
  norm! 0
  call s:NetrwRefresh(a:islocal,s:NetrwBrowseChgDir(a:islocal,'./'))
  call netrw#NetrwRestorePosn(svpos)

"  call Dret("s:NetrwSortStyle : netrw_sort_by<".g:netrw_sort_by.">")
endfun

" ---------------------------------------------------------------------
" s:NetrwSplit: mode {{{2
"           =0 : net   and o
"           =1 : net   and t
"           =2 : net   and v
"           =3 : local and o
"           =4 : local and t
"           =5 : local and v
fun! s:NetrwSplit(mode)
"  call Dfunc("s:NetrwSplit(mode=".a:mode.") alto=".g:netrw_alto." altv=".g:netrw_altv)

  call s:SaveWinVars()

  if a:mode == 0
   " remote and o
"   call Decho("exe ".(g:netrw_alto? "bel " : "abo ").g:netrw_winsize."wincmd s")
   exe (g:netrw_alto? "bel " : "abo ").g:netrw_winsize."wincmd s"
   let s:didsplit= 1
   call s:RestoreWinVars()
   call s:NetrwBrowse(0,s:NetrwBrowseChgDir(0,s:NetrwGetWord()))
   unlet s:didsplit

  elseif a:mode == 1
   " remote and t
   let newdir  = s:NetrwBrowseChgDir(0,s:NetrwGetWord())
"   call Decho("tabnew")
   tabnew
   let s:didsplit= 1
   call s:RestoreWinVars()
   call s:NetrwBrowse(0,newdir)
   unlet s:didsplit

  elseif a:mode == 2
   " remote and v
"   call Decho("exe ".(g:netrw_altv? "rightb " : "lefta ").g:netrw_winsize."wincmd v")
   exe (g:netrw_altv? "rightb " : "lefta ").g:netrw_winsize."wincmd v"
   let s:didsplit= 1
   call s:RestoreWinVars()
   call s:NetrwBrowse(0,s:NetrwBrowseChgDir(0,s:NetrwGetWord()))
   unlet s:didsplit

  elseif a:mode == 3
   " local and o
"   call Decho("exe ".(g:netrw_alto? "bel " : "abo ").g:netrw_winsize."wincmd s")
   exe (g:netrw_alto? "bel " : "abo ").g:netrw_winsize."wincmd s"
   let s:didsplit= 1
   call s:RestoreWinVars()
   call netrw#LocalBrowseCheck(s:NetrwBrowseChgDir(1,s:NetrwGetWord()))
   unlet s:didsplit

  elseif a:mode == 4
   " local and t
   let netrw_curdir= b:netrw_curdir
   let cursorword  = s:NetrwGetWord()
"   call Decho("tabnew")
   tabnew
   let b:netrw_curdir= netrw_curdir
   let s:didsplit= 1
   call s:RestoreWinVars()
   call netrw#LocalBrowseCheck(s:NetrwBrowseChgDir(1,cursorword))
   unlet s:didsplit

  elseif a:mode == 5
   " local and v
"   call Decho("exe ".(g:netrw_altv? "rightb " : "lefta ").g:netrw_winsize."wincmd v")
   exe (g:netrw_altv? "rightb " : "lefta ").g:netrw_winsize."wincmd v"
   let s:didsplit= 1
   call s:RestoreWinVars()
   call netrw#LocalBrowseCheck(s:NetrwBrowseChgDir(1,s:NetrwGetWord()))
   unlet s:didsplit

  else
   call netrw#ErrorMsg(s:ERROR,"(NetrwSplit) unsupported mode=".a:mode,45)
  endif

"  call Dret("s:NetrwSplit")
endfun

" ---------------------------------------------------------------------
" NetrwStatusLine: {{{2
fun! NetrwStatusLine()

" vvv NetrwStatusLine() debugging vvv
"  let g:stlmsg=""
"  if !exists("w:netrw_explore_bufnr")
"   let g:stlmsg="!X<explore_bufnr>"
"  elseif w:netrw_explore_bufnr != bufnr("%")
"   let g:stlmsg="explore_bufnr!=".bufnr("%")
"  endif
"  if !exists("w:netrw_explore_line")
"   let g:stlmsg=" !X<explore_line>"
"  elseif w:netrw_explore_line != line(".")
"   let g:stlmsg=" explore_line!={line(.)<".line(".").">"
"  endif
"  if !exists("w:netrw_explore_list")
"   let g:stlmsg=" !X<explore_list>"
"  endif
" ^^^ NetrwStatusLine() debugging ^^^

  if !exists("w:netrw_explore_bufnr") || w:netrw_explore_bufnr != bufnr("%") || !exists("w:netrw_explore_line") || w:netrw_explore_line != line(".") || !exists("w:netrw_explore_list")
   " restore user's status line
   let &stl        = s:netrw_users_stl
   let &laststatus = s:netrw_users_ls
   if exists("w:netrw_explore_bufnr")|unlet w:netrw_explore_bufnr|endif
   if exists("w:netrw_explore_line") |unlet w:netrw_explore_line |endif
   return ""
  else
   return "Match ".w:netrw_explore_mtchcnt." of ".w:netrw_explore_listlen
  endif
endfun

" ---------------------------------------------------------------------
" s:NetrwTreeDir: determine tree directory given current cursor position {{{2
" (full path directory with trailing slash returned)
fun! s:NetrwTreeDir()
"  call Dfunc("NetrwTreeDir() curline#".line(".")."<".getline('.')."> b:netrw_curdir<".b:netrw_curdir."> tab#".tabpagenr()." win#".winnr()." buf#".bufnr("%")."<".bufname("%").">")

  let treedir= b:netrw_curdir
"  call Decho("set initial treedir<".treedir.">")
  let s:treecurpos= netrw#NetrwSavePosn()

  if w:netrw_liststyle == s:TREELIST
"   call Decho("w:netrrw_liststyle is TREELIST:")
"   call Decho("line#".line(".")." getline(.)<".getline('.')."> treecurpos<".string(s:treecurpos).">")
   if getline('.') =~ '/$'
    let treedir= substitute(getline('.'),'^\%(| \)*\([^|].\{-}\)$','\1','e')
   else
    let treedir= ""
   endif

"   call Decho("treedir<".treedir.">")

   " detect user attempting to close treeroot
   if getline('.') !~ '|' && getline('.') != '..'
"    call Decho("user attempted to close treeroot")
    " now force a refresh
"    call Decho("clear buffer<".expand("%")."> with :%d")
    keepjumps %d
"    call Dret("NetrwTreeDir <".treedir."> : (side effect) s:treecurpos<".string(s:treecurpos).">")
    return b:netrw_curdir
   endif

   " elide all non-depth information
   let depth = substitute(getline('.'),'^\(\%(| \)*\)[^|].\{-}$','\1','e')
"   call Decho("depth<".depth."> 1st subst")

   " elide first depth
   let depth = substitute(depth,'^| ','','')
"   call Decho("depth<".depth."> 2nd subst")

   " construct treedir by searching backwards at correct depth
"   call Decho("constructing treedir<".treedir."> depth<".depth.">")
   while depth != "" && search('^'.depth.'[^|].\{-}/$','bW')
    let dirname= substitute(getline('.'),'^\(| \)*','','e')
    let treedir= dirname.treedir
    let depth  = substitute(depth,'^| ','','')
"    call Decho("constructing treedir<".treedir.">: dirname<".dirname."> while depth<".depth.">")
   endwhile
   if w:netrw_treetop =~ '/$'
    let treedir= w:netrw_treetop.treedir
   else
    let treedir= w:netrw_treetop.'/'.treedir
   endif
"   call Decho("bufnr(.)=".bufnr("%")." line($)=".line("$")." line(.)=".line("."))
  endif
  let treedir= substitute(treedir,'//$','/','')

"  " now force a refresh
"" call DECHO("clear buffer<".expand("%")."> with :%d")
"  setlocal ma noro
"  keepjumps %d

"  call Dret("NetrwTreeDir <".treedir."> : (side effect) s:treecurpos<".string(s:treecurpos).">")
  return treedir
endfun

" ---------------------------------------------------------------------
" s:NetrwTreeDisplay: recursive tree display {{{2
fun! s:NetrwTreeDisplay(dir,depth)
"  call Dfunc("NetrwTreeDisplay(dir<".a:dir."> depth<".a:depth.">)")

  " insure that there are no folds
  setlocal nofen

  " install ../ and shortdir
  if a:depth == ""
   call setline(line("$")+1,'../')
"   call Decho("setline#".line("$")." ../ (depth is zero)")
  endif
  if a:dir =~ '^\a\+://'
   if a:dir == w:netrw_treetop
    let shortdir= a:dir
   else
    let shortdir= substitute(a:dir,'^.*/\([^/]\+\)/$','\1/','e')
   endif
   call setline(line("$")+1,a:depth.shortdir)
  else
   let shortdir= substitute(a:dir,'^.*/','','e')
   call setline(line("$")+1,a:depth.shortdir.'/')
  endif
"  call Decho("setline#".line("$")." shortdir<".a:depth.shortdir.">")

  " append a / to dir if its missing one
  let dir= a:dir
  if dir !~ '/$'
   let dir= dir.'/'
  endif

  " display subtrees (if any)
  let depth= "| ".a:depth

"  call Decho("display subtrees with depth<".depth."> and current leaves")
  for entry in w:netrw_treedict[a:dir]
   let direntry= substitute(dir.entry,'/$','','e')
"   call Decho("dir<".dir."> entry<".entry."> direntry<".direntry.">")
   if entry =~ '/$' && has_key(w:netrw_treedict,direntry)
"    call Decho("<".direntry."> is a key in treedict - display subtree for it")
    call s:NetrwTreeDisplay(direntry,depth)
   elseif entry =~ '/$' && has_key(w:netrw_treedict,direntry.'/')
"    call Decho("<".direntry."/> is a key in treedict - display subtree for it")
    call s:NetrwTreeDisplay(direntry.'/',depth)
   else
"    call Decho("<".entry."> is not a key in treedict (no subtree)")
    call setline(line("$")+1,depth.entry)
   endif
  endfor
"  call Dret("NetrwTreeDisplay")
endfun

" ---------------------------------------------------------------------
" s:NetrwTreeListing: displays tree listing from treetop on down, using NetrwTreeDisplay() {{{2
fun! s:NetrwTreeListing(dirname)
  if w:netrw_liststyle == s:TREELIST
"   call Dfunc("NetrwTreeListing() bufname<".expand("%").">")
"   call Decho("curdir<".a:dirname.">")
"   call Decho("win#".winnr().": w:netrw_treetop ".(exists("w:netrw_treetop")? "exists" : "doesn't exit")." w:netrw_treedict ".(exists("w:netrw_treedict")? "exists" : "doesn't exit"))

   " update the treetop
"   call Decho("update the treetop")
   if !exists("w:netrw_treetop")
    let w:netrw_treetop= a:dirname
"    call Decho("w:netrw_treetop<".w:netrw_treetop."> (reusing)")
   elseif (w:netrw_treetop =~ ('^'.a:dirname) && s:Strlen(a:dirname) < s:Strlen(w:netrw_treetop)) || a:dirname !~ ('^'.w:netrw_treetop)
    let w:netrw_treetop= a:dirname
"    call Decho("w:netrw_treetop<".w:netrw_treetop."> (went up)")
   endif

   " insure that we have at least an empty treedict
   if !exists("w:netrw_treedict")
    let w:netrw_treedict= {}
   endif

   " update the directory listing for the current directory
"   call Decho("updating dictionary with ".a:dirname.":[..directory listing..]")
"   call Decho("bannercnt=".w:netrw_bannercnt." line($)=".line("$"))
   exe "silent! keepjumps ".w:netrw_bannercnt.',$g@^\.\.\=/$@d'
   let w:netrw_treedict[a:dirname]= getline(w:netrw_bannercnt,line("$"))
"   call Decho("w:treedict[".a:dirname."]= ".w:netrw_treedict[a:dirname])
   exe "silent! keepjumps ".w:netrw_bannercnt.",$d"

   " if past banner, record word
   if exists("w:netrw_bannercnt") && line(".") > w:netrw_bannercnt
    let fname= expand("<cword>")
   else
    let fname= ""
   endif
"   call Decho("fname<".fname.">")

   " display from treetop on down
   call s:NetrwTreeDisplay(w:netrw_treetop,"")

"   call Dret("NetrwTreeListing : bufname<".expand("%").">")
  endif
endfun

" ---------------------------------------------------------------------
" s:NetrwWideListing: {{{2
fun! s:NetrwWideListing()

  if w:netrw_liststyle == s:WIDELIST
"   call Dfunc("NetrwWideListing() w:netrw_liststyle=".w:netrw_liststyle.' fo='.&fo.' l:fo='.&l:fo)
   " look for longest filename (cpf=characters per filename)
   " cpf: characters per file
   " fpl: files per line
   " fpc: files per column
   setlocal ma noro
"   call Decho("setlocal ma noro")
   let b:netrw_cpf= 0
   if line("$") >= w:netrw_bannercnt
    exe 'silent keepjumps '.w:netrw_bannercnt.',$g/^./if virtcol("$") > b:netrw_cpf|let b:netrw_cpf= virtcol("$")|endif'
   else
"    call Dret("NetrwWideListing")
    return
   endif
"   call Decho("max file strlen+1=".b:netrw_cpf)
   let b:netrw_cpf= b:netrw_cpf + 1

   " determine qty files per line (fpl)
   let w:netrw_fpl= winwidth(0)/b:netrw_cpf
   if w:netrw_fpl <= 0
    let w:netrw_fpl= 1
   endif
"   call Decho("fpl= ".winwidth(0)."/[b:netrw_cpf=".b:netrw_cpf.']='.w:netrw_fpl)

   " make wide display
   exe 'silent keepjumps '.w:netrw_bannercnt.',$s/^.*$/\=escape(printf("%-'.b:netrw_cpf.'s",submatch(0)),"\\")/'
   let fpc         = (line("$") - w:netrw_bannercnt + w:netrw_fpl)/w:netrw_fpl
   let newcolstart = w:netrw_bannercnt + fpc
   let newcolend   = newcolstart + fpc - 1
"   call Decho("bannercnt=".w:netrw_bannercnt." fpl=".w:netrw_fpl." fpc=".fpc." newcol[".newcolstart.",".newcolend."]")
   silent! let keepregstar = @*
   while line("$") >= newcolstart
    if newcolend > line("$") | let newcolend= line("$") | endif
    let newcolqty= newcolend - newcolstart
    exe newcolstart
    if newcolqty == 0
     exe "silent keepjumps norm! 0\<c-v>$hx".w:netrw_bannercnt."G$p"
    else
     exe "silent keepjumps norm! 0\<c-v>".newcolqty.'j$hx'.w:netrw_bannercnt.'G$p'
    endif
    exe "silent keepjumps ".newcolstart.','.newcolend.'d'
    exe 'silent keepjumps '.w:netrw_bannercnt
   endwhile
   silent! let @*= keepregstar
   exe "silent keepjumps ".w:netrw_bannercnt.',$s/\s\+$//e'
   setlocal noma nomod ro
"   call Dret("NetrwWideListing")
  endif

endfun

" ---------------------------------------------------------------------
" s:PerformListing: {{{2
fun! s:PerformListing(islocal)
"  call Dfunc("s:PerformListing(islocal=".a:islocal.") buf(%)=".bufnr("%")."<".bufname("%").">")

  call s:NetrwSafeOptions()
  setlocal noro ma
"  call Decho("setlocal noro ma")

"  if exists("g:netrw_silent") && g:netrw_silent == 0 && &ch >= 1	" Decho
"   call Decho("(netrw) Processing your browsing request...")
"  endif								" Decho

"  call Decho('w:netrw_liststyle='.(exists("w:netrw_liststyle")? w:netrw_liststyle : 'n/a'))
  if exists("w:netrw_liststyle") && w:netrw_liststyle == s:TREELIST && exists("w:netrw_treedict")
   " force a refresh for tree listings
"   call Decho("force refresh for treelisting: clear buffer<".expand("%")."> with :%d")
   keepjumps %d
  endif

  " save current directory on directory history list
  call s:NetrwBookHistHandler(3,b:netrw_curdir)

  " Set up the banner {{{3
"  call Decho("set up banner")
  keepjumps put ='\" ============================================================================'
  keepjumps put ='\" Netrw Directory Listing                                        (netrw '.g:loaded_netrw.')'
  keepjumps put ='\"   '.b:netrw_curdir
  keepjumps 1d
  let w:netrw_bannercnt= 3
  exe "keepjumps ".w:netrw_bannercnt

  let sortby= g:netrw_sort_by
  if g:netrw_sort_direction =~ "^r"
   let sortby= sortby." reversed"
  endif

  " Sorted by... {{{3
"  call Decho("handle specified sorting: g:netrw_sort_by<".g:netrw_sort_by.">")
  if g:netrw_sort_by =~ "^n"
"   call Decho("directories will be sorted by name")
   " sorted by name
   keepjumps put ='\"   Sorted by      '.sortby
   keepjumps put ='\"   Sort sequence: '.g:netrw_sort_sequence
   let w:netrw_bannercnt= w:netrw_bannercnt + 2
  else
"   call Decho("directories will be sorted by size or time")
   " sorted by size or date
   keepjumps put ='\"   Sorted by '.sortby
   let w:netrw_bannercnt= w:netrw_bannercnt + 1
  endif
  exe "keepjumps ".w:netrw_bannercnt

  " show copy/move target, if any
  if exists("s:netrwmftgt") && exists("s:netrwmftgt_islocal")
"   call Decho("show copy/move target<".s:netrwmftgt.">")
   keepjumps put =''
   if s:netrwmftgt_islocal
    call setline(line("."),'"   Copy/Move Tgt: '.s:netrwmftgt.' (local)')
   else
    call setline(line("."),'"   Copy/Move Tgt: '.s:netrwmftgt.' (remote)')
   endif
   let w:netrw_bannercnt= w:netrw_bannercnt + 1
  else
"   call Decho("s:netrwmftgt does not exist, don't make Copy/Move Tgt")
  endif
  exe "keepjumps ".w:netrw_bannercnt

  " Hiding...  -or-  Showing... {{{3
"  call Decho("handle hiding/showing (g:netrw_hide=".g:netrw_list_hide." g:netrw_list_hide<".g:netrw_list_hide.">)")
  if g:netrw_list_hide != "" && g:netrw_hide
   if g:netrw_hide == 1
    keepjumps put ='\"   Hiding:        '.g:netrw_list_hide
   else
    keepjumps put ='\"   Showing:       '.g:netrw_list_hide
   endif
   let w:netrw_bannercnt= w:netrw_bannercnt + 1
  endif
  exe "keepjumps ".w:netrw_bannercnt
  keepjumps put ='\"   Quick Help: <F1>:help  -:go up dir  D:delete  R:rename  s:sort-by  x:exec'
  keepjumps put ='\" ============================================================================'
  let w:netrw_bannercnt= w:netrw_bannercnt + 2

  " bannercnt should index the line just after the banner
  let w:netrw_bannercnt= w:netrw_bannercnt + 1
  exe "keepjumps ".w:netrw_bannercnt
"  call Decho("bannercnt=".w:netrw_bannercnt." (should index line just after banner) line($)=".line("$"))

  " set up syntax highlighting {{{3
"  call Decho("set up syntax highlighting")
  if has("syntax")
   setlocal ft=netrw
   if !exists("g:syntax_on") || !g:syntax_on
    setlocal ft=
   endif
  endif

  " get list of files
"  call Decho("Get list of files - islocal=".a:islocal)
  if a:islocal
   call s:LocalListing()
  else " remote
   call s:NetrwRemoteListing()
  endif
"  call Decho("w:netrw_bannercnt=".w:netrw_bannercnt." (banner complete)")

  " manipulate the directory listing (hide, sort) {{{3
  if line("$") >= w:netrw_bannercnt
"   call Decho("manipulate directory listing (hide)")
"   call Decho("g:netrw_hide=".g:netrw_hide." g:netrw_list_hide<".g:netrw_list_hide.">")
   if g:netrw_hide && g:netrw_list_hide != ""
    call s:NetrwListHide()
   endif
   if line("$") >= w:netrw_bannercnt
"    call Decho("manipulate directory listing (sort) : g:netrw_sort_by<".g:netrw_sort_by.">")

    if g:netrw_sort_by =~ "^n"
     " sort by name
     call s:NetrwSetSort()

     if w:netrw_bannercnt < line("$")
"      call Decho("g:netrw_sort_direction=".g:netrw_sort_direction." (bannercnt=".w:netrw_bannercnt.")")
      if g:netrw_sort_direction =~ 'n'
       " normal direction sorting
       exe 'silent keepjumps '.w:netrw_bannercnt.',$sort'.' '.g:netrw_sort_options
      else
       " reverse direction sorting
       exe 'silent keepjumps '.w:netrw_bannercnt.',$sort!'.' '.g:netrw_sort_options
      endif
     endif
     " remove priority pattern prefix
"     call Decho("remove priority pattern prefix")
     let sepchr= "\<Char-0xff>"
     exe 'silent keepjumps '.w:netrw_bannercnt.',$s/^\d\{3}'.sepchr.'//e'

    elseif a:islocal
     if w:netrw_bannercnt < line("$")
"      call Decho("g:netrw_sort_direction=".g:netrw_sort_direction)
      if g:netrw_sort_direction =~ 'n'
"       call Decho('exe silent keepjumps '.w:netrw_bannercnt.',$sort')
       exe 'silent keepjumps '.w:netrw_bannercnt.',$sort'.' '.g:netrw_sort_options
      else
"       call Decho('exe silent keepjumps '.w:netrw_bannercnt.',$sort!')
       exe 'silent keepjumps '.w:netrw_bannercnt.',$sort!'.' '.g:netrw_sort_options
      endif
     endif
     exe 'silent keepjumps '.w:netrw_bannercnt.',$s/^\d\{-}\///e'
    endif

   elseif g:netrw_sort_direction =~ 'r'
"    call Decho('reverse the sorted listing')
    exe 'silent keepjumps '.w:netrw_bannercnt.'g/^/m '.w:netrw_bannercnt
   endif
  endif

  " convert to wide/tree listing {{{3
"  call Decho("modify display if wide/tree listing style")
  call s:NetrwWideListing()
  call s:NetrwTreeListing(b:netrw_curdir)

  if exists("w:netrw_bannercnt") && line("$") > w:netrw_bannercnt
   " place cursor on the top-left corner of the file listing
"   call Decho("place cursor on top-left corner of file listing")
   exe 'silent keepjumps '.w:netrw_bannercnt
   norm! 0
  endif

  " record previous current directory
  let w:netrw_prvdir= b:netrw_curdir
"  call Decho("record netrw_prvdir<".w:netrw_prvdir.">")

  " save certain window-oriented variables into buffer-oriented variables {{{3
  call s:SetBufWinVars()
  call s:NetrwOptionRestore("w:")

  " set display to netrw display settings
"  call Decho("set display to netrw display settings (noma nomod etc)")
  setlocal noma nomod nonu nobl nowrap ro
  if exists("s:treecurpos")

   call netrw#NetrwRestorePosn(s:treecurpos)
   unlet s:treecurpos
  endif

"  call Dret("s:PerformListing : curpos<".string(getpos(".")).">")
endfun

" ---------------------------------------------------------------------
" s:SetupNetrwStatusLine: {{{2
fun! s:SetupNetrwStatusLine(statline)
"  call Dfunc("SetupNetrwStatusLine(statline<".a:statline.">)")

  if !exists("s:netrw_setup_statline")
   let s:netrw_setup_statline= 1
"   call Decho("do first-time status line setup")

   if !exists("s:netrw_users_stl")
    let s:netrw_users_stl= &stl
   endif
   if !exists("s:netrw_users_ls")
    let s:netrw_users_ls= &laststatus
   endif

   " set up User9 highlighting as needed
   let keepa= @a
   redir @a
   try
    hi User9
   catch /^Vim\%((\a\+)\)\=:E411/
    if &bg == "dark"
     hi User9 ctermfg=yellow ctermbg=blue guifg=yellow guibg=blue
    else
     hi User9 ctermbg=yellow ctermfg=blue guibg=yellow guifg=blue
    endif
   endtry
   redir END
   let @a= keepa
  endif

  " set up status line (may use User9 highlighting)
  " insure that windows have a statusline
  " make sure statusline is displayed
  let &stl=a:statline
  setlocal laststatus=2
"  call Decho("stl=".&stl)
  redraw

"  call Dret("SetupNetrwStatusLine : stl=".&stl)
endfun

" ---------------------------------------------------------------------
"  Remote Directory Browsing Support:    {{{1
" ===========================================

" ---------------------------------------------------------------------
" s:NetrwRemoteListing: {{{2
fun! s:NetrwRemoteListing()
"  call Dfunc("s:NetrwRemoteListing() b:netrw_curdir<".b:netrw_curdir.">)")

  call s:RemotePathAnalysis(b:netrw_curdir)

  " sanity check:
  if exists("b:netrw_method") && b:netrw_method =~ '[235]'
"   call Decho("b:netrw_method=".b:netrw_method)
   if !executable("ftp")
    if !exists("g:netrw_quiet")
     call netrw#ErrorMsg(s:ERROR,"this system doesn't support remote directory listing via ftp",18)
    endif
    call s:NetrwOptionRestore("w:")
"    call Dret("s:NetrwRemoteListing")
    return
   endif

  elseif !exists("g:netrw_list_cmd") || g:netrw_list_cmd == ''
   if !exists("g:netrw_quiet")
    if g:netrw_list_cmd == ""
     call netrw#ErrorMsg(s:ERROR,g:netrw_ssh_cmd." is not executable on your system",47)
    else
     call netrw#ErrorMsg(s:ERROR,"this system doesn't support remote directory listing via ".g:netrw_list_cmd,19)
    endif
   endif

   call s:NetrwOptionRestore("w:")
"   call Dret("s:NetrwRemoteListing")
   return
  endif  " (remote handling sanity check)

  if exists("b:netrw_method")
"   call Decho("setting w:netrw_method<".b:netrw_method.">")
   let w:netrw_method= b:netrw_method
  endif

  if s:method == "ftp"
   " use ftp to get remote file listing
"   call Decho("use ftp to get remote file listing")
   let s:method  = "ftp"
   let listcmd = g:netrw_ftp_list_cmd
   if g:netrw_sort_by =~ '^t'
    let listcmd= g:netrw_ftp_timelist_cmd
   elseif g:netrw_sort_by =~ '^s'
    let listcmd= g:netrw_ftp_sizelist_cmd
   endif
"   call Decho("listcmd<".listcmd."> (using g:netrw_ftp_list_cmd)")
   call s:NetrwRemoteFtpCmd(s:path,listcmd)
"   exe "keepjumps ".w:netrw_bannercnt.',$g/^./call Decho("raw listing: ".getline("."))'

   if w:netrw_liststyle == s:THINLIST || w:netrw_liststyle == s:WIDELIST || w:netrw_liststyle == s:TREELIST
    " shorten the listing
"    call Decho("generate short listing")
    exe "keepjumps ".w:netrw_bannercnt

    " cleanup
    if g:netrw_ftp_browse_reject != ""
     exe "silent! g/".g:netrw_ftp_browse_reject."/keepjumps d"
    endif
    silent! keepjumps %s/\r$//e

    " if there's no ../ listed, then put ./ and ../ in
    let line1= line(".")
    exe "keepjumps ".w:netrw_bannercnt
    let line2= search('^\.\.\/\%(\s\|$\)','cnW')
    if line2 == 0
"     call Decho("netrw is putting ./ and ../ into listing")
     keepjumps put='../'
     keepjumps put='./'
    endif
    exe "keepjumps ".line1
    keepjumps norm! 0

"    call Decho("line1=".line1." line2=".line2." line(.)=".line("."))
    if search('^\d\{2}-\d\{2}-\d\{2}\s','n') " M$ ftp site cleanup
"     call Decho("M$ ftp cleanup")
     exe 'silent! keepjumps '.w:netrw_bannercnt.',$s/^\d\{2}-\d\{2}-\d\{2}\s\+\d\+:\d\+[AaPp][Mm]\s\+\%(<DIR>\|\d\+\)\s\+//'
    else " normal ftp cleanup
"     call Decho("normal ftp cleanup")
     exe 'silent! keepjumps '.w:netrw_bannercnt.',$s/^\(\%(\S\+\s\+\)\{7}\S\+\)\s\+\(\S.*\)$/\2/e'
     exe "silent! keepjumps ".w:netrw_bannercnt.',$g/ -> /s# -> .*/$#/#e'
     exe "silent! keepjumps ".w:netrw_bannercnt.',$g/ -> /s# -> .*$#/#e'
    endif
   endif

  else
   " use ssh to get remote file listing {{{3
"   call Decho("use ssh to get remote file listing: s:path<".s:path.">")
   let listcmd= s:MakeSshCmd(g:netrw_list_cmd)
"   call Decho("listcmd<".listcmd."> (using g:netrw_list_cmd)")
   if g:netrw_scp_cmd =~ '^pscp'
"    call Decho("1: exe silent r! ".shellescape(listcmd.s:path, 1))
    exe "silent r! ".listcmd.shellescape(s:path, 1)
    " remove rubbish and adjust listing format of 'pscp' to 'ssh ls -FLa' like
    g/^Listing directory/d
    g/^d[-rwx][-rwx][-rwx]/s+$+/+e
    silent g/^l[-rwx][-rwx][-rwx]/s+$+@+e
    if g:netrw_liststyle != s:LONGLIST
     g/^[dlsp-][-rwx][-rwx][-rwx]/s/^.*\s\(\S\+\)$/\1/e
    endif
   else
    if s:path == ""
"     call Decho("2: exe silent r! ".listcmd)
     exe "silent r! ".listcmd
    else
"     call Decho("3: exe silent r! ".listcmd.' '.shellescape(s:path,1))
     exe "silent r! ".listcmd.' '.shellescape(s:path,1)
"     call Decho("listcmd<".listcmd."> path<".s:path.">")
    endif
   endif

   " cleanup
   if g:netrw_ftp_browse_reject != ""
"    call Decho("(cleanup) exe silent! g/".g:netrw_ssh_browse_reject."/keepjumps d")
    exe "silent! g/".g:netrw_ssh_browse_reject."/keepjumps d"
   endif
  endif

  if w:netrw_liststyle == s:LONGLIST
   " do a long listing; these substitutions need to be done prior to sorting {{{3
"   call Decho("fix long listing:")

   if s:method == "ftp"
    " cleanup
    exe "keepjumps ".w:netrw_bannercnt
    while getline('.') =~ g:netrw_ftp_browse_reject
     keepjumps d
    endwhile
    " if there's no ../ listed, then put ./ and ../ in
    let line1= line(".")
    keepjumps 1
    silent keepjumps call search('^\.\.\/\%(\s\|$\)','W')
    let line2= line(".")
    if line2 == 0
     exe 'keepjumps '.w:netrw_bannercnt."put='./'"
     if b:netrw_curdir != '/'
      exe 'keepjumps '.w:netrw_bannercnt."put='../'"
     endif
    endif
   exe "keepjumps ".line1
   keepjumps norm! 0
   endif

   if search('^\d\{2}-\d\{2}-\d\{2}\s','n') " M$ ftp site cleanup
"    call Decho("M$ ftp site listing cleanup")
    exe 'silent! keepjumps '.w:netrw_bannercnt.',$s/^\(\d\{2}-\d\{2}-\d\{2}\s\+\d\+:\d\+[AaPp][Mm]\s\+\%(<DIR>\|\d\+\)\s\+\)\(\w.*\)$/\2\t\1/'
   elseif exists("w:netrw_bannercnt") && w:netrw_bannercnt <= line("$")
"    call Decho("normal ftp site listing cleanup: bannercnt=".w:netrw_bannercnt." line($)=".line("$"))
    exe 'silent keepjumps '.w:netrw_bannercnt.',$s/ -> .*$//e'
    exe 'silent keepjumps '.w:netrw_bannercnt.',$s/^\(\%(\S\+\s\+\)\{7}\S\+\)\s\+\(\S.*\)$/\2\t\1/e'
    exe 'silent keepjumps '.w:netrw_bannercnt
   endif
  endif

"  if exists("w:netrw_bannercnt") && w:netrw_bannercnt <= line("$") " Decho
"   exe "keepjumps ".w:netrw_bannercnt.',$g/^./call Decho("listing: ".getline("."))'
"  endif " Decho
"  call Dret("s:NetrwRemoteListing")
endfun

" ---------------------------------------------------------------------
" s:NetrwRemoteRm: remove/delete a remote file or directory {{{2
fun! s:NetrwRemoteRm(usrhost,path) range
"  call Dfunc("s:NetrwRemoteRm(usrhost<".a:usrhost."> path<".a:path.">) virtcol=".virtcol("."))
"  call Decho("firstline=".a:firstline." lastline=".a:lastline)
  let svpos= netrw#NetrwSavePosn()

  let all= 0
  if exists("s:netrwmarkfilelist_{bufnr('%')}")
   " remove all marked files
"   call Decho("remove all marked files with bufnr#".bufnr("%"))
   for fname in s:netrwmarkfilelist_{bufnr("%")}
    let ok= s:NetrwRemoteRmFile(a:path,fname,all)
    if ok =~ 'q\%[uit]'
     break
    elseif ok =~ 'a\%[ll]'
     let all= 1
    endif
   endfor
   call s:NetrwUnmarkList(bufnr("%"),b:netrw_curdir)

  else
   " remove files specified by range
"   call Decho("remove files specified by range")

   " preparation for removing multiple files/directories
   let ctr= a:firstline

   " remove multiple files and directories
   while ctr <= a:lastline
    exe ctr
    let ok= s:NetrwRemoteRmFile(a:path,s:NetrwGetWord(),all)
    if ok =~ 'q\%[uit]'
     break
    elseif ok =~ 'a\%[ll]'
     let all= 1
    endif
    let ctr= ctr + 1
   endwhile
  endif

  " refresh the (remote) directory listing
"  call Decho("refresh remote directory listing")
  call s:NetrwRefresh(0,s:NetrwBrowseChgDir(0,'./'))
  call netrw#NetrwRestorePosn(svpos)

"  call Dret("s:NetrwRemoteRm")
endfun

" ---------------------------------------------------------------------
" s:NetrwRemoteRmFile: {{{2
fun! s:NetrwRemoteRmFile(path,rmfile,all)
"  call Dfunc("s:NetrwRemoteRmFile(path<".a:path."> rmfile<".a:rmfile.">) all=".a:all)

  let all= a:all
  let ok = ""

  if a:rmfile !~ '^"' && (a:rmfile =~ '@$' || a:rmfile !~ '[\/]$')
   " attempt to remove file
"    call Decho("attempt to remove file (all=".all.")")
   if !all
    echohl Statement
"    call Decho("case all=0:")
    call inputsave()
    let ok= input("Confirm deletion of file<".a:rmfile."> ","[{y(es)},n(o),a(ll),q(uit)] ")
    call inputrestore()
    echohl NONE
    if ok == ""
     let ok="no"
    endif
    let ok= substitute(ok,'\[{y(es)},n(o),a(ll),q(uit)]\s*','','e')
    if ok =~ 'a\%[ll]'
     let all= 1
    endif
   endif

   if all || ok =~ 'y\%[es]' || ok == ""
"    call Decho("case all=".all." or ok<".ok.">".(exists("w:netrw_method")? ': netrw_method='.w:netrw_method : ""))
    if exists("w:netrw_method") && (w:netrw_method == 2 || w:netrw_method == 3)
"     call Decho("case ftp:")
     let path= a:path
     if path =~ '^\a\+://'
      let path= substitute(path,'^\a\+://[^/]\+/','','')
     endif
     silent! keepjumps .,$d
     call s:NetrwRemoteFtpCmd(path,"delete ".'"'.a:rmfile.'"')
    else
"     call Decho("case ssh: g:netrw_rm_cmd<".g:netrw_rm_cmd.">")
     let netrw_rm_cmd= s:MakeSshCmd(g:netrw_rm_cmd)
"     call Decho("netrw_rm_cmd<".netrw_rm_cmd.">")
     if !exists("b:netrw_curdir")
      call netrw#ErrorMsg(s:ERROR,"for some reason b:netrw_curdir doesn't exist!",53)
      let ok="q"
     else
      let remotedir= substitute(b:netrw_curdir,'^.*//[^/]\+/\(.*\)$','\1','')
"      call Decho("netrw_rm_cmd<".netrw_rm_cmd.">")
"      call Decho("remotedir<".remotedir.">")
"      call Decho("rmfile<".a:rmfile.">")
      if remotedir != ""
       let netrw_rm_cmd= netrw_rm_cmd." ".shellescape(fnameescape(remotedir.a:rmfile))
      else
       let netrw_rm_cmd= netrw_rm_cmd." ".shellescape(fnameescape(a:rmfile))
      endif
"      call Decho("call system(".netrw_rm_cmd.")")
      let ret= system(netrw_rm_cmd)
      if ret != 0
       call netrw#ErrorMsg(s:WARNING,"cmd<".netrw_rm_cmd."> failed",60)
      endif
"      call Decho("returned=".ret." errcode=".v:shell_error)
     endif
    endif
   elseif ok =~ 'q\%[uit]'
"    call Decho("ok==".ok)
    break
   endif

  else
   " attempt to remove directory
"    call Decho("attempt to remove directory")
   if !all
    call inputsave()
    let ok= input("Confirm deletion of directory<".a:rmfile."> ","[{y(es)},n(o),a(ll),q(uit)] ")
    call inputrestore()
    if ok == ""
     let ok="no"
    endif
    let ok= substitute(ok,'\[{y(es)},n(o),a(ll),q(uit)]\s*','','e')
    if ok =~ 'a\%[ll]'
     let all= 1
    endif
   endif

   if all || ok =~ 'y\%[es]' || ok == ""
    if exists("w:netrw_method") && (w:netrw_method == 2 || w:netrw_method == 3)
     call s:NetrwRemoteFtpCmd(a:path,"rmdir ".a:rmfile)
    else
     let rmfile          = substitute(a:path.a:rmfile,'/$','','')
     let netrw_rmdir_cmd = s:MakeSshCmd(s:WinPath(g:netrw_rmdir_cmd)).' '.shellescape(s:WinPath(rmfile))
"      call Decho("attempt to remove dir: system(".netrw_rmdir_cmd.")")
     let ret= system(netrw_rmdir_cmd)
"      call Decho("returned=".ret." errcode=".v:shell_error)

     if v:shell_error != 0
"      call Decho("v:shell_error not 0")
      let netrw_rmf_cmd= s:MakeSshCmd(s:WinPath(g:netrw_rmf_cmd)).' '.shellescape(s:WinPath(substitute(rmfile,'[\/]$','','e')))
"      call Decho("2nd attempt to remove dir: system(".netrw_rmf_cmd.")")
      let ret= system(netrw_rmf_cmd)
"      call Decho("returned=".ret." errcode=".v:shell_error)

      if v:shell_error != 0 && !exists("g:netrw_quiet")
      	call netrw#ErrorMsg(s:ERROR,"unable to remove directory<".rmfile."> -- is it empty?",22)
      endif
     endif
    endif

   elseif ok =~ 'q\%[uit]'
    break
   endif
  endif

"  call Dret("s:NetrwRemoteRmFile ".ok)
  return ok
endfun

" ---------------------------------------------------------------------
" s:NetrwRemoteFtpCmd: unfortunately, not all ftp servers honor options for ls {{{2
"  This function assumes that a long listing will be received.  Size, time,
"  and reverse sorts will be requested of the server but not otherwise
"  enforced here.
fun! s:NetrwRemoteFtpCmd(path,listcmd)
"  call Dfunc("NetrwRemoteFtpCmd(path<".a:path."> listcmd<".a:listcmd.">) netrw_method=".w:netrw_method)
"  call Decho("line($)=".line("$")." bannercnt=".w:netrw_bannercnt)

  " because WinXX ftp uses unix style input
  let ffkeep= &ff
  setlocal ma ff=unix noro
"  call Decho("setlocal ma ff=unix noro")

  " clear off any older non-banner lines
  " note that w:netrw_bannercnt indexes the line after the banner
"  call Decho('exe silent! keepjumps '.w:netrw_bannercnt.",$d  (clear off old non-banner lines)")
  exe "silent! keepjumps ".w:netrw_bannercnt.",$d"

  ".........................................
  if w:netrw_method == 2 || w:netrw_method == 5
   " ftp + <.netrc>:  Method #2
   if a:path != ""
    put ='cd \"'.a:path.'\"'
   endif
   if exists("g:netrw_ftpextracmd")
    put =g:netrw_ftpextracmd
"    call Decho("filter input: ".getline('.'))
   endif
   call setline(line("$")+1,a:listcmd)
"   exe "keepjumps ".w:netrw_bannercnt.',$g/^./call Decho("ftp#".line(".").": ".getline("."))'
   if exists("g:netrw_port") && g:netrw_port != ""
"    call Decho("exe ".s:netrw_silentxfer.w:netrw_bannercnt.",$!".g:netrw_ftp_cmd." -i ".shellescape(g:netrw_machine,1)." ".shellescape(g:netrw_port,1))
    exe s:netrw_silentxfer." keepjumps ".w:netrw_bannercnt.",$!".g:netrw_ftp_cmd." -i ".shellescape(g:netrw_machine,1)." ".shellescape(g:netrw_port,1)
   else
"    call Decho("exe ".s:netrw_silentxfer.w:netrw_bannercnt.",$!".g:netrw_ftp_cmd." -i ".shellescape(g:netrw_machine,1))
    exe s:netrw_silentxfer." keepjumps ".w:netrw_bannercnt.",$!".g:netrw_ftp_cmd." -i ".shellescape(g:netrw_machine,1)
   endif

   ".........................................
  elseif w:netrw_method == 3
   " ftp + machine,id,passwd,filename:  Method #3
    setlocal ff=unix
    if exists("g:netrw_port") && g:netrw_port != ""
     put ='open '.g:netrw_machine.' '.g:netrw_port
    else
     put ='open '.g:netrw_machine
    endif

    if exists("g:netrw_ftp") && g:netrw_ftp == 1
     put =g:netrw_uid
     put ='\"'.s:netrw_passwd.'\"'
    else
     put ='user \"'.g:netrw_uid.'\" \"'.s:netrw_passwd.'\"'
    endif

   if a:path != ""
    put ='cd \"'.a:path.'\"'
   endif
   if exists("g:netrw_ftpextracmd")
    put =g:netrw_ftpextracmd
"    call Decho("filter input: ".getline('.'))
   endif
   call setline(line("$")+1,a:listcmd)

    " perform ftp:
    " -i       : turns off interactive prompting from ftp
    " -n  unix : DON'T use <.netrc>, even though it exists
    " -n  win32: quit being obnoxious about password
"    exe w:netrw_bannercnt.',$g/^./call Decho("ftp#".line(".").": ".getline("."))'
"    call Decho("exe ".s:netrw_silentxfer.w:netrw_bannercnt.",$!".g:netrw_ftp_cmd." -i -n")
    exe s:netrw_silentxfer.w:netrw_bannercnt.",$!".g:netrw_ftp_cmd." -i -n"

   ".........................................
  else
   call netrw#ErrorMsg(s:WARNING,"unable to comply with your request<" . choice . ">",23)
  endif

  " cleanup for Windows
  if has("win32") || has("win95") || has("win64") || has("win16")
   silent! keepjumps %s/\r$//e
  endif
  if a:listcmd == "dir"
   " infer directory/link based on the file permission string
   silent! keepjumps g/d\%([-r][-w][-x]\)\{3}/s@$@/@
   silent! keepjumps g/l\%([-r][-w][-x]\)\{3}/s/$/@/
   if w:netrw_liststyle == s:THINLIST || w:netrw_liststyle == s:WIDELIST || w:netrw_liststyle == s:TREELIST
    exe "silent! keepjumps ".w:netrw_bannercnt.',$s/^\%(\S\+\s\+\)\{8}//e'
   endif
  endif

  " ftp's listing doesn't seem to include ./ or ../
  if !search('^\.\/$\|\s\.\/$','wn')
   exe 'keepjumps '.w:netrw_bannercnt
   put ='./'
  endif
  if !search('^\.\.\/$\|\s\.\.\/$','wn')
   exe 'keepjumps '.w:netrw_bannercnt
   put ='../'
  endif

  " restore settings
  let &ff= ffkeep
"  call Dret("NetrwRemoteFtpCmd")
endfun

" ---------------------------------------------------------------------
" s:NetrwRemoteRename: rename a remote file or directory {{{2
fun! s:NetrwRemoteRename(usrhost,path) range
"  call Dfunc("NetrwRemoteRename(usrhost<".a:usrhost."> path<".a:path.">)")

  " preparation for removing multiple files/directories
  let svpos      = netrw#NetrwSavePosn()
  let ctr        = a:firstline
  let rename_cmd = s:MakeSshCmd(g:netrw_rename_cmd)

  " rename files given by the markfilelist
  if exists("s:netrwmarkfilelist_{bufnr('%')}")
   for oldname in s:netrwmarkfilelist_{bufnr("%")}
"    call Decho("oldname<".oldname.">")
    if exists("subfrom")
     let newname= substitute(oldname,subfrom,subto,'')
"     call Decho("subfrom<".subfrom."> subto<".subto."> newname<".newname.">")
    else
     call inputsave()
     let newname= input("Moving ".oldname." to : ",oldname)
     call inputrestore()
     if newname =~ '^s/'
      let subfrom = substitute(newname,'^s/\([^/]*\)/.*/$','\1','')
      let subto   = substitute(newname,'^s/[^/]*/\(.*\)/$','\1','')
      let newname = substitute(oldname,subfrom,subto,'')
"      call Decho("subfrom<".subfrom."> subto<".subto."> newname<".newname.">")
     endif
    endif
   
    if exists("w:netrw_method") && (w:netrw_method == 2 || w:netrw_method == 3)
     call s:NetrwRemoteFtpCmd(a:path,"rename ".oldname." ".newname)
    else
     let oldname= shellescape(a:path.oldname)
     let newname= shellescape(a:path.newname)
"     call Decho("system(s:WinPath(".rename_cmd.") ".oldname.' '.newname.")")
     let ret    = system(s:WinPath(rename_cmd).' '.oldname.' '.newname)
    endif

   endfor
   call s:NetrwUnMarkFile(1)

  else

  " attempt to rename files/directories
   while ctr <= a:lastline
    exe "keepjumps ".ctr

    let oldname= s:NetrwGetWord()
"   call Decho("oldname<".oldname.">")

    call inputsave()
    let newname= input("Moving ".oldname." to : ",oldname)
    call inputrestore()

    if exists("w:netrw_method") && (w:netrw_method == 2 || w:netrw_method == 3)
     call s:NetrwRemoteFtpCmd(a:path,"rename ".oldname." ".newname)
    else
     let oldname= shellescape(a:path.oldname)
     let newname= shellescape(a:path.newname)
"     call Decho("system(s:WinPath(".rename_cmd.") ".oldname.' '.newname.")")
     let ret    = system(s:WinPath(rename_cmd).' '.oldname.' '.newname)
    endif

    let ctr= ctr + 1
   endwhile
  endif

  " refresh the directory
  call s:NetrwRefresh(0,s:NetrwBrowseChgDir(0,'./'))
  call netrw#NetrwRestorePosn(svpos)

"  call Dret("NetrwRemoteRename")
endfun

" ---------------------------------------------------------------------
"  Local Directory Browsing Support:    {{{1
" ==========================================

" ---------------------------------------------------------------------
" netrw#LocalBrowseCheck: {{{2
fun! netrw#LocalBrowseCheck(dirname)
  " unfortunate interaction -- split window debugging can't be
  " used here, must use D-echoRemOn or D-echoTabOn -- the BufEnter
  " event triggers another call to LocalBrowseCheck() when attempts
  " to write to the DBG buffer are made.
  " The &ft == "netrw" test was installed because the BufEnter event
  " would hit when re-entering netrw windows, creating unexpected
  " refreshes (and would do so in the middle of NetrwSaveOptions(), too)
"  call Decho("netrw#LocalBrowseCheck: isdir<".a:dirname.">=".isdirectory(a:dirname))
  if isdirectory(a:dirname)
"   call Decho(" ft<".&ft."> b:netrw_curdir<".(exists("b:netrw_curdir")? b:netrw_curdir : " doesn't exist")."> dirname<".a:dirname.">"." line($)=".line("$"))
   if &ft != "netrw" || (exists("b:netrw_curdir") && b:netrw_curdir != a:dirname)
    silent! call s:NetrwBrowse(1,a:dirname)
   elseif &ft == "netrw" && line("$") == 1
    silent! call s:NetrwBrowse(1,a:dirname)
   endif
  endif
  " not a directory, ignore it
endfun

" ---------------------------------------------------------------------
"  s:LocalListing: does the job of "ls" for local directories {{{2
fun! s:LocalListing()
"  call Dfunc("s:LocalListing()")
"  call Decho("&ma=".&ma)
"  call Decho("&mod=".&mod)
"  call Decho("&ro=".&ro)
"  call Decho("bufname(%)<".bufname("%").">")

"  if exists("b:netrw_curdir") |call Decho('b:netrw_curdir<'.b:netrw_curdir.">")  |else|call Decho("b:netrw_curdir doesn't exist") |endif
"  if exists("g:netrw_sort_by")|call Decho('g:netrw_sort_by<'.g:netrw_sort_by.">")|else|call Decho("g:netrw_sort_by doesn't exist")|endif

  " get the list of files contained in the current directory
  let dirname    = escape(b:netrw_curdir,g:netrw_glob_escape)
  let dirnamelen = strlen(b:netrw_curdir)
  let filelist   = glob(s:ComposePath(dirname,"*"))
"  call Decho("glob(dirname<".dirname."/*>)=".filelist)
  if filelist != ""
   let filelist= filelist."\n"
  endif
  let filelist= filelist.glob(s:ComposePath(dirname,".*"))
"  call Decho("glob(dirname<".dirname."/.*>)=".filelist)

  " Coding choice: either   elide   ./ if present
  "                or       include ./ if not present
  if filelist =~ '[\\/]\.[\\/]\=\(\n\|$\)'
   " elide /path/. from glob() entries if present
"   call Decho("elide /path/. from glob entries if present")
   let filelist = substitute(filelist,'\n','\t','g')
   let filelist = substitute(filelist,'^[^\t]\+[/\\]\.\t','','')
   let filelist = substitute(filelist,'[^\t]\+[/\\]\.$','','')
   let filelist = substitute(filelist,'\t\zs[^\t]\+[/\\]\.\t','','')
   let filelist = substitute(filelist,'\t','\n','g')
  endif
"  call Decho("filelist<".filelist.">")
  if filelist !~ '[\\/]\.\.[\\/]\=\(\n\|$\)'
    " include ../ in the glob() entry if its missing
"   call Decho("forcibly tacking on ..")
   let filelist= filelist."\n".s:ComposePath(b:netrw_curdir,"../")
"   call Decho("filelist<".filelist.">")
  endif
  if b:netrw_curdir == '/'
   " remove .. from filelist when current directory is root directory
"   call Decho("remove .. from filelist")
   let filelist= substitute(filelist,'/\.\.\n','','')
  endif
  " remove multiple contiguous newlines
  let filelist= substitute(filelist,'\n\{2,}','\n','ge')
  if !g:netrw_cygwin && (has("win32") || has("win95") || has("win64") || has("win16"))
   " change all \s to /s
"   call Decho('change all \s to /s')
   let filelist= substitute(filelist,'\','/','g')
  else
   " escape all \s to \\
"   call Decho('escape all \s to \\')
   let filelist= substitute(filelist,'\','\\','g')
  endif

"  call Decho("(before while) dirname<".dirname.">")
"  call Decho("(before while) dirnamelen<".dirnamelen.">")
"  call Decho("(before while) filelist<".filelist.">")

  while filelist != ""
   if filelist =~ '\n'
    let filename = substitute(filelist,'\n.*$','','e')
    let filelist = substitute(filelist,'^.\{-}\n\(.*\)$','\1','e')
   else
    let filename = filelist
    let filelist = ""
   endif
"   call Decho(" ")
"   call Decho("(while) filelist<".filelist.">")
"   call Decho("(while) filename<".filename.">")

   if getftype(filename) == "link"
    " indicate a symbolic link
"    call Decho("indicate <".filename."> is a symbolic link with trailing @")
    let pfile= filename."@"

   elseif getftype(filename) == "socket"
    " indicate a socket
"    call Decho("indicate <".filename."> is a socket with trailing =")
    let pfile= filename."="

   elseif getftype(filename) == "fifo"
    " indicate a fifo
"    call Decho("indicate <".filename."> is a fifo with trailing |")
    let pfile= filename."|"

   elseif isdirectory(filename)
    " indicate a directory
"    call Decho("indicate <".filename."> is a directory with trailing /")
    let pfile= filename."/"

   elseif exists("b:netrw_curdir") && b:netrw_curdir !~ '^.*://' && !isdirectory(filename)
    if (has("win32") || has("win95") || has("win64") || has("win16"))
     if filename =~ '\.[eE][xX][eE]$' || filename =~ '\.[cC][oO][mM]$' || filename =~ '\.[bB][aA][tT]$'
      " indicate an executable
"      call Decho("indicate <".filename."> is executable with trailing *")
      let pfile= filename."*"
     else
      " normal file
      let pfile= filename
     endif
    elseif executable(filename)
     " indicate an executable
"     call Decho("indicate <".filename."> is executable with trailing *")
     let pfile= filename."*"
    else
     " normal file
     let pfile= filename
    endif

   else
    " normal file
    let pfile= filename
   endif
"   call Decho("pfile<".pfile."> (after *@/ appending)")

   if pfile =~ '//$'
    let pfile= substitute(pfile,'//$','/','e')
"    call Decho("change // to /: pfile<".pfile.">")
   endif
   let pfile= strpart(pfile,dirnamelen)
   let pfile= substitute(pfile,'^[/\\]','','e')
"   call Decho("filename<".filename.">")
"   call Decho("pfile   <".pfile.">")

   if w:netrw_liststyle == s:LONGLIST
    let sz   = getfsize(filename)
    let fsz  = strpart("               ",1,15-s:Strlen(sz)).sz
    let pfile= pfile."\t".fsz." ".strftime(g:netrw_timefmt,getftime(filename))
"    call Decho("sz=".sz." fsz=".fsz)
   endif

   if     g:netrw_sort_by =~ "^t"
    " sort by time (handles time up to 1 quintillion seconds, US)
"    call Decho("getftime(".filename.")=".getftime(filename))
    let t  = getftime(filename)
    let ft = strpart("000000000000000000",1,18-s:Strlen(t)).t
"    call Decho("exe keepjumps put ='".ft.'/'.filename."'")
    let ftpfile= ft.'/'.pfile
    keepjumps silent! put=ftpfile

   elseif g:netrw_sort_by =~ "^s"
    " sort by size (handles file sizes up to 1 quintillion bytes, US)
"    call Decho("getfsize(".filename.")=".getfsize(filename))
    let sz   = getfsize(filename)
    let fsz  = strpart("000000000000000000",1,18-s:Strlen(sz)).sz
"    call Decho("exe keepjumps put ='".fsz.'/'.filename."'")
    let fszpfile= fsz.'/'.pfile
    keepjumps silent! put =fszpfile

   else
    " sort by name
"    call Decho("exe keepjumps put ='".pfile."'")
    keepjumps silent! put=pfile
   endif
  endwhile

  " cleanup any windows mess at end-of-line
  silent! keepjumps %s/\r$//e
  exe "setlocal ts=".g:netrw_maxfilenamelen
"  call Decho("setlocal ts=".g:netrw_maxfilenamelen)

"  call Dret("s:LocalListing")
endfun

" ---------------------------------------------------------------------
" s:LocalBrowseShellCmdRefresh: this function is called after a user has {{{2
" performed any shell command.  The idea is to cause all local-browsing
" buffers to be refreshed after a user has executed some shell command,
" on the chance that s/he removed/created a file/directory with it.
fun! s:LocalBrowseShellCmdRefresh()
"  call Dfunc("LocalBrowseShellCmdRefresh() browselist=".(exists("s:netrw_browselist")? string(s:netrw_browselist) : "empty")." ".tabpagenr("$")." tabs")
  " determine which buffers currently reside in a tab
  if !exists("s:netrw_browselist")
"   call Dret("LocalBrowseShellCmdRefresh : browselist is empty")
   return
  endif
  if !exists("w:netrw_bannercnt")
"   call Dret("LocalBrowseShellCmdRefresh : don't refresh when focus not on netrw windwo")
   return
  endif
  if exists("s:locbrowseshellcmd")
   if s:locbrowseshellcmd
    let s:locbrowseshellcmd= 0
"    call Dret("LocalBrowseShellCmdRefresh : NetrwBrowse itself caused the refresh")
    return
   endif
   let s:locbrowseshellcmd= 0
  endif
  let itab       = 1
  let buftablist = []
  while itab <= tabpagenr("$")
   let buftablist = buftablist + tabpagebuflist()
   let itab       = itab + 1
   tabn
  endwhile
"  call Decho("buftablist".string(buftablist))
"  call Decho("s:netrw_browselist<".(exists("s:netrw_browselist")? string(s:netrw_browselist) : "").">")
  "  GO through all buffers on netrw_browselist (ie. just local-netrw buffers):
  "   | refresh any netrw window
  "   | wipe out any non-displaying netrw buffer
  let curwin = winnr()
  let ibl    = 0
  for ibuf in s:netrw_browselist
"   call Decho("bufwinnr(".ibuf.") index(buftablist,".ibuf.")=".index(buftablist,ibuf))
   if bufwinnr(ibuf) == -1 && index(buftablist,ibuf) == -1
    " wipe out any non-displaying netrw buffer
"    call Decho("wiping  buf#".ibuf,"<".bufname(ibuf).">")
    exe "silent! bd ".fnameescape(ibuf)
    call remove(s:netrw_browselist,ibl)
"    call Decho("browselist=".string(s:netrw_browselist))
    continue
   elseif index(tabpagebuflist(),ibuf) != -1
    " refresh any netrw buffer
"    call Decho("refresh buf#".ibuf.'-> win#'.bufwinnr(ibuf))
    exe bufwinnr(ibuf)."wincmd w"
    call s:NetrwRefresh(1,s:NetrwBrowseChgDir(1,'./'))
   endif
   let ibl= ibl + 1
  endfor
  exe curwin."wincmd w"

"  call Dret("LocalBrowseShellCmdRefresh")
endfun

" ---------------------------------------------------------------------
" s:NetrwLocalRm: {{{2
fun! s:NetrwLocalRm(path) range
"  call Dfunc("s:NetrwLocalRm(path<".a:path.">)")
"  call Decho("firstline=".a:firstline." lastline=".a:lastline)

  " preparation for removing multiple files/directories
  let ret   = 0
  let all   = 0
  let svpos = netrw#NetrwSavePosn()

  if exists("s:netrwmarkfilelist_{bufnr('%')}")
   " remove all marked files
"   call Decho("remove all marked files")
   for fname in s:netrwmarkfilelist_{bufnr("%")}
    let ok= s:NetrwLocalRmFile(a:path,fname,all)
    if ok =~ 'q\%[uit]' || ok == "no"
     break
    elseif ok =~ 'a\%[ll]'
     let all= 1
    endif
   endfor
   call s:NetrwUnMarkFile(1)

  else
  " remove (multiple) files and directories
"   call Decho("remove files in range [".a:firstline.",".a:lastline."]")

   let ctr = a:firstline
   while ctr <= a:lastline
    exe "keepjumps ".ctr

    " sanity checks
    if line(".") < w:netrw_bannercnt
     let ctr= ctr + 1
     continue
    endif
    let curword= s:NetrwGetWord()
    if curword == "./" || curword == "../"
     let ctr= ctr + 1
     continue
    endif
    let ok= s:NetrwLocalRmFile(a:path,curword,all)
    if ok =~ 'q\%[uit]' || ok == "no"
     break
    elseif ok =~ 'a\%[ll]'
     let all= 1
    endif
    let ctr= ctr + 1
   endwhile
  endif

  " refresh the directory
"  call Decho("bufname<".bufname("%").">")
  if bufname("%") != "NetrwMessage"
   call s:NetrwRefresh(1,s:NetrwBrowseChgDir(1,'./'))
   call netrw#NetrwRestorePosn(svpos)
  endif

"  call Dret("s:NetrwLocalRm")
endfun

" ---------------------------------------------------------------------
" s:NetrwLocalRmFile: remove file fname given the path {{{2
"                     Give confirmation prompt unless all==1
fun! s:NetrwLocalRmFile(path,fname,all)
"  call Dfunc("s:NetrwLocalRmFile(path<".a:path."> fname<".a:fname."> all=".a:all)
  
  let all= a:all
  let ok = ""
  norm! 0
  let rmfile= s:ComposePath(a:path,a:fname)
"  call Decho("rmfile<".rmfile.">")

  if rmfile !~ '^"' && (rmfile =~ '@$' || rmfile !~ '[\/]$')
   " attempt to remove file
"   call Decho("attempt to remove file<".rmfile.">")
   if !all
    echohl Statement
    call inputsave()
    let ok= input("Confirm deletion of file<".rmfile."> ","[{y(es)},n(o),a(ll),q(uit)] ")
    call inputrestore()
    echohl NONE
    if ok == ""
     let ok="no"
    endif
"    call Decho("response: ok<".ok.">")
    let ok= substitute(ok,'\[{y(es)},n(o),a(ll),q(uit)]\s*','','e')
"    call Decho("response: ok<".ok."> (after sub)")
    if ok =~ 'a\%[ll]'
     let all= 1
    endif
   endif

   if all || ok =~ 'y\%[es]' || ok == ""
    let ret= s:NetrwDelete(rmfile)
"    call Decho("errcode=".v:shell_error." ret=".ret)
   endif

  else
   " attempt to remove directory
   if !all
    echohl Statement
    call inputsave()
    let ok= input("Confirm deletion of directory<".rmfile."> ","[{y(es)},n(o),a(ll),q(uit)] ")
    call inputrestore()
    let ok= substitute(ok,'\[{y(es)},n(o),a(ll),q(uit)]\s*','','e')
    if ok == ""
     let ok="no"
    endif
    if ok =~ 'a\%[ll]'
     let all= 1
    endif
   endif
   let rmfile= substitute(rmfile,'[\/]$','','e')

   if all || ok =~ 'y\%[es]' || ok == ""
"    call Decho("1st attempt: system(s:WinPath(".g:netrw_local_rmdir.') '.shellescape(rmfile).')')
    call system(s:WinPath(g:netrw_local_rmdir).' '.shellescape(rmfile))
"    call Decho("v:shell_error=".v:shell_error)

    if v:shell_error != 0
"     call Decho("2nd attempt to remove directory<".rmfile.">")
     let errcode= s:NetrwDelete(rmfile)
"     call Decho("errcode=".errcode)

     if errcode != 0
      if has("unix")
"       call Decho("3rd attempt to remove directory<".rmfile.">")
       call system("rm ".shellescape(rmfile))
       if v:shell_error != 0 && !exists("g:netrw_quiet")
        call netrw#ErrorMsg(s:ERROR,"unable to remove directory<".rmfile."> -- is it empty?",34)
	let ok="no"
       endif
      elseif !exists("g:netrw_quiet")
       call netrw#ErrorMsg(s:ERROR,"unable to remove directory<".rmfile."> -- is it empty?",35)
       let ok="no"
      endif
     endif
    endif
   endif
  endif

"  call Dret("s:NetrwLocalRmFile ".ok)
  return ok
endfun

" ---------------------------------------------------------------------
" s:NetrwLocalRename: rename a remote file or directory {{{2
fun! s:NetrwLocalRename(path) range
"  call Dfunc("NetrwLocalRename(path<".a:path.">)")

  " preparation for removing multiple files/directories
  let ctr  = a:firstline
  let svpos= netrw#NetrwSavePosn()

  " rename files given by the markfilelist
  if exists("s:netrwmarkfilelist_{bufnr('%')}")
   for oldname in s:netrwmarkfilelist_{bufnr("%")}
"    call Decho("oldname<".oldname.">")
    if exists("subfrom")
     let newname= substitute(oldname,subfrom,subto,'')
"     call Decho("subfrom<".subfrom."> subto<".subto."> newname<".newname.">")
    else
     call inputsave()
     let newname= input("Moving ".oldname." to : ",oldname)
     call inputrestore()
     if newname =~ '^s/'
      let subfrom = substitute(newname,'^s/\([^/]*\)/.*/$','\1','')
      let subto   = substitute(newname,'^s/[^/]*/\(.*\)/$','\1','')
"      call Decho("subfrom<".subfrom."> subto<".subto."> newname<".newname.">")
      let newname = substitute(oldname,subfrom,subto,'')
     endif
    endif
    call rename(oldname,newname)
   endfor
   call s:NetrwUnmarkList(bufnr("%"),b:netrw_curdir)
  
  else

   " attempt to rename files/directories
   while ctr <= a:lastline
    exe "keepjumps ".ctr

    " sanity checks
    if line(".") < w:netrw_bannercnt
     let ctr= ctr + 1
     continue
    endif
    let curword= s:NetrwGetWord()
    if curword == "./" || curword == "../"
     let ctr= ctr + 1
     continue
    endif

    norm! 0
    let oldname= s:ComposePath(a:path,curword)
"   call Decho("oldname<".oldname.">")

    call inputsave()
    let newname= input("Moving ".oldname." to : ",substitute(oldname,'/*$','','e'))
    call inputrestore()

    call rename(oldname,newname)
"   call Decho("renaming <".oldname."> to <".newname.">")

    let ctr= ctr + 1
   endwhile
  endif

  " refresh the directory
"  call Decho("refresh the directory listing")
  call s:NetrwRefresh(1,s:NetrwBrowseChgDir(1,'./'))
  call netrw#NetrwRestorePosn(svpos)

"  call Dret("NetrwLocalRename")
endfun

" ---------------------------------------------------------------------
" s:LocalFastBrowser: handles setting up/taking down fast browsing for the local browser {{{2
"
"     g:netrw_    Directory Is
"     fastbrowse  Local  Remote   
"  slow   0         D      D      D=Deleting a buffer implies it will not be re-used (slow)
"  med    1         D      H      H=Hiding a buffer implies it may be re-used        (fast)
"  fast   2         H      H      
"
"  Deleting a buffer means that it will be re-loaded when examined, hence "slow".
"  Hiding   a buffer means that it will be re-used   when examined, hence "fast".
"           (re-using a buffer may not be as accurate)
fun! s:LocalFastBrowser()
"  call Dfunc("LocalFastBrowser() g:netrw_fastbrowse=".g:netrw_fastbrowse)

  " initialize browselist, a list of buffer numbers that the local browser has used
  if !exists("s:netrw_browselist")
"   call Decho("initialize s:netrw_browselist")
   let s:netrw_browselist= []
  endif

  " append current buffer to fastbrowse list
  if empty(s:netrw_browselist) || bufnr("%") > s:netrw_browselist[-1]
"   call Decho("appendng current buffer to browselist")
   call add(s:netrw_browselist,bufnr("%"))
"   call Decho("browselist=".string(s:netrw_browselist))
  endif

  " enable autocmd events to handle refreshing/removing local browser buffers
  "    If local browse buffer is currently showing: refresh it
  "    If local browse buffer is currently hidden : wipe it
  if !exists("s:netrw_browser_shellcmd") && g:netrw_fastbrowse <= 1
"   call Decho("setting up local-browser shell command refresh")
   let s:netrw_browser_shellcmd= 1
   augroup AuNetrwShellCmd
    au!
    if (has("win32") || has("win95") || has("win64") || has("win16"))
"     call Decho("autocmd: ShellCmdPost * call s:LocalBrowseShellCmdRefresh()")
     au ShellCmdPost			*	call s:LocalBrowseShellCmdRefresh()
    else
     au ShellCmdPost,FocusGained	*	call s:LocalBrowseShellCmdRefresh()
"     call Decho("autocmd: ShellCmdPost,FocusGained * call s:LocalBrowseShellCmdRefresh()")
    endif
   augroup END
  endif

  " user must have changed fastbrowse to its fast setting, so remove
  " the associated autocmd events
  if g:netrw_fastbrowse > 1 && exists("s:netrw_browser_shellcmd")
"   call Decho("remove AuNetrwShellCmd autcmd group")
   unlet s:netrw_browser_shellcmd
   augroup AuNetrwShellCmd
    au!
   augroup END
   augroup! AuNetrwShellCmd
  endif

"  call Dret("LocalFastBrowser : browselist<".string(s:netrw_browselist).">")
endfun

" ---------------------------------------------------------------------
" Support Functions: {{{1

" ---------------------------------------------------------------------
" netrw#ErrorMsg: {{{2
"   0=note     = s:NOTE
"   1=warning  = s:WARNING
"   2=error    = s:ERROR
"  Oct 12, 2008 : max errnum currently is 73
fun! netrw#ErrorMsg(level,msg,errnum)
"  call Dfunc("netrw#ErrorMsg(level=".a:level." msg<".a:msg."> errnum=".a:errnum.") g:netrw_use_errorwindow=".g:netrw_use_errorwindow)

  if a:level == 1
   let level= "**warning** (netrw) "
  elseif a:level == 2
   let level= "**error** (netrw) "
  else
   let level= "**note** (netrw) "
  endif
"  call Decho("level=".level)

  if g:netrw_use_errorwindow
   " (default) netrw creates a one-line window to show error/warning
   " messages (reliably displayed)

   " record current window number for NetrwRestorePosn()'s benefit
   let s:winBeforeErr= winnr()
"   call Decho("s:winBeforeErr=".s:winBeforeErr)

   " getting messages out reliably is just plain difficult!
   " This attempt splits the current window, creating a one line window.
   if bufexists("NetrwMessage") && bufwinnr("NetrwMessage") > 0
"    call Decho("write to NetrwMessage buffer")
    exe bufwinnr("NetrwMessage")."wincmd w"
"    call Decho("setlocal ma noro")
    setlocal ma noro
    call setline(line("$")+1,level.a:msg)
    $
   else
"    call Decho("create a NetrwMessage buffer window")
    bo 1split
    enew
    setlocal bt=nofile
    file NetrwMessage
"    call Decho("setlocal ma noro")
    setlocal ma noro
    call setline(line("$"),level.a:msg)
   endif
"   call Decho("wrote msg<".level.a:msg."> to NetrwMessage win#".winnr())
   if &fo !~ '[ta]'
    syn clear
    syn match netrwMesgNote	"^\*\*note\*\*"
    syn match netrwMesgWarning	"^\*\*warning\*\*"
    syn match netrwMesgError	"^\*\*error\*\*"
    hi link netrwMesgWarning WarningMsg
    hi link netrwMesgError   Error
   endif
   setlocal noma ro bh=wipe

  else
   " (optional) netrw will show messages using echomsg.  Even if the
   " message doesn't appear, at least it'll be recallable via :messages
"   redraw!
   if a:level == s:WARNING
    echohl WarningMsg
   elseif a:level == s:ERROR
    echohl Error
   endif
   echomsg level.a:msg
"   call Decho("echomsg ***netrw*** ".a:msg)
   echohl None
  endif

"  call Dret("netrw#ErrorMsg")
endfun

" ---------------------------------------------------------------------
" netrw#NetrwRestorePosn: restores the cursor and file position as saved by NetrwSavePosn() {{{2
fun! netrw#NetrwRestorePosn(...)
"  call Dfunc("netrw#NetrwRestorePosn() a:0=".a:0." winnr=".(exists("w:netrw_winnr")? w:netrw_winnr : -1)." line=".(exists("w:netrw_line")? w:netrw_line : -1)." col=".(exists("w:netrw_col")? w:netrw_col : -1)." hline=".(exists("w:netrw_hline")? w:netrw_hline : -1))
  let eikeep= &ei
  set ei=all
  if expand("%") == "NetrwMessage"
   exe s:winBeforeErr."wincmd w"
  endif

  if a:0 > 0
   exe a:1
  endif

  " restore window
  if exists("w:netrw_winnr")
"   call Decho("restore window: exe silent! ".w:netrw_winnr."wincmd w")
   exe "silent! ".w:netrw_winnr."wincmd w"
  endif
  if v:shell_error == 0
   " as suggested by Bram M: redraw on no error
   " allows protocol error messages to remain visible
"   redraw!
  endif

  " restore top-of-screen line
  if exists("w:netrw_hline")
"   call Decho("restore topofscreen: exe norm! ".w:netrw_hline."G0z")
   exe "norm! ".w:netrw_hline."G0z\<CR>"
  endif

  " restore position
  if exists("w:netrw_line") && exists("w:netrw_col")
"   call Decho("restore posn: exe norm! ".w:netrw_line."G0".w:netrw_col."|")
   exe "norm! ".w:netrw_line."G0".w:netrw_col."\<bar>"
  endif

  let &ei= eikeep
"  call Dret("netrw#NetrwRestorePosn")
endfun

" ---------------------------------------------------------------------
" netrw#NetrwSavePosn: saves position of cursor on screen {{{2
fun! netrw#NetrwSavePosn()
"  call Dfunc("netrw#NetrwSavePosn()")
  " Save current line and column
  let w:netrw_winnr= winnr()
  let w:netrw_line = line(".")
  let w:netrw_col  = virtcol(".")

  " Save top-of-screen line
  norm! H0
  let w:netrw_hline= line(".")

  " set up string holding position parameters
  let ret          = "let w:netrw_winnr=".w:netrw_winnr."|let w:netrw_line=".w:netrw_line."|let w:netrw_col=".w:netrw_col."|let w:netrw_hline=".w:netrw_hline

  call netrw#NetrwRestorePosn()
"  call Dret("netrw#NetrwSavePosn : winnr=".w:netrw_winnr." line=".w:netrw_line." col=".w:netrw_col." hline=".w:netrw_hline)
  return ret
endfun

" ------------------------------------------------------------------------
"  netrw#RFC2396: converts %xx into characters {{{2
fun! netrw#RFC2396(fname)
"  call Dfunc("netrw#RFC2396(fname<".a:fname.">)")
  let fname = escape(substitute(a:fname,'%\(\x\x\)','\=nr2char("0x".submatch(1))','ge')," \t")
"  call Dret("netrw#RFC2396 ".fname)
  return fname
endfun

" ---------------------------------------------------------------------
"  s:ComposePath: Appends a new part to a path taking different systems into consideration {{{2
fun! s:ComposePath(base,subdir)
"  call Dfunc("s:ComposePath(base<".a:base."> subdir<".a:subdir.">)")

  if(has("amiga"))
"   call Decho("amiga")
   let ec = a:base[strlen(a:base)-1]
   if ec != '/' && ec != ':'
    let ret = a:base . "/" . a:subdir
   else
    let ret = a:base . a:subdir
   endif

  elseif a:subdir =~ '^\a:[/\\][^/\\]' && (has("win32") || has("win95") || has("win64") || has("win16"))
"   call Decho("windows")
   let ret= a:subdir

  elseif a:base =~ '^\a\+://'
"   call Decho("remote linux/macos")
   let urlbase = substitute(a:base,'^\(\a\+://.\{-}/\)\(.*\)$','\1','')
   let curpath = substitute(a:base,'^\(\a\+://.\{-}/\)\(.*\)$','\2','')
   if a:subdir == '../'
    if curpath =~ '[^/]/[^/]\+/$'
     let curpath= substitute(curpath,'[^/]\+/$','','')
    else
     let curpath=""
    endif
    let ret= urlbase.curpath
   else
    let ret= urlbase.curpath.a:subdir
   endif
"   call Decho("urlbase<".urlbase.">")
"   call Decho("curpath<".curpath.">")
"   call Decho("ret<".ret.">")

  else
"   call Decho("local linux/macos")
   let ret = substitute(a:base."/".a:subdir,"//","/","g")
   if a:base =~ '^//'
    " keeping initial '//' for the benefit of network share listing support
    let ret= '/'.ret
   endif
   let ret= simplify(ret)
  endif

"  call Dret("s:ComposePath ".ret)
  return ret
endfun

" ---------------------------------------------------------------------
" s:FileReadable: o/s independent filereadable {{{2
fun! s:FileReadable(fname)
"  call Dfunc("s:FileReadable(fname<".a:fname.">)")

  if g:netrw_cygwin
   let ret= filereadable(substitute(a:fname,'/cygdrive/\(.\)','\1:/',''))
  else
   let ret= filereadable(a:fname)
  endif

"  call Dret("s:FileReadable ".ret)
  return ret
endfun

" ---------------------------------------------------------------------
"  s:GetTempfile: gets a tempname that'll work for various o/s's {{{2
"                 Places correct suffix on end of temporary filename,
"                 using the suffix provided with fname
fun! s:GetTempfile(fname)
"  call Dfunc("s:GetTempfile(fname<".a:fname.">)")

  if !exists("b:netrw_tmpfile")
   " get a brand new temporary filename
   let tmpfile= tempname()
"   call Decho("tmpfile<".tmpfile."> : from tempname()")

   let tmpfile= substitute(tmpfile,'\','/','ge')
"   call Decho("tmpfile<".tmpfile."> : chgd any \\ -> /")

   " sanity check -- does the temporary file's directory exist?
   if !isdirectory(substitute(tmpfile,'[^/]\+$','','e'))
"    call Decho("ro=".&l:ro." ma=".&l:ma." mod=".&l:mod." wrap=".&l:wrap)
    call netrw#ErrorMsg(s:ERROR,"your <".substitute(tmpfile,'[^/]\+$','','e')."> directory is missing!",2)
"    call Dret("s:GetTempfile getcwd<".getcwd().">")
    return ""
   endif

   " let netrw#NetSource() know about the tmpfile
   let s:netrw_tmpfile= tmpfile " used by netrw#NetSource() and netrw#NetrwBrowseX()
"   call Decho("tmpfile<".tmpfile."> s:netrw_tmpfile<".s:netrw_tmpfile.">")

   " o/s dependencies
   if g:netrw_cygwin != 0
    let tmpfile = substitute(tmpfile,'^\(\a\):','/cygdrive/\1','e')
   elseif has("win32") || has("win95") || has("win64") || has("win16")
    if !exists("+shellslash") || !&ssl
     let tmpfile = substitute(tmpfile,'/','\','g')
    endif
   else
    let tmpfile = tmpfile
   endif
   let b:netrw_tmpfile= tmpfile
"   call Decho("o/s dependent fixed tempname<".tmpfile.">")
  else
   " re-use temporary filename
   let tmpfile= b:netrw_tmpfile
"   call Decho("tmpfile<".tmpfile."> re-using")
  endif

  " use fname's suffix for the temporary file
  if a:fname != ""
   if a:fname =~ '\.[^./]\+$'
"    call Decho("using fname<".a:fname.">'s suffix")
    if a:fname =~ '.tar.gz' || a:fname =~ '.tar.bz2'
     let suffix = ".tar".substitute(a:fname,'^.*\(\.[^./]\+\)$','\1','e')
    else
     let suffix = substitute(a:fname,'^.*\(\.[^./]\+\)$','\1','e')
    endif
"    call Decho("suffix<".suffix.">")
    let tmpfile= substitute(tmpfile,'\.tmp$','','e')
"    call Decho("chgd tmpfile<".tmpfile."> (removed any .tmp suffix)")
    let tmpfile .= suffix
"    call Decho("chgd tmpfile<".tmpfile."> (added ".suffix." suffix) netrw_fname<".b:netrw_fname.">")
    let s:netrw_tmpfile= tmpfile " supports netrw#NetSource()
   endif
  endif

"  call Decho("ro=".&l:ro." ma=".&l:ma." mod=".&l:mod." wrap=".&l:wrap)
"  call Dret("s:GetTempfile <".tmpfile.">")
  return tmpfile
endfun

" ---------------------------------------------------------------------
" s:MakeSshCmd: transforms input command using USEPORT HOSTNAME into {{{2
"               a correct command for use with a system() call
fun! s:MakeSshCmd(sshcmd)
"  call Dfunc("s:MakeSshCmd(sshcmd<".a:sshcmd.">) user<".s:user."> machine<".s:machine.">")
  let sshcmd = substitute(a:sshcmd,'\<HOSTNAME\>',s:user.s:machine,'')
  if exists("g:netrw_port") && g:netrw_port != ""
   let sshcmd= substitute(sshcmd,"USEPORT",g:netrw_sshport.' '.g:netrw_port,'')
  elseif exists("s:port") && s:port != ""
   let sshcmd= substitute(sshcmd,"USEPORT",g:netrw_sshport.' '.s:port,'')
  else
   let sshcmd= substitute(sshcmd,"USEPORT ",'','')
  endif
"  call Dret("s:MakeSshCmd <".sshcmd.">")
  return sshcmd
endfun

" ---------------------------------------------------------------------
" s:NetrwBMShow: {{{2
fun! s:NetrwBMShow()
"  call Dfunc("s:NetrwBMShow()")
  redir => bmshowraw
   menu
  redir END
  let bmshowlist = split(bmshowraw,'\n')
  if bmshowlist != []
   let bmshowfuncs= filter(bmshowlist,'v:val =~ "<SNR>\\d\\+_BMShow()"')
   if bmshowfuncs != []
    let bmshowfunc = substitute(bmshowfuncs[0],'^.*:\(call.*BMShow()\).*$','\1','')
    if bmshowfunc =~ '^call.*BMShow()'
     exe "silent! ".bmshowfunc
    endif
   endif
  endif
"  call Dret("s:NetrwBMShow : bmshowfunc<".(exists("bmshowfunc")? bmshowfunc : 'n/a').">")
endfun

" ---------------------------------------------------------------------
" s:NetrwDelete: Deletes a file. {{{2
"           Uses Steve Hall's idea to insure that Windows paths stay
"           acceptable.  No effect on Unix paths.
"  Examples of use:  let result= s:NetrwDelete(path)
fun! s:NetrwDelete(path)
"  call Dfunc("s:NetrwDelete(path<".a:path.">)")

  let path = s:WinPath(a:path)
  if !g:netrw_cygwin && (has("win32") || has("win95") || has("win64") || has("win16"))
   if exists("+shellslash")
    let sskeep= &shellslash
    setlocal noshellslash
    let result      = delete(path)
    let &shellslash = sskeep
   else
"    call Decho("exe let result= ".a:cmd."('".path."')")
    let result= delete(path)
   endif
  else
"   call Decho("let result= delete(".path.")")
   let result= delete(path)
  endif
  if result < 0
   call Netrw#ErrorMsg(s:WARNING,"delete(".path.") failed!",71)
  endif

"  call Dret("s:NetrwDelete ".result)
  return result
endfun

" ---------------------------------------------------------------------
" s:NetrwEnew: opens a new buffer, passes netrw buffer variables through {{{2
fun! s:NetrwEnew(curdir)
"  call Dfunc("s:NetrwEnew(curdir<".a:curdir.">) buf#".bufnr("%")."<".bufname("%").">")

  " grab a function-local-variable copy of buffer variables
  if exists("b:netrw_bannercnt")      |let netrw_bannercnt       = b:netrw_bannercnt      |endif
  if exists("b:netrw_browser_active") |let netrw_browser_active  = b:netrw_browser_active |endif
  if exists("b:netrw_cpf")            |let netrw_cpf             = b:netrw_cpf            |endif
  if exists("b:netrw_curdir")         |let netrw_curdir          = b:netrw_curdir         |endif
  if exists("b:netrw_explore_bufnr")  |let netrw_explore_bufnr   = b:netrw_explore_bufnr  |endif
  if exists("b:netrw_explore_indx")   |let netrw_explore_indx    = b:netrw_explore_indx   |endif
  if exists("b:netrw_explore_line")   |let netrw_explore_line    = b:netrw_explore_line   |endif
  if exists("b:netrw_explore_list")   |let netrw_explore_list    = b:netrw_explore_list   |endif
  if exists("b:netrw_explore_listlen")|let netrw_explore_listlen = b:netrw_explore_listlen|endif
  if exists("b:netrw_explore_mtchcnt")|let netrw_explore_mtchcnt = b:netrw_explore_mtchcnt|endif
  if exists("b:netrw_fname")          |let netrw_fname           = b:netrw_fname          |endif
  if exists("b:netrw_lastfile")       |let netrw_lastfile        = b:netrw_lastfile       |endif
  if exists("b:netrw_liststyle")      |let netrw_liststyle       = b:netrw_liststyle      |endif
  if exists("b:netrw_method")         |let netrw_method          = b:netrw_method         |endif
  if exists("b:netrw_option")         |let netrw_option          = b:netrw_option         |endif
  if exists("b:netrw_prvdir")         |let netrw_prvdir          = b:netrw_prvdir         |endif

  call s:NetrwOptionRestore("w:")
"  call Decho("generate a buffer with keepjumps keepalt enew!")
  keepjumps keepalt enew!
  call s:NetrwOptionSave("w:")

  " copy function-local-variables to buffer variable equivalents
  if exists("netrw_bannercnt")      |let b:netrw_bannercnt       = netrw_bannercnt      |endif
  if exists("netrw_browser_active") |let b:netrw_browser_active  = netrw_browser_active |endif
  if exists("netrw_cpf")            |let b:netrw_cpf             = netrw_cpf            |endif
  if exists("netrw_curdir")         |let b:netrw_curdir          = netrw_curdir         |endif
  if exists("netrw_explore_bufnr")  |let b:netrw_explore_bufnr   = netrw_explore_bufnr  |endif
  if exists("netrw_explore_indx")   |let b:netrw_explore_indx    = netrw_explore_indx   |endif
  if exists("netrw_explore_line")   |let b:netrw_explore_line    = netrw_explore_line   |endif
  if exists("netrw_explore_list")   |let b:netrw_explore_list    = netrw_explore_list   |endif
  if exists("netrw_explore_listlen")|let b:netrw_explore_listlen = netrw_explore_listlen|endif
  if exists("netrw_explore_mtchcnt")|let b:netrw_explore_mtchcnt = netrw_explore_mtchcnt|endif
  if exists("netrw_fname")          |let b:netrw_fname           = netrw_fname          |endif
  if exists("netrw_lastfile")       |let b:netrw_lastfile        = netrw_lastfile       |endif
  if exists("netrw_liststyle")      |let b:netrw_liststyle       = netrw_liststyle      |endif
  if exists("netrw_method")         |let b:netrw_method          = netrw_method         |endif
  if exists("netrw_option")         |let b:netrw_option          = netrw_option         |endif
  if exists("netrw_prvdir")         |let b:netrw_prvdir          = netrw_prvdir         |endif

  let b:netrw_curdir= a:curdir
  if b:netrw_curdir =~ '/$'
   if exists("w:netrw_liststyle") && w:netrw_liststyle == s:TREELIST
    file NetrwTreeListing
    nno <silent> <buffer> [	:silent call <SID>TreeListMove('[')<cr>
    nno <silent> <buffer> ]	:silent call <SID>TreeListMove(']')<cr>
   else
    exe "silent! keepalt file ".fnameescape(b:netrw_curdir)
   endif
  endif

"  call Dret("s:NetrwEnew : buf#".bufnr("%")."<".bufname("%")."> expand(%)<".expand("%")."> expand(#)<".expand("#").">")
endfun

" ------------------------------------------------------------------------
" s:NetrwSaveWordPosn: used to keep cursor on same word after refresh, {{{2
" changed sorting, etc.  Also see s:NetrwRestoreWordPosn().
fun! s:NetrwSaveWordPosn()
"  call Dfunc("NetrwSaveWordPosn()")
  let s:netrw_saveword= '^'.fnameescape(getline('.')).'$'
"  call Dret("NetrwSaveWordPosn : saveword<".s:netrw_saveword.">")
endfun

" ---------------------------------------------------------------------
" s:NetrwRestoreWordPosn: used to keep cursor on same word after refresh, {{{2
"  changed sorting, etc.  Also see s:NetrwSaveWordPosn().
fun! s:NetrwRestoreWordPosn()
"  call Dfunc("NetrwRestoreWordPosn()")
  silent! call search(s:netrw_saveword,'w')
"  call Dret("NetrwRestoreWordPosn")
endfun

" ---------------------------------------------------------------------
" s:RestoreBufVars: {{{2
fun! s:RestoreBufVars()
"  call Dfunc("s:RestoreBufVars()")

  if exists("s:netrw_curdir")        |let b:netrw_curdir         = s:netrw_curdir        |endif
  if exists("s:netrw_lastfile")      |let b:netrw_lastfile       = s:netrw_lastfile      |endif
  if exists("s:netrw_method")        |let b:netrw_method         = s:netrw_method        |endif
  if exists("s:netrw_fname")         |let b:netrw_fname          = s:netrw_fname         |endif
  if exists("s:netrw_machine")       |let b:netrw_machine        = s:netrw_machine       |endif
  if exists("s:netrw_browser_active")|let b:netrw_browser_active = s:netrw_browser_active|endif

"  call Dret("s:RestoreBufVars")
endfun

" ---------------------------------------------------------------------
" s:RemotePathAnalysis: {{{2
fun! s:RemotePathAnalysis(dirname)
"  call Dfunc("s:RemotePathAnalysis()")

  let dirpat  = '^\(\w\{-}\)://\(\w\+@\)\=\([^/:#]\+\)\%([:#]\(\d\+\)\)\=/\(.*\)$'
  let s:method  = substitute(a:dirname,dirpat,'\1','')
  let s:user    = substitute(a:dirname,dirpat,'\2','')
  let s:machine = substitute(a:dirname,dirpat,'\3','')
  let s:port    = substitute(a:dirname,dirpat,'\4','')
  let s:path    = substitute(a:dirname,dirpat,'\5','')
  let s:fname   = substitute(a:dirname,'^.*/\ze.','','')

"  call Decho("set up s:method <".s:method .">")
"  call Decho("set up s:user   <".s:user   .">")
"  call Decho("set up s:machine<".s:machine.">")
"  call Decho("set up s:port   <".s:port.">")
"  call Decho("set up s:path   <".s:path   .">")
"  call Decho("set up s:fname  <".s:fname  .">")

"  call Dret("s:RemotePathAnalysis")
endfun

" ---------------------------------------------------------------------
" s:RemoteSystem: runs a command on a remote host using ssh {{{2
"                 Returns status
" Runs system() on
"    [cd REMOTEDIRPATH;] a:cmd
" Note that it doesn't do shellescape(a:cmd)!
fun! s:RemoteSystem(cmd)
"  call Dfunc("s:RemoteSystem(cmd<".a:cmd.">)")
  if !executable(g:netrw_ssh_cmd)
   call netrw#ErrorMsg(s:ERROR,"g:netrw_ssh_cmd<".g:netrw_ssh_cmd."> is not executable!",52)
  elseif !exists("b:netrw_curdir")
   call netrw#ErrorMsg(s:ERROR,"for some reason b:netrw_curdir doesn't exist!",53)
  else
   let cmd      = s:MakeSshCmd(g:netrw_ssh_cmd." USEPORT HOSTNAME")
   let remotedir= substitute(b:netrw_curdir,'^.*//[^/]\+/\(.*\)$','\1','')
   if remotedir != ""
    let cmd= cmd.' cd '.shellescape(remotedir).";"
   else
    let cmd= cmd.' '
   endif
   let cmd= cmd.a:cmd
"   call Decho("call system(".cmd.")")
   let ret= system(cmd)
  endif
"  call Dret("s:RemoteSystem ".ret)
  return ret
endfun

" ---------------------------------------------------------------------
" s:RestoreWinVars: (used by Explore() and NetrwSplit()) {{{2
fun! s:RestoreWinVars()
"  call Dfunc("s:RestoreWinVars()")
  if exists("s:bannercnt")      |let w:netrw_bannercnt       = s:bannercnt      |unlet s:bannercnt      |endif
  if exists("s:col")            |let w:netrw_col             = s:col            |unlet s:col            |endif
  if exists("s:curdir")         |let w:netrw_curdir          = s:curdir         |unlet s:curdir         |endif
  if exists("s:explore_bufnr")  |let w:netrw_explore_bufnr   = s:explore_bufnr  |unlet s:explore_bufnr  |endif
  if exists("s:explore_indx")   |let w:netrw_explore_indx    = s:explore_indx   |unlet s:explore_indx   |endif
  if exists("s:explore_line")   |let w:netrw_explore_line    = s:explore_line   |unlet s:explore_line   |endif
  if exists("s:explore_listlen")|let w:netrw_explore_listlen = s:explore_listlen|unlet s:explore_listlen|endif
  if exists("s:explore_list")   |let w:netrw_explore_list    = s:explore_list   |unlet s:explore_list   |endif
  if exists("s:explore_mtchcnt")|let w:netrw_explore_mtchcnt = s:explore_mtchcnt|unlet s:explore_mtchcnt|endif
  if exists("s:fpl")            |let w:netrw_fpl             = s:fpl            |unlet s:fpl            |endif
  if exists("s:hline")          |let w:netrw_hline           = s:hline          |unlet s:hline          |endif
  if exists("s:line")           |let w:netrw_line            = s:line           |unlet s:line           |endif
  if exists("s:liststyle")      |let w:netrw_liststyle       = s:liststyle      |unlet s:liststyle      |endif
  if exists("s:method")         |let w:netrw_method          = s:method         |unlet s:method         |endif
  if exists("s:prvdir")         |let w:netrw_prvdir          = s:prvdir         |unlet s:prvdir         |endif
  if exists("s:treedict")       |let w:netrw_treedict        = s:treedict       |unlet s:treedict       |endif
  if exists("s:treetop")        |let w:netrw_treetop         = s:treetop        |unlet s:treetop        |endif
  if exists("s:winnr")          |let w:netrw_winnr           = s:winnr          |unlet s:winnr          |endif
"  call Dret("s:RestoreWinVars")
endfun

" ---------------------------------------------------------------------
" s:Rexplore: implements returning from a buffer to a netrw directory {{{2
"
"             s:SetRexDir() sets up <2-leftmouse> maps (if g:netrw_retmap
"             is true) and a command, :Rexplore, which call this function.
"
"             s:nbcd_curpos_{bufnr('%')} is set up by s:NetrwBrowseChgDir()
fun! s:NetrwRexplore(islocal,dirname)
"  call Dfunc("s:NetrwRexplore(islocal=".a:islocal." dirname<".a:dirname.">)")
  if a:islocal
   call netrw#LocalBrowseCheck(a:dirname)
  else
   call s:NetrwBrowse(0,a:dirname)
  endif
  if exists("s:nbcd_curpos_{bufnr('%')}")
   call netrw#NetrwRestorePosn(s:nbcd_curpos_{bufnr('%')})
   unlet s:nbcd_curpos_{bufnr('%')}
  endif
"  call Dret("s:NetrwRexplore")
endfun

" ---------------------------------------------------------------------
" s:SaveBufVars: {{{2
fun! s:SaveBufVars()
"  call Dfunc("s:SaveBufVars()")

  if exists("b:netrw_curdir")        |let s:netrw_curdir         = b:netrw_curdir        |endif
  if exists("b:netrw_lastfile")      |let s:netrw_lastfile       = b:netrw_lastfile      |endif
  if exists("b:netrw_method")        |let s:netrw_method         = b:netrw_method        |endif
  if exists("b:netrw_fname")         |let s:netrw_fname          = b:netrw_fname         |endif
  if exists("b:netrw_machine")       |let s:netrw_machine        = b:netrw_machine       |endif
  if exists("b:netrw_browser_active")|let s:netrw_browser_active = b:netrw_browser_active|endif

"  call Dret("s:SaveBufVars")
endfun

" ---------------------------------------------------------------------
" s:SaveWinVars: (used by Explore() and NetrwSplit()) {{{2
fun! s:SaveWinVars()
"  call Dfunc("s:SaveWinVars()")
  if exists("w:netrw_bannercnt")      |let s:bannercnt       = w:netrw_bannercnt      |endif
  if exists("w:netrw_col")            |let s:col             = w:netrw_col            |endif
  if exists("w:netrw_curdir")         |let s:curdir          = w:netrw_curdir         |endif
  if exists("w:netrw_explore_bufnr")  |let s:explore_bufnr   = w:netrw_explore_bufnr  |endif
  if exists("w:netrw_explore_indx")   |let s:explore_indx    = w:netrw_explore_indx   |endif
  if exists("w:netrw_explore_line")   |let s:explore_line    = w:netrw_explore_line   |endif
  if exists("w:netrw_explore_listlen")|let s:explore_listlen = w:netrw_explore_listlen|endif
  if exists("w:netrw_explore_list")   |let s:explore_list    = w:netrw_explore_list   |endif
  if exists("w:netrw_explore_mtchcnt")|let s:explore_mtchcnt = w:netrw_explore_mtchcnt|endif
  if exists("w:netrw_fpl")            |let s:fpl             = w:netrw_fpl            |endif
  if exists("w:netrw_hline")          |let s:hline           = w:netrw_hline          |endif
  if exists("w:netrw_line")           |let s:line            = w:netrw_line           |endif
  if exists("w:netrw_liststyle")      |let s:liststyle       = w:netrw_liststyle      |endif
  if exists("w:netrw_method")         |let s:method          = w:netrw_method         |endif
  if exists("w:netrw_prvdir")         |let s:prvdir          = w:netrw_prvdir         |endif
  if exists("w:netrw_treedict")       |let s:treedict        = w:netrw_treedict       |endif
  if exists("w:netrw_treetop")        |let s:treetop         = w:netrw_treetop        |endif
  if exists("w:netrw_winnr")          |let s:winnr           = w:netrw_winnr          |endif
"  call Dret("s:SaveWinVars")
endfun

" ---------------------------------------------------------------------
" s:SetBufWinVars: (used by NetrwBrowse() and LocalBrowseCheck()) {{{2
"   To allow separate windows to have their own activities, such as
"   Explore **/pattern, several variables have been made window-oriented.
"   However, when the user splits a browser window (ex: ctrl-w s), these
"   variables are not inherited by the new window.  SetBufWinVars() and
"   UseBufWinVars() get around that.
fun! s:SetBufWinVars()
"  call Dfunc("s:SetBufWinVars()")
  if exists("w:netrw_liststyle")      |let b:netrw_liststyle      = w:netrw_liststyle      |endif
  if exists("w:netrw_bannercnt")      |let b:netrw_bannercnt      = w:netrw_bannercnt      |endif
  if exists("w:netrw_method")         |let b:netrw_method         = w:netrw_method         |endif
  if exists("w:netrw_prvdir")         |let b:netrw_prvdir         = w:netrw_prvdir         |endif
  if exists("w:netrw_explore_indx")   |let b:netrw_explore_indx   = w:netrw_explore_indx   |endif
  if exists("w:netrw_explore_listlen")|let b:netrw_explore_listlen= w:netrw_explore_listlen|endif
  if exists("w:netrw_explore_mtchcnt")|let b:netrw_explore_mtchcnt= w:netrw_explore_mtchcnt|endif
  if exists("w:netrw_explore_bufnr")  |let b:netrw_explore_bufnr  = w:netrw_explore_bufnr  |endif
  if exists("w:netrw_explore_line")   |let b:netrw_explore_line   = w:netrw_explore_line   |endif
  if exists("w:netrw_explore_list")   |let b:netrw_explore_list   = w:netrw_explore_list   |endif
"  call Dret("s:SetBufWinVars")
endfun

" ---------------------------------------------------------------------
" s:SetRexDir: set directory for :Rexplore {{{2
fun! s:SetRexDir(islocal,dirname)
"  call Dfunc("s:SetRexDir(islocal=".a:islocal." dirname<".a:dirname.">)")
  " set up Rex and leftmouse-double-click
  if a:islocal
   exe 'com! Rexplore call s:NetrwRexplore(1,"'.escape(a:dirname,'"\').'")'
   if g:netrw_retmap
    if !hasmapto("<Plug>NetrwReturn") && maparg("<2-leftmouse>","n") == ""
     nmap <unique> <silent> <2-leftmouse>	<Plug>NetrwReturn
    endif
    let dir = escape(a:dirname, s:netrw_map_escape)
    exe 'nnoremap <silent> <Plug>NetrwReturn :call <SID>NetrwRexplore(1,"'.dir.'")<cr>'
   endif
  else
   exe 'com! Rexplore call s:NetrwRexplore(0,"'.escape(a:dirname,'"\').'")'
   if g:netrw_retmap
    if !hasmapto("<Plug>NetrwReturn") && maparg("<2-leftmouse>","n") == ""
     nmap <unique> <silent> <2-leftmouse>	<Plug>NetrwReturn
    endif
    let dir = escape(a:dirname, s:netrw_map_escape)
    exe 'nnoremap <silent> <Plug>NetrwReturn :call <SID>NetrwRexplore(0,"'.dir.'")<cr>'
   endif
  endif
"  call Dret("s:SetRexDir")
endfun

" ---------------------------------------------------------------------
" s:Strlen: this function returns the length of a string, even if its {{{2
"           using two-byte etc characters.
"           Currently, its only used if g:Align_xstrlen is set to a
"           nonzero value.  Solution from Nicolai Weibull, vim docs
"           (:help strlen()), Tony Mechelynck, and my own invention.
fun! s:Strlen(x)
"  call Dfunc("s:Strlen(x<".a:x.">")
  if g:netrw_xstrlen == 1
   " number of codepoints (Latin a + combining circumflex is two codepoints)
   " (comment from TM, solution from NW)
   let ret= strlen(substitute(a:x,'.','c','g'))

  elseif g:netrw_xstrlen == 2
   " number of spacing codepoints (Latin a + combining circumflex is one spacing 
   " codepoint; a hard tab is one; wide and narrow CJK are one each; etc.)
   " (comment from TM, solution from TM)
   let ret=strlen(substitute(a:x, '.\Z', 'x', 'g')) 

  elseif g:netrw_xstrlen == 3
   " virtual length (counting, for instance, tabs as anything between 1 and 
   " 'tabstop', wide CJK as 2 rather than 1, Arabic alif as zero when immediately 
   " preceded by lam, one otherwise, etc.)
   " (comment from TM, solution from me)
   let modkeep= &mod
   exe "norm! o\<esc>"
   call setline(line("."),a:x)
   let ret= virtcol("$") - 1
   d
   let &mod= modkeep

  else
   " at least give a decent default
   ret= strlen(a:x)
  endif
"  call Dret("s:Strlen ".ret)
  return ret
endfun

" ---------------------------------------------------------------------
" s:TreeListMove: {{{2
fun! s:TreeListMove(dir)
"  call Dfunc("s:TreeListMove(dir<".a:dir.">)")
  let curline  = getline('.')
  let prvline  = (line(".") > 1)?         getline(line(".")-1) : ''
  let nxtline  = (line(".") < line("$"))? getline(line(".")+1) : ''
  let curindent= substitute(curline,'^\([| ]*\).\{-}$','\1','')
  let indentm1 = substitute(curindent,'^| ','','')
"  call Decho("prvline  <".prvline."> #".line(".")-1)
"  call Decho("curline  <".curline."> #".line("."))
"  call Decho("nxtline  <".nxtline."> #".line(".")+1)
"  call Decho("curindent<".curindent.">")
"  call Decho("indentm1 <".indentm1.">")

  if curline !~ '/$'
"   call Decho('regfile')
   if     a:dir == '[' && prvline != ''
    norm! 0
    let nl = search('^'.indentm1.'[^|]','bWe')    " search backwards from regular file
"    call Decho("regfile srch back: ".nl)
   elseif a:dir == ']' && nxtline != ''
    norm! $
    let nl = search('^'.indentm1.'[^|]','We')     " search forwards from regular file
"    call Decho("regfile srch fwd: ".nl)
   endif

  elseif a:dir == '[' && prvline != ''
   norm! 0
   let curline= line(".")
   let nl     = search('^'.curindent.'[^|]','bWe') " search backwards From directory, same indentation
"   call Decho("dir srch back ind: ".nl)
   if nl != 0
    if line(".") == curline-1
     let nl= search('^'.indentm1.'[^|]','bWe')     " search backwards from directory, indentation - 1
"     call Decho("dir srch back ind-1: ".nl)
    endif
   endif

  elseif a:dir == ']' && nxtline != ''
   norm! $
   let curline = line(".")
   let nl      = search('^'.curindent.'[^|]','We') " search forwards from directory, same indentation
"   call Decho("dir srch fwd ind: ".nl)
   if nl != 0
    if line(".") == curline+1
     let nl= search('^'.indentm1.'[^|]','We')         " search forwards from directory, indentation - 1
"     call Decho("dir srch fwd ind-1: ".nl)
    endif
   endif

  endif

"  call Dret("s:TreeListMove")
endfun

" ---------------------------------------------------------------------
" s:UpdateBuffersMenu: does emenu Buffers.Refresh (but due to locale, the menu item may not be called that) {{{2
"                      The Buffers.Refresh menu calls s:BMShow(); unfortunately, that means that that function
"                      can't be called except via emenu.  But due to locale, that menu line may not be called
"                      Buffers.Refresh; hence, s:NetrwBMShow() utilizes a "cheat" to call that function anyway.
fun! s:UpdateBuffersMenu()
"  call Dfunc("s:UpdateBuffersMenu()")
  if has("gui") && has("menu") && has("gui_running") && &go =~ 'm'
   try
    silent emenu Buffers.Refresh\ menu
   catch /^Vim\%((\a\+)\)\=:E/
    let v:errmsg= ""
    silent call s:NetrwBMShow()
   endtry
  endif
"  call Dret("s:UpdateBuffersMenu")
endfun

" ---------------------------------------------------------------------
" s:UseBufWinVars: (used by NetrwBrowse() and LocalBrowseCheck() {{{2
"              Matching function to BufferWinVars()
fun! s:UseBufWinVars()
"  call Dfunc("s:UseBufWinVars()")
  if exists("b:netrw_liststyle")       && !exists("w:netrw_liststyle")      |let w:netrw_liststyle       = b:netrw_liststyle      |endif
  if exists("b:netrw_bannercnt")       && !exists("w:netrw_bannercnt")      |let w:netrw_bannercnt       = b:netrw_bannercnt      |endif
  if exists("b:netrw_method")          && !exists("w:netrw_method")         |let w:netrw_method          = b:netrw_method         |endif
  if exists("b:netrw_prvdir")          && !exists("w:netrw_prvdir")         |let w:netrw_prvdir          = b:netrw_prvdir         |endif
  if exists("b:netrw_explore_indx")    && !exists("w:netrw_explore_indx")   |let w:netrw_explore_indx    = b:netrw_explore_indx   |endif
  if exists("b:netrw_explore_listlen") && !exists("w:netrw_explore_listlen")|let w:netrw_explore_listlen = b:netrw_explore_listlen|endif
  if exists("b:netrw_explore_mtchcnt") && !exists("w:netrw_explore_mtchcnt")|let w:netrw_explore_mtchcnt = b:netrw_explore_mtchcnt|endif
  if exists("b:netrw_explore_bufnr")   && !exists("w:netrw_explore_bufnr")  |let w:netrw_explore_bufnr   = b:netrw_explore_bufnr  |endif
  if exists("b:netrw_explore_line")    && !exists("w:netrw_explore_line")   |let w:netrw_explore_line    = b:netrw_explore_line   |endif
  if exists("b:netrw_explore_list")    && !exists("w:netrw_explore_list")   |let w:netrw_explore_list    = b:netrw_explore_list   |endif
"  call Dret("s:UseBufWinVars")
endfun

" ---------------------------------------------------------------------
" s:WinPath: {{{2
fun! s:WinPath(path)
"  call Dfunc("s:WinPath(path<".a:path.">)")
  if !g:netrw_cygwin && (has("win32") || has("win95") || has("win64") || has("win16"))
   " remove trailing slash (Win95)
   let path = substitute(a:path, '\(\\\|/\)$', '', 'g')
   " remove escaped spaces
   let path = substitute(path, '\ ', ' ', 'g')
   " convert slashes to backslashes
   let path = substitute(path, '/', '\', 'g')
  else
   let path= a:path
  endif
"  call Dret("s:WinPath <".path.">")
  return path
endfun

" ---------------------------------------------------------------------
" Settings Restoration: {{{2
let &cpo= s:keepcpo
unlet s:keepcpo

" ------------------------------------------------------------------------
" Modelines: {{{1
" vim:ts=8 fdm=marker
autoload/netrwFileHandlers.vim	[[[1
361
" netrwFileHandlers: contains various extension-based file handlers for
"                    netrw's browsers' x command ("eXecute launcher")
" Author:	Charles E. Campbell, Jr.
" Date:		Sep 30, 2008
" Version:	10
" Copyright:    Copyright (C) 1999-2008 Charles E. Campbell, Jr. {{{1
"               Permission is hereby granted to use and distribute this code,
"               with or without modifications, provided that this copyright
"               notice is copied with it. Like anything else that's free,
"               netrwFileHandlers.vim is provided *as is* and comes with no
"               warranty of any kind, either expressed or implied. In no
"               event will the copyright holder be liable for any damages
"               resulting from the use of this software.
"
" Rom 6:23 (WEB) For the wages of sin is death, but the free gift of God {{{1
"                is eternal life in Christ Jesus our Lord.

" ---------------------------------------------------------------------
" Load Once: {{{1
if exists("g:loaded_netrwFileHandlers") || &cp
 finish
endif
let g:loaded_netrwFileHandlers= "v10"
if v:version < 702
 echohl WarningMsg
 echo "***warning*** this version of netrwFileHandlers needs vim 7.2"
 echohl Normal
 finish
endif
let s:keepcpo= &cpo
set cpo&vim

" ---------------------------------------------------------------------
" netrwFileHandlers#Invoke: {{{1
fun! netrwFileHandlers#Invoke(exten,fname)
"  call Dfunc("netrwFileHandlers#Invoke(exten<".a:exten."> fname<".a:fname.">)")
  let fname= a:fname
  " list of supported special characters.  Consider rcs,v --- that can be
  " supported with a NFH_rcsCOMMAv() handler
  if a:fname =~ '[@:,$!=\-+%?;~]'
   let specials= {
\   '@' : 'AT',
\   ':' : 'COLON',
\   ',' : 'COMMA',
\   '$' : 'DOLLAR',
\   '!' : 'EXCLAMATION',
\   '=' : 'EQUAL',
\   '-' : 'MINUS',
\   '+' : 'PLUS',
\   '%' : 'PERCENT',
\   '?' : 'QUESTION',
\   ';' : 'SEMICOLON',
\   '~' : 'TILDE'}
   let fname= substitute(a:fname,'[@:,$!=\-+%?;~]','\=specials[submatch(0)]','ge')
"   call Decho('fname<'.fname.'> done with dictionary')
  endif

  if a:exten != "" && exists("*NFH_".a:exten)
   " support user NFH_*() functions
"   call Decho("let ret= netrwFileHandlers#NFH_".a:exten.'("'.fname.'")')
   exe "let ret= NFH_".a:exten.'("'.fname.'")'
  elseif a:exten != "" && exists("*s:NFH_".a:exten)
   " use builtin-NFH_*() functions
"   call Decho("let ret= netrwFileHandlers#NFH_".a:exten.'("'.fname.'")')
   exe "let ret= s:NFH_".a:exten.'("'.fname.'")'
  endif
  
"  call Dret("netrwFileHandlers#Invoke 0 : ret=".ret)
  return 0
endfun

" ---------------------------------------------------------------------
" s:NFH_html: handles html when the user hits "x" when the {{{1
"                        cursor is atop a *.html file
fun! s:NFH_html(pagefile)
"  call Dfunc("s:NFH_html(".a:pagefile.")")

  let page= substitute(a:pagefile,'^','file://','')

  if executable("mozilla")
"   call Decho("executing !mozilla ".page)
   exe "!mozilla ".shellescape(page,1)
  elseif executable("netscape")
"   call Decho("executing !netscape ".page)
   exe "!netscape ".shellescape(page,1)
  else
"   call Dret("s:NFH_html 0")
   return 0
  endif

"  call Dret("s:NFH_html 1")
  return 1
endfun

" ---------------------------------------------------------------------
" s:NFH_htm: handles html when the user hits "x" when the {{{1
"                        cursor is atop a *.htm file
fun! s:NFH_htm(pagefile)
"  call Dfunc("s:NFH_htm(".a:pagefile.")")

  let page= substitute(a:pagefile,'^','file://','')

  if executable("mozilla")
"   call Decho("executing !mozilla ".page)
   exe "!mozilla ".shellescape(page,1)
  elseif executable("netscape")
"   call Decho("executing !netscape ".page)
   exe "!netscape ".shellescape(page,1)
  else
"   call Dret("s:NFH_htm 0")
   return 0
  endif

"  call Dret("s:NFH_htm 1")
  return 1
endfun

" ---------------------------------------------------------------------
" s:NFH_jpg: {{{1
fun! s:NFH_jpg(jpgfile)
"  call Dfunc("s:NFH_jpg(jpgfile<".a:jpgfile.">)")

  if executable("gimp")
   exe "silent! !gimp -s ".shellescape(a:jpgfile,1)
  elseif executable(expand("$SystemRoot")."/SYSTEM32/MSPAINT.EXE")
"   call Decho("silent! !".expand("$SystemRoot")."/SYSTEM32/MSPAINT ".escape(a:jpgfile," []|'"))
   exe "!".expand("$SystemRoot")."/SYSTEM32/MSPAINT ".shellescape(a:jpgfile,1)
  else
"   call Dret("s:NFH_jpg 0")
   return 0
  endif

"  call Dret("s:NFH_jpg 1")
  return 1
endfun

" ---------------------------------------------------------------------
" s:NFH_gif: {{{1
fun! s:NFH_gif(giffile)
"  call Dfunc("s:NFH_gif(giffile<".a:giffile.">)")

  if executable("gimp")
   exe "silent! !gimp -s ".shellescape(a:giffile,1)
  elseif executable(expand("$SystemRoot")."/SYSTEM32/MSPAINT.EXE")
   exe "silent! !".expand("$SystemRoot")."/SYSTEM32/MSPAINT ".shellescape(a:giffile,1)
  else
"   call Dret("s:NFH_gif 0")
   return 0
  endif

"  call Dret("s:NFH_gif 1")
  return 1
endfun

" ---------------------------------------------------------------------
" s:NFH_png: {{{1
fun! s:NFH_png(pngfile)
"  call Dfunc("s:NFH_png(pngfile<".a:pngfile.">)")

  if executable("gimp")
   exe "silent! !gimp -s ".shellescape(a:pngfile,1)
  elseif executable(expand("$SystemRoot")."/SYSTEM32/MSPAINT.EXE")
   exe "silent! !".expand("$SystemRoot")."/SYSTEM32/MSPAINT ".shellescape(a:pngfile,1)
  else
"   call Dret("s:NFH_png 0")
   return 0
  endif

"  call Dret("s:NFH_png 1")
  return 1
endfun

" ---------------------------------------------------------------------
" s:NFH_pnm: {{{1
fun! s:NFH_pnm(pnmfile)
"  call Dfunc("s:NFH_pnm(pnmfile<".a:pnmfile.">)")

  if executable("gimp")
   exe "silent! !gimp -s ".shellescape(a:pnmfile,1)
  elseif executable(expand("$SystemRoot")."/SYSTEM32/MSPAINT.EXE")
   exe "silent! !".expand("$SystemRoot")."/SYSTEM32/MSPAINT ".shellescape(a:pnmfile,1)
  else
"   call Dret("s:NFH_pnm 0")
   return 0
  endif

"  call Dret("s:NFH_pnm 1")
  return 1
endfun

" ---------------------------------------------------------------------
" s:NFH_bmp: visualize bmp files {{{1
fun! s:NFH_bmp(bmpfile)
"  call Dfunc("s:NFH_bmp(bmpfile<".a:bmpfile.">)")

  if executable("gimp")
   exe "silent! !gimp -s ".a:bmpfile
  elseif executable(expand("$SystemRoot")."/SYSTEM32/MSPAINT.EXE")
   exe "silent! !".expand("$SystemRoot")."/SYSTEM32/MSPAINT ".shellescape(a:bmpfile,1)
  else
"   call Dret("s:NFH_bmp 0")
   return 0
  endif

"  call Dret("s:NFH_bmp 1")
  return 1
endfun

" ---------------------------------------------------------------------
" s:NFH_pdf: visualize pdf files {{{1
fun! s:NFH_pdf(pdf)
"  call Dfunc("s:NFH_pdf(pdf<".a:pdf.">)")
  if executable("gs")
   exe 'silent! !gs '.shellescape(a:pdf,1)
  elseif executable("pdftotext")
   exe 'silent! pdftotext -nopgbrk '.shellescape(a:pdf,1)
  else
"  call Dret("s:NFH_pdf 0")
   return 0
  endif

"  call Dret("s:NFH_pdf 1")
  return 1
endfun

" ---------------------------------------------------------------------
" s:NFH_doc: visualize doc files {{{1
fun! s:NFH_doc(doc)
"  call Dfunc("s:NFH_doc(doc<".a:doc.">)")

  if executable("oowriter")
   exe 'silent! !oowriter '.shellescape(a:doc,1)
   redraw!
  else
"  call Dret("s:NFH_doc 0")
   return 0
  endif

"  call Dret("s:NFH_doc 1")
  return 1
endfun

" ---------------------------------------------------------------------
" s:NFH_sxw: visualize sxw files {{{1
fun! s:NFH_sxw(sxw)
"  call Dfunc("s:NFH_sxw(sxw<".a:sxw.">)")

  if executable("oowriter")
   exe 'silent! !oowriter '.shellescape(a:sxw,1)
   redraw!
  else
"   call Dret("s:NFH_sxw 0")
   return 0
  endif

"  call Dret("s:NFH_sxw 1")
  return 1
endfun

" ---------------------------------------------------------------------
" s:NFH_xls: visualize xls files {{{1
fun! s:NFH_xls(xls)
"  call Dfunc("s:NFH_xls(xls<".a:xls.">)")

  if executable("oocalc")
   exe 'silent! !oocalc '.shellescape(a:xls,1)
   redraw!
  else
"  call Dret("s:NFH_xls 0")
   return 0
  endif

"  call Dret("s:NFH_xls 1")
  return 1
endfun

" ---------------------------------------------------------------------
" s:NFH_ps: handles PostScript files {{{1
fun! s:NFH_ps(ps)
"  call Dfunc("s:NFH_ps(ps<".a:ps.">)")
  if executable("gs")
"   call Decho("exe silent! !gs ".a:ps)
   exe "silent! !gs ".shellescape(a:ps,1)
   redraw!
  elseif executable("ghostscript")
"   call Decho("exe silent! !ghostscript ".a:ps)
   exe "silent! !ghostscript ".shellescape(a:ps,1)
   redraw!
  elseif executable("gswin32")
"   call Decho("exe silent! !gswin32 ".shellescape(a:ps,1))
   exe "silent! !gswin32 ".shellescape(a:ps,1)
   redraw!
  else
"   call Dret("s:NFH_ps 0")
   return 0
  endif

"  call Dret("s:NFH_ps 1")
  return 1
endfun

" ---------------------------------------------------------------------
" s:NFH_eps: handles encapsulated PostScript files {{{1
fun! s:NFH_eps(eps)
"  call Dfunc("s:NFH_eps()")
  if executable("gs")
   exe "silent! !gs ".shellescape(a:eps,1)
   redraw!
  elseif executable("ghostscript")
   exe "silent! !ghostscript ".shellescape(a:eps,1)
   redraw!
  elseif executable("ghostscript")
   exe "silent! !ghostscript ".shellescape(a:eps,1)
   redraw!
  elseif executable("gswin32")
   exe "silent! !gswin32 ".shellescape(a:eps,1)
   redraw!
  else
"   call Dret("s:NFH_eps 0")
   return 0
  endif
"  call Dret("s:NFH_eps 0")
  return 1
endfun

" ---------------------------------------------------------------------
" s:NFH_fig: handles xfig files {{{1
fun! s:NFH_fig(fig)
"  call Dfunc("s:NFH_fig()")
  if executable("xfig")
   exe "silent! !xfig ".a:fig
   redraw!
  else
"   call Dret("s:NFH_fig 0")
   return 0
  endif

"  call Dret("s:NFH_fig 1")
  return 1
endfun

" ---------------------------------------------------------------------
" s:NFH_obj: handles tgif's obj files {{{1
fun! s:NFH_obj(obj)
"  call Dfunc("s:NFH_obj()")
  if has("unix") && executable("tgif")
   exe "silent! !tgif ".a:obj
   redraw!
  else
"   call Dret("s:NFH_obj 0")
   return 0
  endif

"  call Dret("s:NFH_obj 1")
  return 1
endfun

let &cpo= s:keepcpo
" ---------------------------------------------------------------------
"  Modelines: {{{1
"  vim: fdm=marker
autoload/netrwSettings.vim	[[[1
207
" netrwSettings.vim: makes netrw settings simpler
" Date:		Sep 03, 2008
" Maintainer:	Charles E Campbell, Jr <drchipNOSPAM at campbellfamily dot biz>
" Version:	13
" Copyright:    Copyright (C) 1999-2007 Charles E. Campbell, Jr. {{{1
"               Permission is hereby granted to use and distribute this code,
"               with or without modifications, provided that this copyright
"               notice is copied with it. Like anything else that's free,
"               netrwSettings.vim is provided *as is* and comes with no
"               warranty of any kind, either expressed or implied. By using
"               this plugin, you agree that in no event will the copyright
"               holder be liable for any damages resulting from the use
"               of this software.
"
" Mat 4:23 (WEB) Jesus went about in all Galilee, teaching in their {{{1
"                synagogues, preaching the gospel of the kingdom, and healing
"                every disease and every sickness among the people.
" Load Once: {{{1
if exists("g:loaded_netrwSettings") || &cp
  finish
endif
let g:loaded_netrwSettings = "v13"
if v:version < 700
 echohl WarningMsg
 echo "***warning*** this version of netrwSettings needs vim 7.0"
 echohl Normal
 finish
endif

" ---------------------------------------------------------------------
" NetrwSettings: {{{1
fun! netrwSettings#NetrwSettings()
  " this call is here largely just to insure that netrw has been loaded
  call netrw#NetrwSavePosn()
  if !exists("g:loaded_netrw")
   echohl WarningMsg | echomsg "***sorry*** netrw needs to be loaded prior to using NetrwSettings" | echohl None
   return
  endif

  above wincmd s
  enew
  setlocal noswapfile bh=wipe
  set ft=vim
  file Netrw\ Settings

  " these variables have the following default effects when they don't
  " exist (ie. have not been set by the user in his/her .vimrc)
  if !exists("g:netrw_liststyle")
   let g:netrw_liststyle= 0
   let g:netrw_list_cmd= "ssh HOSTNAME ls -FLa"
  endif
  if !exists("g:netrw_silent")
   let g:netrw_silent= 0
  endif
  if !exists("g:netrw_use_nt_rcp")
   let g:netrw_use_nt_rcp= 0
  endif
  if !exists("g:netrw_ftp")
   let g:netrw_ftp= 0
  endif
  if !exists("g:netrw_ignorenetrc")
   let g:netrw_ignorenetrc= 0
  endif

  put ='+ ---------------------------------------------'
  put ='+  NetrwSettings:  by Charles E. Campbell, Jr.'
  put ='+ Press <F1> with cursor atop any line for help'
  put ='+ ---------------------------------------------'
  let s:netrw_settings_stop= line(".")

  put =''
  put ='+ Netrw Protocol Commands'
  put = 'let g:netrw_dav_cmd           = '.g:netrw_dav_cmd
  put = 'let g:netrw_fetch_cmd         = '.g:netrw_fetch_cmd
  put = 'let g:netrw_ftp_cmd           = '.g:netrw_ftp_cmd
  put = 'let g:netrw_http_cmd          = '.g:netrw_http_cmd
  put = 'let g:netrw_rcp_cmd           = '.g:netrw_rcp_cmd
  put = 'let g:netrw_rsync_cmd         = '.g:netrw_rsync_cmd
  put = 'let g:netrw_scp_cmd           = '.g:netrw_scp_cmd
  put = 'let g:netrw_sftp_cmd          = '.g:netrw_sftp_cmd
  put = 'let g:netrw_ssh_cmd           = '.g:netrw_ssh_cmd
  let s:netrw_protocol_stop= line(".")
  put = ''

  put ='+Netrw Transfer Control'
  put = 'let g:netrw_cygwin            = '.g:netrw_cygwin
  put = 'let g:netrw_ftp               = '.g:netrw_ftp
  put = 'let g:netrw_ftpmode           = '.g:netrw_ftpmode
  put = 'let g:netrw_ignorenetrc       = '.g:netrw_ignorenetrc
  put = 'let g:netrw_sshport           = '.g:netrw_sshport
  put = 'let g:netrw_use_nt_rcp        = '.g:netrw_use_nt_rcp
  put = 'let g:netrw_win95ftp          = '.g:netrw_win95ftp
  let s:netrw_xfer_stop= line(".")
  put =''
  put ='+ Netrw Messages'
  put ='let g:netrw_use_errorwindow    = '.g:netrw_use_errorwindow

  put = ''
  put ='+ Netrw Browser Control'
  put = 'let g:netrw_alto              = '.g:netrw_alto
  put = 'let g:netrw_altv              = '.g:netrw_altv
  put = 'let g:netrw_browse_split      = '.g:netrw_browse_split
  if exists("g:netrw_browsex_viewer")
   put = 'let g:netrw_browsex_viewer    = '.g:netrw_browsex_viewer
  else
   put = 'let g:netrw_browsex_viewer    = (not defined)'
  endif
  put = 'let g:netrw_compress          = '.g:netrw_compress
  put = 'let g:netrw_cursorline        = '.g:netrw_cursorline
  let decompressline= line("$")
  put ='let g:netrw_decompress...'
  put = 'let g:netrw_dirhistmax        = '.g:netrw_dirhistmax
  put = 'let g:netrw_fastbrowse        = '.g:netrw_fastbrowse
  let fnameescline= line("$")
  put = 'let g:netrw_fname_escape...'
  put = 'let g:netrw_ftp_browse_reject = '.g:netrw_ftp_browse_reject
  put = 'let g:netrw_ftp_list_cmd      = '.g:netrw_ftp_list_cmd
  put = 'let g:netrw_ftp_sizelist_cmd  = '.g:netrw_ftp_sizelist_cmd
  put = 'let g:netrw_ftp_timelist_cmd  = '.g:netrw_ftp_timelist_cmd
  let globescline= line("$")
  put ='let g:netrw_glob_escape...'
  put = 'let g:netrw_hide              = '.g:netrw_hide
  put = 'let g:netrw_keepdir           = '.g:netrw_keepdir
  put = 'let g:netrw_list_cmd          = '.g:netrw_list_cmd
  put = 'let g:netrw_list_hide         = '.g:netrw_list_hide
  put = 'let g:netrw_liststyle         = '.g:netrw_liststyle
  put = 'let g:netrw_localcopycmd      = '.g:netrw_localcopycmd
  put = 'let g:netrw_local_mkdir       = '.g:netrw_local_mkdir
  put = 'let g:netrw_localmovecmd      = '.g:netrw_localmovecmd
  put = 'let g:netrw_local_rmdir       = '.g:netrw_local_rmdir
  put = 'let g:netrw_maxfilenamelen    = '.g:netrw_maxfilenamelen
  put = 'let g:netrw_menu              = '.g:netrw_menu
  put = 'let g:netrw_mkdir_cmd         = '.g:netrw_mkdir_cmd
  put = 'let g:netrw_preview           = '.g:netrw_preview
  put = 'let g:netrw_rename_cmd        = '.g:netrw_rename_cmd
  put = 'let g:netrw_retmap            = '.g:netrw_retmap
  put = 'let g:netrw_rm_cmd            = '.g:netrw_rm_cmd
  put = 'let g:netrw_rmdir_cmd         = '.g:netrw_rmdir_cmd
  put = 'let g:netrw_rmf_cmd           = '.g:netrw_rmf_cmd
  put = 'let g:netrw_silent            = '.g:netrw_silent
  put = 'let g:netrw_sort_by           = '.g:netrw_sort_by
  put = 'let g:netrw_sort_direction    = '.g:netrw_sort_direction
  put = 'let g:netrw_sort_options      = '.g:netrw_sort_options
  put = 'let g:netrw_sort_sequence     = '.g:netrw_sort_sequence
  put = 'let g:netrw_special_syntax    = '.g:netrw_special_syntax
  put = 'let g:netrw_ssh_browse_reject = '.g:netrw_ssh_browse_reject
  put = 'let g:netrw_scpport           = '.g:netrw_scpport
  put = 'let g:netrw_sshport           = '.g:netrw_sshport
  put = 'let g:netrw_timefmt           = '.g:netrw_timefmt
  let tmpfileescline= line("$")
  put ='let g:netrw_tmpfile_escape...'
  put = 'let g:netrw_use_noswf         = '.g:netrw_use_noswf
  put = 'let g:netrw_xstrlen           = '.g:netrw_xstrlen
  put = 'let g:netrw_winsize           = '.g:netrw_winsize

  put =''
  put ='+ For help, place cursor on line and press <F1>'

  1d
  silent %s/^+/"/e
  res 99
  silent %s/= \([^0-9].*\)$/= '\1'/e
  silent %s/= $/= ''/e
  1

  call setline(decompressline,"let g:netrw_decompress        = ".substitute(string(g:netrw_decompress),"^'\\(.*\\)'$",'\1',''))
  call setline(fnameescline,  "let g:netrw_fname_escape      = '".escape(g:netrw_fname_escape,"'")."'")
  call setline(globescline,   "let g:netrw_glob_escape       = '".escape(g:netrw_glob_escape,"'")."'")
  call setline(tmpfileescline,"let g:netrw_tmpfile_escape    = '".escape(g:netrw_tmpfile_escape,"'")."'")

  set nomod

  nmap <buffer> <silent> <F1>                       :call NetrwSettingHelp()<cr>
  nnoremap <buffer> <silent> <leftmouse> <leftmouse>:call NetrwSettingHelp()<cr>
  let tmpfile= tempname()
  exe 'au BufWriteCmd	Netrw\ Settings	silent w! '.tmpfile.'|so '.tmpfile.'|call delete("'.tmpfile.'")|set nomod'
endfun

" ---------------------------------------------------------------------
" NetrwSettingHelp: {{{2
fun! NetrwSettingHelp()
"  call Dfunc("NetrwSettingHelp()")
  let curline = getline(".")
  if curline =~ '='
   let varhelp = substitute(curline,'^\s*let ','','e')
   let varhelp = substitute(varhelp,'\s*=.*$','','e')
"   call Decho("trying help ".varhelp)
   try
    exe "he ".varhelp
   catch /^Vim\%((\a\+)\)\=:E149/
   	echo "***sorry*** no help available for <".varhelp.">"
   endtry
  elseif line(".") < s:netrw_settings_stop
   he netrw-settings
  elseif line(".") < s:netrw_protocol_stop
   he netrw-externapp
  elseif line(".") < s:netrw_xfer_stop
   he netrw-variables
  else
   he netrw-browse-var
  endif
"  call Dret("NetrwSettingHelp")
endfun

" ---------------------------------------------------------------------
" Modelines: {{{1
" vim:ts=8 fdm=marker
doc/pi_netrw.txt	[[[1
3254
*pi_netrw.txt*  For Vim version 7.2.  Last change: 2008 Oct 23

	    -----------------------------------------------------
	    NETRW REFERENCE MANUAL    by Charles E. Campbell, Jr.
	    -----------------------------------------------------


*dav*    *ftp*    *netrw-file*  *Nread*    *rcp*    *scp*
*davs*   *http*   *netrw.vim*   *Nsource*  *rsync*  *sftp*
*fetch*  *netrw*  *network*     *Nwrite*

==============================================================================
1. Contents						*netrw-contents* {{{1

1.  Contents.............................................|netrw-contents|
2.  Starting With Netrw..................................|netrw-start|
3.  Netrw Reference......................................|netrw-ref|
      EXTERNAL APPLICATIONS AND PROTOCOLS................|netrw-externapp|
      READING............................................|netrw-read|
      WRITING............................................|netrw-write|
      DIRECTORY LISTING..................................|netrw-dirlist|
      CHANGING THE USERID AND PASSWORD...................|netrw-chgup|
      VARIABLES AND SETTINGS.............................|netrw-variables|
      PATHS..............................................|netrw-path|
4.  Network-Oriented File Transfer.......................|netrw-xfer|
      NETRC..............................................|netrw-netrc|
      PASSWORD...........................................|netrw-passwd|
5.  Activation...........................................|netrw-activate|
6.  Transparent File Editing.............................|netrw-transparent|
7.  Ex Commands..........................................|netrw-ex|
8.  Variables and Options................................|netrw-var|
9.  Browsing.............................................|netrw-browse|
      Introduction To Browsing...........................|netrw-intro-browse|
      Quick Reference: Maps..............................|netrw-browse-maps|
      Quick Reference: Commands..........................|netrw-browse-cmds|
      Bookmarking A Directory............................|netrw-mb|
      Browsing...........................................|netrw-cr|
      Browsing With A Horizontally Split Window..........|netrw-o|
      Browsing With A New Tab............................|netrw-t|
      Browsing With A Vertically Split Window............|netrw-v|
      Change Listing Style...............................|netrw-i|
      Changing To A Bookmarked Directory.................|netrw-gb|
      Changing To A Predecessor Directory................|netrw-u|
      Changing To A Successor Directory..................|netrw-U|
      Customizing Browsing With A User Function..........|netrw-x|
      Deleting Bookmarks.................................|netrw-mB|
      Deleting Files Or Directories......................|netrw-D|
      Directory Exploring Commands.......................|netrw-explore|
      Exploring With Stars and Patterns..................|netrw-star|
      Displaying Information About File..................|netrw-qf|
      Edit File Or Directory Hiding List.................|netrw-ctrl-h|
      Editing The Sorting Sequence.......................|netrw-S|
      Going Up...........................................|netrw--|
      Hiding Files Or Directories........................|netrw-a|
      Improving Browsing.................................|netrw-ssh-hack|
      Listing Bookmarks And History......................|netrw-qb|
      Making A New Directory.............................|netrw-d|
      Making The Browsing Directory The Current Directory|netrw-c|
      Marking Files......................................|netrw-mf|
      Marking Files By Regular Expression................|netrw-mr|
      Marked Files: Arbitrary Command....................|netrw-mx|
      Marked Files: Compression And Decompression........|netrw-mz|
      Marked Files: Copying..............................|netrw-mc|
      Marked Files: Diff.................................|netrw-md|
      Marked Files: Editing..............................|netrw-me|
      Marked Files: Grep.................................|netrw-mg|
      Marked Files: Hiding and Unhiding by Suffix........|netrw-mh|
      Marked Files: Moving...............................|netrw-mm|
      Marked Files: Printing.............................|netrw-mp|
      Marked Files: Sourcing.............................|netrw-ms|
      Marked Files: Tagging..............................|netrw-mT|
      Marked Files: Setting the Target Directory.........|netrw-mt|
      Marked Files: Unmarking............................|netrw-mu|
      Netrw Browser Variables............................|netrw-browser-var|
      Netrw Browsing And Option Incompatibilities........|netrw-incompatible|
      Netrw Settings.....................................|netrw-settings|
      Obtaining A File...................................|netrw-O|
      Preview Window.....................................|netrw-p|
      Previous Window....................................|netrw-P|
      Refreshing The Listing.............................|netrw-ctrl-l|
      Renaming Files Or Directories......................|netrw-move|
      Reversing Sorting Order............................|netrw-r|
      Selecting Sorting Style............................|netrw-s|
10. Problems and Fixes...................................|netrw-problems|
11. Debugging Netrw Itself...............................|netrw-debug|
12. History..............................................|netrw-history|
13. Credits..............................................|netrw-credits|

{Vi does not have any of this}

==============================================================================
2. Starting With Netrw					*netrw-start* {{{1

Netrw makes reading files, writing files, browsing over a network, and
browsing locally easy!  First, make sure that you have plugins enabled, so
you'll need to have at least the following in your <.vimrc>:
(or see |netrw-activate|) >

	set nocp                    " 'compatible' is not set
	filetype plugin on          " plugins are enabled
<
(see |'cp'| and |:filetype-plugin-on|)

Netrw supports "transparent" editing of files on other machines using urls
(see |netrw-transparent|). As an example of this, let's assume you have an
account on some other machine; if you can use scp, try: >

	vim scp://hostname/path/to/file
<
Want to make ssh/scp easier to use? Check out |netrw-ssh-hack|!

So, what if you have ftp, not ssh/scp?  That's easy, too; try >

	vim ftp://hostname/path/to/file
<
Want to make ftp simpler to use?  See if your ftp supports a file called
<.netrc> -- typically it goes in your home directory, has read/write
permissions for only the user to read (ie. not group, world, other, etc),
and has lines resembling >

	machine HOSTNAME login USERID password "PASSWORD"
	machine HOSTNAME login USERID password "PASSWORD"
	...
	default          login USERID password "PASSWORD"
<
Now about browsing -- when you just want to look around before editing a
file.  For browsing on your current host, just "edit" a directory: >

	vim .
	vim /home/userid/path
<
For browsing on a remote host, "edit" a directory (but make sure that
the directory name is followed by a "/"): >

	vim scp://hostname/
	vim ftp://hostname/path/to/dir/
<
See |netrw-browse| for more!

There are more protocols supported by netrw just than scp and ftp, too: see the
next section, |netrw-externapp|, for how to use these external applications.

If you want to use plugins, but for some reason don't wish to use netrw, then
you need to avoid loading both the plugin and the autoload portions of netrw.
You may do so by placing the following two lines in your <.vimrc>: >

	:let g:loaded_netrw       = 1
	:let g:loaded_netrwPlugin = 1
<

==============================================================================
3. Netrw Reference					*netrw-ref* {{{1

   Netrw supports several protocols in addition to scp and ftp mentioned
   in |netrw-start|.  These include dav, fetch, http,... well, just look
   at the list in |netrw-externapp|.  Each protocol is associated with a
   variable which holds the default command supporting that protocol.

EXTERNAL APPLICATIONS AND PROTOCOLS			*netrw-externapp* {{{2

	Protocol  Variable	    Default Value
	--------  ----------------  -------------
	   dav:  *g:netrw_dav_cmd*   = "cadaver"     if cadaver is executable
	   dav:   g:netrw_dav_cmd    = "curl -o"     elseif curl is available
	 fetch:  *g:netrw_fetch_cmd* = "fetch -o"    if fetch is available
	   ftp:  *g:netrw_ftp_cmd*   = "ftp"
	  http:  *g:netrw_http_cmd*  = "elinks"     if   elinks  is available
	  http:   g:netrw_http_cmd   = "links"      elseif links is available
	  http:   g:netrw_http_cmd   = "curl"       elseif curl  is available
	  http:   g:netrw_http_cmd   = "wget"       elseif wget  is available
          http:   g:netrw_http_cmd   = "fetch"      elseif fetch is available
	   rcp:  *g:netrw_rcp_cmd*   = "rcp"
	 rsync:  *g:netrw_rsync_cmd* = "rsync -a"
	   scp:  *g:netrw_scp_cmd*   = "scp -q"
	  sftp:  *g:netrw_sftp_cmd*  = "sftp"

	*g:netrw_http_xcmd* : the option string for http://... protocols are
	specified via this variable and may be independently oveerridden.
	 
		    elinks : "-dump >"
		    links  : "-dump >"
		    curl   : "-o"
		    wget   : "-q -O"
		    fetch  : "-o"

	For example, if your system has elinks but you want to see the html
	source in detail rather than a text rendering thereof, you may wish
	to have  let g:netrw_http_xcmd= "-source >" in your .vimrc.


READING						*netrw-read* *netrw-nread* {{{2

	Generally, one may just use the url notation with a normal editing
	command, such as >

		:e ftp://[user@]machine/path
<
	Netrw also provides the Nread command:

	:Nread ?					give help
	:Nread "machine:path"				uses rcp
	:Nread "machine path"				uses ftp w/ <.netrc>
	:Nread "machine id password path"		uses ftp
	:Nread "dav://machine[:port]/path"		uses cadaver
	:Nread "fetch://[user@]machine/path"		uses fetch
	:Nread "ftp://[user@]machine[[:#]port]/path"	uses ftp w/ <.netrc>
	:Nread "http://[user@]machine/path"		uses http  uses wget
	:Nread "rcp://[user@]machine/path"		uses rcp
	:Nread "rsync://[user@]machine[:port]/path"	uses rsync
	:Nread "scp://[user@]machine[[:#]port]/path"	uses scp
	:Nread "sftp://[user@]machine/path"		uses sftp

WRITING					*netrw-write* *netrw-nwrite* {{{2

	One may just use the url notation with a normal file writing
	command, such as >

		:w ftp://[user@]machine/path
<
	Netrw also provides the Nwrite command:

	:Nwrite ?					give help
	:Nwrite "machine:path"				uses rcp
	:Nwrite "machine path"				uses ftp w/ <.netrc>
	:Nwrite "machine id password path"		uses ftp
	:Nwrite "dav://machine[:port]/path"		uses cadaver
	:Nwrite "ftp://[user@]machine[[:#]port]/path"	uses ftp w/ <.netrc>
	:Nwrite "rcp://[user@]machine/path"		uses rcp
	:Nwrite "rsync://[user@]machine[:port]/path"	uses rsync
	:Nwrite "scp://[user@]machine[[:#]port]/path"	uses scp
	:Nwrite "sftp://[user@]machine/path"		uses sftp
	http: not supported!

SOURCING					*netrw-source* {{{2

	One may just use the url notation with the normal file sourcing
	command, such as >

		:so ftp://[user@]machine/path
<
	Netrw also provides the Nsource command:

	:Nsource ?					give help
	:Nsource "dav://machine[:port]/path"		uses cadaver
	:Nsource "fetch://[user@]machine/path"		uses fetch
	:Nsource "ftp://[user@]machine[[:#]port]/path"	uses ftp w/ <.netrc>
	:Nsource "http://[user@]machine/path"		uses http  uses wget
	:Nsource "rcp://[user@]machine/path"		uses rcp
	:Nsource "rsync://[user@]machine[:port]/path"	uses rsync
	:Nsource "scp://[user@]machine[[:#]port]/path"	uses scp
	:Nsource "sftp://[user@]machine/path"		uses sftp

DIRECTORY LISTING					*netrw-dirlist* {{{2

	One may browse a directory to get a listing by simply attempting to
	edit the directory: >

		:e scp://[user]@hostname/path/
		:e ftp://[user]@hostname/path/
<
	For remote directories (ie. those using scp or ftp), that trailing
	"/" is necessary (it tells netrw that its to treat it as a directory
	to browse instead of a file to download).

	However, the Nread command can also be used to accomplish this:

	:Nread [protocol]://[user]@hostname/path/

					*netrw-login* *netrw-password*
CHANGING USERID AND PASSWORD		*netrw-chgup* *netrw-userpass* {{{2

	Attempts to use ftp will prompt you for a user-id and a password.
	These will be saved in global variables g:netrw_uid and
	s:netrw_passwd; subsequent uses of ftp will re-use those two items to
	simplify the further use of ftp.  However, if you need to use a
	different user id and/or password, you'll want to call NetUserPass()
	first.  To work around the need to enter passwords, check if your ftp
	supports a <.netrc> file in your home directory.  Also see
	|netrw-passwd| (and if you're using ssh/scp hoping to figure out how
	to not need to use passwords, look at |netrw-ssh-hack|).

	:NetUserPass [uid [password]]		-- prompts as needed
	:call NetUserPass()			-- prompts for uid and password
	:call NetUserPass("uid")		-- prompts for password
	:call NetUserPass("uid","password")	-- sets global uid and password

NETRW VARIABLES AND SETTINGS				*netrw-variables* {{{2
(also see: |netrw-browser-var| |netrw-protocol| |netrw-settings| |netrw-var|)

Netrw provides a lot of variables which allow you to customize netrw to your
preferences.  One way to look at them is via the command :NetrwSettings (see
|netrw-settings|) which will display your current netrw settings.  Most such
settings are described below, in |netrw-browser-options|, and in
|netrw-externapp|:

 *b:netrw_lastfile*	last file Network-read/written retained on a per-buffer
			basis		(supports plain :Nw )

 *g:netrw_ftp*		if it doesn't exist, use default ftp
			=0 use default ftp		       (uid password)
			=1 use alternate ftp method	  (user uid password)
			If you're having trouble with ftp, try changing the
			value of this variable to see if the alternate ftp
			method works for your setup.

 *g:netrw_extracmd*	default: doesn't exist
                        If this variable exists, then any string it contains
			will be placed into the commands set to your ftp
			client.  As an example:
			  ="passive"

 *g:netrw_ftpmode*	="binary"				    (default)
			="ascii"

 *g:netrw_ignorenetrc*	=0 (default for linux, cygwin)
			=1 If you have a <.netrc> file but it doesn't work and
			   you want it ignored, then set this variable as
			   shown. (default for Windows + cmd.exe)

 *g:netrw_menu*		=0 disable netrw's menu
			=1 (default) netrw's menu enabled

 *g:netrw_nogx*		if this variable exists, then the "gx" map will not
			be available (see |netrw-gx|)

 *g:netrw_uid*		(ftp) user-id,      retained on a per-session basis
 *s:netrw_passwd*	(ftp) password,     retained on a per-session basis

 *g:netrw_preview*	=0 (default) preview window shown in a horizontally
                           split window
			=1 preview window shown in a vertically split window.
			Also affects the "previous window" (see |netrw-P|) in
			the same way.

 *g:netrw_scpport*      = "-P" : option to use to set port for scp
 *g:netrw_sshport*      = "-p" : option to use to set port for ssh

  *g:netrw_silent*	=0 : transfers done normally
			=1 : transfers done silently

 *g:netrw_use_errorwindow* =1 : messages from netrw will use a separate one
                                line window.  This window provides reliable
				delivery of messages. (default)
			   =0 : messages from netrw will use echoerr ;
			        messages don't always seem to show up this
				way, but one doesn't have to quit the window.

 *g:netrw_win95ftp*	=1 if using Win95, will remove four trailing blank
			   lines that o/s's ftp "provides" on transfers
			=0 force normal ftp behavior (no trailing line removal)

 *g:netrw_cygwin*	=1 assume scp under windows is from cygwin. Also
			   permits network browsing to use ls with time and
			   size sorting (default if windows)
			=0 assume Windows' scp accepts windows-style paths
			   Network browsing uses dir instead of ls
			This option is ignored if you're using unix

 *g:netrw_use_nt_rcp*	=0 don't use the rcp of WinNT, Win2000 and WinXP
			=1 use WinNT's rcp in binary mode         (default)

PATHS							*netrw-path* {{{2

Paths to files are generally user-directory relative for most protocols.
It is possible that some protocol will make paths relative to some
associated directory, however.
>
	example:  vim scp://user@host/somefile
	example:  vim scp://user@host/subdir1/subdir2/somefile
<
where "somefile" is in the "user"'s home directory.  If you wish to get a
file using root-relative paths, use the full path:
>
	example:  vim scp://user@host//somefile
	example:  vim scp://user@host//subdir1/subdir2/somefile
<

==============================================================================
4. Network-Oriented File Transfer			*netrw-xfer* {{{1

Network-oriented file transfer under Vim is implemented by a VimL-based script
(<netrw.vim>) using plugin techniques.  It currently supports both reading and
writing across networks using rcp, scp, ftp or ftp+<.netrc>, scp, fetch,
dav/cadaver, rsync, or sftp.

http is currently supported read-only via use of wget or fetch.

<netrw.vim> is a standard plugin which acts as glue between Vim and the
various file transfer programs.  It uses autocommand events (BufReadCmd,
FileReadCmd, BufWriteCmd) to intercept reads/writes with url-like filenames. >

	ex. vim ftp://hostname/path/to/file
<
The characters preceding the colon specify the protocol to use; in the
example, it's ftp.  The <netrw.vim> script then formulates a command or a
series of commands (typically ftp) which it issues to an external program
(ftp, scp, etc) which does the actual file transfer/protocol.  Files are read
from/written to a temporary file (under Unix/Linux, /tmp/...) which the
<netrw.vim> script will clean up.

				*netrw-putty* *netrw-pscp* *netrw-psftp*
One may modify any protocol's implementing external application by setting a
variable (ex. scp uses the variable g:netrw_scp_cmd, which is defaulted to
"scp -q").  As an example, consider using PuTTY: >

	let g:netrw_scp_cmd = '"c:\Program Files\PuTTY\pscp.exe" -q -batch'
	let g:netrw_sftp_cmd= '"c:\Program Files\PuTTY\psftp.exe"'
<
See |netrw-p8| for more about putty, pscp, psftp, etc.

Ftp, an old protocol, seems to be blessed by numerous implementations.
Unfortunately, some implementations are noisy (ie., add junk to the end of the
file).  Thus, concerned users may decide to write a NetReadFixup() function
that will clean up after reading with their ftp.  Some Unix systems (ie.,
FreeBSD) provide a utility called "fetch" which uses the ftp protocol but is
not noisy and more convenient, actually, for <netrw.vim> to use.
Consequently, if "fetch" is executable, it will be used to do reads for
ftp://... (and http://...) .  See |netrw-var| for more about this.

For rcp, scp, sftp, and http, one may use network-oriented file transfers
transparently; ie.
>
	vim rcp://[user@]machine/path
	vim scp://[user@]machine/path
<
If your ftp supports <.netrc>, then it too can be just as transparently used
if the needed triad of machine name, user id, and password are present in
that file.  Your ftp must be able to use the <.netrc> file on its own, however.
>
	vim ftp://[user@]machine[[:#]portnumber]/path
<
However, ftp will often need to query the user for the userid and password.
The latter will be done "silently"; ie. asterisks will show up instead of
the actually-typed-in password.  Netrw will retain the userid and password
for subsequent read/writes from the most recent transfer so subsequent
transfers (read/write) to or from that machine will take place without
additional prompting.

								*netrw-urls*
  +=================================+============================+============+
  |  Reading                        | Writing                    |  Uses      |
  +=================================+============================+============+
  | DAV:                            |                            |            |
  |  dav://host/path                |                            | cadaver    |
  |  :Nread dav://host/path         | :Nwrite dav://host/path    | cadaver    |
  +---------------------------------+----------------------------+------------+
  | DAV + SSL:                      |                            |            |
  |  davs://host/path               |                            | cadaver    |
  |  :Nread davs://host/path        | :Nwrite davs://host/path   | cadaver    |
  +---------------------------------+----------------------------+------------+
  | FETCH:                          |                            |            |
  |  fetch://[user@]host/path       |                            |            |
  |  fetch://[user@]host:http/path  |  Not Available             | fetch      |
  |  :Nread fetch://[user@]host/path|                            |            |
  +---------------------------------+----------------------------+------------+
  | FILE:                           |                            |            |
  |  file:///*                      | file:///*                  |            |
  |  file://localhost/*             | file://localhost/*         |            |
  +---------------------------------+----------------------------+------------+
  | FTP:          (*3)              |              (*3)          |            |
  |  ftp://[user@]host/path         | ftp://[user@]host/path     | ftp  (*2)  |
  |  :Nread ftp://host/path         | :Nwrite ftp://host/path    | ftp+.netrc |
  |  :Nread host path               | :Nwrite host path          | ftp+.netrc |
  |  :Nread host uid pass path      | :Nwrite host uid pass path | ftp        |
  +---------------------------------+----------------------------+------------+
  | HTTP: wget is executable: (*4)  |                            |            |
  |  http://[user@]host/path        |        Not Available       | wget       |
  +---------------------------------+----------------------------+------------+
  | HTTP: fetch is executable (*4)  |                            |            |
  |  http://[user@]host/path        |        Not Available       | fetch      |
  +---------------------------------+----------------------------+------------+
  | RCP:                            |                            |            |
  |  rcp://[user@]host/path         | rcp://[user@]host/path     | rcp        |
  +---------------------------------+----------------------------+------------+
  | RSYNC:                          |                            |            |
  |  rsync://[user@]host/path       | rsync://[user@]host/path   | rsync      |
  |  :Nread rsync://host/path       | :Nwrite rsync://host/path  | rsync      |
  |  :Nread rcp://host/path         | :Nwrite rcp://host/path    | rcp        |
  +---------------------------------+----------------------------+------------+
  | SCP:                            |                            |            |
  |  scp://[user@]host/path         | scp://[user@]host/path     | scp        |
  |  :Nread scp://host/path         | :Nwrite scp://host/path    | scp  (*1)  |
  +---------------------------------+----------------------------+------------+
  | SFTP:                           |                            |            |
  |  sftp://[user@]host/path        | sftp://[user@]host/path    | sftp       |
  |  :Nread sftp://host/path        | :Nwrite sftp://host/path   | sftp  (*1) |
  +=================================+============================+============+

	(*1) For an absolute path use scp://machine//path.

	(*2) if <.netrc> is present, it is assumed that it will
	work with your ftp client.  Otherwise the script will
	prompt for user-id and password.

        (*3) for ftp, "machine" may be machine#port or machine:port
	if a different port is needed than the standard ftp port

	(*4) for http:..., if wget is available it will be used.  Otherwise,
	if fetch is available it will be used.

Both the :Nread and the :Nwrite ex-commands can accept multiple filenames.


NETRC							*netrw-netrc*

The <.netrc> file, typically located in your home directory, contains lines
therein which map a hostname (machine name) to the user id and password you
prefer to use with it.

The typical syntax for lines in a <.netrc> file is given as shown below.
Ftp under Unix usually supports <.netrc>; ftp under Windows usually doesn't.
>
	machine {full machine name} login {user-id} password "{password}"
	default login {user-id} password "{password}"

Your ftp client must handle the use of <.netrc> on its own, but if the
<.netrc> file exists, an ftp transfer will not ask for the user-id or
password.

	Note:
	Since this file contains passwords, make very sure nobody else can
	read this file!  Most programs will refuse to use a .netrc that is
	readable for others.  Don't forget that the system administrator can
	still read the file!  Ie. for Linux/Unix: chmod 600 .netrc


PASSWORD						*netrw-passwd*

The script attempts to get passwords for ftp invisibly using |inputsecret()|,
a built-in Vim function.  See |netrw-uidpass| for how to change the password
after one has set it.

Unfortunately there doesn't appear to be a way for netrw to feed a password to
scp.  Thus every transfer via scp will require re-entry of the password.
However, |netrw-ssh-hack| can help with this problem.


==============================================================================
5. Activation						*netrw-activate* {{{1

Network-oriented file transfers are available by default whenever Vim's
|'nocompatible'| mode is enabled.  Netrw's script files reside in your
system's plugin, autoload, and syntax directories; just the
plugin/netrwPlugin.vim script is sourced automatically whenever you bring up
vim.  The main script in autoload/netrw.vim is only loaded when you actually
use netrw.  I suggest that, at a minimum, you have at least the following in
your <.vimrc> customization file: >

	set nocp
	if version >= 600
	  filetype plugin indent on
	endif
<

==============================================================================
6. Transparent File Editing			*netrw-transparent* {{{1

Transparent file transfers occur whenever a regular file read or write
(invoked via an |:autocmd| for |BufReadCmd|, |BufWriteCmd|, or |SourceCmd|
events) is made.  Thus one may read, write, or source  files across networks
just as easily as if they were local files! >

	vim ftp://[user@]machine/path
	...
	:wq

See |netrw-activate| for more on how to encourage your vim to use plugins
such as netrw.


==============================================================================
7. Ex Commands						*netrw-ex* {{{1

The usual read/write commands are supported.  There are also a few
additional commands available.  Often you won't need to use Nwrite or
Nread as shown in |netrw-transparent| (ie. simply use >
  :e url
  :r url
  :w url
instead, as appropriate) -- see |netrw-urls|.  In the explanations
below, a {netfile} is an url to a remote file.

:[range]Nw[rite]	Write the specified lines to the current
		file as specified in b:netrw_lastfile.

:[range]Nw[rite] {netfile} [{netfile}]...
		Write the specified lines to the {netfile}.

:Nr[ead]		Read the specified lines into the current
		buffer from the file specified in
		b:netrw_lastfile.

:Nr[ead] {netfile} {netfile}...
		Read the {netfile} after the current line.

:Ns[ource] {netfile}
		Source the {netfile}.
		To start up vim using a remote .vimrc, one may use
		the following (all on one line) (tnx to Antoine Mechelynck) >
		vim -u NORC -N
		 --cmd "runtime plugin/netrwPlugin.vim"
		 --cmd "source scp://HOSTNAME/.vimrc"
<								*netrw-uidpass*
:call NetUserPass()
		If g:netrw_uid and s:netrw_passwd don't exist,
		this function will query the user for them.

:call NetUserPass("userid")
		This call will set the g:netrw_uid and, if
		the password doesn't exist, will query the user for it.

:call NetUserPass("userid","passwd")
		This call will set both the g:netrw_uid and s:netrw_passwd.
		The user-id and password are used by ftp transfers.  One may
		effectively remove the user-id and password by using empty
		strings (ie. "").

:NetrwSettings  This command is described in |netrw-settings| -- used to
                display netrw settings and change netrw behavior.


==============================================================================
8. Variables and Options		*netrw-options* *netrw-var* {{{1

(if you're interested in the netrw browser settings, see: |netrw-browser-var|)

The <netrw.vim> script provides several variables which act as options to
affect <netrw.vim>'s file transfer behavior.  These variables typically may be
set in the user's <.vimrc> file: (see also |netrw-settings| |netrw-protocol|)

>

                        -------------
                        Netrw Options
                        -------------
	Option			Meaning
	--------------		-----------------------------------------------
<
        b:netrw_col             Holds current cursor position (during NetWrite)
        g:netrw_cygwin          =1 assume scp under windows is from cygwin
                                                              (default/windows)
                                =0 assume scp under windows accepts windows
                                   style paths                (default/else)
        g:netrw_ftp             =0 use default ftp            (uid password)
        g:netrw_ftpmode         ="binary"                     (default)
                                ="ascii"                      (your choice)
	g:netrw_ignorenetrc     =1                            (default)
	                           if you have a <.netrc> file but you don't
				   want it used, then set this variable.  Its
				   mere existence is enough to cause <.netrc>
				   to be ignored.
        b:netrw_lastfile        Holds latest method/machine/path.
        b:netrw_line            Holds current line number     (during NetWrite)
        g:netrw_passwd          Holds current password for ftp.
	g:netrw_silent          =0 transfers done normally
	                        =1 transfers done silently
        g:netrw_uid             Holds current user-id for ftp.
                                =1 use alternate ftp         (user uid password)
                                (see |netrw-options|)
        g:netrw_use_nt_rcp      =0 don't use WinNT/2K/XP's rcp (default)
                                =1 use WinNT/2K/XP's rcp, binary mode
        g:netrw_win95ftp        =0 use unix-style ftp even if win95/98/ME/etc
                                =1 use default method to do ftp >
	-----------------------------------------------------------------------
<
The script will also make use of the following variables internally, albeit
temporarily.
>
			     -------------------
			     Temporary Variables
			     -------------------
	Variable		Meaning
	--------		------------------------------------
<
	g:netrw_method		Index indicating rcp/ftp+.netrc/ftp
	g:netrw_machine		Holds machine name parsed from input
	g:netrw_fname		Holds filename being accessed >
	------------------------------------------------------------
<
							*netrw-protocol*

Netrw supports a number of protocols.  These protocols are invoked using the
variables listed below, and may be modified by the user.
>
			   ------------------------
                           Protocol Control Options
			   ------------------------
    Option            Type        Setting         Meaning
    ---------         --------    --------------  ---------------------------
<
    netrw_ftp         variable    =doesn't exist  userid set by "user userid"
                                  =0              userid set by "user userid"
                                  =1              userid set by "userid"
    NetReadFixup      function    =doesn't exist  no change
                                  =exists         Allows user to have files
                                                  read via ftp automatically
                                                  transformed however they wish
                                                  by NetReadFixup()
    g:netrw_dav_cmd    variable   ="cadaver"      if cadaver  is executable
    g:netrw_dav_cmd    variable   ="curl -o"      elseif curl is executable
    g:netrw_fetch_cmd  variable   ="fetch -o"     if fetch is available
    g:netrw_ftp_cmd    variable   ="ftp"
    g:netrw_http_cmd   variable   ="fetch -o"     if      fetch is available
    g:netrw_http_cmd   variable   ="wget -O"      else if wget  is available
    g:netrw_list_cmd   variable   ="ssh USEPORT HOSTNAME ls -Fa"
    g:netrw_rcp_cmd    variable   ="rcp"
    g:netrw_rsync_cmd  variable   ="rsync -a"
    g:netrw_scp_cmd    variable   ="scp -q"
    g:netrw_sftp_cmd   variable   ="sftp" >
    -------------------------------------------------------------------------
<
								*netrw-ftp*

The g:netrw_..._cmd options (|g:netrw_ftp_cmd| and |g:netrw_sftp_cmd|)
specify the external program to use handle the ftp protocol.  They may
include command line options (such as -p for passive mode).

Browsing is supported by using the |g:netrw_list_cmd|; the substring
"HOSTNAME" will be changed via substitution with whatever the current request
is for a hostname.

Two options (|g:netrw_ftp| and |netrw-fixup|) both help with certain ftp's
that give trouble .  In order to best understand how to use these options if
ftp is giving you troubles, a bit of discussion is provided on how netrw does
ftp reads.

For ftp, netrw typically builds up lines of one of the following formats in a
temporary file:
>
  IF g:netrw_ftp !exists or is not 1     IF g:netrw_ftp exists and is 1
  ----------------------------------     ------------------------------
<
       open machine [port]                    open machine [port]
       user userid password                   userid password
       [g:netrw_ftpmode]                      password
       [g:netrw_extracmd]                     [g:netrw_ftpmode]
       get filename tempfile                  [g:netrw_extracmd]
                                              get filename tempfile >
  ---------------------------------------------------------------------
<
The |g:netrw_ftpmode| and |g:netrw_extracmd| are optional.

Netrw then executes the lines above by use of a filter:
>
	:%! {g:netrw_ftp_cmd} -i [-n]
<
where
	g:netrw_ftp_cmd is usually "ftp",
	-i tells ftp not to be interactive
	-n means don't use netrc and is used for Method #3 (ftp w/o <.netrc>)

If <.netrc> exists it will be used to avoid having to query the user for
userid and password.  The transferred file is put into a temporary file.
The temporary file is then read into the main editing session window that
requested it and the temporary file deleted.

If your ftp doesn't accept the "user" command and immediately just demands a
userid, then try putting "let netrw_ftp=1" in your <.vimrc>.

								*netrw-cadaver*
To handle the SSL certificate dialog for untrusted servers, one may pull
down the certificate and place it into /usr/ssl/cert.pem.  This operation
renders the server treatment as "trusted".

						*netrw-fixup* *netreadfixup*
If your ftp for whatever reason generates unwanted lines (such as AUTH
messages) you may write a NetReadFixup(tmpfile) function:
>
    function! NetReadFixup(method,line1,line2)
      " a:line1: first new line in current file
      " a:line2: last  new line in current file
      if     a:method == 1 "rcp
      elseif a:method == 2 "ftp + <.netrc>
      elseif a:method == 3 "ftp + machine,uid,password,filename
      elseif a:method == 4 "scp
      elseif a:method == 5 "http/wget
      elseif a:method == 6 "dav/cadaver
      elseif a:method == 7 "rsync
      elseif a:method == 8 "fetch
      elseif a:method == 9 "sftp
      else               " complain
      endif
    endfunction
>
The NetReadFixup() function will be called if it exists and thus allows you to
customize your reading process.  As a further example, <netrw.vim> contains
just such a function to handle Windows 95 ftp.  For whatever reason, Windows
95's ftp dumps four blank lines at the end of a transfer, and so it is
desirable to automate their removal.  Here's some code taken from <netrw.vim>
itself:
>
    if has("win95") && g:netrw_win95ftp
     fun! NetReadFixup(method, line1, line2)
       if method == 3   " ftp (no <.netrc>)
        let fourblanklines= line2 - 3
        silent fourblanklines.",".line2."g/^\s*/d"
       endif
     endfunction
    endif
>

==============================================================================
9. Browsing		*netrw-browsing* *netrw-browse* *netrw-help* {{{1
   			*netrw-browser*  *netrw-dir*    *netrw-list*

INTRODUCTION TO BROWSING			*netrw-intro-browse* {{{2
	(Quick References: |netrw-quickmaps| |netrw-quickcoms|)

Netrw supports the browsing of directories on your local system and on remote
hosts; browsing includes listing files and directories, entering directories,
editing files therein, deleting files/directories, making new directories,
moving (renaming) files and directories, copying files and directories, etc.
One may mark files and execute any system command on them!  The Netrw browser
generally implements the previous explorer's maps and commands for remote
directories, although details (such as pertinent global variable names)
necessarily differ.  To browse a directory, simply "edit" it! >

	vim /your/directory/
	vim .
	vim c:\your\directory\
<
(Related topics: |netrw-cr|  |netrw-o|  |netrw-p| |netrw-P| |netrw-t|
                 |netrw-mf|  |netrw-mx| |netrw-D| |netrw-R| |netrw-v| )

The Netrw remote file and directory browser handles two protocols: ssh and
ftp.  The protocol in the url, if it is ftp, will cause netrw also to use ftp
in its remote browsing.  Specifying any other protocol will cause it to be
used for file transfers; but the ssh protocol will be used to do remote
browsing.

To use Netrw's remote directory browser, simply attempt to read a "file" with
a trailing slash and it will be interpreted as a request to list a directory:
>
	vim [protocol]://[user@]hostname/path/
<
where [protocol] is typically scp or ftp.  As an example, try: >

	vim ftp://ftp.home.vim.org/pub/vim/
<
For local directories, the trailing slash is not required.  Again, because its
easy to miss: to browse remote directories, the url must terminate with a
slash!

If you'd like to avoid entering the password repeatedly for remote directory
listings with ssh or scp, see |netrw-ssh-hack|.  To avoid password entry with
ftp, see |netrw-netrc| (if your ftp supports it).

There are several things you can do to affect the browser's display of files:

	* To change the listing style, press the "i" key (|netrw-i|).
	  Currently there are four styles: thin, long, wide, and tree.

	* To hide files (don't want to see those xyz~ files anymore?) see
	  |netrw-ctrl-h|.

	* Press s to sort files by name, time, or size.

See |netrw-browse-cmds| for all the things you can do with netrw!


QUICK HELP						*netrw-quickhelp* {{{2
                       (Use ctrl-] to select a topic)~
	Intro to Browsing...............................|netrw-intro-browse|
	  Quick Reference: Maps.........................|netrw-quickmap|
	  Quick Reference: Commands.....................|netrw-browse-cmds|
	Hiding
	  Edit hiding list..............................|netrw-ctrl-h|
	  Hiding Files or Directories...................|netrw-a|
	  Hiding/Unhiding by suffix.....................|netrw-mh|
	  Hiding  dot-files.............................|netrw-gh|
	Listing Style
	  Select listing style (thin/long/wide/tree)....|netrw-i|
	  Associated setting variable...................|g:netrw_liststyle|
	  Shell command used to perform listing.........|g:netrw_list_cmd|
	  Quick file info...............................|netrw-qf|
	Sorted by
	  Select sorting style (name/time/size).........|netrw-s|
	  Editing the sorting sequence..................|netrw-S|
	  Sorting options...............................|g:netrw_sort_options|
	  Associated setting variable...................|g:netrw_sort_sequence|
	  Reverse sorting order.........................|netrw-r|


				*netrw-quickmap* *netrw-quickmaps*
QUICK REFERENCE: MAPS				*netrw-browse-maps* {{{2
>
	  ---			-----------------			----
	  Map			Quick Explanation			Link
	  ---			-----------------			----
<	 <F1>	Causes Netrw to issue help
	 <cr>	Netrw will enter the directory or read the file      |netrw-cr|
	 <del>	Netrw will attempt to remove the file/directory      |netrw-del|
	   -	Makes Netrw go up one directory                      |netrw--|
	   a	Toggles between normal display,                      |netrw-a|
		hiding (suppress display of files matching g:netrw_list_hide)
		showing (display only files which match g:netrw_list_hide)
	   c	Make browsing directory the current directory        |netrw-c|
	   d	Make a directory                                     |netrw-d|
	   D	Attempt to remove the file(s)/directory(ies)         |netrw-D|
	   gb	Go to previous bookmarked directory                  |netrw-gb|
	   gh	Quick hide/unhide of dot-files                       |netrw-gh|
	   gi	Display information on file                          |netrw-qf|
	 <c-h>	Edit file hiding list                             |netrw-ctrl-h|
	   i	Cycle between thin, long, wide, and tree listings    |netrw-i|
	 <c-l>	Causes Netrw to refresh the directory listing     |netrw-ctrl-l|
	   mb	Bookmark current directory                           |netrw-mb|
	   mc	Copy marked files to marked-file target directory    |netrw-mc|
	   md	Apply diff to marked files (up to 3)                 |netrw-md|
	   me	Place marked files on arg list and edit them         |netrw-me|
	   mf	Mark a file                                          |netrw-mf|
	   mh	Toggle marked file suffices' presence on hiding list |netrw-mh|
	   mm	Move marked files to marked-file target directory    |netrw-mm|
	   mp	Print marked files                                   |netrw-mp|
	   mr	Mark files satisfying a |regexp|                     |netrw-mr|
	   mt	Current browsing directory becomes markfile target   |netrw-mt|
	   mT	Apply ctags to marked files                          |netrw-mT|
	   mu	Unmark all marked files                              |netrw-mu|
	   mx	Apply arbitrary shell command to marked files        |netrw-mx|
	   mz	Compress/decompress marked files                     |netrw-mz|
	   o	Enter the file/directory under the cursor in a new   |netrw-o|
	   	browser window.  A horizontal split is used.
	   O	Obtain a file specified by cursor                    |netrw-O|
	   p	Preview the file                                     |netrw-p|
	   P	Browse in the previously used window                 |netrw-P|
	   q	List bookmarked directories and history              |netrw-qb|
	   r	Reverse sorting order                                |netrw-r|
	   R	Rename the designed file(s)/directory(ies)           |netrw-R|
	   s	Select sorting style: by name, time, or file size    |netrw-s|
	   S	Specify suffix priority for name-sorting             |netrw-S|
	   t	Enter the file/directory under the cursor in a new tab|netrw-t|
	   u	Change to recently-visited directory                 |netrw-u|
	   U	Change to subsequently-visited directory             |netrw-U|
	   v	Enter the file/directory under the cursor in a new   |netrw-v|
	   	browser window.  A vertical split is used.
	   x	View file with an associated program                 |netrw-x|

	   %	Open a new file in netrw's current directory         |netrw-%|

	<leftmouse>	(gvim only) selects word under mouse as if a <cr>
			had been pressed (ie. edit file, change directory)
	<middlemouse>	(gvim only) same as P selecting word under mouse;
			see |netrw-P|
	<rightmouse>	(gvim only) delete file/directory using word under
			mouse
	<2-leftmouse>	(gvim only) when:
	                 * in a netrw-selected file, AND
		         * |g:netrw_retmap| == 1     AND
		         * the user doesn't already have a <2-leftmouse> mapping
			   defined before netrw is autoloaded,
			then a double clicked leftmouse button will return
			to the netrw browser window.  See |g:netrw_retmap|.
	<s-leftmouse>	(gvim only) like mf, will mark files

				*netrw-quickcom* *netrw-quickcoms*
QUICK REFERENCE: COMMANDS	*netrw-explore-cmds* *netrw-browse-cmds* {{{2
     :NetrwClean[!] ...........................................|netrw-clean|
     :NetrwSettings ...........................................|netrw-settings|
     :Explore[!]  [dir] Explore directory of current file......|netrw-explore|
     :Hexplore[!] [dir] Horizontal Split & Explore.............|netrw-explore|
     :Nexplore[!] [dir] Vertical Split & Explore...............|netrw-explore|
     :Pexplore[!] [dir] Vertical Split & Explore...............|netrw-explore|
     :Rexplore          Return to Explorer.....................|netrw-explore|
     :Sexplore[!] [dir] Split & Explore directory .............|netrw-explore|
     :Texplore[!] [dir] Tab & Explore..........................|netrw-explore|
     :Vexplore[!] [dir] Vertical Split & Explore...............|netrw-explore|

BOOKMARKING A DIRECTORY	*netrw-mb* *netrw-bookmark* *netrw-bookmarks* {{{2

One may easily "bookmark" a directory by using >

	mb
<
Bookmarks are retained in between sesions in a $HOME/.netrwbook file, and are
kept in sorted order.

Related Topics:
	|netrw-gb| how to return (go) to a bookmark
	|netrw-mB| how to delete bookmarks
	|netrw-qb| how to list bookmarks


BROWSING						*netrw-cr* {{{2

Browsing is simple: move the cursor onto a file or directory of interest.
Hitting the <cr> (the return key) will select the file or directory.
Directories will themselves be listed, and files will be opened using the
protocol given in the original read request.  

  CAVEAT: There are four forms of listing (see |netrw-i|).  Netrw assumes that
  two or more spaces delimit filenames and directory names for the long and
  wide listing formats.  Thus, if your filename or directory name has two or
  more sequential spaces embedded in it, or any trailing spaces, then you'll
  need to use the "thin" format to select it.

The |g:netrw_browse_split| option, which is zero by default, may be used to
cause the opening of files to be done in a new window or tab instead of the
default.  When the option is one or two, the splitting will be taken
horizontally or vertically, respectively.  When the option is set to three, a
<cr> will cause the file to appear in a new tab.


When using the gui (gvim) one may select a file by pressing the <leftmouse>
button.  In addtion, if

 *|g:netrw_retmap| == 1      AND   (its default value is 0)
 * in a netrw-selected file, AND
 * the user doesn't already have a <2-leftmouse> mapping defined before
   netrw is loaded

then a doubly-clicked leftmouse button will return to the netrw browser
window.

Netrw attempts to speed up browsing, especially for remote browsing where one
may have to enter passwords, by keeping and re-using previously obtained
directory listing buffers.  The |g:netrw_fastbrowse| variable is used to
control this behavior; one may have slow browsing (no buffer re-use), medium
speed browsing (re-use directory buffer listings only for remote directories),
and fast browsing (re-use directory buffer listings as often as possible).
The price for such re-use is that when changes are made (such as new files
are introduced into a directory), the listing may become out-of-date.  One may
always refresh directory listing buffers by pressing ctrl-L (see
|netrw-ctrl-l|).


Related topics: |netrw-o| |netrw-p| |netrw-P| |netrw-t| |netrw-v|
Associated setting variables: |g:netrw_browse_split|      |g:netrw_fastbrowse|
                              |g:netrw_ftp_list_cmd| |g:netrw_ftp_sizelist_cmd|
			      |g:netrw_ftp_timelist_cmd|  |g:netrw_ssh_cmd|
			      |g:netrw_ssh_browse_reject| |g:netrw_use_noswf|


BROWSING WITH A HORIZONTALLY SPLIT WINDOW	*netrw-o* *netrw-horiz* {{{2

Normally one enters a file or directory using the <cr>.  However, the "o" map
allows one to open a new window to hold the new directory listing or file.  A
horizontal split is used.  (for vertical splitting, see |netrw-v|)

Normally, the o key splits the window horizontally with the new window and
cursor at the top.  To change to splitting the window horizontally with the
new window and cursor at the bottom, have

	let g:netrw_alto = 1

in your <.vimrc>.  (also see |netrw-t| |netrw-v|)

There is only one tree listing buffer; using "o" on a displayed subdirectory 
will split the screen, but the same buffer will be shown twice.

Associated setting variables: |g:netrw_alto| |g:netrw_winsize|


BROWSING WITH A NEW TAB				*netrw-t* {{{2

Normally one enters a file or directory using the <cr>.  The "t" map
allows one to open a new window hold the new directory listing or file in a
new tab. (also see: |netrw-o| |netrw-v|)


BROWSING WITH A VERTICALLY SPLIT WINDOW			*netrw-v* {{{2

Normally one enters a file or directory using the <cr>.  However, the "v" map
allows one to open a new window to hold the new directory listing or file.  A
vertical split is used.  (for horizontal splitting, see |netrw-o|)

Normally, the v key splits the window vertically with the new window and
cursor at the left.  To change to splitting the window vertically with the new
window and cursor at the right, have

	let g:netrw_altv = 1

in your <.vimrc>.  (also see: |netrw-o| |netrw-t|)

There is only one tree listing buffer; using "v" on a displayed subdirectory 
will split the screen, but the same buffer will be shown twice.

Associated setting variable: |g:netrw_altv| |g:netrw_winsize|

CHANGE LISTING STYLE					*netrw-i* {{{2

The "i" map cycles between the thin, long, wide, and tree listing formats.

The short listing format gives just the files' and directories' names.

The long listing is either based on the "ls" command via ssh for remote
directories or displays the filename, file size (in bytes), and the time and
date of last modification for local directories.  With the long listing
format, netrw is not able to recognize filenames which have trailing spaces.
Use the thin listing format for such files.

The wide listing format uses two or more contiguous spaces to delineate
filenames; when using that format, netrw won't be able to recognize or use
filenames which have two or more contiguous spaces embedded in the name or any
trailing spaces.  The thin listing format will, however, work with such files.
This listing format is the most compact.

The tree listing format has a top directory followed by files and directories
preceded by a "|".  One may open and close directories by pressing the <cr>
key while atop the directory name.  There is only one tree listing buffer;
hence, using "v" or "o" on a subdirectory will only show the same buffer,
twice.

Associated setting variables: |g:netrw_liststyle| |g:netrw_maxfilenamelen|
                              |g:netrw_timefmt|   |g:netrw_list_cmd|


CHANGING TO A BOOKMARKED DIRECTORY			*netrw-gb*  {{{2

To change directory back to a bookmarked directory, use

	{cnt}gb

Any count may be used to reference any of the bookmarks.

Related Topics:
	|netrw-mB| how to delete bookmarks
	|netrw-mb| how to return to a bookmark
	|netrw-qb| how to list bookmarks


CHANGING TO A PREDECESSOR DIRECTORY	*netrw-u* *netrw-updir* {{{2

Every time you change to a new directory (new for the current session),
netrw will save the directory in a recently-visited directory history
list (unless g:netrw_dirhistmax is zero; by default, it's ten).  With the
"u" map, one can change to an earlier directory (predecessor).  To do
the opposite, see |netrw-U|.


CHANGING TO A SUCCESSOR DIRECTORY		*netrw-U* *netrw-downdir* {{{2

With the "U" map, one can change to a later directory (successor).
This map is the opposite of the "u" map. (see |netrw-u|)  Use the
q map to list both the bookmarks and history. (see |netrw-qb|)


NETRW CLEAN					*netrw-clean* *:NetrwClean*

With :NetrwClean one may easily remove netrw from one's home directory;
more precisely, from the first directory on your |'runtimepath'|.

With :NetrwClean!, netrw will remove netrw from all directories on your
|'runtimepath'|.

With either form of the command, netrw will first ask for confirmation
that the removal is in fact what you want to do.  If netrw doesn't have
permission to remove a file, it will issue an error message.

						*netrw-gx*
CUSTOMIZING BROWSING WITH A USER FUNCTION	*netrw-x* *netrw-handler* {{{2
						(also see |netrw_filehandler|)

Certain files, such as html, gif, jpeg, (word/office) doc, etc, files, are
best seen with a special handler (ie. a tool provided with your computer).
Netrw allows one to invoke such special handlers by: >

	* when Exploring, hit the "x" key
	* when editing, hit gx with the cursor atop the special filename
<	  (not available if the |g:netrw_nogx| variable exists)

Netrw determines which special handler by the following method:

  * if |g:netrw_browsex_viewer| exists, then it will be used to attempt to
    view files.  Examples of useful settings (place into your <.vimrc>): >

	:let g:netrw_browsex_viewer= "kfmclient exec"
<   or >
	:let g:netrw_browsex_viewer= "gnome-open"
<
    If g:netrw_browsex_viewer == '-', then netrwFileHandler() will be
    invoked first (see |netrw_filehandler|).

  * for Windows 32 or 64, the url and FileProtocolHandler dlls are used.  
  * for Gnome (with gnome-open): gnome-open is used.
  * for KDE (with kfmclient)   : kfmclient is used.
  * for Mac OS X               : open is used.
  * otherwise the netrwFileHandler plugin is used.

The file's suffix is used by these various approaches to determine an
appropriate application to use to "handle" these files.  Such things as
OpenOffice (*.sfx), visualization (*.jpg, *.gif, etc), and PostScript (*.ps,
*.eps) can be handled.

							*netrw_filehandler*

The "x" map applies a function to a file, based on its extension.  Of course,
the handler function must exist for it to be called!
>
 Ex. mypgm.html   x ->
                  NFH_html("scp://user@host/some/path/mypgm.html")
<
Users may write their own netrw File Handler functions to support more
suffixes with special handling.  See <plugin/netrwFileHandlers.vim> for
examples on how to make file handler functions.   As an example: >

	" NFH_suffix(filename)
	fun! NFH_suffix(filename)
	..do something special with filename..
	endfun
<
These functions need to be defined in some file in your .vim/plugin
(vimfiles\plugin) directory.  Vim's function names may not have punctuation
characters (except for the underscore) in them.  To support suffices that
contain such characters, netrw will first convert the suffix using the
following table: >

    @ -> AT       ! -> EXCLAMATION    % -> PERCENT  
    : -> COLON    = -> EQUAL          ? -> QUESTION 
    , -> COMMA    - -> MINUS          ; -> SEMICOLON
    $ -> DOLLAR   + -> PLUS           ~ -> TILDE    
<    
So, for example: >

	file.rcs,v  ->  NFH_rcsCOMMAv()
<
If more such translations are necessary, please send me email: >
		NdrOchip at ScampbellPfamily.AbizM - NOSPAM
with a request.

Associated setting variable: |g:netrw_browsex_viewer|

							*netrw-curdir*
DELETING BOOKMARKS					*netrw-mB* {{{2

To delete a bookmark, use >

	{cnt}mB
<
Related Topics:
	|netrw-gb| how to return (go) to a bookmark
	|netrw-mb| how to make a bookmark
	|netrw-qb| how to list bookmarks


DELETING FILES OR DIRECTORIES	*netrw-delete* *netrw-D* *netrw-del* {{{2

If files have not been marked with |netrw-mf|:   (local marked file list)

    Deleting/removing files and directories involves moving the cursor to the
    file/directory to be deleted and pressing "D".  Directories must be empty
    first before they can be successfully removed.  If the directory is a
    softlink to a directory, then netrw will make two requests to remove the
    directory before succeeding.  Netrw will ask for confirmation before doing
    the removal(s).  You may select a range of lines with the "V" command
    (visual selection), and then pressing "D".

If files have been marked with |netrw-mf|:   (local marked file list)

    Marked files (and empty directories) will be deleted; again, you'll be
    asked to confirm the deletion before it actually takes place.

The |g:netrw_rm_cmd|, |g:netrw_rmf_cmd|, and |g:netrw_rmdir_cmd| variables are
used to control the attempts to remove files and directories.  The
g:netrw_rm_cmd is used with files, and its default value is:

	g:netrw_rm_cmd: ssh HOSTNAME rm

The g:netrw_rmdir_cmd variable is used to support the removal of directories.
Its default value is:

	g:netrw_rmdir_cmd: ssh HOSTNAME rmdir

If removing a directory fails with g:netrw_rmdir_cmd, netrw then will attempt
to remove it again using the g:netrw_rmf_cmd variable.  Its default value is:

	g:netrw_rmf_cmd: ssh HOSTNAME rm -f

Associated setting variable: |g:netrw_local_rmdir| |g:netrw_rm_cmd|
                             |g:netrw_rmdir_cmd|   |g:netrw_ssh_cmd|


*netrw-explore*  *netrw-hexplore* *netrw-nexplore* *netrw-pexplore*
*netrw-rexplore* *netrw-sexplore* *netrw-texplore* *netrw-vexplore*
DIRECTORY EXPLORATION COMMANDS  {{{2

     :[N]Explore[!]   [dir]... Explore directory of current file     *:Explore*
     :[N]Hexplore[!]  [dir]... Horizontal Split & Explore            *:Hexplore*
     :Rexplore             ... Return to Explorer                    *:Rexplore*
     :[N]Sexplore[!]  [dir]... Split&Explore current file's directory*:Sexplore*
     :Texplore        [dir]... Tab              & Explore            *:Texplore*
     :[N]Vexplore[!]  [dir]... Vertical   Split & Explore            *:Vexplore*

     Used with :Explore **/pattern : (also see |netrw-starstar|)
     :Nexplore............. go to next matching file                *:Nexplore*
     :Pexplore............. go to previous matching file            *:Pexplore*

:Explore  will open the local-directory browser on the current file's
          directory (or on directory [dir] if specified).  The window will be
	  split only if the file has been modified, otherwise the browsing
	  window will take over that window.  Normally the splitting is taken
	  horizontally.
:Explore! is like :Explore, but will use vertical splitting.
:Sexplore will always split the window before invoking the local-directory
          browser.  As with Explore, the splitting is normally done
	  horizontally.
:Sexplore! [dir] is like :Sexplore, but the splitting will be done vertically.
:Hexplore  [dir] does an :Explore with |:belowright| horizontal splitting.
:Hexplore! [dir] does an :Explore with |:aboveleft|  horizontal splitting.
:Vexplore  [dir] does an :Explore with |:leftabove|  vertical splitting.
:Vexplore! [dir] does an :Explore with |:rightbelow| vertical splitting.
:Texplore  [dir] does a tabnew before generating the browser window

By default, these commands use the current file's directory.  However, one may
explicitly provide a directory (path) to use.

The [N] will override |g:netrw_winsize| to specify the quantity of rows and/or
columns the new explorer window should have.

Otherwise, the |g:netrw_winsize| variable, if it has been specified by the
user, is used to control the quantity of rows and/or columns new explorer
windows should have.

:Rexplore  This command is a little different from the others.  When one
           edits a file, for example by pressing <cr> when atop a file in
	   a netrw browser window, :Rexplore will return the display to
	   that of the last netrw browser window.  Its a command version
	   of <2-leftmouse> (which is only available under gvim and
	   cooperative terms).


*netrw-star* *netrw-starpat* *netrw-starstar* *netrw-starstarpat*
EXPLORING WITH STARS AND PATTERNS

When Explore, Sexplore, Hexplore, or Vexplore are used with one of the
following four styles, Explore generates a list of files which satisfy
the request. >

    */filepat	files in current directory which satisfy filepat
    **/filepat	files in current directory or below which satisfy the
    		file pattern
    *//pattern	files in the current directory which contain the
    		pattern (vimgrep is used)
    **//pattern	files in the current directory or below which contain
    		the pattern (vimgrep is used)
<
The cursor will be placed on the first file in the list.  One may then
continue to go to subsequent files on that list via |:Nexplore| or to
preceding files on that list with |:Pexplore|.  Explore will update the
directory and place the cursor appropriately.

A plain >
	:Explore
will clear the explore list.

If your console or gui produces recognizable shift-up or shift-down sequences,
then you'll likely find using shift-downarrow and shift-uparrow convenient.
They're mapped by netrw:

	<s-down>  == Nexplore, and
	<s-up>    == Pexplore.

As an example, consider
>
	:Explore */*.c
	:Nexplore
	:Nexplore
	:Pexplore
<
The status line will show, on the right hand side of the status line, a
message like "Match 3 of 20".

Associated setting variables: |g:netrw_keepdir|      |g:netrw_browse_split|
                              |g:netrw_fastbrowse|   |g:netrw_ftp_browse_reject|
			      |g:netrw_ftp_list_cmd| |g:netrw_ftp_sizelist_cmd|
			      |g:netrw_ftp_timelist_cmd| |g:netrw_list_cmd|
			      |g:netrw_liststyle|


DISPLAYING INFORMATION ABOUT FILE				*netrw-qf* {{{2

With the cursor atop a filename, pressing "qf" will reveal the file's size
and last modification timestamp.  Currently this capability is only available
for local files.


EDIT FILE OR DIRECTORY HIDING LIST	*netrw-ctrl-h* *netrw-edithide* {{{2

The "<ctrl-h>" map brings up a requestor allowing the user to change the
file/directory hiding list contained in |g:netrw_list_hide|.  The hiding list
consists of one or more patterns delimited by commas.  Files and/or
directories satisfying these patterns will either be hidden (ie. not shown) or
be the only ones displayed (see |netrw-a|).

The "gh" mapping (see |netrw-gh|) quickly alternates between the usual
hiding list and the hiding of files or directories that begin with ".".

Associated setting variables: |g:netrw_hide| |g:netrw_list_hide|
Associated topics: |netrw-a| |netrw-gh| |netrw-mh|


EDITING THE SORTING SEQUENCE		*netrw-S* *netrw-sortsequence* {{{2

When "Sorted by" is name, one may specify priority via the sorting sequence
(g:netrw_sort_sequence).  The sorting sequence typically prioritizes the
name-listing by suffix, although any pattern will do.  Patterns are delimited
by commas.  The default sorting sequence is (all one line):
>
	'[\/]$,\.[a-np-z]$,\.h$,\.c$,\.cpp$,*,\.o$,\.obj$,\.info$,
	\.swp$,\.bak$,\~$'
<
The lone * is where all filenames not covered by one of the other patterns
will end up.  One may change the sorting sequence by modifying the
g:netrw_sort_sequence variable (either manually or in your <.vimrc>) or by
using the "S" map.

Related topics:               |netrw-s|               |netrw-S|
Associated setting variables: |g:netrw_sort_sequence| |g:netrw_sort_options|


GOING UP							*netrw--* {{{2

To go up a directory, press "-" or press the <cr> when atop the ../ directory
entry in the listing.

Netrw will use the command in |g:netrw_list_cmd| to perform the directory
listing operation after changing HOSTNAME to the host specified by the
user-provided url.  By default netrw provides the command as:

	ssh HOSTNAME ls -FLa

where the HOSTNAME becomes the [user@]hostname as requested by the attempt to
read.  Naturally, the user may override this command with whatever is
preferred.  The NetList function which implements remote browsing
expects that directories will be flagged by a trailing slash.


HIDING FILES OR DIRECTORIES			*netrw-a* *netrw-hiding* {{{2

Netrw's browsing facility allows one to use the hiding list in one of three
ways: ignore it, hide files which match, and show only those files which
match.

If no files have been marked via |netrw-mf|:

The "a" map allows the user to cycle through the three hiding modes.

The |g:netrw_list_hide| variable holds a comma delimited list of patterns
based on regular expressions (ex. ^.*\.obj$,^\.) which specify the hiding list.
(also see |netrw-ctrl-h|)  To set the hiding list, use the <c-h> map.  As an
example, to hide files which begin with a ".", one may use the <c-h> map to
set the hiding list to '^\..*' (or one may put let g:netrw_list_hide= '^\..*'
in one's <.vimrc>).  One may then use the "a" key to show all files, hide
matching files, or to show only the matching files.

	Example: \.[ch]$
		This hiding list command will hide/show all *.c and *.h files.

	Example: \.c$,\.h$
		This hiding list command will also hide/show all *.c and *.h
		files.

Don't forget to use the "a" map to select the mode (normal/hiding/show) you
want!

If files have been marked using |netrw-mf|, then this command will:

  if showing all files or non-hidden files:
   modify the g:netrw_list_hide list by appending the marked files to it
   and showing only non-hidden files.

  else if showing hidden files only:
   modify the g:netrw_list_hide list by removing the marked files from it
   and showing only non-hidden files.
  endif

					*netrw-gh* *netrw-hide*
As a quick shortcut, one may press >
	gh
to toggle between hiding files which begin with a period (dot) and not hiding
them.

Associated setting variable: |g:netrw_list_hide|
Associated topics: |netrw-a| |netrw-ctrl-h| |netrw-mh|

IMPROVING BROWSING			*netrw-listhack* *netrw-ssh-hack* {{{2

Especially with the remote directory browser, constantly entering the password
is tedious.

For Linux/Unix systems, the book "Linux Server Hacks - 100 industrial strength
tips & tools" by Rob Flickenger (O'Reilly, ISBN 0-596-00461-3) gives a tip
for setting up no-password ssh and scp and discusses associated security
issues.  It used to be available at http://hacks.oreilly.com/pub/h/66 ,
but apparently that address is now being redirected to some "hackzine".
I'll attempt a summary based on that article and on a communication from
Ben Schmidt:

	1. Generate a public/private key pair on the local machine
	   (ssh client): >
		ssh-keygen -t rsa
		(saving the file in ~/.ssh/id_rsa as prompted)
<
	2. Just hit the <CR> when asked for passphrase (twice) for no
	   passphrase.  If you do use a passphrase, you will also need to use
	   ssh-agent so you only have to type the passphrase once per session.
	   If you don't use a passphrase, simply logging onto your local
	   computer or getting access to the keyfile in any way will suffice
	   to access any ssh servers which have that key authorized for login.

	3. This creates two files: >
		~/.ssh/id_rsa
		~/.ssh/id_rsa.pub
<
	4. On the target machine (ssh server): >
		cd
		mkdir -p .ssh
		chmod 0700 .ssh
<
	5. On your local machine (ssh client): (one line) >
		ssh {serverhostname}
		  cat '>>' '~/.ssh/authorized_keys2' < ~/.ssh/id_rsa.pub
<
	   or, for OpenSSH, (one line) >
		ssh {serverhostname}
		  cat '>>' '~/.ssh/authorized_keys' < ~/.ssh/id_rsa.pub
<
You can test it out with >
	ssh {serverhostname}
and you should be log onto the server machine without further need to type
anything.

If you decided to use a passphrase, do: >
	ssh-agent $SHELL
	ssh-add
	ssh {serverhostname}
You will be prompted for your key passphrase when you use ssh-add, but not
subsequently when you use ssh.  For use with vim, you can use >
	ssh-agent vim
and, when next within vim, use >
	:!ssh-add
Alternatively, you can apply ssh-agent to the terminal you're planning on
running vim in: >
	ssh-agent xterm &
and do ssh-add whenever you need.

For Windows, folks on the vim mailing list have mentioned that Pageant helps
with avoiding the constant need to enter the password.

Kingston Fung wrote about another way to avoid constantly needing to enter
passwords:

    In order to avoid the need to type in the password for scp each time, you
    provide a hack in the docs to set up a non password ssh account. I found a
    better way to do that: I can use a regular ssh account which uses a
    password to access the material without the need to key-in the password
    each time. It's good for security and convenience. I tried ssh public key
    authorization + ssh-agent, implementing this, and it works! Here are two
    links with instructions:

    http://www.ibm.com/developerworks/library/l-keyc2/
    http://sial.org/howto/openssh/publickey-auth/


LISTING BOOKMARKS AND HISTORY		*netrw-qb* *netrw-listbookmark* {{{2

Pressing "qb" (query bookmarks) will list both the bookmarked directories and
directory traversal history.

Related Topics:
	|netrw-gb| how to return (go) to a bookmark
	|netrw-mb| how to make a bookmark
	|netrw-mB| how to delete bookmarks
	|netrw-u|  change to a predecessor directory via the history stack
	|netrw-U|  change to a successor   directory via the history stack

MAKING A NEW DIRECTORY					*netrw-d* {{{2

With the "d" map one may make a new directory either remotely (which depends
on the global variable g:netrw_mkdir_cmd) or locally (which depends on the
global variable g:netrw_local_mkdir).  Netrw will issue a request for the new
directory's name.  A bare <CR> at that point will abort the making of the
directory.  Attempts to make a local directory that already exists (as either
a file or a directory) will be detected, reported on, and ignored.

Currently, making a directory via ftp is not supported.

Associated setting variable: |g:netrw_local_mkdir| |g:netrw_mkdir_cmd|


MAKING THE BROWSING DIRECTORY THE CURRENT DIRECTORY	*netrw-c* {{{2

By default, |g:netrw_keepdir| is 1.  This setting means that the current
directory will not track the browsing directory.

Setting g:netrw_keepdir to 0 tells netrw to make vim's current directory to
track netrw's browsing directory.

However, given the default setting for g:netrw_keepdir of 1 where netrw
maintains its own separate notion of the current directory, in order to make
the two directories the same, use the "c" map (just type c).  That map will
set Vim's notion of the current directory to netrw's current browsing
directory.

Associated setting variable: |g:netrw_keepdir|

MARKING FILES							*netrw-mf* {{{2
	(also see |netrw-mr|)

One may mark files with the cursor atop a filename and then pressing "mf".
With gvim, one may also mark files with <s-leftmouse>.  The following netrw
maps make use of marked files:

    |netrw-a|	Hide marked files/directories
    |netrw-D|	Delete marked files/directories
    |netrw-mc|	Copy marked files to target
    |netrw-md|	Apply vimdiff to marked files
    |netrw-me|	Edit marked files
    |netrw-mg|	Apply vimgrep to marked files
    |netrw-mm|	Move marked files
    |netrw-mp|	Print marked files
    |netrw-mt|	Set target for |netrw-mm| and |netrw-mc|
    |netrw-mT|	Generate tags using marked files
    |netrw-mx|	Apply shell command to marked files
    |netrw-mz|	Compress/Decompress marked files
    |netrw-O|	Obtain marked files
    |netrw-R|	Rename marked files

One may unmark files one at a time the same way one marks them; ie. place
the cursor atop a marked file and press "mf".  This process also works
with <s-leftmouse> using gvim.  One may unmark all files by pressing
"mu" (see |netrw-mu|).

*markfilelist* *global_markfilelist* *local_markfilelist*
All marked files are entered onto the global marked file list; there is only
one such list.  In addition, every netrw buffer also has its own local marked
file list; since netrw buffers are associated with specific directories, this
means that each directory has its own local marked file list.  The various
commands which operate on marked files use one or the other of the marked file
lists.


MARKING FILES BY REGULAR EXPRESSION				*netrw-mr* {{{2
	(also see |netrw-mf|)

One may also mark files by pressing "mr"; netrw will then issue a prompt,
"Enter regexp: ".  You may then enter a regular expression such as \.c$ .
All files in the current directory will then be marked.  Note that the
regular expressions are vim-style |regexp| ones, not shell ones.  So
entering *.c probably isn't what you want!


MARKED FILES: ARBITRARY COMMAND				*netrw-mx* {{{2
	    (See |netrw-mf| and |netrw-mr| for how to mark files)
		      (uses the local marked-file list)

Upon activation of the "mx" map, netrw will query the user for some (external)
command to be applied to all marked files.  All "%"s in the command will be
substituted with the name of each marked file in turn.  If no "%"s are in the
command, then the command will be followed by a space and a marked filename.


MARKED FILES: COMPRESSION AND DECOMPRESSION		*netrw-mz* {{{2
	    (See |netrw-mf| and |netrw-mr| for how to mark files)
		      (uses the local marked file list)

If any marked files are compressed,   then "mz" will decompress them.
If any marked files are decompressed, then "mz" will compress them
using the command specified by |g:netrw_compress|; by default,
that's "gzip".

For decompression, netrw provides a |Dictionary| of suffices and their
associated decompressing utilities; see |g:netrw_decompress|.

Associated setting variables: |g:netrw_compress| |g:netrw_decompress|

MARKED FILES: COPYING						*netrw-mc* {{{2
	    (See |netrw-mf| and |netrw-mr| for how to mark files)
		      (Uses the global marked file list)

Select a target directory with mt (|netrw-mt|).  Then change directory,
select file(s) (see |netrw-mf|), and press "mc".

Associated setting variable: |g:netrw_localcopycmd| |g:netrw_ssh_cmd|

MARKED FILES: DIFF						*netrw-md* {{{2
	    (See |netrw-mf| and |netrw-mr| for how to mark files)
		      (uses the global marked file list)

Use |vimdiff| to visualize difference between selected files (two or
three may be selected for this).  Uses the global marked file list.

MARKED FILES: EDITING						*netrw-me* {{{2
	    (See |netrw-mf| and |netrw-mr| for how to mark files)
		      (uses the global marked file list)

This command will place the marked files on the |arglist| and commence
editing them.  One may return the to explorer window with |:Rexplore|.

MARKED FILES: GREP						*netrw-mg* {{{2
	    (See |netrw-mf| and |netrw-mr| for how to mark files)
		      (uses the global marked file list)

This command will apply |:vimgrep| to the marked files.  The command will ask
for the requested pattern; one may enter: >
	/pattern/[g][j]
	! /pattern/[g][j]
	pattern
<
MARKED FILES: HIDING AND UNHIDING BY SUFFIX			*netrw-mh* {{{2
	    (See |netrw-mf| and |netrw-mr| for how to mark files)
		      (uses the local marked file list)

This command extracts the suffices of the marked files and toggles their
presence on the hiding list.  Please note that marking the same suffix
this way multiple times will result in the suffix's presence being toggled
for each file (so an even quantity of marked files having the same suffix
is the same as not having bothered to select them at all).

Related topics: |netrw-a| |g:netrw_list_hide|

MARKED FILES: MOVING						*netrw-mm* {{{2
	    (See |netrw-mf| and |netrw-mr| for how to mark files)
		      (uses the global marked file list)

	WARNING: moving files is more dangerous than copying them.
	A file being moved is first copied and then deleted; if the
	copy operation fails and the delete succeeds, you will lose
	the file.  Either try things out with unimportant files
	first or do the copy and then delete yourself using mc and D.
	Use at your own risk!

Select a target directory with mT (|netrw-mt|).  Then change directory,
select file(s) (see |netrw-mf|), and press "mm".

Associated setting variable: |g:netrw_localmovecmd| |g:netrw_ssh_cmd|

MARKED FILES: PRINTING						*netrw-mp* {{{2
	    (See |netrw-mf| and |netrw-mr| for how to mark files)
		      (uses the local marked file list)

Netrw will apply the |:hardcopy| command to marked files.  What it does
is open each file in a one-line window, execute hardcopy, then close the
one-line window.


MARKED FILES: SOURCING						*netrw-ms* {{{2
	    (See |netrw-mf| and |netrw-mr| for how to mark files)
		      (uses the local marked file list)

Netrw will source the marked files (using vim's |:source| command)


MARKED FILES: TAGGING						*netrw-mT* {{{2
	    (See |netrw-mf| and |netrw-mr| for how to mark files)
		      (uses the global marked file list)

The "mt" mapping will apply the command in |g:netrw_ctags| (by default, its
"ctags") to marked files.  For remote browsing, in order to create a tags file
netrw will use ssh (see |g:netrw_ssh_cmd|), and so ssh must be available for
this to work on remote systems.  For your local system, see |ctags| on how to
get a version.  I myself use hdrtags, currently available at
http://mysite.verizon.net/astronaut/src/index.html , and have >

	let g:netrw_ctags= "hdrtag"
<
in my <.vimrc>.

When a remote set of files are tagged, the resulting tags file is "obtained";
ie. a copy is transferred to the local system's directory.  The local tags
file is then modified so that one may use it through the network.  The
modification is concerns the names of the files in the tags; each filename is
preceded by the netrw-compatible url used to obtain it.  When one subsequently
uses one of the go to tag actions (|tags|), the url will be used by netrw to
edit the desired file and go to the tag.

Associated setting variables: |g:netrw_ctags| |g:netrw_ssh_cmd|


MARKED FILES: SETTING THE TARGET DIRECTORY			*netrw-mt* {{{2
     (See |netrw-mf| and |netrw-mr| for how to mark files)

Set the marked file copy/move-to target (see |netrw-mc| and |netrw-mm|):

  * if the cursor is atop a file name, then the netrw window's currently
    displayed directory is used for the copy/move-to target.

  * also, if the cursor is in the banner, then the netrw window's currently
    displayed directory is used for the copy/move-to target.

  * however, if the cursor is atop a directory name, then that directory is
    used for the copy/move-to target

There is only one copy/move-to target per vim session; ie. the target is a
script variable (see |s:var|) and is shared between all netrw windows (in an
instance of vim).

MARKED FILES: UNMARKING						*netrw-mu* {{{2
     (See |netrw-mf| and |netrw-mr| for how to mark files)

The "mu" mapping will unmark all currently marked files.


NETRW BROWSER VARIABLES		*netrw-browser-options* *netrw-browser-var* {{{2

(if you're interestd in the netrw file transfer settings, see |netrw-options|)

The <netrw.vim> browser provides settings in the form of variables which
you may modify; by placing these settings in your <.vimrc>, you may customize
your browsing preferences.  (see also: |netrw-settings|)
>
   ---				-----------
   Var				Explanation
   ---				-----------
< *g:netrw_alto*		change from above splitting to below splitting
				by setting this variable (see |netrw-o|)
				 default: =&sb           (see |'sb'|)

  *g:netrw_altv*		change from left splitting to right splitting
				by setting this variable (see |netrw-v|)
				 default: =&spr          (see |'spr'|)

  *g:netrw_browse_split*	when browsing, <cr> will open the file by:
				=0: re-using the same window
				=1: horizontally splitting the window first  
				=2: vertically   splitting the window first  
				=3: open file in new tab
				=4: act like "P" (ie. open previous window)

  *g:netrw_browsex_viewer*	specify user's preference for a viewer: >
					"kfmclient exec"
					"gnome-open"
<				If >
					"-"
<				is used, then netrwFileHandler() will look for
				a script/function to handle the given
				extension.  (see |netrw_filehandler|).

  *g:netrw_compress*		="gzip"
				    Will compress marked files with this
				    command

  *g:netrw_ctags*		="ctags"
				The default external program used to create tags

  *g:netrw_cursorline*		= 1 (default)
				will use the |'cursorline'| local setting when
				|g:netrw_liststyle| ==0 (thin listing) or
				|g:netrw_liststyle| ==1 (long listing) or
				|g:netrw_liststyle| ==3 (tree listing)
				=0: off
				=2: like ==1, but the wide listing gets both
				cursorline and |'cursorcolumn'|locally set
				(ie. doesn't affect the wide listing)

  *g:netrw_decompress*		= { ".gz" : "gunzip" ,
				    ".bz2" : "bunzip2" ,
				    ".zip" : "unzip" ,
				    ".tar" : "tar -xf"}
				  A dictionary mapping suffices to
				  decompression programs.

  *g:netrw_fastbrowse*		=0: slow speed directory browsing;
				    never re-uses directory listings,
				    always obtains directory listings.
				=1: medium speed directory browsing;
				    re-use directory listings only
				    when remote directory browsing.
				    (default value)
				=2: fast directory browsing;
				    only obtains directory listings when the
				    directory hasn't been seen before
				    (or |netrw-ctrl-l| is used).

				Fast browsing retains old directory listing
				buffers so that they don't need to be
				re-acquired.  This feature is especially
				important for remote browsing.  However, if
				a file is introduced or deleted into or from
				such directories, the old directory buffer
				becomes out-of-date.  One may always refresh
				such a directory listing with |netrw-ctrl-l|.
				This option gives the user the choice of
				trading off accuracy (ie. up-to-date listing)
				versus speed.

  *g:netrw_fname_escape*	=' ?&;%'
  				Used on filenames before remote reading/writing

  *g:netrw_ftp_browse_reject*	ftp can produce a number of errors and warnings
				that can show up as "directories" and "files"
				in the listing.  This pattern is used to
				remove such embedded messages.  By default its
				value is:
				 '^total\s\+\d\+$\|
				 ^Trying\s\+\d\+.*$\|
				 ^KERBEROS_V\d rejected\|
				 ^Security extensions not\|
				 No such file\|
				 : connect to address [0-9a-fA-F:]*
				 : No route to host$'

  *g:netrw_ftp_list_cmd*	options for passing along to ftp for directory
				listing.  Defaults:
				 unix or g:netrw_cygwin set: : "ls -lF"
				 otherwise                     "dir"


  *g:netrw_ftp_sizelist_cmd*	options for passing along to ftp for directory
				listing, sorted by size of file.
				Defaults:
				 unix or g:netrw_cygwin set: : "ls -slF"
				 otherwise                     "dir"

  *g:netrw_ftp_timelist_cmd*	options for passing along to ftp for directory
				listing, sorted by time of last modification.
				Defaults:
				 unix or g:netrw_cygwin set: : "ls -tlF"
				 otherwise                     "dir"

  *g:netrw_glob_escape*		='[]*?`{~$'
  				These characters in directory names are
				escaped before applying glob()

  *g:netrw_hide*		if true, the hiding list is used
				 default: =0

  *g:netrw_home*		The home directory for where bookmarks and
				history are saved (as .netrwbook and
				.netrwhist).
				 default: the first directory on the
				         |'runtimepath'|

  *g:netrw_keepdir*		=1 (default) keep current directory immune from
				   the browsing directory.
				=0 keep the current directory the same as the
				   browsing directory.
				The current browsing directory is contained in
				b:netrw_curdir (also see |netrw-c|)

  *g:netrw_list_cmd*		command for listing remote directories
				 default: (if ssh is executable)
				          "ssh HOSTNAME ls -FLa"

  *g:netrw_liststyle*		Set the default listing style:
                                = 0: thin listing (one file per line)
                                = 1: long listing (one file per line with time
				     stamp information and file size)
				= 2: wide listing (multiple files in columns)
				= 3: tree style listing
  *g:netrw_list_hide*		comma separated pattern list for hiding files
				Patterns are regular expressions (see |regexp|)
				Example: let g:netrw_list_hide= '.*\.swp$'
				 default: ""

  *g:netrw_localcopycmd*	="cp" Linux/Unix/MacOS/Cygwin
  				="copy" Windows
				Copies marked files (|netrw-mf|) to target
				directory (|netrw-mt|, |netrw-mc|)

  *g:netrw_localmovecmd*	="mv" Linux/Unix/MacOS/Cygwin
  				="move" Windows
				Moves marked files (|netrw-mf|) to target
				directory (|netrw-mt|, |netrw-mm|)

  *g:netrw_local_mkdir*		command for making a local directory
				 default: "mkdir"

  *g:netrw_local_rmdir*		remove directory command (rmdir)
				 default: "rmdir"

  *g:netrw_maxfilenamelen*	=32 by default, selected so as to make long
				    listings fit on 80 column displays.
				If your screen is wider, and you have file
				or directory names longer than 32 bytes,
				you may set this option to keep listings
				columnar.

  *g:netrw_mkdir_cmd*		command for making a remote directory
				 default: "ssh USEPORT HOSTNAME mkdir"

  *g:netrw_retmap*		if it exists and is set to one, then:
				 * if in a netrw-selected file, AND
				 * no normal-mode <2-leftmouse> mapping exists,
				then the <2-leftmouse> will be mapped for easy
				return to the netrw browser window.
				 example: click once to select and open a file,
				          double-click to return.

				Note that one may instead choose to:
				 * let g:netrw_retmap= 1, AND
				 * nmap <silent> YourChoice <Plug>NetrwReturn
				and have another mapping instead of
				<2-leftmouse> to invoke the return.

				You may also use the |:Rexplore| command to do
				the same thing.

				  default: =0

  *g:netrw_rm_cmd*		command for removing files
				 default: "ssh USEPORT HOSTNAME rm"

  *g:netrw_rmdir_cmd*		command for removing directories
				 default: "ssh USEPORT HOSTNAME rmdir"

  *g:netrw_rmf_cmd*		 command for removing softlinks
				 default: "ssh USEPORT HOSTNAME rm -f"

  *g:netrw_sort_by*		sort by "name", "time", or "size"
				 default: "name"

  *g:netrw_sort_direction*	sorting direction: "normal" or "reverse"
				 default: "normal"

  *g:netrw_sort_options*	sorting is done using |:sort|; this
				variable's value is appended to the
				sort command.  Thus one may ignore case,
				for example, with the following in your
				.vimrc: >
					let g:netrw_sort_options="i"
<				 default: ""

  *g:netrw_sort_sequence*	when sorting by name, first sort by the
				comma-separated pattern sequence
				 default: '[\/]$,*,\.bak$,\.o$,\.h$,
				           \.info$,\.swp$,\.obj$'

  *g:netrw_special_syntax*	If true, then certain files will be shown
  				in special syntax in the browser:

					netrwBak     : *.bak
					netrwCompress: *.gz *.bz2 *.Z *.zip
					netrwData    : *.dat
					netrwHdr     : *.h
					netrwLib     : *.a *.so *.lib *.dll
					netrwMakefile: [mM]akefile *.mak
					netrwObj     : *.o *.obj
					netrwTags    : tags ANmenu ANtags
					netrwTilde   : *~ 
					netrwTmp     : tmp* *tmp

				These syntax highlighting groups are linked
				to Folded or DiffChange by default
				(see |hl-Folded| and |hl-DiffChange|), but
				one may put lines like >
					hi link netrwCompress Visual
<				into one's <.vimrc> to use one's own
				preferences.

  *g:netrw_ssh_cmd*		One may specify an executable command
				to use instead of ssh for remote actions
				such as listing, file removal, etc.
				 default: ssh

  *g:netrw_ssh_browse_reject*	ssh can sometimes produce unwanted lines,
				messages, banners, and whatnot that one doesn't
				want masquerading as "directories" and "files".
				Use this pattern to remove such embedded
				messages.  By default its value is:
					 '^total\s\+\d\+$'


  *g:netrw_tmpfile_escape*	=' &;'
  				escape() is applied to all temporary files
				to escape these characters.

  *g:netrw_timefmt*		specify format string to vim's strftime().
				The default, "%c", is "the preferred date
				and time representation for the current
				locale" according to my manpage entry for
				strftime(); however, not all are satisfied
				with it.  Some alternatives:
				 "%a %d %b %Y %T",
				 " %a %Y-%m-%d  %I-%M-%S %p"
				 default: "%c"

  *g:netrw_use_noswf*		netrw normally avoids writing swapfiles
  				for browser buffers.  However, under some
				systems this apparently is causing nasty
				ml_get errors to appear; if you're getting
				ml_get errors, try putting
				  let g:netrw_use_noswf= 0
				in your .vimrc.

  *g:netrw_winsize*		specify initial size of new windows made with
				"o" (see |netrw-o|), "v" (see |netrw-v|),
				|:Hexplore| or |:Vexplore|.
				 default: ""

  *g:netrw_xstrlen*		Controls how netrw computes a string
  				including multi-byte characters' string
				length. (thanks to N Weibull, T Mechelynck)
				=0: uses Vim's built-in strlen()
				=1: number of codepoints (Latin + a combining
				    circumflex is two codepoints)  (DEFAULT)
				=2: number of spacing codepoints (Latin a +
				    combining circumflex is one spacing 
				    codepoint; a hard tab is one; wide and
				    narrow CJK are one each; etc.)
				=3: virtual length (counting tabs as anything
				    between 1 and |'tabstop'|, wide CJJK as 2
				    rather than 1, Arabic alif as zero when
				    immediately preceded by lam, one
				    otherwise, etc)

  *g:NetrwTopLvlMenu*		This variable specifies the top level
				menu name; by default, it's "Netrw.".  If
				you wish to change this, do so in your
				.vimrc.

NETRW BROWSING AND OPTION INCOMPATIBILITIES	*netrw-incompatible* {{{2

Netrw has been designed to handle user options by saving them, setting the
options to something that's compatible with netrw's needs, and then restoring
them.  However, the autochdir option: >
	:set acd
is problematical.  Autochdir sets the current directory to that containing the
file you edit; this apparently also applies to directories.  In other words,
autochdir sets the current directory to that containing the "file" (even if
that "file" is itself a directory).

NETRW SETTINGS						*netrw-settings* {{{2

With the NetrwSettings.vim plugin, >
	:NetrwSettings
will bring up a window with the many variables that netrw uses for its
settings.  You may change any of their values; when you save the file, the
settings therein will be used.  One may also press "?" on any of the lines for
help on what each of the variables do.

(also see: |netrw-browser-var| |netrw-protocol| |netrw-var| |netrw-variables|)


==============================================================================
OBTAINING A FILE					*netrw-O* {{{2

If there are no marked files:

    When browsing a remote directory, one may obtain a file under the cursor
    (ie.  get a copy on your local machine, but not edit it) by pressing the O
    key.

If there are marked files:

    The marked files will be obtained (ie. a copy will be transferred to your
    local machine, but not set up for editing).

Only ftp and scp are supported for this operation (but since these two are
available for browsing, that shouldn't be a problem).  The status bar will
then show, on its right hand side, a message like "Obtaining filename".  The
statusline will be restored after the transfer is complete.

Netrw can also "obtain" a file using the local browser.  Netrw's display
of a directory is not necessarily the same as Vim's "current directory",
unless |g:netrw_keepdir| is set to 0 in the user's <.vimrc>.  One may select
a file using the local browser (by putting the cursor on it) and pressing
"O" will then "obtain" the file; ie. copy it to Vim's current directory.

Related topics:
 * To see what the current directory is, use |:pwd|
 * To make the currently browsed directory the current directory, see |netrw-c|
 * To automatically make the currently browsed directory the current
   directory, see |g:netrw_keepdir|.


OPEN A NEW FILE IN NETRW'S CURRENT DIRECTORY		*netrw-%*

To open a file in netrw's current directory, press "%".  This map will
query the user for a new filename; an empty file by that name will be
placed in the netrw's current directory (ie. b:netrw_curdir).


PREVIEW WINDOW				*netrw-p* *netrw-preview* {{{2

One may use a preview window by using the "p" key when the cursor is atop the
desired filename to be previewed.  The display will then split to show both
the browser (where the cursor will remain) and the file (see |:pedit|).
By default, the split will be taken horizontally; one may use vertical
splitting if one has set |g:netrw_preview| first.


PREVIOUS WINDOW				*netrw-P* *netrw-prvwin* {{{2

To edit a file or directory in the previously used (last accessed) window (see
:he |CTRL-W_p|), press a "P".  If there's only one window, then the one window
will be horizontally split (above/below splitting is controlled by
|g:netrw_alto|, and its initial size is controlled by |g:netrw_winsize|).

If there's more than one window, the previous window will be re-used on
the selected file/directory.  If the previous window's associated buffer
has been modified, and there's only one window with that buffer, then
the user will be asked if s/he wishes to save the buffer first (yes,
no, or cancel).


REFRESHING THE LISTING			*netrw-ctrl-l* *netrw-ctrl_l* {{{2

To refresh either a local or remote directory listing, press ctrl-l (<c-l>) or
hit the <cr> when atop the ./ directory entry in the listing.  One may also
refresh a local directory by using ":e .".


RENAMING FILES OR DIRECTORIES	*netrw-move* *netrw-rename* *netrw-R* {{{2

If there are no marked files: (see |netrw-mf|)

    Renaming/moving files and directories involves moving the cursor to the
    file/directory to be moved (renamed) and pressing "R".  You will then be
    queried for where you want the file/directory to be moved.  You may select
    a range of lines with the "V" command (visual selection), and then
    pressing "R".

If there are marked files:  (see |netrw-mf|)

    Marked files will be renamed (moved).  You will be queried as above in
    order to specify where you want the file/directory to be moved.

    WARNING:~

    Note that moving files is a dangerous operation; copies are safer.  That's
    because a "move" for remote files is actually a copy + delete -- and if
    the copy fails and the delete does not, you may lose the file.

The g:netrw_rename_cmd variable is used to implement renaming.  By default its
value is:

	ssh HOSTNAME mv

One may rename a block of files and directories by selecting them with
the V (|linewise-visual|).


REVERSING SORTING ORDER		*netrw-r* *netrw-reverse* {{{2

One may toggle between normal and reverse sorting order by pressing the
"r" key.

Related topics:              |netrw-s|
Associated setting variable: |g:netrw_sort_direction|


SELECTING SORTING STYLE			*netrw-s* *netrw-sort* {{{2

One may select the sorting style by name, time, or (file) size.  The "s" map
allows one to circulate amongst the three choices; the directory listing will
automatically be refreshed to reflect the selected style.

Related topics:               |netrw-r| |netrw-S|
Associated setting variables: |g:netrw_sort_by| |g:netrw_sort_sequence|


10. Problems and Fixes					*netrw-problems* {{{1

	(This section is likely to grow as I get feedback)
	(also see |netrw-debug|)
								*netrw-p1*
	P1. I use windows 95, and my ftp dumps four blank lines at the
	    end of every read.

		See |netrw-fixup|, and put the following into your
		<.vimrc> file:

			let g:netrw_win95ftp= 1

								*netrw-p2*
	P2. I use Windows, and my network browsing with ftp doesn't sort by
	    time or size!  -or-  The remote system is a Windows server; why
	    don't I get sorts by time or size?

		Windows' ftp has a minimal support for ls (ie. it doesn't
		accept sorting options).  It doesn't support the -F which
		gives an explanatory character (ABC/ for "ABC is a directory").
		Netrw then uses "dir" to get both its short and long listings.
		If you think your ftp does support a full-up ls, put the
		following into your <.vimrc>: >

			let g:netrw_ftp_list_cmd    = "ls -lF"
			let g:netrw_ftp_timelist_cmd= "ls -tlF"
			let g:netrw_ftp_sizelist_cmd= "ls -slF"
<
		Alternatively, if you have cygwin on your Windows box, put
		into your <.vimrc>: >

			let g:netrw_cygwin= 1
<
		This problem also occurs when the remote system is Windows.
		In this situation, the various g:netrw_ftp_[time|size]list_cmds
		are as shown above, but the remote system will not correctly
		modify its listing behavior.


								*netrw-p3*
	P3. I tried rcp://user@host/ (or protocol other than ftp) and netrw
	    used ssh!  That wasn't what I asked for...

		Netrw has two methods for browsing remote directories: ssh
		and ftp.  Unless you specify ftp specifically, ssh is used.
		When it comes time to do download a file (not just a directory
		listing), netrw will use the given protocol to do so.

								*netrw-p4*
	P4. I would like long listings to be the default.

		Put the following statement into your |.vimrc|: >

			let g:netrw_liststyle= 1
<
		Check out |netrw-browser-var| for more customizations that
		you can set.

								*netrw-p5*
	P5. My times come up oddly in local browsing

		Does your system's strftime() accept the "%c" to yield dates
		such as "Sun Apr 27 11:49:23 1997"?  If not, do a "man strftime"
		and find out what option should be used.  Then put it into
		your |.vimrc|: >

			let g:netrw_timefmt= "%X"  (where X is the option)
<
								*netrw-p6*
	P6. I want my current directory to track my browsing.
	    How do I do that?

	    Put the following line in your |.vimrc|:
>
		let g:netrw_keepdir= 0
<	
								*netrw-p7*
	P7. I use Chinese (or other non-ascii) characters in my filenames, and
	    netrw (Explore, Sexplore, Hexplore, etc) doesn't display them!

		(taken from an answer provided by Wu Yongwei on the vim
		mailing list)
		I now see the problem. You code page is not 936, right? Vim
		seems only able to open files with names that are valid in the
		current code page, as are many other applications that do not
		use the Unicode version of Windows APIs. This is an OS-related
		issue. You should not have such problems when the system
		locale uses UTF-8, such as modern Linux distros.

		(...it is one more reason to recommend that people use utf-8!)

								*netrw-p8*
	P8. I'm getting "ssh is not executable on your system" -- what do I
	    do?

		(Dudley Fox) Most people I know use putty for windows ssh.  It
		is a free ssh/telnet application. You can read more about it
		here:

		http://www.chiark.greenend.org.uk/~sgtatham/putty/ Also:

		(Marlin Unruh) This program also works for me. It's a single
		executable, so he/she can copy it into the Windows\System32
		folder and create a shortcut to it. 

		(Dudley Fox) You might also wish to consider plink, as it
		sounds most similar to what you are looking for. plink is an
		application in the putty suite.

           http://the.earth.li/~sgtatham/putty/0.58/htmldoc/Chapter7.html#plink

	   	(Vissale Neang) Maybe you can try OpenSSH for windows, which
		can be obtained from:

		http://sshwindows.sourceforge.net/

		It doesn't need the full Cygwin package. 

		(Antoine Mechelynck) For individual Unix-like programs needed
		for work in a native-Windows environment, I recommend getting
		them from the GnuWin32 project on sourceforge if it has them:

		    http://gnuwin32.sourceforge.net/

		Unlike Cygwin, which sets up a Unix-like virtual machine on
		top of Windows, GnuWin32 is a rewrite of Unix utilities with
		Windows system calls, and its programs works quite well in the
		cmd.exe "Dos box". 

		(dave) Download WinSCP and use that to connect to the server.
		In Preferences > Editors, set gvim as your editor:

			- Click "Add..."
			- Set External Editor (adjust path as needed, include
			  the quotes and !.! at the end):
			    "c:\Program Files\Vim\vim70\gvim.exe" !.!
			- Check that the filetype in the box below is
			  {asterisk}.{asterisk} (all files), or whatever types
			  you want (cec: change {asterisk} to * ; I had to
			  write it that way because otherwise the helptags
			  system thinks it's a tag)
			- Make sure it's at the top of the listbox (click it,
			  then click "Up" if it's not)
		If using the Norton Commander style, you just have to hit <F4>
		to edit a file in a local copy of gvim.

		(Vit Gottwald) How to generate public/private key and save
		public key it on server: >
  http://www.tartarus.org/~simon/puttydoc/Chapter8.html#pubkey-gettingready
			8.3 Getting ready for public key authentication
<
		How to use a private key with 'pscp': >

			http://www.tartarus.org/~simon/puttydoc/Chapter5.html
			5.2.4 Using public key authentication with PSCP 
<
		(Ben Schmidt) I find the ssh included with cwRsync is
		brilliant, and install cwRsync or cwRsyncServer on most
		Windows systems I come across these days. I guess COPSSH,
		packed by the same person, is probably even better for use as
		just ssh on Windows, and probably includes sftp, etc. which I
		suspect the cwRsync doesn't, though it might

		(cec) To make proper use of these suggestions above, you will
		need to modify the following user-settable variables in your
		.vimrc:

		|g:netrw_ssh_cmd| |g:netrw_list_cmd|  |g:netrw_mkdir_cmd|
		|g:netrw_rm_cmd|  |g:netrw_rmdir_cmd| |g:netrw_rmf_cmd|

		The first one (|g:netrw_ssh_cmd|) is the most important; most
		of the others will use the string in g:netrw_ssh_cmd by
		default.
						*netrw-p9* *netrw-ml_get*
	P9. I'm browsing, changing directory, and bang!  ml_get errors
	    appear and I have to kill vim.  Any way around this?

		Normally netrw attempts to avoid writing swapfiles for
		its temporary directory buffers.  However, on some systems
		this attempt appears to be causing ml_get errors to
		appear.  Please try setting |g:netrw_use_noswf| to 0
		in your <.vimrc>: >
			let g:netrw_use_noswf= 0
<
								*netrw-p10*
	P10. I'm being pestered with "[something] is a directory" and
	     "Press ENTER or type command to continue" prompts...

		The "[something] is a directory" prompt is issued by Vim,
		not by netrw, and there appears to be no way to work around
		it.  Coupled with the default cmdheight of 1, this message
		causes the "Press ENTER..." prompt.  So:  read |hit-enter|;
		I also suggest that you set your |'cmdheight'| to 2 (or more) in
		your <.vimrc> file.

								*netrw-p11*
	P11. I want to have two windows; a thin one on the left and my editing
	     window on the right.  How can I do this?

		* Put the following line in your <.vimrc>:
			let g:netrw_altv = 1
		* Edit the current directory:  :e .
		* Select some file, press v
		* Resize the windows as you wish (see |CTRL-W_<| and
		  |CTRL-W_>|).  If you're using gvim, you can drag
		  the separating bar with your mouse.
		* When you want a new file, use  ctrl-w h  to go back to the
		  netrw browser, select a file, then press P  (see |CTRL-W_h|
		  and |netrw-P|).  If you're using gvim, you can press
		  <leftmouse> in the browser window and then press the
		  <middlemouse> to select the file.

==============================================================================
11. Debugging Netrw Itself				*netrw-debug* {{{1

The <netrw.vim> script is typically available as:
>
	/usr/local/share/vim/vim6x/plugin/netrwPlugin.vim
	/usr/local/share/vim/vim6x/autoload/netrw.vim
< -or- >
	/usr/local/share/vim/vim7x/plugin/netrwPlugin.vim
	/usr/local/share/vim/vim7x/autoload/netrw.vim
<
which is loaded automatically at startup (assuming :set nocp).

	1. Get the <Decho.vim> script, available as:

	     http://mysite.verizon.net/astronaut/vim/index.html#DECHO
	   or
	     http://vim.sourceforge.net/scripts/script.php?script_id=120

	  It now comes as a "vimball"; if you're using vim 7.0 or earlier,
	  you'll need to update vimball, too.  See
	     http://mysite.verizon.net/astronaut/vim/index.html#VIMBALL

	2. Edit the <netrw.vim> file by typing: >

		vim netrw.vim
		:DechoOn
		:wq
<
	   To restore to normal non-debugging behavior, re-edit <netrw.vim>
	   and type >

		vim netrw.vim
		:DechoOff
		:wq
<
	   This command, provided by <Decho.vim>, will comment out all
	   Decho-debugging statements (Dfunc(), Dret(), Decho(), Dredir()).

	3. Then bring up vim and attempt to evoke the problem by doing a
	   transfer or doing some browsing.  A set of messages should appear
	   concerning the steps that <netrw.vim> took in attempting to
	   read/write your file over the network in a separate tab.

	   To save the file, use >
		:wincmd j
		:set bt=
		:w! DBG
<	   Please send that information to <netrw.vim>'s maintainer, >
		NdrOchip at ScampbellPfamily.AbizM - NOSPAM
<
==============================================================================
12. History						*netrw-history* {{{1

	v134: Sep 30, 2008 * (Sander Marechal) provided a bugfix involving
			     the use of the |netrw-t| command with a remote
			     directory.
	      Sep 30, 2008 * using "x" on a remote jpg was failing; fixed.
	      Oct 03, 2008 * bookmarks now go on a list and are stored to
			     the first directory on the |'runtimepath'| in
			     the hopes of making their retention reliable.
			     History now also goes to that directory.
	      Oct 07, 2008 * Included check that vim 7.0 or later is in use.
	      Oct 07, 2008 * Improved |g:netrw_retmap| handling.
	      Oct 12, 2008 * Based upon Sébastien Migniot's suggestion, if
			     cadaver isn't available then netrw will try to
			     use curl for the dav://... protocol.
	      Oct 13, 2008 * added @*/ to netrw buffers' |'iskeyword'|setting
			     This lets mf (|netrw-mf|) mark directories, links
			     and executables.
	      Oct 13, 2008 * avoids a second NetrwBrowse() refresh when
			     g:netrw_fastbrowse is <= 1 (slow, medium speed)
	      Oct 22, 2008 * |g:netrw_http_xcmd| may now be overridden
			     independently of |g:netrw_http_cmd|.
	      Oct 23, 2008 * [N] added to the various Explore commands to
			     let users specify the width/height of new
			     explorer windows, overriding |g:netrw_winsize|.
	v133: Aug 10, 2008 * NetReadFixup() for win95 was missing some "a:"s
	      Aug 12, 2008 * (Jan Minář) an error condition in NetrwMethod()
			     wasn't being used, resulting in "b:netrw_fname
			     undefined" errors
	      Aug 12, 2008 * (François Ingeirest) asked that "hi link" be
			     changed to hi default link in the netrw syntax
			     files.
	      Aug 12, 2008 * using s:NetrwUnmarkList() more often.  Filenames
			     were being left on the global list when removed
			     from the buffer-local lists.
	      Aug 14, 2008 * (Joshua Clayton) an errant extra ")" was left in
			     the rcp-handling portion of NetRead().
	      Sep 03, 2008 * added |'cursorline'| highlighting to thin, long,
			     and tree displays.
	v132: Aug 06, 2008 * Fixed marked file-based obtain
	      Aug 08, 2008 * sourcing a file via ftp from a netrw-generated
	                     buffer (or any buffer with |'nobl'|) left an
			     empty no-name buffer in its wake.  Fixed.
	v130: Jul 31, 2008 * trying out elinks/links for http://host/
			     requests.  One problem: in-page links
			     (such as with ...#LABEL) are not supported
			   * verified that Bram's modified netrwPlugin works
	      Aug 01, 2008 * fixed a bug: when sourcing a file via ftp, the
			     "filter window" was left behind.
	v129: Jul 31, 2008 * bug found in non-mouse enabled vim and some
			     local maps
	v128: Jul 30, 2008 * much work done in using shellescape() and
			     fnameescape()
	v126: Jun 30, 2008 * after having gone to a remote directory,
	                     <f1> was no longer taking one to the correct
			     entry in the help (|netrw-quickhelp|).  Fixed.
	      Jul 01, 2008 * extracting the last filename from a wide listing
			     missed the last letter when |'virtualedit'| not
			     enabled.
	      Jul 01, 2008 * vim foo/bar  was creating [Scratch] buffers,
			     where bar was also a directory
	      Jul 01, 2008 * numerous additional changes were made to netrw
			     to use fnameescape() and shellescape() instead
			     of escape().  Not all changes have been tested
			     as yet...
	      Jul 01, 2008 * (James Vega reported) some problems with
			     :NetrwSettings (due to no longer used setting
			     variables).
	      Jul 07, 2008 * Additional numerous changes to support security;
	                     shellescape(arg,1), etc.
	v125: Apr 07, 2008 * (Cristian Rigamonti) CR provides a patch; he
			     noted that gx was failing since its call to
			     netrw#NetBrowseX() wasn't updated to
			     netrw#NetrwBrowseX().
			   * (Stanis Trendelenburg) ST provides a patch to
			     supports davs: (dav + ssl)
			   * (Rick Choi) noted that directory names comprised
			     of three digits were not being displayed by
			     the internal browser.  Fixed.
			   * (Erik Falor) provided a patch to handle problems
			     with changing directory and |'acd'| option.
			   * (James Vega, Teemu Likonen) noted that netrw
			     wasn't handling multi-byte filenames/directories
			     correctly.  Fixed.
			   * (Rick) found problem with g:netrw_maxfilenamelen
			     being overridden.
			   * (James Vega) pointed out that netrw was
			     misidentifying all files in a symbolically linked
			     directory as being symbolically linked
			     themselves.  This particular problem was fixed;
			     however, there are now situations where
			     symbolically linked files will not be detected.
			     Really need an internal vim function to do this
			     identification.
	      Apr 17, 2008 * When g:netrw_keepdir==0, current directory
	                     doesn't necessarily equal b:netrw_curdir
			     initially.  Problem is due to the patch directly
			     above.
			   * Fixed qf to handle case where b:netrw_curdir
			     isn't the same as the current directory under
			     linux/macosx.
			   * New: |netrw-mg| (apply vimgrep to marked files)
	      May 05, 2008 * (Rick) pointed out that a "setlocal ts=32" was
			     interfering with g:netrw_maxfilenamelen
	      May 05, 2008 * (James Vega) a file inside a linked directory
			     was showing up as a symbolic link itself.
	      May 22, 2008 * symbolic links, fifos, and sockets are now
	                     indicated by a trailing @, |, or =, respectively.
	      Jun 06, 2008 * Removed numerous bugs from the marked file
			     move and copy.  Tested these changes under
			     Unix only thus far.
			   * :Rexplore returns to the screen position in the
			     netrw listing from whence the file was edited
	v124: Apr 02, 2008 * (Adrian Rollett) change the line supporting the
			    "x" action for mac to use g:netrw_shq
	v123: Feb 27, 2008 * Marked files now keeps a "global" marked file
			     list.  The global marked file list is used to
			     support tag processing and vimdiff'ing
			     (|netrw-md| |netrw-mt|)
			   * Been insuring that mm and mc works with various
			     combinations of local and remote directories
			   * (Stefan Bittner) http://.../ should always have
			     filetype "html" -- fixed.
			   * (Stefan Bittner) a "?" in a http://.../ request
			     wasn't being handled correctly.  Fixed by
			     removing ? from default |g:netrw_tmpfile_escape|.
			   * (Nico Weber) % codes in http://.../ requests
			     weren't being handled correctly.  Fixed by
			     including % in default |g:netrw_fname_escape|.
			   * (Stefan Bittner) attempts to update Buffers.Refresh
			     were failing because locale use changed the menu
			     names.  I implemented a workaround.
	v122: Feb 12, 2008 * bugfix - first sorting sequence match now has
			     priority
	      Feb 14, 2008 * bugfix - sorting sequence was effectively ignoring
			     sequencing priority of anything following '*'
			   * toggling a marked file was showing incorrect list
			     (list was correct, but displayed matches weren't)
			   * |g:netrw_special_syntax| implemented
	v121: Feb 11, 2008 * Bram M reported that :e file ... :e . would not
			     retain the alternate file.  Fixed -- I hope!
			   * bugfix -- apparently v120 broke an explicit
			     :Explore dirname
	v120: Jan 21, 2008 * |netrw-mt| changed to allow for target selection
	                     based on whether or not word under cursor is a
			     directory or file, or if cursor is in banner
			     area.
			   * |netrw-mh| included (hiding by marked-file suffix)
			   * functions moved about a bit (improved
			     categorization)
			   * executable files now displayed with trailing (*)
			   * symbolically linked files now displayed with
			     trailing (@)
			   * Somewhen, s:NetrwMarkFileMove() got damaged.  Its
			     now restored (missing an endif, for example).
			   * |netrw-mu| implemented (unmarking marked files)
			   * many bugs have been removed from the marked file
			     system (tnx to Mark S. for feedback)
			   * |netrw-ms| implemented (sourcing marked files)
			   * fixed use of P with tree listing style
			   * multiple tree listing now supported
			   * ./ suppressed
			   * changed q -> qb (query bookmarks)
			   * implemented |netrw-qf|
			   * Explore now has four special list-generation
			     modes: */filepat **/filepat
			           *//pattern **//pattern
			   * gh (|netrw-gh|) is a shortcut for toggling the
			     hiding of files and directories beginning with a
			     dot
	v119: Jan 10, 2008 * When g:netrw_keepdir is false,
			     NetrwOptionsRestore() had a problem
			     (Bill McCarthy)
	      Jan 11, 2008 * Netrw now shows symbolic links with a trailing
	                     "@" and special highlighting.
	      Jan 15, 2008 * Changed g:netrw_noretmap -> |g:netrw_retmap|.
	                     Changed: disabled by default at Bram's
			     preference.
	v118: Jan 02, 2008 * Fixed a problem with Windows;
			     :Explore c:/path/ would not work,
			     but :Explore c:/path would.
			   * Fixed a bug in s:NetrwOptionRestore() - lcd's
			     argument wasn't being properly escaped so it
			     wouldn't handle spaces in directory names.
			     (Gary Johnson)
	v117: Jan 02, 2008 * Fixed a problem with P; had to include
			     a b:netrw_curdir bypass (Bram Moolenaar)
	v116: Nov 27, 2007 * netrw#LocalBrowseCheck() has &ft=="netrw"
			     check to prevent doing a directory listing
			     (was getting unexpected directory refreshes
			     in the middle of some function calls)
			   * NetrwOptionRestore moved after e! filename
			     in order to retain user options for editing
			     in s:NetrwBrowseChgDir()
	      Dec 12, 2007 * Bug fix -- netrw does a better job of retaining
	                     user options when editing files under the aegis
			     of the browser
	v115: Oct 04, 2007 * Erik Remmelzwaal pointed out that the use of
			     shellslash in s:GetTempfile() was incorrect
	      Oct 11, 2007 * Tracked down and eliminated a bug with editing
			     remote *.tar.gz and *.tar.bz2 files
	      Oct 11, 2007 * g:netrw_localmovecmd wasn't being initialized
			     properly, and g:netrw_localcopycmd was being
			     overwritten.
	      Oct 12, 2007 * Placed all :Rexplore and <2-leftmouse> setup
			     in a new support function (s:SetRexDir()).
	      Oct 15, 2007 * new: g:netrw_browse_split == 4; means <cr>
			     based selection will use previous window
	      Oct 20, 2007 * also checks on |'shellxquote'| to set g:netrw_shq
	      Oct 24, 2007 * Explore handles path/**/filename
	      Oct 27, 2007 * sourcing remote files often didn't work with ftp,
	                     turns out that b:netrw_method was undefined, so
			     s:SaveBufVars and s:RestoreBufVars() fixed it.
	v114: Sep 28, 2007 * mT, the map that invokes tags, has been improved
			     to support use of remote tags files.
	      Oct 02, 2007 * changed Netrw menu to use more submenus
	v113: Sep 07, 2007 * worked out why the cursor position wasn't being
			     saved and restored as intended after doing such
			     things as deleting and renaming files.
	      Sep 11, 2007 * Fixed bug which effectively disabled <c-l> and
			     <c-h> maps
	      Sep 18, 2007 * there used to be one NetrwOptionRestore() call at
			     the end of the s:NetrwBrowseChgDir() function;
			     they're now at the end of every if..elseif..else
			     block.  The edit-a-file one is not quite at the end
			     of its block; instead, its just before the edit.
			     Restores user options, then this new placement
			     allows ftplugins, autocmds, etc to change settings
			     (ex. ftplugin/cpp.vim sets cindent).
	      Sep 19, 2007 * changed all strlen() calls to use s:Strlen(), a
			     function which handles utf-8 wide characters
			     correctly.
	      Sep 20, 2007 * (Nico Weber) the "x" command has been extended
			     to Mac's OS/X (macunix); it now uses open to
			     handle |netrw-x| browsing with special files.
	      Sep 22, 2007 * Added g:netrw_noretmap to netrw at Tony M's
			     request.
			   * Included path to NetrwRemoteRmFile()
	v112: Aug 18, 2007 * added mx (|netrw-mx|) for executing arbitrary
			     commands on marked files
	      Aug 22, 2007 * more option save/restore work for
			     s:NetrwBrowseChgDir(); s:NetrwOptionSave()
			     and s:NetrwOptionRestore() now take a parameter
			     specifying the type of variables to be used for
			     saving and restoring (either "w:" or "s:")
	      Sep 04, 2007 * added the :NetrwClean[!] command
	v111: Jul 25, 2007 * using Windows but not using Cygwin, netrw does a
			     "file bufname" where the bufname uses /s
			     instead of \s; Vim "fixes" it by changing the
			     bufname to use \s anyway.  This meant that
			     NetrwGetBuffer() didn't find the appropriately
			     named buffer, and so would generate a new
			     buffer listing; hence the cursor would appear
			     to have been moved when doing a preview.
			   * added <2-leftmouse> map to return to netrw's
			     browser display
	      Aug 16, 2007 * added the mark-file system, including
			     maps for mf mp mt mz and mu.  Modifications
			     made to maps for a D O and R to support
			     marked files.
	v110: May 10, 2007 * added [ and ] maps to NetrwTreeListing
	      May 25, 2007 * |g:netrw_preview| included
	      May 29, 2007 * modifed netrw#NetBrowseX to consistently use
			     g:netrw_shq instead of hardcoded quotes,
			     and modified the snippet that sets up redir
			     so Windows machines use "nul" instead of
			     "/dev/null".
	      Jun 01, 2007 * fixed bug -- NetGetBuffer() wasn't always
			     recognizing a buffer name match when it should,
			     thus resulting in [Scratch] buffers.
	      Jun 04, 2007 * Gary Johnson found a bugfix for the "c" mapping
			     when the directory is to be made current but
			     the name contains spaces.
	v109: Mar 26, 2007 * if a directory name includes a "$" character,
			     Explore() will use expand() in an attempt to
			     decipher the name.
	      May 07, 2007 * g:netrw_use_errorwindow now allows one to
			     have error messages go to a reliable window
			     or to use a less reliable but recallable 
			     echoerr method
	      May 07, 2007 * g:netrw_scpport and g:netrw_sshport support
			     use of -P and -p, respectively, to set port
			     for scp/ssh.
	v108: Jan 03, 2007 * included preview map (|netrw-p|), supporting
			     remote browsing
			   * netrw can now source remote files
	      Jan 26, 2007 * Colton Jamieson noted that remote directory
			     browsing did not support alternate port
			     selection.  This feature has now been extended
			     to apply to all remote browsing commands via ssh.
			     (list, remove/delete, rename)
	      Jan 31, 2007 * Luis Florit reported that @* was an invalid
			     register.  The @* register is now only saved and
			     restored if |'guioptions'| contains "a".
	      Feb 02, 2007 * Fixed a bug that cropped up when writing files
			     via scp using cygwin
	      Feb 08, 2007 * tree listing mode managed to stop working again;
			     fixed again!
	      Feb 15, 2007 * Guido Van Hoecke reported that netrw didn't
			     handle browsing well with M$ ftp servers.  He even
			     set up a temporary account for me to test with
			     (thanks!).  Netrw now can browse M$ ftp servers.
	v107: Oct 12, 2006 * bypassed the autowrite option
	      Oct 24, 2006 * handles automatic decompression of *.gz and *.bz2
			     files
	      Nov 03, 2006 * Explore will highlight matching files when
			     **/pattern is used (and if the |'hls'| option
			     is set)
	      Nov 09, 2006 * a debugging line, when enabled, was inadvertently
			     bringing up help instead of simply reporting on
			     list contents
	      Nov 21, 2006 * tree listing improved (cursor remains put)
	      Nov 27, 2006 * fixed b:netrw_curdir bug when repeated "i"s were
			     pressed.
	      Dec 15, 2006 * considerable qty of changes, mostly to share more
			     code between local and remote browsing.  Includes
			     support for tree-style listing for both remote
			     and local browsing.
	      Dec 15, 2006 * Included Peter Bengtsson's modifications to
			     support the Amiga.
	v106: Sep 21, 2006 * removed old v:version<700 code as netrw now
			     requires vim 7.0
			   * worked around a bug where register * was
			     overwritten during local browsing
	v104: Sep 05, 2006 * as suggested by Rodolfo Borges, :Explore and
			     variants will position the cursor on the file
			     just having been edited
			   * changed default |g:netrw_sort_sequence| order
			   * changed b, Nb to simply mb  (see |netrw-mb|)
			   * changed B, NB to simply gb  (see |netrw-gb|)
			   * tree listing style (see |g:netrw_liststyle|)
			   * attempts to retain the alternate file
	v103: Jul 26, 2006 * used Yakov Lerner's tip#1289 to improve netrw
			     error message display
			   * wide listings didn't handle files with backslashes
			     in their names properly.  A symptom was an
			     inability to open files.
	      Aug 09, 2006 * included "t" mapping for opening tabbed windows,
			    both for remote and local browsing
			   * changed netrw_longlist to netrw_liststyle
	      Aug 15, 2006 * fixed one of the NB maps
	      Aug 22, 2006 * changed *Explore commands to use -nargs=* instead
			     of -nargs=?.  Allows both -complete=dir _and_ the
			     starstar arguments to work (-nargs=? seems to
			     require one or the other).
	      Aug 23, 2006 * copied all w:.. variables across splits to
			     new windows
	      Aug 25, 2006 * when g:netrw_browsex_viewer was '-'
			     (see |g:netrw_browsex_viewer|) it wasn't causing
			     netrwFileHandlers#Invoke() to be called as it
			     was expected to.  (tnx Steve Dugaro)
	      Aug 29, 2006 * changed NetBrowseX() to use "setlocal ... noswf"
			     instead of "set ... noswf"  (tnx Benji Fisher)
	      Aug 31, 2006 * tabs and fastbrowse<=1 didn't work together.
	v102: Jun 15, 2006 * chgd netrwPlugin to call netrw#LocalBrowseCheck()
			   * bugfix: g:netrw_keepdir==0 had stopped working
	      Jul 06, 2006 * bugfix: NetOptionSave/Restore now saves/restores
			     the unnamed register (|registers|)
	      Jul 07, 2006 * |g:netrw_menu| support included
	      Jul 13, 2006 * :Texplore command implemented
	      Jul 17, 2006 * NetSplit and (Local|Net)BrowseChgDir() were both
			     splitting windows.  This affected o, v, and
			     g:netrw_browse_split.
	      Jul 20, 2006 * works around wildignore setting (was causing
			     netrw's local browser not to list wildignore'd
			     files)
	      Jul 24, 2006 * <leftmouse> acts as a <cr> for selecting a file
			     <rightmouse> acts as a <del> for deleting a file
	v100: May 14, 2006 * when using Windows and shell==cmd.exe, the
			     default for g:netrw_ignorenetrc is now 1
			   * bugfix: unwanted ^Ms now removed
			     (affected shell==cmd.exe - Windows)
			   * added Bookmarks and History to the menu
			   * an error message about non-existing
			     w:netrw_longlist was appearing during attempts to
			     Explore (fixed)
			   * g:netrw_shq now available to make netrw use
			     specified style of quotes for commands
	     May 29, 2006  * user NFH_*() functions were inadvertently being
			     ignored
			   * fixed a Windows non-cygwin ftp handling problem.
			   * hiding pattern candidate separators included some
			     characters it shouldn't have (tnx to Osei Poku)
	     Jun 01, 2006  * for browsing, netrw was supposed to use "dir"
			     instead of "ls -lF" when using
			     ftp+non-cygwin+windows.  Fixed.
			   * an inadvertently left-in-place debugging statement
			     was preventing use of the "x" key with browsing.
	     Jun 05, 2006  * g:netrw_nogx available to prevent making the gx
			     map (see |g:netrw_nogx|)
			   * bugfix, Explore wouldn't change directory
			     properly (vim ., :Explore subdirname)
	     Jun 06, 2006  * moved history to 2nd line in Netrw menu
			   * fixed delete for unix-based systems
	     Jun 07, 2006  * x key now works for windows-noncygwin-ftp
	     Jun 08, 2006  * Explore */pat and **//pat now wraps
	v99: May 09, 2006  * g:netrw_browse_split=3 for opening files in new
			     tabs implemented.
	     May 12, 2006  * deletes temporary file at end of NetRead()
			   * visual mode based Obtain implemented
			   * added -complete=dir to the various Explore
			     commands
	v98: May 02, 2006  * the "p" key didn't work properly when the browsing
			     directory name had spaces in it.
	v97: May 01, 2006  * exists("&acd") now used to determine if
			     the 'acd' option exists
			   * "obtain" now works again under Windows
	v96:		   * bugfix - the |'acd'| option is not always defined
			     but is now bypassed only when it is
	v95:		   * bugfix - Hiding mode worked correctly (don't show
			     any file matching any of the g:netrw_hide
			     patterns), but showing mode was showing only those
			     files that didn't match any of the g:netrw_hide
			     patterns.  Instead, it now shows all files that
			     match any of the g:netrw_hide patterns (the
			     difference between a logical and and logical or).
	v94:		   * bugfix - a Decho() had a missing quote; only
			     affects things when debugging was enabled.
	v93:		   * bugfix - removed FocusGained event from causing a
			     slow-browser refresh for Windows
	v92:		   * :Explore **//pattern implemented
			      (**/filepattern was already taken)
	v91:		   * :Explore */pattern implemented
			   * |'acd'| option bypassed
	v90:		   * mark ', as suggested by Yegappan Lakshmanan, used
			     to help guarantee entry into the jump list when
			     appropriate.
			   * <s-down> and <s-up> are no longer defined until a
			     :Explore **/pattern  is used (if the user already
			     has a map for them).  They will be defined for new
			     browser windows from that point forward.
	v89:		   * A <s-down>, <s-up>, :Nexplore, or a :Pexplore
			     without having first done an :Explore **/pattern
			     (see |netrw-starstar|) caused
			     a lot of unhelpful error messages to appear
	v88:		   * moved DrChip.Netrw menu to Netrw.  Now has
			     priority 80 by default.
			     g:NetrwTopLvlMenu == "Netrw" and can be changed
			     by the user to suit.  The priority is given by
			     g:NetrwMenuPriority.
			   * Changed filetype for browser displays from
			     netrwlist to netrw.
	v87:		   * bug fix -- menus were partially disappearing
	v85:		   * bug fix -- missing an endif
			   * bug fix -- handles spaces in names and directories
			     when using ftp-based browsing
	v83:		   * disabled stop-acd handling; the change in directory
			     handling may allow acd to be used again.
			   * D was refusing to delete remote files/directories
			     in wide listing mode.
	v81:		   * FocusGained also used to refresh/wipe local browser
			     directory buffers
			   * (bugfix) netrw was leaving [Scratch] buffers behind
			     when the user had the "hidden" option set.  The
			     'hidden' option is now bypassed.
	v80:		   * ShellCmdPost event used in conjunction with
			     g:netrw_fastbrowse to refresh/wipe local browser
			     directory buffers.
	v79:		   * directories are now displayed with nowrap
			   * (bugfix) if the column width was smaller than the
			     largest file's name, then netrw would hang when
			     using wide-listing mode - fixed
			   * g:netrw_fastbrowse introduced
	v78:		   * progress has been made on allowing spaces inside
			     directory names for remote work (reading, writing,
			     browsing).  (scp)
	v77:		   * Mikolaj Machowski fixed a bug in a substitute cmd
			   * g:netrw_browsex_viewer implemented
			   * Mikolaj Machowski pointed out that gnome-open is
			     often executable under KDE systems, although it is
			     effectively not functional.  NetBrowseX now looks
			     for "kicker" as a running process to determine if
			     KDE is actually running.
			   * Explorer's O functionality was inadvertently left
			     out.  Netrw now does the same thing, but with the
			     "P" key.
			   * added g:netrw_browse_split option
			   * fixed a bug where the directory contained a "." but
			     the file didn't (was treating the dirname from "."
			     onwards as a suffix)
	v76:		   * "directory is missing" error message now restores
			      echo highlighting
	v75:		   * file://... now conforms to RFC2396 (thanks to
			     S. Zacchiroli)
			   * if the binary option is set, then NetWrite() will
			     only write the whole file (line numbers don't make
			     sense with this).  Supports writing of tar and zip
			     files.
	v74:		   * bugfix (vim, then :Explore) now works
			   * ctrl-L keeps cursor at same screen location (both
			     local and remote browsing)
			   * netrw now can read remote zip and tar files
			   * Obtain now uses WinXP ftp+.netrc successfully
	v73:		   * bugfix -- scp://host/path/file was getting named
			     incorrectly
			   * netrw detects use of earlier-than-7.0 version of
			     vim and issues a pertinent error message.
			   * netrwSettings.vim is now uses autoloading.  Only
			     <netrwPlugin.vim> is needed as a pure plugin
			     (ie. always loaded).
	v72:		   * bugfix -- formerly, one could prevent the loading
			     of netrw by "let g:loaded_netrw=1"; when
			     autoloading became supported, this feature was
			     lost.  It is now restored.
	v71:		   * bugfix -- made some "set nomodifiable"s into
			     setlocal variants (allows :e somenewfile  to be
			     modifiable as usual)
			   * NetrwSettings calls a netrw function, thereby
			     assuring that netrw has loaded.  However, if netrw
			     does not load for whatever reason, then
			     NetrwSettings will now issue a warning message.
			   * For what reason I don't recall, when wget and fetch
			     are both not present, and an attempt to read a
			     http://... url is made, netrw exited.  It now only
			     returns.
			   * When ch=1, on the second and subsequent uses of
			     browsing Netrw would issue a blank line to clear
			     the echo'd messages.  This caused an annoying
			     "Hit-Enter" prompt; now a blank line message
			     is echo'd only if &ch>1.
	v70:		   * when using |netrw-O|, the "Obtaining filename"
			     message is now shown using |hl-User9|.  If User9
			     has not been defined, netrw itself will define it.
	v69:		   * Bugfix: win95/98 machines were experiencing a
			     "E121: Undefined variable: g:netrw_win95ftp"
			     message
	v68:		   * double-click-leftmouse selects word under mouse
	v67:		   * Passwords which contain blanks will now be
			     surrounded by double-quotes automatically (Yongwei)
	v66:		   * Netrw now seems to work with a few more Windows
			     situations
			   * O now obtains a file: remote browsing
			     file -> local copy, locally browsing
			     file -> current directory (see :pwd)
			   * i now cycles between thin, long, and wide listing
			     styles
			   * NB and Nb are maps that are always available;
			     corresponding B and b maps are only available when
			     not using wide listing in order to allow them to
			     be used for motions
	v65:		   * Browser functions now use NetOptionSave/Restore; in
			     particular, netrw now works around the report
			     setting
	v64:		   * Bugfix - browsing a "/" directory (Unix) yielded
			     buffers named "[Scratch]" instead of "/"
			   * Bugfix - remote browsing with ftp was omitting
			     the ./ and ../
	v63:		   * netrw now takes advantage of autoload (needs 7.0)
			   * Bugfix - using r (to reverse sort) working again
	v62:		   * Bugfix - spaces allowed again in directory names
			     with g:netrw_keepdir=0.  In fact, I've tested netrw
			     with most ANSI punctuation marks for directory
			     names.
			   * Bugfix - NetrwSettings gave errors when
			     g:netrw_silent had not be set.
	v61:		   * Document upgrade -- netrw variable-based settings
			     all should have tags.  Supports NetrwSettings cmd.
			   * Several important variables are window-oriented.
			     Netrw has to transfer these across a window split.
			     See s:BufWinVars() and s:UseBufWinVars().
	v60:		   * When using the i map to switch between long and
			     short listings, netrw will now keep cursor on same
			     line
			   * "Match # of #" now uses status line
			   * :Explore **/*.c  will now work from a
			     non-netrw-browser window
			   * :Explore **/patterns can now be run in separate
			     browser windows
			   * active banner (hit <cr> will cause various things
			     to happen)
	v59:		   * bugfix -- another keepalt work-around installed
			     (for vim6.3)
			   * "Match # of #" for Explore **/pattern matches
	v58:		   * Explore and relatives can now handle
			     **/somefilepattern (v7)
			   * Nexplore and Pexplore introduced (v7).  shift-down
			     and shift-up cursor keys will invoke Nexplore and
			     Pexplore, respectively.
			   * bug fixed with o and v
			   * autochdir only worked around for vim when it has
			     been compiled with either
			     |+netbeans_intg| or |+sun_workshop|
			   * Under Windows, all directories and files were
			     being preceded with a "/" when local browsing.
			     Fixed.
			   * When: syntax highlighting is off, laststatus=2, and
			     remote browsing is used, sometimes the laststatus
			     highlighting bleeds into the entire display.  Work
			     around - do an extra redraw in that case.
			   * Bugfix: when g:netrw_keepdir=0, due to re-use of
			     buffers, netrw didn't change the directory when it
			     should've
			   * Bugfix: D and R commands work again
	v57:		   * Explore and relatives can now handle RO files
			   * reverse sort restored with vim7's sort command
			   * g:netrw_keepdir now being used to keep the current
			     directory unchanged as intended (sense change)
			   * vim 6.3 still supported
	v56:		   * LocalBrowse now saves autochdir setting, unsets it,
			     and restores it before returning.
			   * using vim's rename() instead of system +
			     local_rename variable
			   * avoids changing directory when g:netrw_keepdir is
			     false
	v55:		   * -bar used with :Explore :Sexplore etc to allow
			     multiple commands to be separated by |s
			   * browser listings now use the "nowrap" option
			   * browser: some unuseful error messages now
			     suppressed
	v54:		   * For backwards compatibility, Explore and Sexplore
			     have been implemented.  In addition, Hexplore and
			     Vexplore commands are available, too.
			   * <amatch> used instead of <afile> in the
			     transparency support (BufReadCmd, FileReadCmd,
			     FileWriteCmd)
			   * ***netrw*** prepended to various error messages
			     netrw may emit
			   * g:netrw_port used instead of b:netrw_port for scp
			   * any leading [:#] is removed from port numbers
	v53:		   * backslashes as well as slashes placed in various
			     patterns (ex. g:netrw_sort_sequence) to better
			     support Windows
	v52:		   * nonumber'ing now set for browsing buffers
			   * when the hiding list hid all files, error messages
			     ensued. Fixed
			   * when browsing, swf is set, but directory is not
			     set, when netrw was attempting to restore options,
			     vim wanted to save a swapfile to a local directory
			     using an url-style path.  Fixed
	v51:		   * cygwin detection now automated
			     (using windows and &shell is bash)
			   * customizable browser "file" rejection patterns
			   * directory history
			   * :[range]w url  now supported (ie. netrw uses a
			     FileWriteCmd event)
			   * error messages have a "Press <cr> to continue" to
			     allow them to be seen
			   * directory browser displays no longer bother the
			     swapfile
			   * u/U commands to go up and down the history stack
			   * history stack may be saved with viminfo with it's
			     "!" option
			   * bugfixes associated with unwanted [No Files]
			     entries
	v50:		   * directories now displayed using buftype=nofile;
			     should keep the directory names as-is
			   * attempts to remove empty "[No File]" buffers
			     leftover from :file ..name.. commands
			   * bugfix: a "caps-lock" editing difficulty left in
			     v49 was fixed
			   * syntax highlighting for "Showing:" the hiding list
			     included
			   * bookmarks can now be retained if "!" is in the
			     viminfo option
	v49:		   * will use ftp for http://.../ browsing
	v48:		   * One may use ftp to do remote host file browsing
			   * (windows and !cygwin) remote browsing with ftp can
			     now use the "dir" command internally to provide
			     listings
			   * g:netrw_keepdir now allows one to keep the initial
			     current directory as the current directory
			     (normally the local file browser makes the
			     currently viewed directory the current directory)
			   * g:netrw_alto and g:netrw_altv now support
			     alternate placement of windows started with o or v
			   * Nread ? and Nwrite ?  now uses echomsg (instead of
			     echo) so :messages can repeat showing the help
			   * bugfix: avoids problems with partial matches of
			     directory names to prior buffers with longer names
			   * one can suppress error messages with g:netrw_quiet
			     ctrl-h used
			   * instead of <Leader>h for editing hiding list one
			     may edit the sorting sequence with the S map, which
			     now allows confirmation of deletion with
			     [y(es) n(o) a(ll) q(uit)]
			   * the "x" map now handles special file viewing with:
			     (windows) rundll32 url.dll (gnome) gnome-open (kde)
			     kfmclient If none of these are on the executable
			     path, then netrwFileHandlers.vim is used.
			   * directory bookmarking during both local and remote
			     browsing implemented
			   * one may view all, use the hiding list to suppress,
			     or use the hiding list to show-only remote and
			     local file/directory listings
			   * improved unusual file and directory name handling
			     preview window support
	v47:		   * now handles local browsing.
	v46:		   * now handles remote browsing
			   * g:netrw_silent (if 1) will cause all transfers to
			     be silent
	v45:		   * made the [user@]hostname:path form a bit more
			     restrictive to better handle errors in using
			     protocols (e.g. scp:usr@host:file was being
			     recognized as an rcp request)
	v44:		   * changed from "rsync -a" to just "rsync"
			   * somehow an editing error messed up the test to
			     recognize use of the fetch method for NetRead.
			   * more debugging statements included
	v43:		   * moved "Explanation" comments to <pi_netrw.txt> help
			     file as "Network Reference" (|netrw-ref|)
			   * <netrw.vim> now uses Dfunc() Decho() and Dret() for
			     debugging
			   * removed superfluous NetRestorePosn() calls
	v42:		   * now does BufReadPre and BufReadPost events on
			     file:///* and file://localhost/*
	v41:		   * installed file:///* and file://localhost/* handling
	v40:		   * prevents redraw when a protocol error occurs so
			     that the user may see it
	v39:		   * sftp support
	v38:		   * Now uses NetRestorePosn() calls with Nread/Nwrite
			     commands
			   * Temporary files now removed via bwipe! instead of
			     bwipe (thanks to Dave Roberts)
	v37:		   * Claar's modifications which test if ftp is
			     successful, otherwise give an error message
			   * After a read, the alternate file was pointing to
			     the temp file.  The temp file buffer is now wiped
			     out.
			   * removed silent from transfer methods so user can
			     see what's happening


==============================================================================
12. Credits						*netrw-credits* {{{1

	Vim editor	by Bram Moolenaar (Thanks, Bram!)
	dav		support by C Campbell
	fetch		support by Bram Moolenaar and C Campbell
	ftp		support by C Campbell <NdrOchip@ScampbellPfamily.AbizM>
	http		support by Bram Moolenaar <bram@moolenaar.net>
	rcp
	rsync		support by C Campbell (suggested by Erik Warendorph)
	scp		support by raf <raf@comdyn.com.au>
	sftp		support by C Campbell

	inputsecret(), BufReadCmd, BufWriteCmd contributed by C Campbell

	Jérôme Augé		-- also using new buffer method with ftp+.netrc
	Bram Moolenaar		-- obviously vim itself, :e and v:cmdarg use,
	                           fetch,...
	Yasuhiro Matsumoto	-- pointing out undo+0r problem and a solution
	Erik Warendorph		-- for several suggestions (g:netrw_..._cmd
				   variables, rsync etc)
	Doug Claar		-- modifications to test for success with ftp
	                           operation

==============================================================================
Modelines: {{{1
 vim:tw=78:ts=8:ft=help:norl:fdm=marker
syntax/netrw.vim	[[[1
104
" Language   : Netrw Remote-Directory Listing Syntax
" Maintainer : Charles E. Campbell, Jr.
" Last change: Aug 12, 2008
" Version    : 14
" ---------------------------------------------------------------------

" Syntax Clearing: {{{1
if version < 600
 syntax clear
elseif exists("b:current_syntax")
 finish
endif

" ---------------------------------------------------------------------
" Directory List Syntax Highlighting: {{{1
syn cluster NetrwGroup		contains=netrwHide,netrwSortBy,netrwSortSeq,netrwQuickHelp,netrwVersion,netrwCopyTgt
syn cluster NetrwTreeGroup	contains=netrwDir,netrwSymLink,netrwExe

syn match  netrwSpecial		"\%(\S\+ \)*\S\+[*|=]\ze\%(\s\{2,}\|$\)"		contains=netrwClassify
syn match  netrwDir		"\.\{1,2}/"						contains=netrwClassify
syn match  netrwDir		"\%(\S\+ \)*\S\+/"					contains=netrwClassify
syn match  netrwSizeDate	"\<\d\+\s\d\{1,2}/\d\{1,2}/\d\{4}\s"			contains=netrwDateSep skipwhite nextgroup=netrwTime
syn match  netrwSymLink		"\%(\S\+ \)*\S\+@\ze\%(\s\{2,}\|$\)"  			contains=netrwClassify
syn match  netrwExe		"\%(\S\+ \)*\S\+\*\ze\%(\s\{2,}\|$\)" 			contains=netrwClassify
syn match  netrwTreeBar		"^\%([-+|] \)*"						contains=netrwTreeBarSpace	nextgroup=@netrwTreeGroup
syn match  netrwTreeBarSpace	" "				contained

syn match  netrwClassify	"[*=|@/]\ze\%(\s\{2,}\|$\)"	contained
syn match  netrwDateSep		"/"				contained
syn match  netrwTime		"\d\{1,2}:\d\{2}:\d\{2}"	contained		contains=netrwTimeSep
syn match  netrwTimeSep		":"

syn match  netrwComment		'".*\%(\t\|$\)'						contains=@NetrwGroup
syn match  netrwHide		'^"\s*\(Hid\|Show\)ing:'	skipwhite nextgroup=netrwHidePat
syn match  netrwSlash		"/"				contained
syn match  netrwHidePat		"[^,]\+"			contained skipwhite nextgroup=netrwHideSep
syn match  netrwHideSep		","				contained skipwhite nextgroup=netrwHidePat
syn match  netrwSortBy		"Sorted by"			contained transparent skipwhite nextgroup=netrwList
syn match  netrwSortSeq		"Sort sequence:"		contained transparent skipwhite nextgroup=netrwList
syn match  netrwCopyTgt		"Copy/Move Tgt:"		contained transparent skipwhite nextgroup=netrwList
syn match  netrwList		".*$"				contained		contains=netrwComma
syn match  netrwComma		","				contained
syn region netrwQuickHelp	matchgroup=Comment start="Quick Help:\s\+" end="$"	contains=netrwHelpCmd keepend contained
syn match  netrwHelpCmd		"\S\ze:"			contained skipwhite nextgroup=netrwCmdSep
syn match  netrwCmdSep		":"				contained nextgroup=netrwCmdNote
syn match  netrwCmdNote		".\{-}\ze  "			contained
syn match  netrwVersion		"(netrw.*)"			contained

" -----------------------------
" Special filetype highlighting {{{1
" -----------------------------
if exists("g:netrw_special_syntax") && netrw_special_syntax
 syn match netrwBak		"\(\S\+ \)*\S\+\.bak\>"				contains=netrwTreeBar
 syn match netrwCompress	"\(\S\+ \)*\S\+\.\%(gz\|bz2\|Z\|zip\)\>"	contains=netrwTreeBar
 syn match netrwData		"\(\S\+ \)*\S\+\.dat\>"				contains=netrwTreeBar
 syn match netrwHdr		"\(\S\+ \)*\S\+\.h\>"				contains=netrwTreeBar
 syn match netrwLib		"\(\S\+ \)*\S*\.\%(a\|so\|lib\|dll\)\>"		contains=netrwTreeBar
 syn match netrwMakeFile	"\<[mM]akefile\>\|\(\S\+ \)*\S\+\.mak\>"	contains=netrwTreeBar
 syn match netrwObj		"\(\S\+ \)*\S*\.\%(o\|obj\)\>"			contains=netrwTreeBar
 syn match netrwTags    	"\<tags\>"					contains=netrwTreeBar
 syn match netrwTags		"\<\(ANmenu\|ANtags\)\>"			contains=netrwTreeBar
 syn match netrwTilde		"\(\S\+ \)*\S\+\~\>"				contains=netrwTreeBar
 syn match netrwTmp		"\<tmp\(\S\+ \)*\S\+\>\|\(\S\+ \)*\S*tmp\>"	contains=netrwTreeBar
endif

" ---------------------------------------------------------------------
" Highlighting Links: {{{1
if !exists("did_drchip_netrwlist_syntax")
 let did_drchip_netrwlist_syntax= 1
 hi default link netrwClassify	Function
 hi default link netrwCmdSep	Delimiter
 hi default link netrwComment	Comment
 hi default link netrwDir	Directory
 hi default link netrwHelpCmd	Function
 hi default link netrwHidePat	Statement
 hi default link netrwHideSep	netrwComment
 hi default link netrwList	Statement
 hi default link netrwVersion	Identifier
 hi default link netrwSymLink	Question
 hi default link netrwExe	PreProc
 hi default link netrwDateSep	Delimiter

 hi default link netrwTreeBar	Special
 hi default link netrwTimeSep	netrwDateSep
 hi default link netrwComma	netrwComment
 hi default link netrwHide	netrwComment
 hi default link netrwMarkFile	Identifier

 " special syntax highlighting (see :he g:netrw_special_syntax)
 hi default link netrwBak	NonText
 hi default link netrwCompress	Folded
 hi default link netrwData	DiffChange
 hi default link netrwLib	DiffChange
 hi default link netrwMakefile	DiffChange
 hi default link netrwObj	Folded
 hi default link netrwTilde	Folded
 hi default link netrwTmp	Folded
 hi default link netrwTags	Folded
endif

" Current Syntax: {{{1
let   b:current_syntax = "netrwlist"
" ---------------------------------------------------------------------
" vim: ts=8 fdm=marker
