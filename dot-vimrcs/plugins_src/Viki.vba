" Vimball Archiver by Charles E. Campbell, Jr., Ph.D.
UseVimball
finish
autoload/viki.vim	[[[1
2453
" viki.vim
" @Author:      Tom Link (micathom AT gmail com?subject=vim-viki)
" @Website:     http://www.vim.org/account/profile.php?user_id=4037
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Created:     2007-03-25.
" @Last Change: 2009-02-15.
" @Revision:    0.521

if &cp || exists("loaded_viki_auto") "{{{2
    finish
endif
let loaded_viki_auto = 1

""" General {{{1

" Outdated way to keep cursor information
function! s:ResetSavedCursorPosition() "{{{3
    let s:cursorSet  = -1
    let s:cursorCol  = -1
    let s:cursorVCol = -1
    let s:cursorLine = -1
    let s:cursorWinTLine = -1
    let s:cursorEol  = 0
    let s:lazyredraw = &lazyredraw
endf

call s:ResetSavedCursorPosition()

" Outdated: a cheap implementation of printf
function! s:sprintf1(string, arg) "{{{3
    if exists('printf')
        return printf(string, a:arg)
    else
        let rv = substitute(a:string, '\C[^%]\zs%s', escape(a:arg, '"\'), 'g')
        let rv = substitute(rv, '%%', '%', 'g')
        return rv
    end
endf

let s:InterVikiRx = '^\(['. g:vikiUpperCharacters .']\+\)::\(.*\)$'
let s:InterVikis  = []

" Define an interviki name
" viki#Define(name, prefix, ?suffix="*", ?index="Index.${suffix}")
" suffix == "*" -> g:vikiNameSuffix
function! viki#Define(name, prefix, ...) "{{{3
    if a:name =~ '[^A-Z]'
        throw 'Invalid interviki name: '. a:name
    endif
    call add(s:InterVikis, a:name .'::')
    call sort(s:InterVikis)
    let g:vikiInter{a:name}          = a:prefix
    let g:vikiInter{a:name}_suffix   = a:0 >= 1 && a:1 != '*' ? a:1 : g:vikiNameSuffix
    let index = a:0 >= 2 && a:2 != '' ? a:2 : g:vikiIndex
    let findex = fnamemodify(g:vikiInter{a:name} .'/'. index . g:vikiInter{a:name}_suffix, ':p')
    if filereadable(findex)
        let vname = viki#MakeName(a:name, index, 0)
        let g:vikiInter{a:name}_index = index
    else
        " let vname = '[['. a:name .'::]]'
        let vname = a:name .'::'
    end
    " let vname = escape(vname, ' \%#')
    " exec 'command! -bang -nargs=? -complete=customlist,viki#EditComplete '. a:name .' call viki#Edit(escape(empty(<q-args>) ?'. string(vname) .' : <q-args>, "#"), "<bang>")'
    if !exists(':'+ a:name)
        exec 'command -bang -nargs=? -complete=customlist,viki#EditComplete '. a:name .' call viki#Edit(empty(<q-args>) ? '. string(vname) .' : viki#InterEditArg('. string(a:name) .', <q-args>), "<bang>")'
    else
        echom "Viki: Command already exists. Cannot define a command for "+ a:name
    endif
    if g:vikiMenuPrefix != ''
        if g:vikiMenuLevel > 0
            let name = [ a:name[0 : g:vikiMenuLevel - 1] .'&'. a:name[g:vikiMenuLevel : -1] ]
            let weight = []
            for i in reverse(range(g:vikiMenuLevel))
                call insert(name, a:name[i])
                call insert(weight, char2nr(a:name[i]) + 500)
            endfor
            let ml = len(split(g:vikiMenuPrefix, '[^\\]\zs\.'))
            let mw = repeat('500.', ml) . join(weight, '.')
        else
            let name = [a:name]
            let mw = ''
        endif
        exec 'amenu '. mw .' '. g:vikiMenuPrefix . join(name, '.') .' :VikiEdit! '. vname .'<cr>'
    endif
endf

for [s:iname, s:idef] in items(g:viki_intervikis)
    " viki#Define(name, prefix, ?suffix="*", ?index="Index.${suffix}")
    if type(s:idef) == 1
        call call('viki#Define', [s:iname, s:idef])
    else
        call call('viki#Define', [s:iname] + s:idef)
    endif
    unlet! s:iname s:idef
endfor

function! s:AddToRegexp(regexp, pattern) "{{{3
    if a:pattern == ''
        return a:regexp
    elseif a:regexp == ''
        return a:pattern
    else
        return a:regexp .'\|'. a:pattern
    endif
endf

" Make all filenames use slashes
function! viki#CanonicFilename(fname) "{{{3
    return substitute(simplify(a:fname), '[\/]\+', '/', 'g')
endf

" Build the rx to find viki names
function! viki#FindRx() "{{{3
    let rx = s:AddToRegexp('', b:vikiSimpleNameSimpleRx)
    let rx = s:AddToRegexp(rx, b:vikiExtendedNameSimpleRx)
    let rx = s:AddToRegexp(rx, b:vikiUrlSimpleRx)
    return rx
endf

" Wrap edit commands. Every action that creates a new buffer should use 
" this function.
function! s:EditWrapper(cmd, fname) "{{{3
    " TLogVAR a:cmd, a:fname
    let fname = escape(simplify(a:fname), ' %#')
    " let fname = escape(simplify(a:fname), '%#')
    if a:cmd =~ g:vikiNoWrapper
        " TLogDBG a:cmd .' '. fname
        " echom 'No wrapper: '. a:cmd .' '. fname
        exec a:cmd .' '. fname
    else
        try
            if g:vikiHide == 'hide'
                " TLogDBG 'hide '. a:cmd .' '. fname
                exec 'hide '. a:cmd .' '. fname
            elseif g:vikiHide == 'update'
                update
                " TLogDBG a:cmd .' '. fname
                exec a:cmd .' '. fname
            else
                " TLogDBG a:cmd .' '. fname
                exec a:cmd .' '. fname
            endif
        catch /^Vim\%((\a\+)\)\=:E37/
            echoerr "Vim raised E37: You tried to abondon a dirty buffer (see :h E37)"
            echoerr "Viki: You may want to reconsider your g:vikiHide or 'hidden' settings"
        catch /^Vim\%((\a\+)\)\=:E325/
        " catch
        "     echohl error
        "     echom v:errmsg
        "     echohl NONE
        endtry
    endif
endf

" Find the previous heading
function! viki#FindPrevHeading()
    let vikisr=@/
    let cl = getline('.')
    if cl =~ '^\*'
        let head = matchstr(cl, '^\*\+')
        let head = '*\{1,'. len(head) .'}'
    else
        let head = '*\+'
    endif
    call search('\V\^'. head .'\s', 'bW')
    let @/=vikisr
endf

" Find the next heading
function! viki#FindNextHeading()
    let pos = getpos('.')
    " TLogVAR pos
    let cl  = getline('.')
    " TLogDBG 'line0='. cl
    if cl =~ '^\*'
        let head = matchstr(cl, '^\*\+')
        let head = '*\{1,'. len(head) .'}'
    else
        let head = '*\+'
    endif
    " TLogDBG 'head='. head
    " TLogVAR pos
    call setpos('.', pos)
    let vikisr = @/
    call search('\V\^'. head .'\s', 'W')
    let @/=vikisr
endf

" Test whether we want to markup a certain viki name type for the current 
" buffer
" viki#IsSupportedType(type, ?types=b:vikiNameTypes)
function! viki#IsSupportedType(type, ...) "{{{3
    if a:0 >= 1
        let types = a:1
    elseif exists('b:vikiNameTypes')
        let types = b:vikiNameTypes
    else
        let types = g:vikiNameTypes
    end
    if types == ''
        return 1
    else
        " return stridx(b:vikiNameTypes, a:type) >= 0
        return types =~# '['. a:type .']'
    endif
endf

" Build an rx from a list of names
function! viki#RxFromCollection(coll) "{{{3
    " TAssert IsList(a:coll)
    let rx = join(a:coll, '\|')
    if rx == ''
        return ''
    else
        return '\V\('. rx .'\)'
    endif
endf

" Mark inexistent viki names
" VikiMarkInexistent(line1, line2, ?maxcol, ?quick)
" maxcol ... check only up to maxcol
" quick  ... check only if the cursor is located after a link
function! s:MarkInexistent(line1, line2, ...) "{{{3
    if !exists('b:vikiMarkInexistent') || !b:vikiMarkInexistent
        return
    endif
    if s:cursorCol == -1
        " let cursorRestore = 1
        let li0 = line('.')
        let co0 = col('.')
        let co1 = co0 - 1
    else
        " let cursorRestore = 0
        let li0 = s:cursorLine
        let co0 = s:cursorCol
        let co1 = co0 - 2
    end
    if a:0 >= 2 && a:2 > 0 && synIDattr(synID(li0, co1, 1), 'name') !~ '^viki.*Link$'
        return
    endif

    let lazyredraw = &lazyredraw
    set lazyredraw

    let maxcol = a:0 >= 1 ? (a:1 == -1 ? 9999999 : a:1) : 9999999

    if a:line1 > 0
        keepjumps call cursor(a:line1, 1)
        let min = a:line1
    else
        go
        let min = 1
    endif
    let max = a:line2 > 0 ? a:line2 : line('$')

    if line('.') == 1 && line('$') == max
        let b:vikiNamesNull = []
        let b:vikiNamesOk   = []
    else
        if !exists('b:vikiNamesNull') | let b:vikiNamesNull = [] | endif
        if !exists('b:vikiNamesOk')   | let b:vikiNamesOk   = [] | endif
    endif
    let b:vikiNamesNull0 = copy(b:vikiNamesNull)
    let b:vikiNamesOk0   = copy(b:vikiNamesOk)

    let feedback = (max - min) > b:vikiFeedbackMin
    let b:vikiMarkingInexistent = 1
    try
        if feedback
            call tlib#progressbar#Init(line('$'), 'Viki: Mark inexistent %s', 20)
        endif

        " if line('.') == 1
        "     keepjumps norm! G$
        " else
        "     keepjumps norm! k$
        " endif

        let rx = viki#FindRx()
        let pp = 0
        let ll = 0
        let cc = 0
        keepjumps let li = search(rx, 'Wc', max)
        let co = col('.')
        while li != 0 && !(ll == li && cc == co) && li >= min && li <= max && co <= maxcol
            let lic = line('.')
            if synIDattr(synID(lic, col('.'), 1), "name") !~ '^vikiFiles'
                if feedback
                    call tlib#progressbar#Display(lic)
                endif
                let ll  = li
                let co1 = co - 1
                " TLogVAR co1
                let def = viki#GetLink(1, getline('.'), co1)
                " TAssert IsList(def)
                " TLogDBG getline('.')[co1 : -1]
                " TLogVAR def
                if empty(def)
                    echom 'Internal error: VikiMarkInexistent: '. co .' '. getline('.')
                else
                    exec viki#SplitDef(def)
                    " TLogVAR v_part
                    if v_part =~ '^'. b:vikiSimpleNameSimpleRx .'$'
                        if v_dest =~ g:vikiSpecialProtocols
                            " TLogDBG "v_dest =~ g:vikiSpecialProtocols => 0"
                            let check = 0
                        elseif v:version >= 700 && viki#IsHyperWord(v_part)
                            " TLogDBG "viki#IsHyperWord(v_part) => 0"
                            let check = 0
                        elseif v_name == g:vikiSelfRef
                            " TLogDBG "simple self ref"
                            let check = 0
                        else
                            " TLogDBG "else1 => 1"
                            let check = 1
                            let partx = escape(v_part, "'\"\\/")
                            if partx !~ '^\['
                                let partx = '\<'.partx
                            endif
                            if partx !~ '\]$'
                                let partx = partx.'\>'
                            endif
                        endif
                    elseif v_dest =~ '^'. b:vikiUrlSimpleRx .'$'
                        " TLogDBG "v_dest =~ '^'. b:vikiUrlSimpleRx .'$' => 0"
                        let check = 0
                        let partx = escape(v_part, "'\"\\/")
                        call filter(b:vikiNamesNull, 'v:val != partx')
                        if index(b:vikiNamesOk, partx) == -1
                            call insert(b:vikiNamesOk, partx)
                        endif
                    elseif v_part =~ b:vikiExtendedNameSimpleRx
                        if v_dest =~ '^'. g:vikiSpecialProtocols .':'
                            " TLogDBG "v_dest =~ '^'. g:vikiSpecialProtocols .':' => 0"
                            let check = 0
                        else
                            " TLogDBG "else2 => 1"
                            let check = 1
                            let partx = escape(v_part, "'\"\\/")
                        endif
                        " elseif v_part =~ b:vikiCmdSimpleRx
                        " <+TODO+>
                    else
                        " TLogDBG "else3 => 0"
                        let check = 0
                    endif
                    " TLogVAR check, v_dest
                    " if check && v_dest != "" && v_dest != g:vikiSelfRef && !isdirectory(v_dest)
                    if check && v_dest != g:vikiSelfRef && !isdirectory(v_dest)
                        if filereadable(v_dest)
                            call filter(b:vikiNamesNull, 'v:val != partx')
                            if index(b:vikiNamesOk, partx) == -1
                                call insert(b:vikiNamesOk, partx)
                            endif
                        else
                            if index(b:vikiNamesNull, partx) == -1
                                call insert(b:vikiNamesNull, partx)
                            endif
                            call filter(b:vikiNamesOk, 'v:val != partx')
                        endif
                        " TLogVAR partx, b:vikiNamesNull, b:vikiNamesOk
                    endif
                endif
                unlet! def
            endif
            keepjumps let li = search(rx, 'W', max)
            let co = col('.')
        endwh
        if b:vikiNamesOk0 != b:vikiNamesOk || b:vikiNamesNull0 != b:vikiNamesNull
            call viki#HighlightInexistent()
            if tlib#var#Get('vikiCacheInexistent', 'wbg')
                call viki#SaveCache()
            endif
        endif
        let b:vikiCheckInexistent = 0
    finally
        " if cursorRestore && !s:cursorSet
        "     call viki#RestoreCursorPosition(li0, co0)
        " endif
        if feedback
            call tlib#progressbar#Restore()
        endif
        let &lazyredraw = lazyredraw
        unlet! b:vikiMarkingInexistent
    endtry
endf

" Actually highlight inexistent file names
function! viki#HighlightInexistent() "{{{3
    if b:vikiMarkInexistent == 1
        if exists('b:vikiNamesNull')
            exe 'syntax clear '. b:vikiInexistentHighlight
            let rx = viki#RxFromCollection(b:vikiNamesNull)
            if rx != ''
                exe 'syntax match '. b:vikiInexistentHighlight .' /'. rx .'/'
            endif
        endif
    elseif b:vikiMarkInexistent == 2
        if exists('b:vikiNamesOk')
            syntax clear vikiOkLink
            syntax clear vikiExtendedOkLink
            let rx = viki#RxFromCollection(b:vikiNamesOk)
            if rx != ''
                exe 'syntax match vikiOkLink /'. rx .'/'
            endif
        endif
    endif
endf

" Check a text element for inexistent names
if v:version == 700 && !has('patch8')
    function! s:SID()
        let fullname = expand("<sfile>")
        return matchstr(fullname, '<SNR>\d\+_')
    endf

    function! viki#MarkInexistentInElement(elt) "{{{3
        let lr = &lazyredraw
        set lazyredraw
        call viki#SaveCursorPosition()
        let kpk = s:SID() . "MarkInexistentIn" . a:elt
        call {kpk}()
        call viki#RestoreCursorPosition()
        call s:ResetSavedCursorPosition()
        let &lazyredraw = lr
        return ''
    endf
else
    function! viki#MarkInexistentInElement(elt) "{{{3
        let lr = &lazyredraw
        set lazyredraw
        " let pos = getpos('.')
        " TLogVAR pos
        try
            call viki#SaveCursorPosition()
            call s:MarkInexistentIn{a:elt}()
            call viki#RestoreCursorPosition()
            call s:ResetSavedCursorPosition()
            return ''
        finally
            " TLogVAR pos
            " call setpos('.', pos)
            let &lazyredraw = lr
        endtry
    endf
endif

function! viki#MarkInexistentInRange(line1, line2) "{{{3
    let lr = &lazyredraw
    set lazyredraw
    " let pos = getpos('.')
    " TLogVAR pos
    try
        call viki#SaveCursorPosition()
        call s:MarkInexistent(a:line1, a:line2)
        call viki#RestoreCursorPosition()
        call s:ResetSavedCursorPosition()
        " call s:MarkInexistent(a:line1, a:line2)
    finally
        " TLogVAR pos
        " call setpos('.', pos)
        let &lazyredraw = lr
    endtry
endf

function! s:MarkInexistentInParagraph() "{{{3
    if getline('.') =~ '\S'
        call s:MarkInexistent(line("'{"), line("'}"))
    endif
endf

function! s:MarkInexistentInDocument() "{{{3
    call s:MarkInexistent(1, line("$"))
endf

function! s:MarkInexistentInParagraphVisible() "{{{3
    let l0 = max([line("'{"), line("w0")])
    " let l1 = line("'}")
    let l1 = line(".")
    call s:MarkInexistent(l0, l1)
endf

function! s:MarkInexistentInParagraphQuick() "{{{3
    let l0 = line("'{")
    let l1 = line("'}")
    call s:MarkInexistent(l0, l1, -1, 1)
endf

function! s:MarkInexistentInLine() "{{{3
    call s:MarkInexistent(line("."), line("."))
endf

function! s:MarkInexistentInLineQuick() "{{{3
    call s:MarkInexistent(line("."), line("."), (col('.') + 1), 1)
endf

" Set values for the cache
function! s:CValsSet(cvals, var) "{{{3
    if exists('b:'. a:var)
        let a:cvals[a:var] = b:{a:var}
    endif
endf

" First-time markup of inexistent names. Handles cached values. Called 
" from syntax/viki.vim
function! viki#MarkInexistentInitial() "{{{3
    " let save_inexistent = 0
    if tlib#var#Get('vikiCacheInexistent', 'wbg')
        let cfile = tlib#cache#Filename('viki_inexistent', '', 1)
        " TLogVAR cfile
        if getftime(cfile) < getftime(expand('%:p'))
            " let cfile = ''
            " let save_inexistent = 1
        elseif !empty(cfile)
        " if !empty(cfile)
            let cvals = tlib#cache#Get(cfile)
            " TLogVAR cvals
            if !empty(cvals)
                for [key, value] in items(cvals)
                    let b:{key} = value
                    unlet value
                endfor
                call viki#HighlightInexistent()
                return
            endif
        endif
    else
        let cfile = ''
    endif
    call viki#MarkInexistentInElement('Document')
    " if save_inexistent
    "     call viki#SaveCache(cfile)
    " endif
endf

function! viki#SaveCache(...) "{{{3
    if tlib#var#Get('vikiCacheInexistent', 'wbg')
        let cfile = a:0 >= 1 ? a:1 : tlib#cache#Filename('viki_inexistent', '', 1)
        if !empty(cfile)
            " TLogVAR cfile
            let cvals = {}
            call s:CValsSet(cvals, 'vikiNamesNull')
            call s:CValsSet(cvals, 'vikiNamesOk')
            call s:CValsSet(cvals, 'vikiInexistentHighlight')
            call s:CValsSet(cvals, 'vikiMarkInexistent')
            call tlib#cache#Save(cfile, cvals)
        endif
    endif
endf

" The function called from autocommands: re-check for inexistent names 
" when re-entering a buffer.
function! viki#CheckInexistent() "{{{3
    if g:vikiEnabled && exists("b:vikiCheckInexistent") && b:vikiCheckInexistent > 0
        call viki#MarkInexistentInRange(b:vikiCheckInexistent, b:vikiCheckInexistent)
    endif
endf

" Initialize buffer-local variables on the basis of other variables "..." 
" or from a global variable.
function! viki#SetBufferVar(name, ...) "{{{3
    if !exists('b:'.a:name)
        if a:0 > 0
            let i = 1
            while i <= a:0
                exe 'let altVar = a:'. i
                if altVar[0] == '*'
                    exe 'let b:'.a:name.' = '. strpart(altVar, 1)
                    return
                elseif exists(altVar)
                    exe 'let b:'.a:name.' = '. altVar
                    return
                endif
                let i = i + 1
            endwh
            throw 'VikiSetBuffer: Couldn't set '. a:name
        else
            exe 'let b:'.a:name.' = g:'.a:name
        endif
    endif
endf

" Get some vimscript code to set a variable from either a buffer-local or 
" a global variable
function! s:LetVar(name, var) "{{{3
    if exists('b:'.a:var)
        return 'let '.a:name.' = b:'.a:var
    elseif exists('g:'.a:var)
        return 'let '.a:name.' = g:'.a:var
    else
        return ''
    endif
endf

" Call a fn.family if existent, call fn otherwise.
" viki#DispatchOnFamily(fn, ?family='', *args)
function! viki#DispatchOnFamily(fn, ...) "{{{3
    let fam = a:0 >= 1 && a:1 != '' ? a:1 : viki#Family()
    if !exists('g:loaded_viki_'. fam)
        exec 'runtime autoload/viki_'. fam .'.vim'
    endif
    if fam == '' || !exists('*viki_'.fam.'#'.a:fn)
        let cmd = 'viki'
    else
        let cmd = fam
    endif
    let cmd .= '#'. a:fn
    if a:0 >= 2
        let args = join(map(range(2, a:0), 'string(a:{v:val})'), ', ')
    else
        let args = ''
    endif
    " TLogDBG args
    " TLogDBG cmd .'('. args .')'
    exe 'return viki_'. cmd .'('. args .')'
endf

function! viki#IsHyperWord(word) "{{{3
    if !exists('b:vikiHyperWordTable')
        return 0
    endif
    return has_key(b:vikiHyperWordTable, s:CanonicHyperWord(a:word))
endf

function! viki#HyperWordValue(word) "{{{3
    return b:vikiHyperWordTable[s:CanonicHyperWord(a:word)]
endf

function! s:CanonicHyperWord(word) "{{{3
    " return substitute(a:word, '\s\+', '\\s\\+', 'g')
    return substitute(a:word, '\s\+', ' ', 'g')
endf

function! viki#CollectFileWords(table, simpleWikiName) "{{{3
    let patterns = []
    if exists('b:vikiNameSuffix')
        call add(patterns, b:vikiNameSuffix)
    endif
    if g:vikiNameSuffix != '' && index(patterns, g:vikiNameSuffix) == -1
        call add(patterns, g:vikiNameSuffix)
    end
    let suffix = '.'. expand('%:e')
    if suffix != '.' && index(patterns, suffix) == -1
        call add(patterns, suffix)
    end
    for p in patterns
        let files = glob(expand('%:p:h').'/*'. p)
        if files != ''
            let files_l = split(files, '\n')
            call filter(files_l, '!isdirectory(v:val) && v:val != expand("%:p")')
            if !empty(files_l)
                for w in files_l
                    let ww = s:CanonicHyperWord(fnamemodify(w, ":t:r"))
                    if !has_key(a:table, ww) && 
                                \ (a:simpleWikiName == '' || ww !~# a:simpleWikiName)
                        let a:table[ww] = w
                    endif
                endfor
            endif
        endif
    endfor
endf


function! viki#CollectHyperWords(table) "{{{3
    let vikiWordsBaseDir = expand('%:p:h')
    for filename in g:vikiHyperWordsFiles
        if filename =~ '^\./'
            let bn  = fnamemodify(filename, ':t')
            let filename = vikiWordsBaseDir . filename[1:-1]
            let acc = []
            for dir in tlib#file#Split(vikiWordsBaseDir)
                call add(acc, dir)
                let fn = tlib#file#Join(add(copy(acc), bn))
                call s:CollectVikiWords(a:table, fn, vikiWordsBaseDir)
            endfor
        else
            call s:CollectVikiWords(a:table, filename, vikiWordsBaseDir)
        endif
    endfor
endf


function! s:CollectVikiWords(table, filename, basedir) "{{{3
    " TLogVAR a:filename, a:basedir
    if filereadable(a:filename)
        let dir = fnamemodify(a:filename, ':p:h')
        " TLogVAR dir
        call tlib#dir#Push(dir, 1)
        try
            let hyperWords = readfile(a:filename)
            for wl in hyperWords
                if wl =~ '^\s*%'
                    continue
                endif
                let ml = matchlist(wl, '^\(.\{-}\) *\t\+ *\(.\+\)$')
                " let ml = matchlist(wl, '^\(\S\+\) *\t\+ *\(.\+\)$')
                " let ml = matchlist(wl, '^\(\S\+\)[[:space:]]\+\(.\+\)$')
                if !empty(ml)
                    let mkey = s:CanonicHyperWord(ml[1])
                    let mval = ml[2]
                    if mval == '-'
                        if has_key(a:table, mkey)
                            call remove(a:table, mkey)
                        endif
                    elseif !has_key(a:table, mkey)
                        " TLogVAR mval
                        " call TLogDBG(viki#IsInterViki(mval))
                        if viki#IsInterViki(mval)
                            let interviki = viki#InterVikiName(mval)
                            let suffix    = viki#InterVikiSuffix(mval, interviki)
                            let name      = viki#InterVikiPart(mval)
                            " TLogVAR mkey, interviki, suffix, name
                            let a:table[mkey] = {
                                        \ 'interviki': interviki,
                                        \ 'suffix':    suffix,
                                        \ 'name':      name,
                                        \ }
                        else
                            let a:table[mkey] = tlib#file#Relative(mval, a:basedir)
                            " TLogVAR mkey, mval, a:basedir, a:table[mkey]
                        endif
                    endif
                endif
            endfor
        finally
            call tlib#dir#Pop()
        endtry
    endif
endf

" Get a rx that matches a simple name
function! viki#GetSimpleRx4SimpleWikiName() "{{{3
    let upper = s:UpperCharacters()
    let lower = s:LowerCharacters()
    let simpleWikiName = '\<['.upper.']['.lower.']\+\(['.upper.']['.lower.'0-9]\+\)\+\>'
    " This will mistakenly highlight words like LaTeX
    " let simpleWikiName = '\<['.upper.']['.lower.']\+\(['.upper.']['.lower.'0-9]\+\)\+'
    return simpleWikiName
endf

" Return a viki name for a vikiname on a specified interviki
" viki#MakeName(iviki, name, ?quote=1)
function! viki#MakeName(iviki, name, ...) "{{{3
    let quote = a:0 >= 1 ? a:1 : 1
    let name  = a:name
    if quote && name !~ '\C'. viki#GetSimpleRx4SimpleWikiName()
        let name = '[-'. name .'-]'
    endif
    if a:iviki != ''
        let name = a:iviki .'::'. name
    endif
    return name
endf

" Return a string defining upper-case characters
function! s:UpperCharacters() "{{{3
    return exists('b:vikiUpperCharacters') ? b:vikiUpperCharacters : g:vikiUpperCharacters
endf

" Return a string defining lower-case characters
function! s:LowerCharacters() "{{{3
    return exists('b:vikiLowerCharacters') ? b:vikiLowerCharacters : g:vikiLowerCharacters
endf

" Remove backslashes from string
function! s:StripBackslash(string) "{{{3
    return substitute(a:string, '\\\(.\)', '\1', 'g')
endf

" Map a key that triggers checking for inexistent names
function! viki#MapMarkInexistent(key, element) "{{{3
    if a:key == "\n"
        let key = '<cr>'
    elseif a:key == ' '
        let key = '<space>'
    else
        let key = a:key
    endif
    let arg = maparg(key, 'i')
    if arg == ''
        let arg = key
    endif
    let map = '<c-r>=viki#MarkInexistentInElement("'. a:element .'")<cr>'
    let map = stridx(g:vikiMapBeforeKeys, a:key) != -1 ? arg.map : map.arg
    exe 'inoremap <silent> <buffer> '. key .' '. map
endf


" In case this function gets called repeatedly for the same position, check only once.
let s:hookcursormoved_oldpos = []
function! viki#HookCheckPreviousPosition(mode) "{{{3
    " if a:mode == 'n'
    if s:hookcursormoved_oldpos != b:hookcursormoved_oldpos
        keepjumps keepmarks call s:MarkInexistent(b:hookcursormoved_oldpos[1], b:hookcursormoved_oldpos[1])
        let s:hookcursormoved_oldpos = b:hookcursormoved_oldpos
    endif
endf


" Restore the cursor position
" TODO: adapt for vim7
" viki#RestoreCursorPosition(?line, ?VCol, ?EOL, ?Winline)
function! viki#RestoreCursorPosition(...) "{{{3
    " let li  = a:0 >= 1 && a:1 != '' ? a:1 : s:cursorLine
    " " let co  = a:0 >= 2 && a:2 != '' ? a:2 : s:cursorVCol
    " let co  = a:0 >= 2 && a:2 != '' ? a:2 : s:cursorCol
    " " let eol = a:0 >= 3 && a:3 != '' ? a:3 : s:cursorEol
    " let wli = a:0 >= 4 && a:4 != '' ? a:4 : s:cursorWinTLine
    let li  = s:cursorLine
    let co  = s:cursorCol
    let wli = s:cursorWinTLine
    if li >= 0
        let ve = &virtualedit
        set virtualedit=all
        if wli > 0
            exe 'keepjumps norm! '. wli .'zt'
        endif
        " TLogVAR li, co
        call cursor(li, co)
        let &virtualedit = ve
    endif
endf

" Save the cursor position
" TODO: adapt for vim7
function! viki#SaveCursorPosition() "{{{3
    let ve = &virtualedit
    set virtualedit=all
    " let s:lazyredraw   = &lazyredraw
    " set nolazyredraw
    let s:cursorSet     = 1
    let s:cursorCol     = col('.')
    let s:cursorEol     = (col('.') == col('$'))
    let s:cursorVCol    = virtcol('.')
    if s:cursorEol
        let s:cursorVCol = s:cursorVCol + 1
    endif
    let s:cursorLine    = line('.')
    keepjumps norm! H
    let s:cursorWinTLine = line('.')
    call cursor(s:cursorLine, s:cursorCol)
    let &virtualedit    = ve
    " call viki#DebugCursorPosition()
    return ''
endf

" Display a debug message
function! viki#DebugCursorPosition(...) "{{{3
    let msg = 'DBG '
    if a:0 >= 1 && a:1 != ''
        let msg = msg . a:1 .' '
    endif
    let msg = msg . "s:cursorCol=". s:cursorCol
                \ ." s:cursorEol=". s:cursorEol
                \ ." ($=". col('$') .')'
                \ ." s:cursorVCol=". s:cursorVCol
                \ ." s:cursorLine=". s:cursorLine
                \ ." s:cursorWinTLine=". s:cursorWinTLine
    if a:0 >= 2 && a:2
        echo msg
    else
        echom msg
    endif
endf

" Check if the key maps should support a specified functionality
function! viki#MapFunctionality(mf, key)
    return a:mf == 'ALL' || (a:mf =~# '\<'. a:key .'\>')
endf

" Re-set minor mode if the buffer is already in viki minor mode.
function! viki#MinorModeReset() "{{{3
    if exists("b:vikiEnabled") && b:vikiEnabled == 1
        call viki#DispatchOnFamily('MinorMode', '', 1)
    endif
endf

" Check whether line is within a region syntax
function! viki#IsInRegion(line) "{{{3
    let i   = 0
    let max = col('$')
    while i < max
        if synIDattr(synID(a:line, i, 1), "name") == "vikiRegion"
            return 1
        endif
        let i = i + 1
    endw
    return 0
endf

" Set back references for use with viki#GoBack()
function! s:SetBackRef(file, li, co) "{{{3
    let br = s:GetBackRef()
    call filter(br, 'v:val[0] != a:file')
    call insert(br, [a:file, a:li, a:co])
endf

" Retrieve a certain back reference
function! s:SelectThisBackRef(n) "{{{3
    return 'let [vbf, vbl, vbc] = s:GetBackRef()['. a:n .']'
endf

" Select a back reference
function! s:SelectBackRef(...) "{{{3
    if a:0 >= 1 && a:1 >= 0
        let s = a:1
    else
        let br  = s:GetBackRef()
        let br0 = map(copy(br), 'v:val[0]')
        let st  = tlib#input#List('s', 'Select Back Reference', br0)
        if st != ''
            let s = index(br0, st)
        else
            let s = -1
        endif
    endif
    if s >= 0
        return s:SelectThisBackRef(s)
    endif
    return ''
endf

" Retrieve information for back references
function! s:GetBackRef()
    if g:vikiSaveHistory
        let id = expand('%:p')
        if empty(id)
            return []
        else
            if !has_key(g:VIKIBACKREFS, id)
                let g:VIKIBACKREFS[id] = []
            endif
            return g:VIKIBACKREFS[id]
        endif
    else
        if !exists('b:VIKIBACKREFS')
            let b:VIKIBACKREFS = []
        endif
        return b:VIKIBACKREFS
    endif
endf

" Jump to the parent buffer (or go back in history)
function! viki#GoParent() "{{{3
    if exists('b:vikiParent')
        call viki#Edit(b:vikiParent)
    else
        call viki#GoBack()
    endif
endf

" Go back in history
function! viki#GoBack(...) "{{{3
    let s  = (a:0 >= 1) ? a:1 : -1
    let br = s:SelectBackRef(s)
    if br == ''
        echomsg "Viki: No back reference defined? (". s ."/". br .")"
    else
        exe br
        let buf = bufnr("^". vbf ."$")
        if buf >= 0
            call s:EditWrapper('buffer', buf)
        else
            call s:EditWrapper('edit', vbf)
        endif
        if vbf == expand("%:p")
            call cursor(vbl, vbc)
        else
            throw "Viki: Couldn't open file: ". vbf
        endif
    endif
endf

" Expand template strings as in
" "foo %{FILE} bar", 'FILE', 'file.txt' => "foo file.txt bar"
function! viki#SubstituteArgs(str, ...) "{{{3
    let i  = 1
    " let rv = escape(a:str, '\')
    let rv = a:str
    let default = ''
    let done = 0
    while a:0 >= i
        exec "let lab = a:". i
        exec "let val = a:". (i+1)
        if lab == ''
            let default = val
        else
            let rv0 = substitute(rv, '\C\(^\|[^%]\)\zs%{'. lab .'}', escape(val, '\~&'), 'g')
            if rv != rv0
                let done = 1
                let rv = rv0
            endif
        endif
        let i = i + 2
    endwh
    if !done
        let rv .= ' '. default
    end
    let rv = substitute(rv, '%%', "%", "g")
    return rv
endf

" Handle special anchors in extented viki names
" Example: [[index#l=10]]
if !exists('*VikiAnchor_l') "{{{2
    function! VikiAnchor_l(arg) "{{{3
        if a:arg =~ '^\d\+$'
            exec a:arg
        endif
    endf
endif

" Example: [[index#line=10]]
if !exists('*VikiAnchor_line') "{{{2
    function! VikiAnchor_line(arg) "{{{3
        call VikiAnchor_l(a:arg)
    endf
endif

" Example: [[index#rx=foo]]
if !exists('*VikiAnchor_rx') "{{{2
    function! VikiAnchor_rx(arg) "{{{3
        let arg = escape(s:StripBackslash(a:arg), '/')
        exec 'keepjumps norm! gg/'. arg .''
    endf
endif

" Example: [[index#vim=/foo]]
if !exists('*VikiAnchor_vim') "{{{2
    function! VikiAnchor_vim(arg) "{{{3
        exec s:StripBackslash(a:arg)
    endf
endif

" Return an rx for searching anchors
function! viki#GetAnchorRx(anchor)
    " TLogVAR a:anchor
    let anchorRx = tlib#var#Get('vikiAnchorMarker', 'wbg') . a:anchor
    if exists('b:vikiEnabled')
        let anchorRx = '\^\s\*\('. b:vikiCommentStart .'\)\?\s\*'. anchorRx
        if exists('b:vikiAnchorRx')
            " !!! b:vikiAnchorRx must be a very nomagic (\V) regexp 
            "     expression
            let varx = viki#SubstituteArgs(b:vikiAnchorRx, 'ANCHOR', a:anchor)
            let anchorRx = '\('.anchorRx.'\|'. varx .'\)'
        endif
    endif
    " TLogVAR anchorRx
    return '\V'. anchorRx
endf

" Set automatic anchor marks: #ma => 'a
function! viki#SetAnchorMarks() "{{{3
    let pos = getpos(".")
    " TLogVAR pos
    let sr  = @/
    let anchorRx = viki#GetAnchorRx('m\zs\[a-zA-Z]\ze\s\*\$')
    " TLogVAR anchorRx
    " exec 'silent keepjumps g /'. anchorRx .'/exec "norm! m". substitute(getline("."), anchorRx, ''\2'', "")'
    exec 'silent keepjumps g /'. anchorRx .'/exec "norm! m". matchstr(getline("."), anchorRx)'
    let @/ = sr
    " TLogVAR pos
    call setpos('.', pos)
endf

" Get the window number where the destination file should be opened
function! viki#GetWinNr(...) "{{{3
    let winNr = a:0 >= 1 ? a:1 : 0
    " TLogVAR winNr
    if type(winNr) == 0 && winNr == 0
        if exists('b:vikiSplit')
            let winNr = b:vikiSplit
        elseif exists('g:vikiSplit')
            let winNr = g:vikiSplit
        else
            let winNr = 0
        endif
    endif
    return winNr
endf

" Set the window where to open a file/display a buffer
function! viki#SetWindow(winNr) "{{{3
    let winNr = viki#GetWinNr(a:winNr)
    " TLogVAR winNr
    if type(winNr) == 1 && winNr == 'tab'
        tabnew
    elseif winNr != 0
        let wm = s:HowManyWindows()
        if winNr == -2
            wincmd v
        elseif wm == 1 || winNr == -1
            wincmd s
        else
            exec winNr ."wincmd w"
        end
    endif
endf

" Open a filename in a certain window and jump to an anchor if any
" viki#OpenLink(filename, anchor, ?create=0, ?postcmd='', ?wincmd=0)
function! viki#OpenLink(filename, anchor, ...) "{{{3
    " TLogVAR a:filename
    let create  = a:0 >= 1 ? a:1 : 0
    let postcmd = a:0 >= 2 ? a:2 : ''
    if a:0 >= 3
        let winNr = a:3
    elseif exists('b:vikiNextWindow')
        let winNr = b:vikiNextWindow
    else
        let winNr = 0
    endif
    " TLogVAR winNr
    
    let li = line('.')
    let co = col('.')
    let fi = expand('%:p')
   
    let filename = fnamemodify(a:filename, ':p')
    if exists('*simplify')
        let filename = simplify(filename)
    endif
    " TLogVAR filename
    let buf = bufnr('^'. filename .'$')
    call viki#SetWindow(winNr)
    if buf >= 0 && bufloaded(buf)
        call s:EditLocalFile('buffer', buf, fi, li, co, a:anchor)
    elseif create && exists('b:createVikiPage')
        call s:EditLocalFile(b:createVikiPage, filename, fi, li, co, g:vikiDefNil)
    elseif exists('b:editVikiPage')
        call s:EditLocalFile(b:editVikiPage, filename, fi, li, co, g:vikiDefNil)
    elseif isdirectory(filename)
        call s:EditLocalFile(g:vikiExplorer, tlib#dir#PlainName(filename), fi, li, co, g:vikiDefNil)
    else
        call s:EditLocalFile('edit', filename, fi, li, co, a:anchor)
    endif
    if postcmd != ''
        exec postcmd
    endif
endf

" Open a local file in vim
function! s:EditLocalFile(cmd, fname, fi, li, co, anchor) "{{{3
    " TLogVAR a:cmd, a:fname
    let vf = viki#Family()
    let cb = bufnr('%')
    call tlib#dir#Ensure(fnamemodify(a:fname, ':p:h'))
    call s:EditWrapper(a:cmd, a:fname)
    if cb != bufnr('%')
        set buflisted
    endif
    if vf != ''
        let b:vikiFamily = vf
    endif
    call s:SetBackRef(a:fi, a:li, a:co)
    if g:vikiPromote && (!exists('b:vikiEnabled') || !b:vikiEnable)
        call viki#DispatchOnFamily('MinorMode', vf, 1)
    endif
    call viki#DispatchOnFamily('FindAnchor', vf, a:anchor)
endf

" Get the current viki family
function! viki#Family(...) "{{{3
    let anyway = a:0 >= 1 ? a:1 : 0
    if (anyway || (exists('b:vikiEnabled') && b:vikiEnabled)) && exists('b:vikiFamily') && !empty(b:vikiFamily)
        return b:vikiFamily
    else
        return g:vikiFamily
    endif
endf

" Return the number of windows
function! s:HowManyWindows() "{{{3
    let i = 1
    while winbufnr(i) > 0
        let i = i + 1
    endwh
    return i - 1
endf

" Decompose an url into filename, anchor, args
function! viki#DecomposeUrl(dest) "{{{3
    let dest = substitute(a:dest, '^\c/*\([a-z]\)|', '\1:', "")
    let rv = ""
    let i  = 0
    while 1
        let in = match(dest, '%\d\d', i)
        if in >= 0
            let c  = "0x".strpart(dest, in + 1, 2)
            let rv = rv. strpart(dest, i, in - i) . nr2char(c)
            let i  = in + 3
        else
            break
        endif
    endwh
    let rv     = rv. strpart(dest, i)
    let uend   = match(rv, '[?#]')
    if uend >= 0
        let args   = matchstr(rv, '?\zs.\+$', uend)
        let anchor = matchstr(rv, '#\zs.\+$', uend)
        let rv     = strpart(rv, 0, uend)
    else
        let args   = ""
        let anchor = ""
        let rv     = rv
    end
    return "let filename='". rv ."'|let anchor='". anchor ."'|let args='". args ."'"
endf

" Get a list of special files' suffixes
function! viki#GetSpecialFilesSuffixes() "{{{3
    " TAssert IsList(g:vikiSpecialFiles)
    if exists("b:vikiSpecialFiles")
        " TAssert IsList(b:vikiSpecialFiles)
        return b:vikiSpecialFiles + g:vikiSpecialFiles
    else
        return g:vikiSpecialFiles
    endif
endf

" Get an rx matching special files' suffixes
function! viki#GetSpecialFilesSuffixesRx(...) "{{{3
    let sfx = a:0 >= 1 ? a:1 : viki#GetSpecialFilesSuffixes()
    return join(sfx, '\|')
endf

" Check if dest is a special file
function! viki#IsSpecialFile(dest) "{{{3
    return (a:dest =~ '\.\('. viki#GetSpecialFilesSuffixesRx() .'\)$' &&
                \ (g:vikiSpecialFilesExceptions == "" ||
                \ !(a:dest =~ g:vikiSpecialFilesExceptions)))
endf

" Check if dest uses a special protocol
function! viki#IsSpecialProtocol(dest) "{{{3
    return a:dest =~ '^\('.b:vikiSpecialProtocols.'\):' &&
                \ (b:vikiSpecialProtocolsExceptions == "" ||
                \ !(a:dest =~ b:vikiSpecialProtocolsExceptions))
endf

" Check if dest is somehow special
function! viki#IsSpecial(dest) "{{{3
    return viki#IsSpecialProtocol(a:dest) || 
                \ viki#IsSpecialFile(a:dest) ||
                \ isdirectory(a:dest)
endf

" Open a viki name/link
function! s:FollowLink(def, ...) "{{{3
    " TLogVAR a:def
    let winNr = a:0 >= 1 ? a:1 : 0
    " TLogVAR winNr
    exec viki#SplitDef(a:def)
    if type(winNr) == 0 && winNr == 0
        " TAssert IsNumber(winNr)
        if exists('v_winnr')
            let winNr = v_winnr
        elseif exists('b:vikiOpenInWindow')
            if b:vikiOpenInWindow =~ '^l\(a\(s\(t\)\?\)\?\)\?'
                let winNr = s:HowManyWindows()
            elseif b:vikiOpenInWindow =~ '^[+-]\?\d\+$'
                if b:vikiOpenInWindow[0] =~ '[+-]'
                    exec 'let winNr = '. bufwinnr("%") . b:vikiOpenInWindow
                else
                    let winNr = b:vikiOpenInWindow
                endif
            endif
        endif
    endif
    let inter = s:GuessInterViki(a:def)
    let bn    = bufnr('%')
    " TLogVAR v_name, v_dest, v_anchor
    if v_name == g:vikiSelfRef || v_dest == g:vikiSelfRef
        call viki#DispatchOnFamily('FindAnchor', '', v_anchor)
    elseif v_dest == g:vikiDefNil
		throw 'No target? '. string(a:def)
    else
        call s:OpenLink(v_dest, v_anchor, winNr)
    endif
    if exists('b:vikiEnabled') && b:vikiEnabled && inter != '' && !exists('b:vikiInter')
        let b:vikiInter = inter
    endif
    return ""
endf

" Actually open a viki name/link
function! s:OpenLink(dest, anchor, winNr)
    let b:vikiNextWindow = a:winNr
    " TLogVAR a:dest, a:anchor, a:winNr
    try
        if viki#IsSpecialProtocol(a:dest)
            let url = viki#MakeUrl(a:dest, a:anchor)
            " TLogVAR url
            call VikiOpenSpecialProtocol(url)
        elseif viki#IsSpecialFile(a:dest)
            call VikiOpenSpecialFile(a:dest)
        elseif isdirectory(a:dest)
            " exec g:vikiExplorer .' '. a:dest
            call viki#OpenLink(a:dest, a:anchor, 0, '', a:winNr)
        elseif filereadable(a:dest) "reference to a local, already existing file
            call viki#OpenLink(a:dest, a:anchor, 0, '', a:winNr)
        elseif bufexists(a:dest) && buflisted(a:dest)
            call s:EditWrapper('buffer!', a:dest)
        else
            let ok = input("File doesn't exists. Create '".a:dest."'? (Y/n) ", "y")
            if ok != "" && ok != "n"
                let b:vikiCheckInexistent = line(".")
                call viki#OpenLink(a:dest, a:anchor, 1, '', a:winNr)
            endif
        endif
    finally
        let b:vikiNextWindow = 0
    endtry
endf

function! viki#MakeUrl(dest, anchor) "{{{3
    if a:anchor == ""
        return a:dest
    else
        " if a:dest[-1:-1] != '/'
        "     let dest = a:dest .'/'
        " else
        "     let dest = a:dest
        " endif
        " return join([dest, a:anchor], '#')
        return join([a:dest, a:anchor], '#')
    endif 
endf

" Guess the interviki name from a viki name definition
function! s:GuessInterViki(def) "{{{3
    exec viki#SplitDef(a:def)
    if v_type == 's'
        let exp = v_name
    elseif v_type == 'e'
        let exp = v_dest
    else
        return ''
    endif
    if viki#IsInterViki(exp)
        return viki#InterVikiName(exp)
    else
        return ''
    endif
endf

" Somewhat pointless legacy function
" TODO: adapt for vim7
function! s:MakeVikiDefPart(txt) "{{{3
    if a:txt == ''
        return g:vikiDefNil
    else
        return a:txt
    endif
endf

" TODO: adapt for vim7
" Return a structure or whatever describing a viki name/link
function! viki#MakeDef(v_name, v_dest, v_anchor, v_part, v_type) "{{{3
    let arr = map([a:v_name, a:v_dest, a:v_anchor, a:v_part, a:v_type, 0], 's:MakeVikiDefPart(v:val)')
    " TLogDBG string(arr)
    return arr
endf

" Legacy function: Today we would use dictionaries for this
" TODO: adapt for vim7
" Return vimscript code that defines a set of variables on the basis of a 
" viki name definition
function! viki#SplitDef(def) "{{{3
    " TAssert IsList(a:def)
    " TLogDBG string(a:def)
    if empty(a:def)
        let rv = 'let [v_name, v_dest, v_anchor, v_part, v_type, v_winnr] = ["", "", "", "", "", ""]'
    else
        if a:def[4] == 'e'
            let mod = viki#ExtendedModifier(a:def[3])
            if mod =~# '*'
                let a:def[5] = -1
            endif
        endif
        let rv = 'let [v_name, v_dest, v_anchor, v_part, v_type, v_winnr] = '. string(a:def)
    endif
    return rv
endf

" Get a viki name's/link's name, destination, or anchor
" function! s:GetVikiNamePart(txt, erx, idx, errorMsg) "{{{3
"     if a:idx
"         " let rv = substitute(a:txt, '^\C'. a:erx ."$", '\'.a:idx, "")
"         let rv = matchlist(a:txt, '^\C'. a:erx ."$")[a:idx]
"         if rv == ''
"             return g:vikiDefNil
"         else
"             return rv
"         endif
"     else
"         return g:vikiDefNil
"     endif
" endf

function! s:ExtractMatch(match, idx, default) "{{{3
    if a:idx > 0
        return get(a:match, a:idx, a:default)
    else
        return a:default
    endif
endf

" If txt matches a viki name typed as defined by compound return a 
" structure defining this viki name.
function! viki#LinkDefinition(txt, col, compound, ignoreSyntax, type) "{{{3
    " TLogVAR a:txt, a:compound, a:col
    exe a:compound
    if erx != ''
        let ebeg = -1
        let cont = match(a:txt, erx, 0)
        " TLogDBG 'cont='. cont .'('. a:col .')'
        while (ebeg >= 0 || (0 <= cont) && (cont <= a:col))
            let contn = matchend(a:txt, erx, cont)
            " TLogDBG 'contn='. contn .'('. cont.')'
            if (cont <= a:col) && (a:col < contn)
                let ebeg = match(a:txt, erx, cont)
                let elen = contn - ebeg
                break
            else
                let cont = match(a:txt, erx, contn)
            endif
        endwh
        " TLogDBG 'ebeg='. ebeg
        if ebeg >= 0
            let part   = strpart(a:txt, ebeg, elen)
            let match  = matchlist(part, '^\C'. erx .'$')
            let name   = s:ExtractMatch(match, nameIdx,   g:vikiDefNil)
            let dest   = s:ExtractMatch(match, destIdx,   g:vikiDefNil)
            let anchor = s:ExtractMatch(match, anchorIdx, g:vikiDefNil)
            " let name   = s:GetVikiNamePart(part, erx, nameIdx,   "no name")
            " let dest   = s:GetVikiNamePart(part, erx, destIdx,   "no destination")
            " let anchor = s:GetVikiNamePart(part, erx, anchorIdx, "no anchor")
            " TLogVAR name, dest, anchor, part, a:type
            return viki#MakeDef(name, dest, anchor, part, a:type)
        elseif a:ignoreSyntax
            return []
        else
            throw "Viki: Malformed viki v_name: " . a:txt . " (". erx .")"
        endif
    else
        return []
    endif
endf

" Return a viki filename with a suffix
function! viki#WithSuffix(fname)
    " TLogVAR a:fname
    " TLogDBG isdirectory(a:fname)
    if isdirectory(a:fname)
        return a:fname
    else
        return a:fname . s:GetSuffix()
    endif
endf

" Get the suffix to use for viki filenames
function! s:GetSuffix() "{{{3
    if exists('b:vikiNameSuffix')
        return b:vikiNameSuffix
    endif
    if g:vikiUseParentSuffix
        let sfx = expand("%:e")
        " TLogVAR sfx
        if !empty(sfx)
            return '.'. sfx
        endif
    endif
    return g:vikiNameSuffix
endf

" Return the real destination for a simple viki name
function! viki#ExpandSimpleName(dest, name, suffix) "{{{3
    " TLogVAR a:dest
    if a:name == ''
        return a:dest
    else
        if a:dest == ''
            let dest = a:name
        else
            let dest = a:dest . g:vikiDirSeparator . a:name
        endif
        " TLogVAR dest, a:suffix
        if a:suffix == g:vikiDefSep
            " TLogDBG 'ExpandSimpleName 1'
            return viki#WithSuffix(dest)
        elseif isdirectory(dest)
            " TLogDBG 'ExpandSimpleName 2'
            return dest
        else
            " TLogDBG 'ExpandSimpleName 3'
            return dest . a:suffix
        endif
    endif
endf

" Check whether a vikiname uses an interviki
function! viki#IsInterViki(vikiname)
    return  viki#IsSupportedType('i') && a:vikiname =~# s:InterVikiRx
endf

" Get the interviki name of a vikiname
function! viki#InterVikiName(vikiname)
    " return substitute(a:vikiname, s:InterVikiRx, '\1', '')
    return matchlist(a:vikiname, s:InterVikiRx)[1]
endf

" Get the plain vikiname of a vikiname
function! viki#InterVikiPart(vikiname)
    " return substitute(a:vikiname, s:InterVikiRx, '\2', '')
    return matchlist(a:vikiname, s:InterVikiRx)[2]
endf

" Return vimscript code describing an interviki
function! s:InterVikiDef(vikiname, ...)
    let ow = a:0 >= 1 ? a:1 : viki#InterVikiName(a:vikiname)
    let vd = s:LetVar('i_dest', 'vikiInter'.ow)
    let id = s:LetVar('i_index', 'vikiInter'.ow.'_index')
    " TLogVAR a:vikiname, ow, id
    if !empty(id)
        let vd .= '|'. id
    endif
    " TLogVAR vd
    if vd != ''
        exec vd
        if i_dest =~ '^\*\S\+('
            let it = 'fn'
        elseif i_dest[0] =~ '%'
            let it = 'fmt'
        else
            let it = 'prefix'
        endif
        return vd .'|let i_type="'. it .'"|let i_name="'. ow .'"'
    end
    return vd
endf

" Return an interviki's root directory
function! viki#InterVikiDest(vikiname, ...)
    TVarArg 'ow', ['rx', 0]
    " TLogVAR ow, rx
    if empty(ow)
        let ow     = viki#InterVikiName(a:vikiname)
        let v_dest = viki#InterVikiPart(a:vikiname)
    else
        let v_dest = a:vikiname
    endif
    let vd = s:InterVikiDef(a:vikiname, ow)
    " TLogVAR vd
    if vd != ''
        exec vd
        let f = strpart(i_dest, 1)
        " TLogVAR i_type, i_dest
        if !empty(rx)
            let f = s:RxifyFilename(f)
        endif
        if i_type == 'fn'
            exec 'let v_dest = '. s:sprintf1(f, v_dest)
        elseif i_type == 'fmt'
            let v_dest = s:sprintf1(f, v_dest)
        else
            if empty(v_dest) && exists('i_index')
                let v_dest = i_index
            endif
            let i_dest = expand(i_dest)
            if !empty(rx)
                let sep    = '[\/]'
                let i_dest = s:RxifyFilename(i_dest)
            else
                let sep    = g:vikiDirSeparator
            endif
            let v_dest = i_dest . sep . v_dest
        endif
        " TLogVAR v_dest
        return v_dest
    else
        " TLogVAR ow
        echohl Error
        echom "Viki: InterViki is not defined: ". ow
        echohl NONE
        return g:vikiDefNil
    endif
endf

function! s:RxifyFilename(filename) "{{{3
    let f = tlib#rx#Escape(a:filename)
    if exists('+shellslash')
        let f = substitute(f, '\(\\\\\|/\)', '[\\/]', 'g')
    endif
    return f
endf

" Return an interviki's suffix
function! viki#InterVikiSuffix(vikiname, ...)
    exec tlib#arg#Let(['ow'])
    if empty(ow)
        let ow = viki#InterVikiName(a:vikiname)
    endif
    let vd = s:InterVikiDef(a:vikiname, ow)
    if vd != ''
        exec vd
        if i_type =~ 'fn'
            return ''
        else
            if fnamemodify(a:vikiname, ':e') != ''
                let useSuffix = ''
            else
                exec s:LetVar('useSuffix', 'vikiInter'.ow.'_suffix')
            endif
            return useSuffix
        endif
    else
        return ''
    endif
endf

" Return the modifiers in extended viki names
function! viki#ExtendedModifier(part)
    " let mod = substitute(a:part, b:vikiExtendedNameRx, '\'.b:vikiExtendedNameModIdx, '')
    let mod = matchlist(a:part, b:vikiExtendedNameRx)[b:vikiExtendedNameModIdx]
    if mod != a:part
        return mod
    else
        return ''
    endif
endf

" Complete a file's basename on the basis of a list of suffixes
function! viki#FindFileWithSuffix(filename, suffixes) "{{{3
    " TAssert IsList(a:suffixes)
    " TLogVAR a:filename, a:suffixes
    if filereadable(a:filename)
        return a:filename
    else
        for elt in a:suffixes
            if elt != ''
                let fn = a:filename .".". elt
                if filereadable(fn)
                    return fn
                endif
            else
                return g:vikiDefNil
            endif
        endfor
    endif
    return g:vikiDefNil
endf

" Do something if no viki name was found under the cursor position
function! s:LinkNotFoundEtc(oldmap, ignoreSyntax) "{{{3
    if a:oldmap == ""
        echomsg "Viki: Show me the way to the next viki name or I have to ... ".a:ignoreSyntax.":".getline(".")
    elseif a:oldmap == 1
        return "\<c-cr>"
    else
        return a:oldmap
    endif
endf

" This is the core function that builds a viki name definition from what 
" is under the cursor.
" viki#GetLink(ignoreSyntax, ?txt, ?col=0, ?supported=b:vikiNameTypes)
function! viki#GetLink(ignoreSyntax, ...) "{{{3
    let col   = a:0 >= 2 ? a:2 : 0
    let types = a:0 >= 3 ? a:3 : b:vikiNameTypes
    if a:0 >= 1 && a:1 != ''
        let txt      = a:1
        let vikiType = a:ignoreSyntax
        let tryAll   = 1
    else
        let synName = synIDattr(synID(line('.'), col('.'), 0), 'name')
        if synName ==# 'vikiLink'
            let vikiType = 1
            let tryAll   = 0
        elseif synName ==# 'vikiExtendedLink'
            let vikiType = 2
            let tryAll   = 0
        elseif synName ==# 'vikiURL'
            let vikiType = 3
            let tryAll   = 0
        elseif synName ==# 'vikiCommand' || synName ==# 'vikiMacro'
            let vikiType = 4
            let tryAll   = 0
        elseif a:ignoreSyntax
            let vikiType = a:ignoreSyntax
            let tryAll   = 1
        else
            return ''
        endif
        let txt = getline('.')
        let col = col('.') - 1
    endif
    " TLogDBG "txt=". txt
    " TLogDBG "col=". col
    " TLogDBG "tryAll=". tryAll
    " TLogDBG "vikiType=". tryAll
    if (tryAll || vikiType == 2) && viki#IsSupportedType('e', types)
        if exists('b:getExtVikiLink')
            exe 'let def = ' . b:getExtVikiLink.'()'
        else
            let def = viki#LinkDefinition(txt, col, b:vikiExtendedNameCompound, a:ignoreSyntax, 'e')
        endif
        " TAssert IsList(def)
        if !empty(def)
            return viki#DispatchOnFamily('CompleteExtendedNameDef', '', def)
        endif
    endif
    if (tryAll || vikiType == 3) && viki#IsSupportedType('u', types)
        if exists('b:getURLViki')
            exe 'let def = ' . b:getURLViki . '()'
        else
            let def = viki#LinkDefinition(txt, col, b:vikiUrlCompound, a:ignoreSyntax, 'u')
        endif
        " TAssert IsList(def)
        if !empty(def)
            return viki#DispatchOnFamily('CompleteExtendedNameDef', '', def)
        endif
    endif
    if (tryAll || vikiType == 4) && viki#IsSupportedType('x', types)
        if exists('b:getCmdViki')
            exe 'let def = ' . b:getCmdViki . '()'
        else
            let def = viki#LinkDefinition(txt, col, b:vikiCmdCompound, a:ignoreSyntax, 'x')
        endif
        " TAssert IsList(def)
        if !empty(def)
            return viki#DispatchOnFamily('CompleteCmdDef', '', def)
        endif
    endif
    if (tryAll || vikiType == 1) && viki#IsSupportedType('s', types)
        if exists('b:getVikiLink')
            exe 'let def = ' . b:getVikiLink.'()'
        else
            let def = viki#LinkDefinition(txt, col, b:vikiSimpleNameCompound, a:ignoreSyntax, 's')
        endif
        " TLogVAR def
        " TAssert IsList(def)
        if !empty(def)
            return viki#DispatchOnFamily('CompleteSimpleNameDef', '', def)
        endif
    endif
    return []
endf

" Follow a viki name if any or complain about not having found a valid 
" viki name under the cursor.
" viki#MaybeFollowLink(oldmap, ignoreSyntax, ?winNr=0)
function! viki#MaybeFollowLink(oldmap, ignoreSyntax, ...) "{{{3
    let winNr = a:0 >= 1 ? a:1 : 0
    " TLogVAR winNr
    let def = viki#GetLink(a:ignoreSyntax)
    " TAssert IsList(def)
    if empty(def)
        return s:LinkNotFoundEtc(a:oldmap, a:ignoreSyntax)
    else
        return s:FollowLink(def, winNr)
    endif
endf


function! viki#InterEditArg(iname, name) "{{{3
    if a:name !~ '^'. tlib#rx#Escape(a:iname) .'::'
        return a:iname .'::'. a:name
    else
        return a:name
    endif
endf


" Edit a vikiname
" viki#Edit(name, ?bang='', ?winNr=0, ?ìgnoreSpecial=0)
function! viki#Edit(name, ...) "{{{3
    TVarArg ['bang', ''], ['winNr', 0], ['ignoreSpecial', 0]
    " TLogVAR a:name
    if exists('b:vikiEnabled') && bang != '' && 
                \ exists('b:vikiFamily') && b:vikiFamily != ''
                " \ (!exists('b:vikiFamily') || b:vikiFamily != '')
        if g:vikiHomePage != ''
            call viki#OpenLink(g:vikiHomePage, '', '', '', winNr)
        else
            call s:EditWrapper('buffer', 1)
        endif
    endif
    if a:name == '*'
        let name = g:vikiHomePage
    else
        let name = a:name
    end
    let name = substitute(name, '\\', '/', 'g')
    if !exists('b:vikiNameTypes')
        call viki#SetBufferVar('vikiNameTypes')
        call viki#DispatchOnFamily('SetupBuffer', '', 0)
    endif
    let def = viki#GetLink(1, '[['. name .']]', 0, '')
    " TLogVAR def
    " TAssert IsList(def)
    if empty(def)
        call s:LinkNotFoundEtc('', 1)
    else
        exec viki#SplitDef(def)
        if ignoreSpecial
            call viki#OpenLink(v_dest, '', '', '', winNr)
        else
            call s:OpenLink(v_dest, '', winNr)
        endif
    endif
endf


function! viki#Browse(name) "{{{3
    " TLogVAR a:name
    let iname = a:name .'::'
    let vd = s:InterVikiDef(iname, a:name)
    " TLogVAR vd
    if !empty(vd)
        exec vd
        " TLogVAR i_type
        if i_type == 'prefix'
            exec s:LetVar('sfx', 'vikiInter'. a:name .'_suffix')
            " TLogVAR i_dest, sfx
            let files = split(globpath(i_dest, '**'), '\n')
            if !empty(sfx)
                call filter(files, 'v:val =~ '''. tlib#rx#Escape(sfx) .'$''')
            endif
            let files = tlib#input#List('m', 'Select files', files, [
                        \ {'display_format': 'filename'},
                        \ ])
            for fn in files
                call viki#OpenLink(fn, g:vikiDefNil)
                " echom fn
            endfor
            return
        endif
    endif
    echoerr 'Viki: No an interviki name: '. a:name
endf

function! viki#BrowseComplete(ArgLead, CmdLine, CursorPos) "{{{3
    let rv = copy(s:InterVikis)
    let rv = filter(rv, 'v:val =~ ''^'. a:ArgLead .'''')
    let rv = map(rv, 'matchstr(v:val, ''\w\+'')')
    return rv
endf


" Helper function for the command line completion of :VikiEdit
function! s:EditCompleteAgent(interviki, afname, fname) "{{{3
    if isdirectory(a:afname)
        return a:afname .'/'
    else
        if exists('g:vikiInter'. a:interviki .'_suffix')
            let sfx = g:vikiInter{a:interviki}_suffix
        else
            let sfx = s:GetSuffix()
        endif
        if sfx != '' && sfx == '.'. fnamemodify(a:fname, ':e')
            let name = fnamemodify(a:fname, ':t:r')
        else
            let name = a:fname
        endif
        " if name !~ '\C'. viki#GetSimpleRx4SimpleWikiName()
        "     let name = '[-'. a:fname .'-]'
        " endif
        if a:interviki != ''
            let name = a:interviki .'::'. name
        endif
        return name
    endif
endf

" Helper function for the command line completion of :VikiEdit
function! s:EditCompleteMapAgent1(val, sfx, iv, rx) "{{{3
    if isdirectory(a:val)
        let rv = a:val .'/'
    else
        let rsfx = '\V'. a:sfx .'\$'
        if a:sfx != '' && a:val !~ rsfx
            return ''
        else
            let rv = substitute(a:val, rsfx, '', '')
            if isdirectory(rv)
                let rv = a:val
            endif
        endif
    endif
    " TLogVAR rv, a:rx
    " let rv = substitute(rv, a:rx, '\1', '')
    let rv = matchlist(rv, a:rx)[1]
    " TLogVAR rv
    if empty(a:iv)
        return rv
    else
        return a:iv .'::'. rv
    endif
endf

" Command line completion of :VikiEdit
function! viki#EditComplete(ArgLead, CmdLine, CursorPos) "{{{3
    " TLogVAR a:ArgLead, a:CmdLine, a:CursorPos
    " let arglead = a:ArgLead
    let rx_pre = '^\s*\(\d*\(verb\|debug\|sil\|sp\|vert\|tab\)\w\+!\?\s\+\)*'
    let arglead = matchstr(a:CmdLine, rx_pre .'\(\u\+\)\s\zs.*')
    let ii = matchstr(a:CmdLine, rx_pre .'\zs\(\u\+\)\ze\s')
    " TLogVAR ii
    if !empty(ii) && arglead !~ '::'
        let arglead = ii.'::'.arglead
    endif
    let i = viki#InterVikiName(arglead)
    " TLogVAR i, arglead
    if index(s:InterVikis, i.'::') >= 0
        if exists('g:vikiInter'. i .'_suffix')
            let sfx = g:vikiInter{i}_suffix
        else
            let sfx = s:GetSuffix()
        endif
    else
        let i = ''
        let sfx = s:GetSuffix()
    endif
    " TLogVAR i
    if i != '' && exists('g:vikiInter'. i)
        " TLogDBG 'A'
        let f  = matchstr(arglead, '::\(\[-\)\?\zs.*$')
        let d  = viki#InterVikiDest(f.'*', i)
        let r  = '^'. viki#InterVikiDest('\(.\{-}\)', i, 1) .'$'
        " TLogVAR f,d,r
        let d  = substitute(d, '\', '/', 'g')
        let rv = split(glob(d), '\n')
        " call map(rv, 'escape(v:val, " ")')
        " TLogVAR d,rv
        if sfx != ''
            call filter(rv, 'isdirectory(v:val) || ".". fnamemodify(v:val, ":e") == sfx')
        endif
        " TLogVAR rv
        call map(rv, 's:EditCompleteMapAgent1(v:val, sfx, i, r)')
        " TLogVAR rv
        call filter(rv, '!empty(v:val)')
        " TLogVAR rv
        " call map(rv, string(i). '."::". substitute(v:val, r, ''\1'', "")')
    else
        " TLogDBG 'B'
        let rv = split(glob(arglead.'*'.sfx), '\n')
        " TLogVAR rv
        call map(rv, 's:EditCompleteAgent('. string(i) .', v:val, v:val)')
        " TLogVAR rv
        " call map(rv, 'escape(v:val, " ")')
        " TLogVAR rv
        if arglead == ''
            let rv += s:InterVikis
        else
            let rv += filter(copy(s:InterVikis), 'v:val =~ ''\V\^''.arglead')
        endif
    endif
    " TLogVAR rv
    " call map(rv, 'substitute(v:val, ''^\(.\{-}\s\ze\S*$'', "", "")')
    " call map(rv, 'escape(v:val, "%# ")')
    return rv
endf

" Edit the current directory's index page
function! viki#Index() "{{{3
    if exists('b:vikiIndex')
        let fname = viki#WithSuffix(b:vikiIndex)
    else
        let fname = viki#WithSuffix(g:vikiIndex)
    endif
    if filereadable(fname)
        return viki#OpenLink(fname, '')
    else
        echom "Index page not found: ". fname
    endif
endf


fun! viki#FindNextRegion(name) "{{{3
    let rx = s:GetRegionStartRx(a:name)
    return search(rx, 'We')
endf


""" indent {{{1
fun! viki#GetIndent()
    let lr = &lazyredraw
    set lazyredraw
    try
        let cnum = v:lnum
        " Find a non-blank line above the current line.
        let lnum = prevnonblank(v:lnum - 1)

        " At the start of the file use zero indent.
        if lnum == 0
            " TLogVAR lnum
            return 0
        endif

        let ind  = indent(lnum)
        " if ind == 0
        "     TLogVAR ind
        "     return 0
        " end

        let line = getline(lnum)      " last line
        " TLogVAR lnum, ind, line
        
        let cind  = indent(cnum)
        let cline = getline(cnum)
        " TLogVAR v:lnum, cnum, cind, cline
        
        " Do not change indentation in regions
        if viki#IsInRegion(cnum)
            " TLogVAR cnum, cind
            return cind
        endif
        
        let cHeading = matchend(cline, '^\*\+\s\+')
        if cHeading >= 0
            " TLogVAR cHeading
            return 0
        endif
            
        let pnum   = v:lnum - 1
        let pind   = indent(pnum)
        let pline  = getline(pnum) " last line
        let plCont = matchend(pline, '\\$')
        
        if plCont >= 0
            " TLogVAR plCont, cind
            return cind
        end
        
        if cind > 0
            " TLogVAR cind
            " Do not change indentation of:
            "   - commented lines
            "   - headings
            if cline =~ '^\(\s*%\|\*\)'
                " TLogVAR cline, ind
                return ind
            endif

            let markRx = '^\s\+\([#?!+]\)\1\{2,2}\s\+'
            let listRx = '^\s\+\([-+*#?@]\|[0-9#]\+\.\|[a-zA-Z?]\.\)\s\+'
            let priRx  = '^\s\+#[A-Z]\d\? \+\([x_0-9%-]\+ \+\)\?'
            let descRx = '^\s\+.\{-1,}\s::\s\+'
            
            let clMark = matchend(cline, markRx)
            let clList = matchend(cline, listRx)
            let clPri  = matchend(cline, priRx)
            let clDesc = matchend(cline, descRx)
            " let cln    = clList >= 0 ? clList : clDesc

			let swhalf = &sw / 2

            if clList >= 0 || clDesc >= 0 || clMark >= 0 || clPri >= 0
                " let spaceEnd = matchend(cline, '^\s\+')
                " let rv = (spaceEnd / &sw) * &sw
                let rv = (cind / &sw) * &sw
                " TLogVAR clList, clDesc, clMark, clPri, rv
                return rv
            else
                let plMark = matchend(pline, markRx)
                if plMark >= 0
                    " TLogVAR plMark
                    " return plMark
                    return pind + 4
                endif
                
                let plList = matchend(pline, listRx)
                if plList >= 0
                    " TLogVAR plList
                    return plList
                endif

                let plPri = matchend(pline, priRx)
                if plPri >= 0
                    " let rv = indent(pnum) + &sw / 2
                    let rv = pind + swhalf
                    " TLogVAR plPri, rv
                    " return plPri
                    return rv
                endif

                let plDesc = matchend(pline, descRx)
                if plDesc >= 0
                    " TLogVAR plDesc, pind
                    if plDesc >= 0 && g:vikiIndentDesc == '::'
                        " return plDesc
                        return pind
                    else
                        return pind + swhalf
                    endif
                endif

                " TLogVAR cind, ind
                if cind < ind
                    let rv = (cind / &sw) * &sw
                    return rv
                elseif cind >= ind
                    if cind % &sw == 0
                        return cind
                    else
                        return ind
                    end
                endif
            endif
        endif

        " TLogVAR ind
        return ind
    finally
        let &lazyredraw = lr
    endtry
endf

function! viki#ExecExternal(cmd) "{{{3
    " TLogVAR a:cmd
    exec a:cmd
    if !has("gui_running")
        " Scrambled window with vim
        redraw!
    endif
endf


""" #Files related stuff {{{1
fun! viki#FilesUpdateAll() "{{{3
    let p = getpos('.')
    try
        norm! gg
        while viki#FindNextRegion('Files')
            call viki#FilesUpdate()
            norm! j
        endwh
    finally
        call setpos('.', p)
    endtry
endf

fun! viki#FilesExec(cmd, bang, ...) "{{{3
    let [lh, lb, le, indent] = s:GetRegionGeometry('Files')
    if a:0 >= 1 && a:1
        let lb = line('.')
        let le = line('.') + 1
    endif
    let ilen = len(indent)
    let done = []
    for f in s:CollectFileNames(lb, le, a:bang)
        let ff = escape(f, '%#\ ')
        let x = viki#SubstituteArgs(a:cmd, 
                    \ '', ff, 
                    \ 'FILE', f, 
                    \ 'FFILE', ff,
                    \ 'DIR', fnamemodify(f, ':h'))
        if index(done, x) == -1
            exec x
            call add(done, x)
        endif
    endfor
endf

fun! viki#FilesCmd(cmd, bang) "{{{3
    let [lh, lb, le, indent] = s:GetRegionGeometry('Files')
    let ilen = len(indent)
    for t in s:CollectFileNames(lb, le, a:bang)
        exec VikiCmd_{a:cmd} .' '. escape(t, '%#\ ')
    endfor
endf

fun! viki#FilesCall(cmd, bang) "{{{3
    let [lh, lb, le, indent] = s:GetRegionGeometry('Files')
    let ilen = len(indent)
    for t in s:CollectFileNames(lb, le, a:bang)
        call VikiCmd_{a:cmd}(t)
    endfor
endf

fun! s:CollectFileNames(lb, le, bang) "{{{3
    let afile = viki#FilesGetFilename(getline('.'))
    let acc   = []
    for l in range(a:lb, a:le - 1)
        let line  = getline(l)
        let bfile = viki#FilesGetFilename(line)
        if s:IsEligibleLine(afile, bfile, a:bang)
            call add(acc, fnamemodify(bfile, ':p'))
        endif
    endfor
    return acc
endf

fun! s:IsEligibleLine(afile, bfile, bang) "{{{3
    if empty(a:bang)
        return 1
    else
        if isdirectory(a:bfile)
            return 0
        else
            let adir  = isdirectory(a:afile) ? a:afile : fnamemodify(a:afile, ':h')
            let bdir  = isdirectory(a:bfile) ? a:bfile : fnamemodify(a:bfile, ':h')
            let rv = s:IsSubdir(adir, bdir)
            return rv
        endif
    endif
endf

fun! s:IsSubdir(adir, bdir) "{{{3
    if a:adir == '' || a:bdir == ''
        return 0
    elseif a:adir == a:bdir
        return 1
    else
        return s:IsSubdir(a:adir, fnamemodify(a:bdir, ':h'))
    endif
endf

fun! viki#FilesUpdate() "{{{3
    let [lh, lb, le, indent] = s:GetRegionGeometry('Files')
    " 'vikiFiles', 'vikiFilesRegion'
    call s:DeleteRegionBody(lb, le)
    call viki#DirListing(lh, lb, indent)
endf

fun! viki#DirListing(lhs, lhb, indent) "{{{3
    let args = s:GetRegionArgs(a:lhs, a:lhb - 1)
    " TLogVAR args
    let patt = get(args, 'glob', '')
    " TLogVAR patt
    if empty(patt)
        echoerr 'Viki: No glob pattern defnied: '. string(args)
    else
        let p = getpos('.')
        let t = @t
        try
            " let style = get(args, 'style', 'ls')
            " let ls = VikiGetDirListing_{style}(split(glob(patt), '\n'))
            let ls = split(glob(patt), '\n')
            " TLogVAR ls
            let types = get(args, 'types', '')
            " TLogVAR ls
            if !empty(types)
                let show_files = stridx(types, 'f') != -1
                let show_dirs  = stridx(types, 'd') != -1
                call filter(ls, '(show_files && !isdirectory(v:val)) || (show_dirs && isdirectory(v:val))')
            endif
            let filter = get(args, 'filter', '')
            if !empty(filter)
                call filter(ls, 'v:val =~ filter')
            endif
            let exclude = get(args, 'exclude', '')
            if !empty(exclude)
                call filter(ls, 'v:val !~ exclude')
            endif
            let order = get(args, 'order', '')
            " if !empty(order)
            "     if order == 'd'
            "         call sort(ls, 's:SortDirsFirst')
            "     endif
            " endif
            let list = split(get(args, 'list', ''), ',\s*')
            call map(ls, 'a:indent.s:GetFileEntry(v:val, list)')
            let @t = join(ls, "\<c-j>") ."\<c-j>"
            exec 'norm! '. a:lhb .'G"tP'
        finally
            let @t = t
            call setpos('.', p)
        endtry
    endif
endf

" fun! VikiGetDirListing_ls(files)
"     return a:files
" endf

fun! s:GetFileEntry(file, list) "{{{3
    " let prefix = substitute(a:file, '[^/]', '', 'g')
    " let prefix = substitute(prefix, '/', repeat(' ', &shiftwidth), 'g')
    let attr = []
    if index(a:list, 'detail') != -1
        let type = getftype(a:file)
        if type != 'file'
            if type == 'dir'
                call add(attr, 'D')
            else
                call add(attr, type)
            endif
        endif
        call add(attr, strftime('%c', getftime(a:file)))
        call add(attr, getfperm(a:file))
    else
        if isdirectory(a:file)
            call add(attr, 'D')
        endif
    endif
    let f = []
    let d = s:GetDepth(a:file)
    " if index(a:list, 'tree') == -1
    "     call add(f, '[[')
    "     call add(f, repeat('|-', d))
    "     if index(attr, 'D') == -1
    "         call add(f, ' ')
    "     else
    "         call add(f, '-+ ')
    "     endif
    "     call add(f, fnamemodify(a:file, ':t') .'].]')
    " else
        if index(a:list, 'flat') == -1
            call add(f, repeat(' ', d * &shiftwidth))
        endif
        call add(f, '[['. a:file .']!]')
    " endif
    if !empty(attr)
        call add(f, ' {'. join(attr, '|') .'}')
    endif
    let c = get(s:savedComments, a:file, '')
    if !empty(c)
        call add(f, c)
    endif
    return join(f, '')
endf

fun! s:GetDepth(file) "{{{3
    return len(substitute(a:file, '[^/]', '', 'g'))
endf

fun! s:GetRegionArgs(ls, le) "{{{3
    let t = @t
    " let p = getpos('.')
    try
        let t = s:GetBrokenLine(a:ls, a:le)
        " TLogVAR t
        let t = matchstr(t, '^\s*#\([A-Z]\([a-z][A-Za-z]*\)\?\>\|!!!\)\zs.\{-}\ze<<$')
        " TLogVAR t
        let args = {}
        let rx = '^\s*\(\(\S\{-}\)=\("\(\(\"\|.\{-}\)\{-}\)"\|\(\(\S\+\|\\ \)\+\)\)\|\(\w\)\+!\)\s*'
        let s  = 0
        let sm = len(t)
        while s < sm
            let m = matchlist(t, rx, s)
            " TLogVAR m
            if empty(m)
                echoerr "Viki: Can't parse argument list: ". t
            else
                let key = m[2]
                " TLogVAR key
                if !empty(key)
                    let val = empty(m[4]) ? m[6] : m[4]
                    if val =~ '^".\{-}"'
                        let val = val[1:-2]
                    endif
                    let args[key] = substitute(val, '\\\(.\)', '\1', 'g')
                else
                    let key = m[8]
                    if key == '^no\u'
                        let antikey = substitute(key, '^no\zs.', '\l&', '')
                    else
                        let antikey = 'no'. substitute(key, '^.', '\u&', '')
                    endif
                    let args[key] = 1
                    let args[antikey] = 0
                endif
                let s += len(m[0])
            endif
        endwh
        return args
    finally
        let @t = t
        " call setpos('.', p)
    endtry
endf

fun! s:GetBrokenLine(ls, le) "{{{3
    let t = @t
    try
        exec 'norm! '. a:ls .'G"ty'. a:le .'G'
        let @t = substitute(@t, '[^\\]\zs\\\n\s*', '', 'g')
        let @t = substitute(@t, '\n*$', '', 'g')
        return @t
    finally
        let @t = t
    endtry
endf

fun! s:GetRegionStartRx(...) "{{{3
    let name = a:0 >= 1 && !empty(a:1) ? '\(\('. a:1 .'\>\)\)' : '\([A-Z]\([a-z][A-Za-z]*\)\?\>\|!!!\)'
    let rx_start = '^\([[:blank:]]*\)#'. name .'\(\\\n\|.\)\{-}<<\(.*\)$'
    return rx_start
endf

fun! s:GetRegionGeometry(...) "{{{3
    let p = getpos('.')
    try
        norm! $
        let rx_start = s:GetRegionStartRx(a:0 >= 1 ? a:1 : '')
        let hds = search(rx_start, 'cbWe')
        if hds > 0
            let hde = search(rx_start, 'ce')
            let hdt = s:GetBrokenLine(hds, hde)
            let hdm = matchlist(hdt, rx_start)
            let hdi = hdm[1]
            let rx_end = '\V\^\[[:blank:]]\*'. escape(hdm[5], '\') .'\[[:blank:]]\*\$'
            let hbe = search(rx_end)
            if hds > 0 && hde > 0 && hbe > 0
                return [hds, hde + 1, hbe, hdi]
            else
                echoerr "Viki: Can't determine region geometry: ". string([hds, hde, hbe, hdi, hdm, rx_start, rx_end])
            endif
        else
            echoerr "Viki: Can't determine region geometry: ". join([rx_start], ', ')
        endif
        return [0, 0, 0, '']
    finally
        call setpos('.', p)
    endtry
endf

fun! s:DeleteRegionBody(...) "{{{3
    if a:0 >= 2
        let lb = a:1
        let le = a:2
    else
        let [lh, lb, le, indent] = s:GetRegionGeometry('Files')
    endif
    call s:SaveComments(lb, le - 1)
    if le > lb
        exec 'norm! '. lb .'Gd'. (le - 1) .'G'
    endif
endf

fun! s:SaveComments(lb, le) "{{{3
    let s:savedComments = {}
    for l in range(a:lb, a:le)
        let t = getline(l)
        let k = viki#FilesGetFilename(t)
        if !empty(k)
            let s:savedComments[k] = viki#FilesGetComment(t)
        endif
    endfor
endf

fun! viki#FilesGetFilename(t) "{{{3
    return matchstr(a:t, '^\s*\[\[\zs.\{-}\ze\]!\]')
endf

fun! viki#FilesGetComment(t) "{{{3
    return matchstr(a:t, '^\s*\[\[.\{-}\]!\]\( {.\{-}}\)\?\zs.*')
endf

autoload/viki_anyword.vim	[[[1
94
" vikiAnyWord.vim
" @Author:      Tom Link (mailto:micathom AT gmail com?subject=vim-vikiAnyWord)
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Created:     04-Apr-2005.
" @Last Change: 2009-02-15.
" @Revision:    0.36

if &cp || exists('loaded_viki_anyword')
    finish
endif
let loaded_viki_anyword = 1

"""" Any Word {{{1
function! viki_anyword#MinorMode(state) "{{{3
    let b:vikiFamily = 'anyword'
    call viki_viki#MinorMode(a:state)
endfun

function! viki_anyword#SetupBuffer(state, ...) "{{{3
    let dontSetup = a:0 > 0 ? a:1 : ''
    call viki_viki#SetupBuffer(a:state, dontSetup)
    if b:vikiNameTypes =~? "s" && !(dontSetup =~? "s")
        if b:vikiNameTypes =~# "S" && !(dontSetup =~# "S")
            let simpleWikiName = b:vikiSimpleNameQuoteBeg
                        \ .'['. b:vikiSimpleNameQuoteChars .']'
                        \ .'\{-}'. b:vikiSimpleNameQuoteEnd
        else
            let simpleWikiName = ""
        endif
        if b:vikiNameTypes =~# "s" && !(dontSetup =~# "s")
            let simple = '\<['. g:vikiUpperCharacters .']['. g:vikiLowerCharacters
                        \ .']\+\(['. g:vikiUpperCharacters.']['.g:vikiLowerCharacters
                        \ .'0-9]\+\)\+\>'
            if simpleWikiName != ""
                let simpleWikiName = simpleWikiName .'\|'. simple
            else
                let simpleWikiName = simple
            endif
        endif
        let anyword = '\<['. b:vikiSimpleNameQuoteChars .' ]\+\>'
        if simpleWikiName != ""
            let simpleWikiName = simpleWikiName .'\|'. anyword
        else
            let simpleWikiName = anyword
        endif
        let b:vikiSimpleNameRx = '\C\(\(\<['. g:vikiUpperCharacters .']\+::\)\?'
                    \ .'\('. simpleWikiName .'\)\)'
                    \ .'\(#\('. b:vikiAnchorNameRx .'\)\>\)\?'
        let b:vikiSimpleNameSimpleRx = '\C\(\<['.g:vikiUpperCharacters.']\+::\)\?'
                    \ .'\('. simpleWikiName .'\)'
                    \ .'\(#'. b:vikiAnchorNameRx .'\>\)\?'
        let b:vikiSimpleNameNameIdx   = 1
        let b:vikiSimpleNameDestIdx   = 0
        let b:vikiSimpleNameAnchorIdx = 6
        let b:vikiSimpleNameCompound = 'let erx="'. escape(b:vikiSimpleNameRx, '\"')
                    \ .'" | let nameIdx='. b:vikiSimpleNameNameIdx
                    \ .' | let destIdx='. b:vikiSimpleNameDestIdx
                    \ .' | let anchorIdx='. b:vikiSimpleNameAnchorIdx
    endif
    let b:vikiInexistentHighlight = "vikiAnyWordInexistentLink"
    let b:vikiMarkInexistent = 2
endf

function! viki_anyword#DefineMarkup(state) "{{{3
    if b:vikiNameTypes =~? "s" && b:vikiSimpleNameRx != ""
        exe "syn match vikiRevLink /" . b:vikiSimpleNameRx . "/"
    endif
    if b:vikiNameTypes =~# "e" && b:vikiExtendedNameRx != ""
        exe "syn match vikiRevExtendedLink '" . b:vikiExtendedNameRx . "'"
    endif
    if b:vikiNameTypes =~# "u" && b:vikiUrlRx != ""
        exe "syn match vikiURL /" . b:vikiUrlRx . "/"
    endif
endfun

function! viki_anyword#DefineHighlighting(state, ...) "{{{3
    let dontSetup = a:0 > 0 ? a:1 : ''
    call viki_viki#DefineHighlighting(a:state)
    if version < 508
        command! -nargs=+ VikiHiLink hi link <args>
    else
        command! -nargs=+ VikiHiLink hi def link <args>
    endif
    exec 'VikiHiLink '. b:vikiInexistentHighlight .' Normal'
    delcommand VikiHiLink
endf

function! viki_anyword#Find(flag, ...) "{{{3
    let rx = viki#RxFromCollection(b:vikiNamesOk)
    let i  = a:0 >= 1 ? a:1 : 0
    call viki#Find(a:flag, i, rx)
endfun


autoload/viki_latex.vim	[[[1
125
" vikiLatex.vim -- viki add-on for LaTeX
" @Author:      Tom Link (micathom AT gmail com?subject=vim)
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Created:     28-Jän-2004.
" @Last Change: 2009-02-15.
" @Revision:    0.196

if &cp || exists('loaded_viki_latex')
    finish
endif
let loaded_viki_latex = 1

function! viki_latex#SetupBuffer(state, ...)
    let noMatch = ""
    let b:vikiNameSuffix = '.tex'
    call viki_viki#SetupBuffer(a:state, "sSic")
    let b:vikiAnchorRx   = '\\label{%{ANCHOR}}'
    let b:vikiNameTypes  = substitute(b:vikiNameTypes, '\C[Sicx]', "", "g")
    let b:vikiLaTeXCommands = 'viki\|include\|input\|usepackage\|psfig\|includegraphics\|bibliography\|ref'
    if exists("g:vikiLaTeXUserCommands")
        let b:vikiLaTeXCommands = b:vikiLaTeXCommands .'\|'. g:vikiLaTeXUserCommands
    endif
    if b:vikiNameTypes =~# "s"
        let b:vikiSimpleNameRx         = '\(\\\('. b:vikiLaTeXCommands .'\)\(\[\(.\{-}\)\]\)\?{\(.\{-}\)}\)'
        let b:vikiSimpleNameSimpleRx   = '\\\('. b:vikiLaTeXCommands .'\)\(\[.\{-}\]\)\?{.\{-}}'
        let b:vikiSimpleNameNameIdx    = 2
        let b:vikiSimpleNameDestIdx    = 5
        let b:vikiSimpleNameAnchorIdx  = 4
        let b:vikiSimpleNameCompound = 'let erx="'. escape(b:vikiSimpleNameRx, '\"')
                    \ .'" | let nameIdx='. b:vikiSimpleNameNameIdx
                    \ .' | let destIdx='. b:vikiSimpleNameDestIdx
                    \ .' | let anchorIdx='. b:vikiSimpleNameAnchorIdx
    else
        let b:vikiSimpleNameRx        = noMatch
        let b:vikiSimpleNameSimpleRx  = noMatch
        let b:vikiSimpleNameNameIdx   = 0
        let b:vikiSimpleNameDestIdx   = 0
        let b:vikiSimpleNameAnchorIdx = 0
    endif
endf

function! viki_latex#CheckFilename(filename, ...)
    if a:filename != ""
        """ search in the current directory
        let i = 1
        while i <= a:0
            let fn = a:filename .a:{i}
            " TLogVAR fn
            if filereadable(fn)
                return fn
            endif
            let i = i + 1
        endwh

        """ use kpsewhich
        let i = 1
        while i <= a:0
            let fn = a:filename .a:{i}
            let rv = system('kpsewhich '. string(fn))
            if rv != ""
                return substitute(rv, "\n", "", "g")
            endif
            let i = i + 1
        endwh
    endif
    return ""
endfun


function! viki_latex#CompleteSimpleNameDef(def)
    exec viki#SplitDef(a:def)
    if v_name == g:vikiDefNil
        throw "Viki: Malformed command (no name): ". string(a:def)
    endif
    let opts = v_anchor
    let v_anchor  = g:vikiDefNil
    let useSuffix = g:vikiDefSep

    if v_name == "input"
        let v_dest = viki_latex#CheckFilename(v_dest, "", ".tex", ".sty")
    elseif v_name == "usepackage"
        let v_dest = viki_latex#CheckFilename(v_dest, ".sty")
    elseif v_name == "include"
        let v_dest = viki_latex#CheckFilename(v_dest, ".tex")
    elseif v_name == "viki"
        let v_dest = viki_latex#CheckFilename(v_dest, ".tex")
        let v_anchor = opts
    elseif v_name == "psfig"
        let f == matchstr(v_dest, "figure=\zs.\{-}\ze[,}]")
        let v_dest = viki_latex#CheckFilename(v_dest, "")
    elseif v_name == "includegraphics"
        let v_dest = viki_latex#CheckFilename(v_dest, "", 
                    \ ".eps", ".ps", ".pdf", ".png", ".jpeg", ".jpg", ".gif", ".wmf")
    elseif v_name == "bibliography"
        if !exists('b:vikiMarkingInexistent')
            let bibs = split(v_dest, ",")
            let f = tlib#input#List('s', "Select Bibliography", bibs)
            let v_dest = empty(f) ? '' : viki_latex#CheckFilename(f, ".bib")
        endif
    elseif v_name == "ref"
        let v_anchor = v_dest
        let v_dest   = g:vikiSelfRef
    elseif exists("*VikiLaTeX_".v_name)
        exec VikiLaTeX_{v_name}(v_dest, opts)
    else
        throw "Viki LaTeX: unsupported command: ". v_name
    endif
    
    if v_dest == ""
        if !exists('b:vikiMarkingInexistent')
            throw "Viki LaTeX: can't find: ". v_name ." ". string(a:def)
        endif
    else
        return viki#MakeDef(v_name, v_dest, v_anchor, v_part, 'simple')
    endif
endfun

function! viki_latex#MinorMode(state)
    let b:vikiFamily = "latex"
    call viki_viki#MinorMode(a:state)
endf

" au FileType tex let b:vikiFamily="LaTeX"

" vim: ff=unix
autoload/viki_viki.vim	[[[1
597
" vikiDeplate.vim
" @Author:      Tom Link (micathom AT gmail com?subject=[vim])
" @Website:     http://www.vim.org/account/profile.php?user_id=4037
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Created:     2007-09-03.
" @Last Change: 2009-02-15.
" @Revision:    0.0.111

if &cp || exists("loaded_viki_viki")
    finish
endif
let loaded_viki_viki = 1

let s:save_cpo = &cpo
set cpo&vim


""" viki/deplate {{{1
" Prepare a buffer for use with viki.vim. Setup all buffer-local 
" variables etc.
" This also sets up the rx for the different viki name types.
" viki_viki#SetupBuffer(state, ?dontSetup='')
function! viki_viki#SetupBuffer(state, ...) "{{{3
    if !g:vikiEnabled
        return
    endif
    " TLogDBG expand('%') .': '. (exists('b:vikiFamily') ? b:vikiFamily : 'default')

    let dontSetup = a:0 > 0 ? a:1 : ""
    let noMatch = ""
   
    if exists("b:vikiNoSimpleNames") && b:vikiNoSimpleNames
        let b:vikiNameTypes = substitute(b:vikiNameTypes, '\Cs', '', 'g')
    endif
    if exists("b:vikiDisableType") && b:vikiDisableType != ""
        let b:vikiNameTypes = substitute(b:vikiNameTypes, '\C'. b:vikiDisableType, '', 'g')
    endif

    call viki#SetBufferVar("vikiAnchorMarker")
    call viki#SetBufferVar("vikiSpecialProtocols")
    call viki#SetBufferVar("vikiSpecialProtocolsExceptions")
    call viki#SetBufferVar("vikiMarkInexistent")
    call viki#SetBufferVar("vikiTextstylesVer")
    " call viki#SetBufferVar("vikiTextstylesVer")
    call viki#SetBufferVar("vikiLowerCharacters")
    call viki#SetBufferVar("vikiUpperCharacters")
    call viki#SetBufferVar("vikiAnchorNameRx")
    call viki#SetBufferVar("vikiUrlRestRx")
    call viki#SetBufferVar("vikiFeedbackMin")

    if a:state == 1
        call viki#SetBufferVar("vikiCommentStart", 
                    \ "b:commentStart", "b:ECcommentOpen", "b:EnhCommentifyCommentOpen",
                    \ "*matchstr(&commentstring, '^\\zs.*\\ze%s')")
        call viki#SetBufferVar("vikiCommentEnd",
                    \ "b:commentEnd", "b:ECcommentClose", "b:EnhCommentifyCommentClose", 
                    \ "*matchstr(&commentstring, '%s\\zs.*\\ze$')")
    elseif !exists('b:vikiCommentStart')
        " This actually is an error.
        if &debug != ''
            echom "Viki: FTPlugin wasn't loaded. Viki requires :filetype plugin on"
        endif
        let b:vikiCommentStart = '%'
        let b:vikiCommentEnd   = ''
    endif
    
    let b:vikiSimpleNameQuoteChars = '^][:*/&?<>|\"'
    
    let b:vikiSimpleNameQuoteBeg   = '\[-'
    let b:vikiSimpleNameQuoteEnd   = '-\]'
    let b:vikiQuotedSelfRef        = "^". b:vikiSimpleNameQuoteBeg . b:vikiSimpleNameQuoteEnd ."$"
    let b:vikiQuotedRef            = "^". b:vikiSimpleNameQuoteBeg .'.\+'. b:vikiSimpleNameQuoteEnd ."$"

    if empty(b:vikiAnchorNameRx)
        let b:vikiAnchorNameRx         = '['. b:vikiLowerCharacters .']['. 
                    \ b:vikiLowerCharacters . b:vikiUpperCharacters .'_0-9]*'
    endif
    " TLogVAR b:vikiAnchorNameRx
    
    let interviki = '\<['. b:vikiUpperCharacters .']\+::'

    " if viki#IsSupportedType("sSc") && !(dontSetup =~? "s")
    if viki#IsSupportedType("s") && !(dontSetup =~? "s")
        if viki#IsSupportedType("S") && !(dontSetup =~# "S")
            let quotedVikiName = b:vikiSimpleNameQuoteBeg 
                        \ .'['. b:vikiSimpleNameQuoteChars .']'
                        \ .'\{-}'. b:vikiSimpleNameQuoteEnd
        else
            let quotedVikiName = ""
        endif
        if viki#IsSupportedType("c") && !(dontSetup =~# "c")
            let simpleWikiName = viki#GetSimpleRx4SimpleWikiName()
            if quotedVikiName != ""
                let quotedVikiName = quotedVikiName .'\|'
            endif
        else
            let simpleWikiName = '\(\)'
        endif
        let simpleHyperWords = ''
        if v:version >= 700 && viki#IsSupportedType('w') && !(dontSetup =~# 'w')
            let b:vikiHyperWordTable = {}
            if viki#IsSupportedType('f') && !(dontSetup =~# 'f')
                call viki#CollectFileWords(b:vikiHyperWordTable, simpleWikiName)
            endif
            call viki#CollectHyperWords(b:vikiHyperWordTable)
            let hyperWords = keys(b:vikiHyperWordTable)
            if !empty(hyperWords)
                let simpleHyperWords = join(map(hyperWords, '"\\<".tlib#rx#Escape(v:val)."\\>"'), '\|') .'\|'
                let simpleHyperWords = substitute(simpleHyperWords, ' \+', '\\s\\+', 'g')
            endif
        endif
        let b:vikiSimpleNameRx = '\C\(\('. interviki .'\)\?'.
                    \ '\('. simpleHyperWords . quotedVikiName . simpleWikiName .'\)\)'.
                    \ '\(#\('. b:vikiAnchorNameRx .'\)\>\)\?'
        let b:vikiSimpleNameSimpleRx = '\C\(\<['.b:vikiUpperCharacters.']\+::\)\?'.
                    \ '\('. simpleHyperWords . quotedVikiName . simpleWikiName .'\)'.
                    \ '\(#'. b:vikiAnchorNameRx .'\>\)\?'
        let b:vikiSimpleNameNameIdx   = 1
        let b:vikiSimpleNameDestIdx   = 0
        let b:vikiSimpleNameAnchorIdx = 6
        let b:vikiSimpleNameCompound = 'let erx="'. escape(b:vikiSimpleNameRx, '\"')
                    \ .'" | let nameIdx='. b:vikiSimpleNameNameIdx
                    \ .' | let destIdx='. b:vikiSimpleNameDestIdx
                    \ .' | let anchorIdx='. b:vikiSimpleNameAnchorIdx
    else
        let b:vikiSimpleNameRx        = noMatch
        let b:vikiSimpleNameSimpleRx  = noMatch
        let b:vikiSimpleNameNameIdx   = 0
        let b:vikiSimpleNameDestIdx   = 0
        let b:vikiSimpleNameAnchorIdx = 0
    endif
   
    if viki#IsSupportedType("u") && !(dontSetup =~# "u")
        let urlChars = 'A-Za-z0-9.,:%?=&_~@$/|+-'
        let b:vikiUrlRx = '\<\(\('.b:vikiSpecialProtocols.'\):['. urlChars .']\+\)'.
                    \ '\(#\('. b:vikiAnchorNameRx .'\)\)\?'. b:vikiUrlRestRx
        let b:vikiUrlSimpleRx = '\<\('. b:vikiSpecialProtocols .'\):['. urlChars .']\+'.
                    \ '\(#'. b:vikiAnchorNameRx .'\)\?'. b:vikiUrlRestRx
        let b:vikiUrlNameIdx   = 0
        let b:vikiUrlDestIdx   = 1
        let b:vikiUrlAnchorIdx = 4
        let b:vikiUrlCompound = 'let erx="'. escape(b:vikiUrlRx, '\"')
                    \ .'" | let nameIdx='. b:vikiUrlNameIdx
                    \ .' | let destIdx='. b:vikiUrlDestIdx
                    \ .' | let anchorIdx='. b:vikiUrlAnchorIdx
    else
        let b:vikiUrlRx        = noMatch
        let b:vikiUrlSimpleRx  = noMatch
        let b:vikiUrlNameIdx   = 0
        let b:vikiUrlDestIdx   = 0
        let b:vikiUrlAnchorIdx = 0
    endif
   
    if viki#IsSupportedType("x") && !(dontSetup =~# "x")
        " let vikicmd = '['. b:vikiUpperCharacters .']\w*'
        let vikicmd    = '\(IMG\|Img\|INC\%[LUDE]\)\>'
        let vikimacros = '\(img\|ref\)\>'
        let b:vikiCmdRx        = '\({'. vikimacros .'\|#'. vikicmd .'\)\(.\{-}\):\s*\(.\{-}\)\($\|}\)'
        let b:vikiCmdSimpleRx  = '\({'. vikimacros .'\|#'. vikicmd .'\).\{-}\($\|}\)'
        let b:vikiCmdNameIdx   = 1
        let b:vikiCmdDestIdx   = 5
        let b:vikiCmdAnchorIdx = 4
        let b:vikiCmdCompound = 'let erx="'. escape(b:vikiCmdRx, '\"')
                    \ .'" | let nameIdx='. b:vikiCmdNameIdx
                    \ .' | let destIdx='. b:vikiCmdDestIdx
                    \ .' | let anchorIdx='. b:vikiCmdAnchorIdx
    else
        let b:vikiCmdRx        = noMatch
        let b:vikiCmdSimpleRx  = noMatch
        let b:vikiCmdNameIdx   = 0
        let b:vikiCmdDestIdx   = 0
        let b:vikiCmdAnchorIdx = 0
    endif
    
    if viki#IsSupportedType("e") && !(dontSetup =~# "e")
        let b:vikiExtendedNameRx = 
                    \ '\[\[\(\('.b:vikiSpecialProtocols.'\)://[^]]\+\|[^]#]\+\)\?'.
                    \ '\(#\([^]]*\)\)\?\]\(\[\([^]]\+\)\]\)\?\([!~*$\-]*\)\]'
                    " \ '\(#\('. b:vikiAnchorNameRx .'\)\)\?\]\(\[\([^]]\+\)\]\)\?[!~*\-]*\]'
        let b:vikiExtendedNameSimpleRx = 
                    \ '\[\[\('. b:vikiSpecialProtocols .'://[^]]\+\|[^]#]\+\)\?'.
                    \ '\(#[^]]*\)\?\]\(\[[^]]\+\]\)\?[!~*$\-]*\]'
                    " \ '\(#'. b:vikiAnchorNameRx .'\)\?\]\(\[[^]]\+\]\)\?[!~*\-]*\]'
        let b:vikiExtendedNameNameIdx   = 6
        let b:vikiExtendedNameModIdx    = 7
        let b:vikiExtendedNameDestIdx   = 1
        let b:vikiExtendedNameAnchorIdx = 4
        let b:vikiExtendedNameCompound = 'let erx="'. escape(b:vikiExtendedNameRx, '\"')
                    \ .'" | let nameIdx='. b:vikiExtendedNameNameIdx
                    \ .' | let destIdx='. b:vikiExtendedNameDestIdx
                    \ .' | let anchorIdx='. b:vikiExtendedNameAnchorIdx
    else
        let b:vikiExtendedNameRx        = noMatch
        let b:vikiExtendedNameSimpleRx  = noMatch
        let b:vikiExtendedNameNameIdx   = 0
        let b:vikiExtendedNameDestIdx   = 0
        let b:vikiExtendedNameAnchorIdx = 0
    endif

    let b:vikiInexistentHighlight = "vikiInexistentLink"

    " TLogVAR a:state
    if a:state == 2
        " TLogVAR g:vikiAutoMarks
        if g:vikiAutoMarks
            call viki#SetAnchorMarks()
        endif
        if g:vikiNameSuffix != ''
            exec 'setlocal suffixesadd+='. g:vikiNameSuffix
        endif
        if exists('b:vikiNameSuffix') && b:vikiNameSuffix != '' && b:vikiNameSuffix != g:vikiNameSuffix
            exec 'setlocal suffixesadd+='. b:vikiNameSuffix
        endif
        if exists('g:loaded_hookcursormoved') && g:loaded_hookcursormoved >= 3 && exists('b:vikiMarkInexistent') && b:vikiMarkInexistent
            let b:hookcursormoved_syntaxleave = ['vikiLink', 'vikiExtendedLink', 'vikiURL', 'vikiOkLink', 'vikiInexistentLink']
            for cond in g:vikiHCM
                call hookcursormoved#Register(cond, function('viki#HookCheckPreviousPosition'))
            endfor
        endif
    endif
endf


" Define viki core syntax groups for hyperlinks
function! viki_viki#DefineMarkup(state) "{{{3
    if viki#IsSupportedType("sS") && b:vikiSimpleNameSimpleRx != ""
        exe "syntax match vikiLink /" . b:vikiSimpleNameSimpleRx . "/"
    endif
    if viki#IsSupportedType("e") && b:vikiExtendedNameSimpleRx != ""
        exe "syntax match vikiExtendedLink '" . b:vikiExtendedNameSimpleRx . "' skipnl"
    endif
    if viki#IsSupportedType("u") && b:vikiUrlSimpleRx != ""
        exe "syntax match vikiURL /" . b:vikiUrlSimpleRx . "/"
    endif
endf


" Define the highlighting of the core syntax groups for hyperlinks
function! viki_viki#DefineHighlighting(state) "{{{3
    exec 'hi vikiInexistentLink '. g:viki_highlight_inexistent_{&background}
    exec 'hi vikiHyperLink '. g:viki_highlight_hyperlink_{&background}

    if viki#IsSupportedType("sS")
        hi def link vikiLink vikiHyperLink
        hi def link vikiOkLink vikiHyperLink
        hi def link vikiRevLink Normal
    endif
    if viki#IsSupportedType("e")
        hi def link vikiExtendedLink vikiHyperLink
        hi def link vikiExtendedOkLink vikiHyperLink
        hi def link vikiRevExtendedLink Normal
    endif
    if viki#IsSupportedType("u")
        hi def link vikiURL vikiHyperLink
    endif
endf


" Define viki-related key maps
function! viki_viki#MapKeys(state) "{{{3
    if exists('b:vikiDidMapKeys')
        return
    endif
    if a:state == 1
        if exists('b:vikiMapFunctionalityMinor') && b:vikiMapFunctionalityMinor
            let mf = b:vikiMapFunctionalityMinor
        else
            let mf = g:vikiMapFunctionalityMinor
        endif
    elseif exists('b:vikiMapFunctionality') && b:vikiMapFunctionality
        let mf = b:vikiMapFunctionality
    else
        let mf = g:vikiMapFunctionality
    endif

    " if !hasmapto('viki#MaybeFollowLink')
        if viki#MapFunctionality(mf, 'c')
            nnoremap <buffer> <silent> <c-cr> :call viki#MaybeFollowLink(0,1)<cr>
            inoremap <buffer> <silent> <c-cr> <c-o>:call viki#MaybeFollowLink(0,1)<cr>
            " nnoremap <buffer> <silent> <LocalLeader><c-cr> :call viki#MaybeFollowLink(0,1,-1)<cr>
        endif
        if viki#MapFunctionality(mf, 'f')
            " nnoremap <buffer> <silent> <c-cr> :call viki#MaybeFollowLink(0,1)<cr>
            " inoremap <buffer> <silent> <c-cr> <c-o>:call viki#MaybeFollowLink(0,1)<cr>
            " nnoremap <buffer> <silent> <LocalLeader><c-cr> :call viki#MaybeFollowLink(0,1,-1)<cr>
            exec 'nnoremap <buffer> <silent> '. g:vikiMapLeader .'f :call viki#MaybeFollowLink(0,1)<cr>'
            exec 'nnoremap <buffer> <silent> '. g:vikiMapLeader .'s :call viki#MaybeFollowLink(0,1,-1)<cr>'
            exec 'nnoremap <buffer> <silent> '. g:vikiMapLeader .'v :call viki#MaybeFollowLink(0,1,-2)<cr>'
            exec 'nnoremap <buffer> <silent> '. g:vikiMapLeader .'1 :call viki#MaybeFollowLink(0,1,1)<cr>'
            exec 'nnoremap <buffer> <silent> '. g:vikiMapLeader .'2 :call viki#MaybeFollowLink(0,1,2)<cr>'
            exec 'nnoremap <buffer> <silent> '. g:vikiMapLeader .'3 :call viki#MaybeFollowLink(0,1,3)<cr>'
            exec 'nnoremap <buffer> <silent> '. g:vikiMapLeader .'4 :call viki#MaybeFollowLink(0,1,4)<cr>'
            exec 'nnoremap <buffer> <silent> '. g:vikiMapLeader .'t :call viki#MaybeFollowLink(0,1,"tab")<cr>'
        endif
        if viki#MapFunctionality(mf, 'mf')
            " && !hasmapto("viki#MaybeFollowLink")
            nnoremap <buffer> <silent> <m-leftmouse> <leftmouse>:call viki#MaybeFollowLink(0,1)<cr>
            inoremap <buffer> <silent> <m-leftmouse> <leftmouse><c-o>:call viki#MaybeFollowLink(0,1)<cr>
        endif
    " endif

    " if !hasmapto('VikiMarkInexistent')
        if viki#MapFunctionality(mf, 'i')
            exec 'noremap <buffer> <silent> '. g:vikiMapLeader .'d :call viki#MarkInexistentInElement("Document")<cr>'
            exec 'noremap <buffer> <silent> '. g:vikiMapLeader .'p :call viki#MarkInexistentInElement("Paragraph")<cr>'
        endif
        if viki#MapFunctionality(mf, 'I')
            if g:vikiMapInexistent
                let i = 0
                let m = strlen(g:vikiMapKeys)
                while i < m
                    let k = g:vikiMapKeys[i]
                    call viki#MapMarkInexistent(k, "LineQuick")
                    let i = i + 1
                endwh
                let i = 0
                let m = strlen(g:vikiMapQParaKeys)
                while i < m
                    let k = g:vikiMapQParaKeys[i]
                    call viki#MapMarkInexistent(k, "ParagraphVisible")
                    let i = i + 1
                endwh
            endif
        endif
    " endif

    if viki#MapFunctionality(mf, 'e')
        " && !hasmapto("viki#Edit")
        exec 'noremap <buffer> '. g:vikiMapLeader .'e :VikiEdit '
    endif
    
    if viki#MapFunctionality(mf, 'q') && exists("*VEnclose")
        " && !hasmapto("VikiQuote")
        exec 'vnoremap <buffer> <silent> '. g:vikiMapLeader .'q :VikiQuote<cr><esc>:call viki#MarkInexistentInElement("LineQuick")<cr>'
        exec 'nnoremap <buffer> <silent> '. g:vikiMapLeader .'q viw:VikiQuote<cr><esc>:call viki#MarkInexistentInElement("LineQuick")<cr>'
        exec 'inoremap <buffer> <silent> '. g:vikiMapLeader .'q <esc>viw:VikiQuote<cr>:call viki#MarkInexistentInElement("LineQuick")<cr>i'
    endif
    
    if viki#MapFunctionality(mf, 'p')
        exec 'nnoremap <buffer> <silent> '. g:vikiMapLeader .'<bs> :call viki#GoParent()<cr>'
        exec 'nnoremap <buffer> <silent> '. g:vikiMapLeader .'<up> :call viki#GoParent()<cr>'
    endif

    if viki#MapFunctionality(mf, 'b')
        " && !hasmapto("VikiGoBack")
        exec 'nnoremap <buffer> <silent> '. g:vikiMapLeader .'b :call viki#GoBack()<cr>'
        exec 'nnoremap <buffer> <silent> '. g:vikiMapLeader .'<left> :call viki#GoBack()<cr>'
    endif
    if viki#MapFunctionality(mf, 'mb')
        nnoremap <buffer> <silent> <m-rightmouse> <leftmouse>:call viki#GoBack(0)<cr>
        inoremap <buffer> <silent> <m-rightmouse> <leftmouse><c-o>:call viki#GoBack(0)<cr>
    endif
    
    if viki#MapFunctionality(mf, 'F')
        exec 'nnoremap <buffer> <silent> '. g:vikiMapLeader .'n :VikiFindNext<cr>'
        exec 'nnoremap <buffer> <silent> '. g:vikiMapLeader .'N :VikiFindPrev<cr>'
        exec 'nmap <buffer> <silent> '. g:vikiMapLeader .'F '. g:vikiMapLeader .'n'. g:vikiMapLeader .'f'
    endif
    if viki#MapFunctionality(mf, 'tF')
        nnoremap <buffer> <silent> <c-tab>   :VikiFindNext<cr>
        nnoremap <buffer> <silent> <c-s-tab> :VikiFindPrev<cr>
    endif
    if viki#MapFunctionality(mf, 'Files')
        exec 'nnoremap <buffer> <silent> '. g:vikiMapLeader .'u :VikiFilesUpdate<cr>'
        exec 'nnoremap <buffer> <silent> '. g:vikiMapLeader .'U :VikiFilesUpdateAll<cr>'
        exec 'nnoremap <buffer> '. g:vikiMapLeader .'x :VikiFilesExec '
        exec 'nnoremap <buffer> '. g:vikiMapLeader .'X :VikiFilesExec! '
    endif
    let b:vikiDidMapKeys = 1
endf


" Initialize viki as minor mode (add-on to some buffer filetype)
"state ... no-op:0, minor:1, major:2
function! viki_viki#MinorMode(state) "{{{3
    if !g:vikiEnabled
        return 0
    endif
    if a:state == 0
        return 0
    endif
    let state = a:state < 0 ? -a:state : a:state
    let vf = viki#Family(1)
    " c ... CamelCase 
    " s ... Simple viki name 
    " S ... Simple quoted viki name
    " e ... Extended viki name
    " u ... URL
    " i ... InterViki
    " call viki#SetBufferVar('vikiNameTypes', 'g:vikiNameTypes', "*'csSeui'")
    call viki#SetBufferVar('vikiNameTypes')
    call viki#DispatchOnFamily('SetupBuffer', vf, state)
    call viki#DispatchOnFamily('DefineMarkup', vf, state)
    call viki#DispatchOnFamily('DefineHighlighting', vf, state)
    call viki#DispatchOnFamily('MapKeys', vf, state)
    if !exists('b:vikiEnabled') || b:vikiEnabled < state
        let b:vikiEnabled = state
    endif
    " call viki#DispatchOnFamily('VikiDefineMarkup', vf, state)
    " call viki#DispatchOnFamily('VikiDefineHighlighting', vf, state)
    return 1
endf


" Find an anchor
function! viki_viki#FindAnchor(anchor) "{{{3
    " TLogVAR a:anchor
    if a:anchor == g:vikiDefNil || a:anchor == ''
        return
    endif
    let mode = matchstr(a:anchor, '^\(l\(ine\)\?\|rx\|vim\)\ze=')
    if exists('*VikiAnchor_'. mode)
        let arg  = matchstr(a:anchor, '=\zs.\+$')
        call VikiAnchor_{mode}(arg)
    else
        let co = col('.')
        let li = line('.')
        let anchorRx = viki#GetAnchorRx(a:anchor)
        " TLogVAR anchorRx
        keepjumps go
        let found = search(anchorRx, 'Wc')
        " TLogVAR found
        if !found
            call cursor(li, co)
            if g:vikiFreeMarker
                call search('\c\V'. escape(a:anchor, '\'), 'w')
            endif
        endif
    endif
    exec g:vikiPostFindAnchor
endf


" Complete missing information in the definition of an extended viki name
function! viki_viki#CompleteExtendedNameDef(def) "{{{3
    " TLogVAR a:def
    exec viki#SplitDef(a:def)
    if v_dest == g:vikiDefNil
        if v_anchor == g:vikiDefNil
            throw "Viki: Malformed extended viki name (no destination): ". string(a:def)
        else
            let v_dest = g:vikiSelfRef
        endif
    elseif viki#IsInterViki(v_dest)
        let useSuffix = viki#InterVikiSuffix(v_dest)
        let v_dest = viki#InterVikiDest(v_dest)
        " TLogVAR v_dest
        if v_dest != g:vikiDefNil
            let v_dest = viki#ExpandSimpleName('', v_dest, useSuffix)
            " TLogVAR v_dest
        endif
    else
        if v_dest =~? '^[a-z]:'                      " an absolute dos path
        elseif v_dest =~? '^\/'                          " an absolute unix path
        elseif v_dest =~? '^'.b:vikiSpecialProtocols.':' " some protocol
        elseif v_dest =~ '^\~'                           " user home
            " let v_dest = $HOME . strpart(v_dest, 1)
            let v_dest = fnamemodify(v_dest, ':p')
            let v_dest = viki#CanonicFilename(v_dest)
        else                                           " a relative path
            let v_dest = expand("%:p:h") .g:vikiDirSeparator. v_dest
            let v_dest = viki#CanonicFilename(v_dest)
        endif
        if v_dest != '' && v_dest != g:vikiSelfRef && !viki#IsSpecial(v_dest)
            let mod = viki#ExtendedModifier(v_part)
            if fnamemodify(v_dest, ':e') == '' && mod !~# '!'
                let v_dest = viki#WithSuffix(v_dest)
            endif
        endif
    endif
    if v_name == g:vikiDefNil
        let v_name = fnamemodify(v_dest, ':t:r')
    endif
    let v_type = v_type == g:vikiDefNil ? 'e' : v_type
    " TLogVAR v_name, v_dest, v_anchor, v_part, v_type
    return viki#MakeDef(v_name, v_dest, v_anchor, v_part, v_type)
endf


" Complete missing information in the definition of a command viki name
function! viki_viki#CompleteCmdDef(def) "{{{3
    " TLogVAR a:def
    exec viki#SplitDef(a:def)
    " TLogVAR v_name, v_dest, v_anchor
    let args     = v_anchor
    let v_anchor = g:vikiDefNil
    if v_name ==# "#IMG" || v_name =~# "{img"
        let v_dest = viki#FindFileWithSuffix(v_dest, viki#GetSpecialFilesSuffixes())
        " TLogVAR v_dest
    elseif v_name ==# "#Img"
        let id = matchstr(args, '\sid=\zs\w\+')
        if id != ''
            let v_dest = viki#FindFileWithSuffix(id, viki#GetSpecialFilesSuffixes())
        endif
    elseif v_name =~ "^#INC"
        " <+TODO+> Search path?
    elseif v_name =~ '^{ref\>'
        let v_anchor = v_dest
        let v_name = g:vikiSelfRef
        let v_dest = g:vikiSelfRef
        " TLogVAR v_name, v_anchor, v_dest
    else
        " throw "Viki: Unknown command: ". v_name
        let v_name = g:vikiDefNil
        let v_dest = g:vikiDefNil
        " let v_anchor = g:vikiDefNil
    endif
    let v_type = v_type == g:vikiDefNil ? 'cmd' : v_type
    let vdef   = viki#MakeDef(v_name, v_dest, v_anchor, v_part, v_type)
    " TLogVAR vdef
    return vdef
endf


" Complete missing information in the definition of a simple viki name
function! viki_viki#CompleteSimpleNameDef(def) "{{{3
    " TLogVAR a:def
    exec viki#SplitDef(a:def)
    if v_name == g:vikiDefNil
        throw "Viki: Malformed simple viki name (no name): ". string(a:def)
    endif

    if !(v_dest == g:vikiDefNil)
        throw "Viki: Malformed simple viki name (destination=".v_dest."): ". string(a:def)
    endif

    " TLogVAR v_name
    if viki#IsInterViki(v_name)
        let i_name = viki#InterVikiName(v_name)
        let useSuffix = viki#InterVikiSuffix(v_name)
        let v_name = viki#InterVikiPart(v_name)
    elseif viki#IsHyperWord(v_name)
        let hword = viki#HyperWordValue(v_name)
        if type(hword) == 4
            let i_name = hword.interviki
            let useSuffix = hword.suffix
            let v_name = hword.name
        else
            let i_name = ''
            let useSuffix = ''
            let v_name = hword
        end
    else
        let i_name = ''
        let v_dest = expand("%:p:h")
        let useSuffix = g:vikiDefSep
    endif
    " TLogVAR i_name

    if viki#IsSupportedType("S")
        " TLogVAR v_name
        if v_name =~ b:vikiQuotedSelfRef
            let v_name  = g:vikiSelfRef
        elseif v_name =~ b:vikiQuotedRef
            let v_name = matchstr(v_name, "^". b:vikiSimpleNameQuoteBeg .'\zs.\+\ze'. b:vikiSimpleNameQuoteEnd ."$")
        endif
    elseif !viki#IsSupportedType("c")
        throw "Viki: CamelCase names not allowed"
    endif

    if v_name != g:vikiSelfRef
        " TLogVAR v_dest, v_name, useSuffix
        let rdest = viki#ExpandSimpleName(v_dest, v_name, useSuffix)
        " TLogVAR rdest
    else
        let rdest = g:vikiDefNil
        " TLogVAR rdest
    endif

    if i_name != ''
        let rdest = viki#InterVikiDest(rdest, i_name)
        " TLogVAR rdest
        " let v_name = ''
    endif

    let v_type   = v_type == g:vikiDefNil ? 's' : v_type
    " TLogVAR v_type
    return viki#MakeDef(v_name, rdest, v_anchor, v_part, v_type)
endf


" Find a viki name
" viki_viki#Find(flag, ?count=0, ?rx=nil)
function! viki_viki#Find(flag, ...) "{{{3
    let rx = (a:0 >= 2 && a:2 != '') ? a:2 : viki#FindRx()
    if rx != ""
        let i = a:0 >= 1 ? a:1 : 0
        while i >= 0
            call search(rx, a:flag)
            let i = i - 1
        endwh
    endif
endf


let &cpo = s:save_cpo
unlet s:save_cpo
compiler/deplate.vim	[[[1
43
" viki.vim
" @Author:      Tom Link (micathom AT gmail com?subject=vim)
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Created:     25-Apr-2004.
" @Last Change: 2009-02-15.
" @Revision:    0.43
" 
" Description:
" Use deplate as the "compiler" for viki files.

if exists("current_compiler")
  finish
endif
let current_compiler = "deplate"
" let g:current_compiler="deplate"

if exists(":CompilerSet") != 2
    command! -nargs=* CompilerSet setlocal <args>
endif

let s:cpo_save = &cpo
set cpo&vim

fun! DeplateCompilerSet(options)
    if exists("b:deplatePrg")
        exec "CompilerSet makeprg=".escape(b:deplatePrg ." ". a:options, " ")."\\ $*\\ %"
    elseif exists("g:deplatePrg")
        exec "CompilerSet makeprg=".escape(g:deplatePrg ." ". a:options, " ")."\\ $*\\ %"
    else
        exec "CompilerSet makeprg=deplate ".escape(a:options, " ")."\\ $*\\ %"
        " CompilerSet makeprg=deplate\ $*\ %
    endif
endf
command! -nargs=* DeplateCompilerSet call DeplateCompilerSet(<q-args>)

DeplateCompilerSet

CompilerSet errorformat=%f:%l:%m,%f:%l-%*\\d:%m

let &cpo = s:cpo_save
unlet s:cpo_save

" vim: ff=unix
doc/viki.txt	[[[1
1196
*viki.txt*              Viki - A Pseudo Local Wiki Tool

                        Viki MANUAL
                        Thomas Link (micathom AT gmail com?subject=vim)


================================================================================
                                                    *viki-description*
Description~

This plugin adds wiki-like hypertext capabilities to Vim. You can use viki as 
a "minor" mode (i.e., as an add-on to any other mode) or as a full-fledged 
wiki mode. There is also an add-on plugin for "wikifying" latex documents by 
turning some latex commands into wiki names. If viki is properly configured, 
activating a reference to an image, a webpage etc. will view that resource in 
an external viewer.

From http://sourceforge.net/projects/deplate/ you can download a ruby based 
tool to convert viki markup to LaTeX, HTML, or DocBook. On its homepage 
(http://deplate.sf.net) you can read a more detailled specification of the 
markup.

MINOR WIKI MODE:
Just type |:VikiMinorMode| and all wiki names and URLs will be highlighted.  
When the cursor is over a wiki name, you can press <c-cr> to jump to (or 
create) the referred page (on a terminal use <LocalLeader>vf). Pressing 
<LocalLeader>vb brings you back to the original document. Alternatively, you 
can use <m-leftmouse> and <m-rightmouse> to jump back and forth. (NOTE: In 
minor mode, it's possible that viki words and URLs are not highlighted when 
they are included in some syntactic regions.)

FULL WIKI MODE:
In full mode, viki becomes a personal wiki 
(http://c2.com/cgi/wiki?PersonalWiki). Set 'filetype' to viki or execute 
|:VikiMode|. The full wiki mode is like the minor mode but with folding 
support, syntax highlighting (for headings, lists, tables, textstyles etc.), 
and additional key bindings (i.e., you can press <c-tab> or <s-c-tab> to move 
the cursor to the next/previous viki name).

BUT HEY, WHAT IS A WIKI ANYWAY:
Among the vast amount of possible definitions, I prefer this one, which is my 
own anyway :-): a wiki is a simple way of creating hypertexts. In its basic 
form creating a hyperlink is as easy as writing a word in CamelCase (although 
this sometimes turn out to be more annoying than useful) or by a rather 
minimalist markup -- in the case of viki, this would be [[destination]] or 
[-destination-].

You begin by creating a directory where your wiki files should go to and by 
creating a wiki index -- a master file that contains references to sub-pages. 
After a while you end up with many small, tightly interlinked files/notes.

Wikis also come with a rather subtle markup. Here is a simple comparison of 
two examples of LaTeX and viki markup so that you get the idea of what it 
looks like:

LaTeX: \section{Title}
Viki:  * Title

LaTeX: \emph{text}
Viki:  __text__

And some wikis provide tools for translating this markup to other formats 
(like viki does in the form of the "deplate" program, which can translate viki 
markup to LaTeX, HTML, and Docbook). Unfortunately, about every wiki has its 
own markup. 


================================================================================
                                                    *viki-installation*
Installation~

Edit the vba file and type: >

    :so %

See :help vimball for details. If you have difficulties or use vim 7.0, 
please make sure, you have the current version of vimball (vimscript 
#1502) installed.

This script requires tlib (vimscript #1863) to be installed.

Viki requires: >

    :set nocompatible
    :filetype plugin indent on
    :syntax on

You might also want to set 'expandtab' (local to buffer) in 
after/ftplugin/viki.vim: >

    setlocal expandtab

Viki will be automatically loaded when starting vim. In case you have vim 
already running and don't want to restart it, you can also type: >

    :runtime plugin/viki.vim

Viki doesn't set the viki filetype for you. How you set the filetype is up to 
you to decide. Basically, there are two possibilities: based on a suffix or 
based on the location. See |viki-filetype-detection|.


Customization:                                      *viki-customization*
It's probably a good idea to check the values of the following variables:

    - |g:vikiUpperCharacters| and |g:vikiLowerCharacters|; for the most 
      commonly used foreign language characters in a Western European 
      context set these variables to something like (this refers to the 
      characters allowed in simple viki names and in anchors; for East Asian 
      languages you probably prefer to use quoted viki names anyway): >

        " this is in iso-latin-1
        let g:vikiLowerCharacters = "a-zäöüßáàéèíìóòçñ"
        let g:vikiUpperCharacters = "A-ZÄÖÜ"
<
    - |g:vikiUseParentSuffix| (see also |viki-names|); I personally prefer 
      this to be ON >

        let g:vikiUseParentSuffix = 1
<
    - |vikiNameTypes| (see |viki-names|): control which type of viki names you 
      want to use (this allows you to turn off, e.g., simple viki names)

You might also need to configure some external programs (use the variables 
g:vikiOpenUrlWith_{PROTOCOL} and g:vikiOpenFileWith_{SUFFIX}) like in this 
example: >

    let g:vikiOpenUrlWith_mailto = 'thunderbird -compose %{URL}'
    let g:vikiOpenFileWith_html  = "silent !firefox %{FILE}"
    let g:vikiOpenFileWith_ANY   = "silent !start %{FILE}"

This way, if you had, e.g., pdftotext (from the xpdf distribution) installed, 
you could make viki to open references to pdf files right in VIM: >

    fun! ConvertPDF()
        if !exists("b:convertedPDF")
            exec "cd ". expand("%:p:h")
            exec "%!pdftotext ". expand("%:t") ." -"
            :%!par 72w
            cd -
            setlocal noswapfile buftype=nowrite
            let b:convertedPDF = 1
        endif
    endf
    let g:vikiOpenFileWith_pdf = 'call viki#OpenLink("%{FILE}", "", 1)|silent call ConvertPDF()'

                                                    *viki-intervikis*
Later on, you probably want to define some intervikis. A |interviki| is a 
shortcut to a different viki directory/namespace, so that you have to care 
less about page names.

There are two ways to define an interviki:

                                                    *viki#Define()*
    1. Use viki#Define(name, prefix, ?suffix="*", ?index="Index.${suffix}")

        call viki#Define('SCI', $HOME."/Projects/Sci/Ideas", ".txt")

       This command will automatically define a menu for each interviki 
       (unless g:vikiMenuPrefix is empty) and it will also define a command 
       with the name of the interviki that can be used to quickly access viki 
       files from the vim command line.

                                                    *g:viki_intervikis*
    2. Use g:viki_intervikis (a dictionary). The values can be either a list 
       (arguments for |viki#Define()|) or a string.

        let g:viki_intervikis['SCI']  = [$HOME."/Projects/Sci/Ideas", ".txt"]
        let g:viki_intervikis['PROJ'] = $HOME."/Projects"

Intervikis added to g:viki_intervikis will be defined via |viki#Define()| when 
first loading ~/vimfiles/autoload/viki.vim. I.e. you cannot use automatically 
defined commands or menus before loading the autoload file. So, if you don't 
use the menus and the interviki commands to open files from the command line, 
use the variable. Otherwise, calling |viki#Define()| from 
~/vimfiles/after/plugin/viki.vim might be the better solution (which would 
also load autoload/viki.vim on startup though).

This could then be accessed as SCI::ThisIdea, which would refer to the file 
"~/Projects/Sci/Ideas/ThisIdea.txt".

viki#Define also defines a command (:SCI in this example) that opens a wiki's 
index file (an optional 4th argument or "${g:vikiIndex}.${suffix}").

Intervikis can also be defined as patterns or functions as in the following 
example: >

    fun! GetAddress(vikiname)
        let surname = substitute(a:vikiname, '^\(\u.\{-}\)\(\u\U*\)\?$', '\1', '')
        let firstname  = substitute(a:vikiname, '^\(\u.\{-}\)\(\u\U*\)\?$', '\2', '')
        return 'https://www.example.com/cgi/search.cgi?search='. surname .','. firstname
    endf

    call viki#Define('CONTACT', '*GetAddress("%s")')
    call viki#Define('INDEX', '%/foo/%s/index.html')

CONTACT::JohnDoe would the refer to 
https://www.example.com/cgi/search.cgi?search=Dow,John and [[INDEX::bar]] 
would refer to /foo/bar/index.html

In order to use the LaTeX enabled viki variant, add this to your |vimrc| file: >

    au FileType tex let b:vikiFamily="LaTeX"

In order to automatically set |deplate| as the compiler for viki files: >

    " we want to allow deplate to execute ruby code and external helper 
    " application
    let g:deplatePrg = "deplate -x -X "
    au FileType viki compiler deplate

                                                    *viki-filetype-detection*
Some users might want to automatically set the filetype to viki depening on 
the file extension. This can be done using |:autocmd|: >

    let g:vikiNameSuffix=".viki"
    autocmd! BufRead,BufNewFile *.viki set filetype=viki

You can also use |:autocmd| to set the filetype depending on the path: >

    autocmd! BufRead,BufNewFile $HOME/MyWiki/* set filetype=viki

If the variables b:getVikiLink or b:getExtVikiLink exist, their values are 
used as _function_ names for returning the current viki name's definition. A 
viki definition is an array of the three elements name, destination, anchor 
with g:vikiDefSep as the separator.

If the variables b:editVikiPage or b:createVikiPage exist, their values are 
interpreted as _command_ names for editing readable or creating new wiki 
pages.

For a better highlighting of viki files, also check out these variables:

    - |g:vikiTypewriterFont| (see |viki-textstyles|)
    - |g:vikiHeadingFont| (see |viki-headings|)
    - |g:vikiHyperLinkColor|
    - |g:vikiInexistentColor|

                                                    *viki-indent-disable*
In order to disable the indentation plugin, define the variable g:vikiNoIndent 
and set it to whatever you want.


===============================================================================
                                                    *viki-requirements*
Optional Enhancements~

- genutils.vim (vimscript #197 for saving back references; but see 
  |g:vikiSaveHistory|)
- imaps.vim (vimscript #244 or #475 for |:VimQuote|)
- kpsewhich (not a vim plugin :-) for LaTeX support


================================================================================
                                                    *viki-names*
Viki Names~

A viki name is either:

                                                    *viki-simple-names*
    1. Simple wiki names -- these refer to files in the same directory as the 
       current file:

        a. a word in CamelCase
            VikiName
            VikiName#anchor

            NOTE: A simple viki name may include characters from 
            |g:vikiUpperCharacters| and |g:vikiLowerCharacters|.

        b. some text between "[-" and "-]"
            [-name-]
            [-some name-]#there

            NOTE: "[--]" refers to the current file.

            NOTE: Anyways, the characters []:*&?<>/|\" are not allowed in 
            names as they usually cause trouble when included in file names.

                                                    *interviki*
         c. an "inter wiki" name, where the first part (in upper-case letters) 
         is a shortcut to some other viki, so that you have to care less about 
         page names

            OTHERVIKI::VikiName
            OTHERVIKI::VikiName#there
            OTHERVIKI::[-some name-]
            OTHERVIKI::[-some name-]#there

            E.g., if you had two intervikis defined, say SCI and COMP, you 
            could the refer to their pages as in: >

                Couldn't SCI::ThisIdeaOfMine be combined with COMP::ThisIdeaOfMine?
<
            NOTE: You can define intervikis with the VikiDefine command: >

                VikiDefine OTHERVIKI /home/t/Wiki .vik

<           Then OTHERVIKI::VikiName points to the file "/home/t/Wiki/VikiName.vik".

            NOTE: Set the string variable g:vikiInter{NAME}_suffix (see 
            |curly-braces-names|) in order to override the settings of 
            |b:vikiNameSuffix| and |g:vikiUseParentSuffix| for references to 
            the other viki.

        NOTE: If the variable |b:vikiNameSuffix| is defined, it will be added to 
        simple wiki names so that the simple wiki name "OtherFile" refers to 
        "OtherFile.suffix" -- e.g. for interlinking LaTeX-files.  
        Alternatively, you can set |g:vikiUseParentSuffix| to non-zero in order 
        to make viki always append the "parent" file's suffix to the 
        destination file.

                                                    *viki-extended-names*
    2. an extended wiki name of the form:

            [[destination]]
            [[OTHERVIKI::destination]]
            [[destination][name]]
            [[destination#anchor][name]]
            [[#anchor]]
            [[#anchor][name]]

        NOTE: The destination name is taken literally, i.e. variables like 
        |g:vikiUseParentSuffix| or |b:vikiNameSuffix| have no effect.

        NOTE: Opening extended wiki names referring to files with suffixes 
        matching one of |vikiSpecialFiles| (e.g. [[test.jpg]]) can be 
        delegated to the operating system -- see |VikiOpenSpecialFile()|. The 
        same is true for names matching |vikiSpecialProtocols|, which will be 
        opened with |VikiOpenSpecialProtocol()|.

        NOTE: In extended wiki names, destination path is relative to the 
        document's current directory if it doesn't match 
        "^\(\/\|[a-z]:\|[a-z]\+://\)". I.e.  [[../test]] refers to the 
        directory parent to the document's directory. A tilde at the beginning 
        will be replaced with $HOME.

                                                    *viki-urls*
    3. an URL
        It is assumed that these URLs should be opened with an external 
        program; this behaviour can be changed by redefining the function 
        |VikiOpenSpecialProtocol()|.

    4. Hyperwords (not supported by deplate)
        Hyperwords are defined in either ./.vikiWords or &rtp[0]/vikiWords.txt 
        each word in a line in the form "word destination" (lines beginning  
        with '%' are ignored). These words are automatically highlighted.  
        Depending on your setting of |vikiNameTypes|, viki may try to make 
        hyperwords out of the filenames in the current buffer's directory.  
        I.e. if |vikiNameSuffix| is '.txt' and there is a file 'example.txt' 
        in the same directory as the current buffer's file, then each 
        occurrence of the word 'example' will be turned into a clickable link. 
        You can prevent a file name from being highlighted as hyperword by 
        defining an entry in the vikiWords file with "-" as destination.

Adding #[a-z0-9]\+ to the wiki name denotes a reference to a specific anchor.  
Examples for wiki names referring to an anchor: >

	ThatPage#there
	[[anyplace/filename.txt#there]]
	[[anyplace/filename.txt#there][Filename]]

A anchor is marked as "^".b:commentStart."\?#[a-z0-9]\+" in the destination
file. If |b:commentStart| is not defined, the EnhancedCommentify-variables or
|&commentstring| will be used instead.  Examples ('|' = beginning of line):

    - LaTeX file, b:commentStart is set to "%"
      |%#anchor
      |#anchor
    - C file, |&commentstring| is set to "/*%s*/"
      |/*#anchor */
    - Text file, b:commentStart is undefined
      |#anchor

NOTE: If "#" is the comment character (as in ruby), a space should follow the
comment character in order to distinguish comments from anchors.

NOTE: In "full" viki mode (when invoked via VikiMode) comments are marked 
with "%" by default (see g:vikiCommentStart). An anchor has thus to be 
written as in the LaTeX example.

NOTE: |deplate| attaches an anchor to the previous element (e.g. |viki-tables|).


================================================================================
                                                    *viki-markup*
Pseudo Markup~

The pseudo markup is to some degree compatible with emacs-wiki, which in turn  
is to some degree compatible with some other wiki -- i.e., it's compatible 
enough to edit and work with files in emacs-wiki markup, but in some aspects 
it's more restrictive. Unfortunately, as there is currently no 
html-translator/exporter for this markup, it's quite useless for the moment.
But it looks nice on the screen.


                                                    *viki-headings*
Headings~
* Level 1
** Level 2
...

    NOTE: Headings can span more than one line by putting a backslash ('\') at 
    the end of the line.

    NOTE: If |g:vikiHeadingFont| is defined, the heading will be set in this 
    font.


                                                    *viki-lists*
Lists: (indented)~

    - Item
        * Item
            + Item
                1. Item 1
                    a. Item a
                    B. Item B
        # Item
            # Item 1
            # Item 2
                @ Item A
                @ Item B

NOTE: "@" (unordered lists) and "#" (ordered lists) are the preferred markers.


                                                    *viki-descriptions*
Descriptions: (indented)~

    Item :: Description


                                                    *viki-tasks*
Tasks: (indented)~
emacs-planer compatible mode: >

    #A1 _           Important task
    #A2 x           Less important task (done)
    #A2 90%         Less important task (mostly completed)
    #B2 2005-10-30  Less important task with deadline
    #B2 x2005-10-25 Less important task (completed)

You can switch category, priority, and date: >

    #1A _           Important task
    #2A x           Less important task (done)

    #2005-10-30  2A Important task
    #2005-11-11  1A Most important task
    #x2005-10-30 3A Less important task (done)


                                                    *viki-tables*
Tables~
|| Head || Category ||
|  Row  |  Value     |
#CAPTION: This Table
#label

NOTE: Rows can span more than one line by putting a backslash ('\') at the end 
of the line.


                                                    *viki-symbols*
Symbols~
<-, ->, <=, =>, <~, ~>, <->, <=>, <~>, !=, ~~, ..., --, ==


                                                    *viki-markers*
Markers~
+++, ###, ???, !!!


                                                    *viki-strings*
Strings~
"Text in \"quotes\""

NOTE: See also |g:vikiMarkupEndsWithNewline|.


                                                    *viki-textstyles*
Textstyles~

    __emphasized__, ''typewriter''

<   NOTE: There must not be a whitespace after the opening mark.

    NOTE: For the word styles, there must be a non-word character (|/\W|) 
    before the opening mark, i.e. a__b__c will be highlighted as normal text -- 
    it won't be highlighted. You could use the continuous markup for putting 
    the "b" in the example in italic.

    NOTE: If |g:vikiTypewriterFont| is defined, this font will be used to 
    highlight text in typewriter style.

    NOTE: See also |g:vikiMarkupEndsWithNewline|.


                                                    *viki-comments*
Comments (whole lines)~
%Comment


                                                    *viki-regions*
Regions~
#Type [OPTIONS] <<EndOfRegion
Text ...
EndOfRegion

For a list of supported regions see the |deplate| documentation.


                                                    *viki-sharp-commands*
One-line commands~
#COMMAND [OPTIONS]: ARGS

OPTIONS have the form
    - OPTION! ... set option to true
    - OPTION=VALUE
    - the characters "!" and "=" have to be escaped with a backslash

Commands are applied only if the option "fmt" isn't given or if it matches the 
formatter regexp.

Short list of available COMMANDS "COMMAND" (see also |deplate|):
    - INC: INCLUDED FILENAME
    - FIG [here!|top!|bottom!]: FILENAME
    - CAP [above!|below!]: TEXT
    - TITLE: TEXT
    - AUTHOR: TEXT
    - AUTHORNOTE: TEXT
    - DATE: [TEXT|now|today]
    - MAKETITLE [page!]
    - LIST [page!]: [contents|tables|figures|index]
    - PAGE

It depends on the formatter if these options have any effect.
    - DOC ... document options
    - OPT ... element options (applies to the previous element)


                                                   *viki-macros*
Curly braces~
Curly braces should be escaped with a backslash (i.e., \{ and \}), as they 
usually mark macros: >

    {MACRO [OPTIONS]: ARGS...}
<
Short list of available macros (see also |deplate|):
    - {fn: ID}
        - inserts a footnote as defined by in a Fn or Footnote region. 
        - output depends on the formatter
        - Example: >
            Foo bar{fn: x} foo bar.

            #Fn: x <<EOF
                Bla bla.
            EOF
<   - {cite: ID}
        - output depends on the formatter
    - {date: [format string|now|today]}
        - the format string uses ruby's strftime method.
    - {ins: LITERALLY INSERTED TEXT}
        - Example: {ins fmt=html: &lt;&lt;}
    - {doc: ID}
        - access document options, e.g. {opt: author}
    - {opt: ID}
        - access element (paragraph, table etc.) options
    - {ruby [alt=ALTERNATIVE OUTPUT]: RUBY CODE}
        - if the evaluation of ruby code is disabled, the text given in the 
          alt option or an empty string will be inserted
        - a sequence of ruby commands must be separated by semicolons

Common options:
    - fmt=FORMATTER, nofmt=UNMATCHED FORMATTER

NOTE: Macros cannot cross paragraph borders, i.e., they must not contain empty 
lines. Using newlines in a macro argument is useless, as the macro text will 
be collapsed to one single line.


                                                    *viki-backslash*
Backslashes~
    - A backslash at the end of the line should make a pattern include the 
      next line.
    - In general, a backslash should be an escape character that prevents the 
      vikification of the following character.
    - A backslash should itself be escaped by a backslash.

\_nounderline_, \NoVikiName


================================================================================
                                                    *viki-key-bindings*
Default Key Binding~

<c-cr> ... |viki#MaybeFollowLink()|: Usually only works when the cursor is over 
a wiki syntax group -- if the second argument is 1 it tries to interpret the 
text under the cursor as a wiki name anyway. (NOTE: If you're working on a 
terminal, <c-cr> most likely won't work. Use <LocalLeader>vf instead.)

<LocalLeader>vf ... Open in window
<LocalLeader>vt ... Open in a new tab
<LocalLeader>vs ... Open in a new window
<LocalLeader>vv ... Open in a new window but split vertically
    - see also |vikiSplit|

<LocalLeader>v1 - <LocalLeader>v4 ... Open in window 1-4

<LocalLeader>ve ... |:VikiEdit| edit a viki page

<LocalLeader>vb <LocalLeader>v<left> ... |viki#GoBack()|
<LocalLeader>v<bs> <LocalLeader>v<up> ... |viki#GoParent()|

<LocalLeader>vq ... |:VikiQuote| mark selected text a quoted viki name

<LocalLeader>vd ... |:VikiMarkInexistent| in the whole document
<LocalLeader>vp ... |:VikiMarkInexistent| in the current paragraph

If |g:vikiMapMouse| is true then these mappings are active, too:
<m-leftmouse> ... |viki#MaybeFollowLink()|
<m-leftmouse> ... |viki#GoBack()| (always jumps to the last known entry point)


Additional Key Binding In Full Viki Mode

<c-tab>, <LocalLeader>vn   ... |:VikiFindNext|
<s-c-tab>, <LocalLeader>vN ... |:VikiFindPrev|


================================================================================
                                                    *viki-commands*
Commands~

                                                    *:VikiMinorMode*
- VikiMinorMode
  NOTE: Be aware that we cannot highlight a reference if the text is embedded 
  in syntax group that doesn't allow inclusion of arbitrary syntax elemtents.

                                                    *:VikiMode*
- VikiMode (do additional highlighting)
  Basically the same as: >
    set ft=viki
< The main difference between these two is that VikiMode unlets 
  b:did_ftplugin to make sure that the ftplugin gets loaded.

                                                    *:VikiFind*
                                                    *:VikiFindNext* *:VikiFindPrev*
- VikiFindNext, VikiFindPrev (find the next/previous viki name or URL)

                                                    *:VikiMarkInexistent*
                                                    *:VikiMarkInexistentInParagraph*
- VikiMarkInexistent, VikiMarkInexistentInParagraph
  Update the highlighting of links to inexistent files. VikiMarkInexistent 
  can take a range as argument.

- VikiQuote                                         *:VikiQuote*
  Mark selected text as a quoted simple viki name, i.e., enclose it in 
  [- and -].

- VikiEdit[!] NAME                                     *:VikiEdit*
  Edit the wiki page called NAME. If the NAME is '*', the |viki-homepage| will 
  be opened. This is a convenient way to edit any wiki page from vim's command 
  line. If you call :VikiEdit! (with bang), the homepage will be opened first, 
  so that the homepage's customizations (and not the current buffer's one) are 
  in effect. There are a few gotchas:

  1. Viki doesn't define a default directory for wiki pages. Thus a wiki page 
  will be looked for in the directory of the current buffer -- whatever this 
  is -- and the customizations of this buffer are in effect. You can 
  circumvent this problem by using |interviki| names or define a 
  |viki-homepage| and call :VikiEdit! with a bang.

  2. Viki relies on some buffer local variables to be set. As customizability 
  is one viki's main design goal (although, one might want to discuss whether 
  I overdid it), there are no global settings that would define what a valid 
  viki name is supposed to look like. As a consequence, if you disabled a 
  certain type of wiki name in the current buffer, you won't be able to edit a 
  wiki page of this type. E.g.: If the current buffer contains a LaTeX file, 
  |vikiFamily| is most likely set to "LaTeX" (see |viki-latex|). For the LaTeX 
  family, e.g., CamelCase and interwiki names are disabled. Consequently, you 
  can't do, e.g., ":VikiEdit IDEAS::WikiPage". Again, you can circumvent this 
  problem by defining a |viki-homepage| and call :VikiEdit! with a bang.

- VikiHome                                          *:VikiHome*
  Open the |viki-homepage|.

- VikiDefine NAME BASE ?SUFFIX                      *:VikiDefine*
    Define an interviki. See also |viki#Define()|.

================================================================================
                                                    *viki-functions*
Functions~

- VikiMinorMode(state)                              *VikiMinorMode()*

- VikiMode(family)                                  *VikiMode()*

- viki#MaybeFollowLink(oldmap, ignoreSyntax)         *viki#MaybeFollowLink()*
    oldmap: If there isn't a viki link under the cursor:
        ""       ... throw error 
        1        ... return \<c-cr>
     	whatever ... return whatever
    ignoreSyntax: If there isn't a viki syntax group under the cursor:
        0 ... no viki name found
        1 ... look if there is a viki name under cursor anyways

- viki#FindAnchor(anchor)                            *viki#FindAnchor()*

                                                    *b:vikiParent*
- viki#GoParent()                                    *viki#GoParent()* 
    If b:vikiParent is defined, open this viki name, otherwise use 
    |viki#GoBack()|.

- viki#GoBack()                                      *viki#GoBack()*
    Viki keeps record about the "source" files from where a viki page was 
    entered.  Calling this function jumps back to the "source" file (if only 
    one such back reference is known) or let's you select from a list of 
    "source" files. The information is stored in buffer variables -- i.e., it 
    gets lost after closing the buffer. Care was taken to reduce information 
    clutter, which is why the number of possible back references per "source" 
    file was limited to one.

- VikiOpenSpecialFile(filename)                     *VikiOpenSpecialFile()*
    Handles filenames that match |vikiSpecialFiles|.
    If g:vikiOpenFileWith_{SUFFIX} is defined, it contains a command 
    definition for opending files of this type. "%{FILE}" is replaced with the 
    file name ("%%" = "%") and the resulting string is executed. Example: >

        let g:vikiOpenFileWith_html = '!firefox %{FILE}'

<   The contents of variable g:vikiOpenFileWith_ANY will be used as fallback
    command. Under Windows, g:vikiOpenFileWith_ANY defaults to "silent !cmd /c 
    start".
    All suffixes are translated to lower case.

- VikiOpenSpecialProtocol(url)                      *VikiOpenSpecialProtocol()*
    Handles filenames that match |vikiSpecialProtocols|.
    If g:vikiOpenUrlWith_{PROTOCOL} is defined, it contains a command definition 
    for opending urls of this type. "%{URL}" is replaced with the url ("%%" = 
    "%") and the resulting string is executed. Example: >

        let g:vikiOpenUrlWith_mailto = '!thunderbird -compose %{URL}'

<   The contents of variable g:vikiOpenUrlWith_ANY will be used as fallback
    command. Under Windows, g:vikiOpenUrlWith_ANY defaults to "silent 
    !rundll32 url.dll ...".
    All protocol names are translated to lower case.


================================================================================
                                                    *viki-variables*
Variables~

Homepage:                                           *viki-homepage*
                                                    *g:vikiHomePage*
- g:vikiHomePage:
    An absolute filename that is the general viki homepage (see also 
    |:VikiEdit| and |:VikiHome|).

Simple Viki Names [2]:                              *viki-vars-simple-names*
                                                    *g:vikiLowerCharacters* 
                                                    *g:vikiUpperCharacters*
- g:vikiLowerCharacters, g:vikiUpperCharacters, b:vikiLowerCharacters, 
  b:vikiUpperCharacters
    These default to "a-z" and "A-Z" respectively; "international" users 
    should set these variables in their |vimrc| file to fit their needs

- b:vikiAnchorMarker

- b:vikiSimpleNameRx, b:vikiSimpleNameSimpleRx[1]
- b:vikiSimpleNameNameIdx, b:vikiSimpleNameDestIdx, b:vikiSimpleNameAnchorIdx

Extended Viki Names [2]:                            *viki-vars-ext-names*
- b:vikiExtendedNameRx, b:vikiExtendedNameSimpleRx[1]
- b:vikiExtendedNameNameIdx, b:vikiExtendedNameDestIdx, 
  b:vikiExtendedNameAnchorIdx

URLs [2]:                                           *viki-vars-urls*
- b:vikiUrlRx, b:vikiUrlSimpleRx[1]
- b:vikiUrlNameIdx, b:vikiUrlDestIdx, b:vikiUrlAnchorIdx

NOTE: [1] The same as *Rx variables but with less groups.
NOTE: [2] These variables are defined by |VikiSetupBuffer()|.

- b:vikiAnchorRx                                    *b:vikiAnchorRx*
    If this variable exists, the string "%{ANCHOR}" will be replaced with the 
    search text. The expression has to conform to the very nomagic |/\V| 
    syntax.

- g:vikiFreeMarker                                  *g:vikiFreeMarker*
    If true and an explicitly marked anchor isn't found, search for the anchor 
    text as such. This search will be case-insensitive. deplate won't be able 
    to deal with such pseudo-references, of course.


File handling:

- g:vikiSpecialFiles, b:vikiSpecialFiles            *vikiSpecialFiles*
    Default value: jpg\|gif\|bmp\|pdf\|dvi\|ps
    A list of extensions for files that should be opened with 
    |VikiOpenSpecialFile()|.

- g:vikiSpecialProtocols, b:vikiSpecialProtocols    *vikiSpecialProtocols*
    Default value: https\?\|ftps\?
    A list of protocolls that should be opened with 
    |VikiOpenSpecialProtocol()|.

- g:vikiUseParentSuffix                             *g:vikiUseParentSuffix*
    Default value: 0
    If true, always append the "parent" file's suffix to the destination file 
    name. I.e. if the current file is "ThisIdea.txt" the the viki name 
    "OtherIdea" will refer to the file "OtherIdea.txt".

- g:vikiNameSuffix b:vikiNameSuffix                 *vikiNameSuffix* *b:vikiNameSuffix*
    Default value: ""
    Append suffix to the destination file name.


Markup:

- g:vikiTextStyles, b:vikiTextStyles                *vikiTextStyles*
    Default: 2
    Defines the markup of |viki-textstyles| like emphasized or code.

- g:vikiCommentStart                                *g:vikiCommentStart*
    Default value: %
    Defines the prefix of comments when in "full" viki mode.

- b:vikiCommentStart                                *b:vikiCommentStart*
    In minor mode this variable is set to either:
        - b:commentStart
        - b:ECcommentOpen
        - matchstr(&commentstring, "^\\zs.*\\ze%s")
    In "full" viki mode it's set to |g:vikiCommentStart|.

- g:vikiTypewriterFont                              *g:vikiTypewriterFont*
    See |viki-textstyles|.

- g:vikiHeadingFont                                 *g:vikiHeadingFont*
    See |viki-headings|.

- g:vikiHyperLinkColor                              *g:vikiHyperLinkColor*
    Default: DarkBlue or LightBlue (depending on 'background')
    The color of hyperlinks, viki names etc.

- g:vikiInexistentColor                             *g:vikiInexistentColor*
    Default: Red
    The color of links to inexistent files.

- g:vikiFamily, b:vikiFamily                        *vikiFamily*
    By defining this variable, family specific functions will be called for:
        - viki#{b:vikiFamily}#SetupBuffer(state)
        - viki#{b:vikiFamily}#DefineMarkup(state)
        - viki#{b:vikiFamily}#DefineHighlighting(state)
        - viki#{b:vikiFamily}#CompleteSimpleNameDef(def)
        - viki#{b:vikiFamily}#CompleteExtendedNameDef(def)
        - viki#{b:vikiFamily}#FindAnchor(anchor)
    If one of these functions is undefined for a "viki family", then the
    default one is called.

    Apart from the default behaviour the following families are defined:
        - latex (see |viki-latex|)
        - anyword (see |viki-anyword|)


Etc:

- g:vikiMapMouse                                    *g:vikiMapMouse*
    See |viki-key-bindings|.

- b:vikiSplit, g:vikiSplit                          *vikiSplit*
    -1 ... open all links in a new windows
    -2 ... open all links in a new windows but split vertically
    Any positive number ... open always in this window

- b:vikiNameTypes, g:vikiNameTypes                  *vikiNameTypes*
    Default value: "csSeuixwf"
        s ... Simple viki name 
            c ... CamelCase 
            S ... simple, quoted viki name
            i ... |interviki|
            w ... Hyperwords
                f ... file-bases hyperwords
        e ... Extended viki name
        u ... URL
        x ... Directives (some commands, regions ...)
    Disable certain types of viki names globally or for a single buffer.
    (experimental, doesn't fully work yet)

- g:vikiSaveHistory                                 *g:vikiSaveHistory*
    Default value: 0
    If genutils.vim is installed, the history data will be saved in 
    |viminfo-file|. Like most of this plugin, this feature is _experimental_
    and is turned off by default.

- g:vikiExplorer                                    *g:vikiExplorer*
    Default: "Sexplore"
    If a viki name points to a directory, we use this command for viewing the 
    directory contents.

- g:vikiMarkInexistent                              *g:vikiMarkInexistent*
    Default: 1
    If non-zero, highligh links to existent or inexistent files in different 
    colours.

- b:vikiInverseFold                                 *b:vikiInverseFold*
    Default: 0 == OFF
    If set, the section headings' levels are folded in reversed order so that 
    |b:vikiMaxFoldLevel| corresponds to the top level and 1 to the lowest 
    level. This is useful when maintaining a file with a fixed structure where 
    the important things happen in subsections while the top sections change 
    little.

- b:vikiMaxFoldLevel                                *b:vikiMaxFoldLevel*
    Default: 5
    When using |b:vikiInverseFold|, a heading of level b:vikiMaxFoldLevel 
    corresponds to level 1, b:vikiMaxFoldLevel - 1 to level 2, 
    b:vikiMaxFoldLevel - 2 to level 3 ...  and a top heading to level 
    b:vikiMaxFoldLevel. I.e., if you set |foldlevel| to 1, you will see only 
    the text at level b:vikiMaxFoldLevel.

- g:vikiFoldBodyLevel, b:vikiFoldBodyLevel          *vikiFoldBodyLevel*
    Default: 4
    If set to 0, the "b" mode in |vikiFolds| will set the body level depending 
    on the headings used in the current buffer. Otherwise 
    g:vikiHeadingMaxLevel + 1 will be used.

- g:vikiFolds, b:vikiFolds                          *vikiFolds*
    Default: hl
    Define which elements should be folded:
        h :: Heading
        H :: Headings (but inverse folding)
        l :: Lists
        b :: The body has max heading level + 1. This is slightly faster 
          than the other version as vim never has to scan the text; but 
          the behaviour may vary depending on the sequence of headings if 
          |vikiFoldBodyLevel| is set to 0.
        s :: ???

- b:vikiNoSimpleNames                               *b:vikiNoSimpleNames*
    Default: 0
    If non-nil, simple viki names are disabled.

- b:vikiDisableType                                 *b:vikiDisableType*
    Disable certain viki name types (see |vikiNameTypes|).
    E.g., in order to disable CamelCase names only, set this variable to 'c'.

- g:vikiHide                                        *g:vikiHide*
    Default: ''
    If a dirty buffers gets hidden, vim usually complains. This can be 
    tiresome -- depending on your editing habits. When this variable is set to 
    "hide", vim won't complain. If you set it to "update", a viki buffer will 
    be automatically updated before editing a different file.  If you leave 
    this empty (""), the default behaviour is in effect. See also |hidden|.


================================================================================
                                                    *viki-highlight*
Highlighting~

Viki.vim defines several new highlight groups. Precaution is taken to select 
different colours depending on the background, but colour schemes are ignored. 
The colors are tested using color scheme with a white background.

    - vikiHyperLink
    - vikiHeading
    - vikiList
    - vikiTableHead
    - vikiTableRow
    - vikiSymbols
    - vikiMarkers
    - vikiAnchor
    - vikiString
    - vikiBold
    - vikiItalic
    - vikiUnderline
    - vikiTypewriter
    - vikiCommand


================================================================================
                                                    *viki-files*
Files Region~

Viki knows a special #Files region.

Example: >
    #Files glob=lib/** types=f <<
    [[example1.rb]]     This is an example file
    [[example2.rb]]     This is another example
    [[lib/example1.rb]]
    [[lib/example2.rb]]

    #Files glob=*.txt types=f <<
    [[example.txt]] The manual

The filenames are stored as extended viki names. Each line can take a comment 
that is restored upon automatic update.

There are a few special commands to deal with this region.

                                                    *:VikiFilesUpdate*
:VikiFilesUpdate
    - Update the current #Files region under the cursor.

                                                    *:VikiFilesUpdateAll*
:VikiFilesUpdateAll
    - Update all #Files region in the current buffer.


If in the following commands a "!" is added, the command works only on files 
in the same directory or a subdirectory as the file on the current line.

                                                    *:VikiFilesExec*
:VikiFilesExec[!] FORMAT_STRING
    - |:execute| a vim command after doing some replacements with the command 
      string. For each formatted string the command is issued only once -- 
      i.e. you can work easily with the directories. If no special formatting 
      string is contained, the preformatted filename is appended to the command.
        %{FILE}  ... filename
        %{FFILE} ... preformatted filename (with '#%\ ' escaped)
        %{DIR}   ... file's directory

                                                    *:VikiFilesCmd*
:VikiFilesCmd[!] VIKI_COMMAND_NAME
    - |:execute| VikiCmd_{VIKI_COMMAND_NAME} FILENAME

                                                    *:VikiFilesCall*
:VikiFilesCall[!] FUNCTION_NAME
    - |:call| VikiCmd_{FUNCTION_NAME}(FILENAME)


Default Key Binding~
<LocalLeader>vu ... :VikiFilesUpdate
<LocalLeader>vU ... :VikiFilesUpdateAll
<LocalLeader>vx ... :VikiFilesExec
<LocalLeader>vX ... :VikiFilesExec!

Example: >
    Use ":VikiFilesExec! e" (<LocalLeader>vXe<cr>) to edit all the files in 
    the same directory or a subdirectory of the current file under the cursor.


================================================================================
                                                    *viki-compile*
Viki Compile~

The compile plugin simply defines |deplate| as the current file's |makeprg|. 
It also provides basic support for |deplate|'s error messages.

The compiler plugin provides a command for setting compiler options:

    - DeplateSetCompiler [FLAGS]

E.g. when using the lvimrc plugin, you could put something like this into the 
current directorie's .lvimrc-file for putting the output into a dedicated 
directory: >

    DeplateSetCompiler -d ../html


================================================================================
                                                    *viki-latex* *vikiLatex*
Viki LaTeX~

The archiv includes an experimental add-on for using LaTeX commands as simple 
wiki names. Among the commands that are to some degree used as hyperlinks or 
anchors:

    - \viki[anchor]{name}
 	- \input
 	- \include
 	- \usepackage
 	- \psfig
 	- \includegraphics
    - \bibliography
    - \label (as anchors)
    - \ref (in the current file only)

Limitations: There must not be spaces between between the leading backslash, 
the command name, and its arguments. A command must not span several lines.

Simple viki names (including |interviki|, CamelCase, and quoted viki names) 
are disabled -- as they wouldn't be of much use in a LaTeX document anyway. 
(Well, as a matter of fact they aren't disabled but LaTeX commands are defined 
as simple viki names.)

This plugin also highlights a hypothetical \viki[anchor]{name} command, which
could be defined as: \newcommand{\viki}[2][]{#2}

If b:vikiFamily is set to "latex", then calling |:VikiMinorMode| will use 
these commands instead of normal viki names. This change can be made permanent 
by adding this line to your |vimrc| file: >

    au FileType tex let b:vikiFamily="latex"
<
                                                    *:VikiMinorModeLaTeX*
LaTeX support is switched on with the command :VikiMinorModeLaTeX. This 
command sets b:vikiFamily to "latex" and calls |:VikiMinorMode|. This
command relies on the external kpsewhich tool, which has to be installed on
your computer.

                                                    *vikiLatex-UserCommands*
You can extend the list of supported commands by listing your commands in
g:vikiLaTeXUserCommands and by defining a corresponding function called 
VikiLaTeX_{YourCommand}(args, opts). VikiLaTeX assumes that a command looks 
like this: \latexcommand[opts]{args}. This function should return a string 
that defines the variable dest (=destination file) as well as, optionally, 
anchor and name -- see |:return| for an explanation of how this works. A 
simple minded example: >

    let g:vikiLaTeXUserCommands = 'other\|self'

    fun! VikiLaTeX_other(args, opts)
        return 'let dest="'.a:args.'.tex" | let anchor="'.a:opts.'"'
    endfun

    fun! VikiLaTeX_self(args, opts)
        return 'let dest="'.g:vikiSelfRef.'" | let anchor="'.a:opts.'"'
    endfun


================================================================================
                                                    *viki-anyword*
Viki Any Word~

If b:vikiFamily or g:vikiFamily is set to "anyword", then any word becomes a 
potential viki link.

This feature conflicts with the highlighting of links to inexistent files. 
Links to inexistent files are displayed as normal text.


================================================================================
                                                    *viki-bibtex*
Viki BibTeX~

The bibtex ftplugin defines record labels as anchors. Thus, if make an 
|interviki| definition point to your bib files you can refer to bib entries as 
viki names. Example: >

    call viki#Define('BIB', $HOME ."/local/share/texmf/bibtex/bib/tml", ".bib")

    Then, activating the following viki name
    BIB::[-monos-]#rec02
    would open the file monos.bib and search for the record rec02.


================================================================================
                                                    *viki-tags*
Ctags~

For ctags support (e.g. in conjunction with taglist) add this to your .ctags 
file (this assumes that *.txt files are in viki mode; you have to adjust the 
file suffix if you choose a different suffix): >

    --langdef=deplate
    --langmap=deplate:.txt
    --regex-deplate=/^(\*+ .+)/\1/s,structure/
    --regex-deplate=/^(#[a-z][a-z0-9]+)/\1/s,structure/
    --regex-deplate=/\[\[[^\]]+\]\[([^\]]+)\]\]/\1/r,reference/
    --regex-deplate=/\[\[([^\]]+)\]\]/\1/r,reference/
    --regex-deplate=/([A-Z][a-z]+([A-Z][a-z]+)+)/\1/r,reference/
    --regex-deplate=/([a-z]+:\/\/[A-Za-z0-9.:%?=&_~@\/|-]+)/\1/u,url/

For use with taglist, the variable "tlist_viki_settings" is already set for 
you.


================================================================================
                                                    *deplate*
Deplate~

deplate is a ruby script/library that converts viki markup to:

    - html
    - htmlslides
    - latex
    - docbook

Download the latest version from http://sourceforge.net/projects/deplate/.

deplate's markup is not 100% identical with the standard viki mode's one.  
E.g., it doesn't support underline, italic markup. deplate sometimes failes 
with cryptic error messages and it doesn't always give the results one would 
expect. On the other hand, it features inclusion of LaTeX snippets, footnotes, 
references, an autogenerated index etc.


--
(the following is adapted from latex-suite.txt)
vim:fdm=expr:tw=78
vim:foldexpr=getline(v\:lnum-2)=~"=\\\\{80,}"?"a1"\:(getline(v\:lnum+1)=~"=\\\\{80,}"?"s1"\:"=")
vim:foldtext=v\:folddashes.substitute(getline(v\:foldstart),"\\\\s*\\\\*.*","","")
ftplugin/bib/viki.vim	[[[1
10
" viki.vim -- Make adaptions for bibtex
" @Author:      Tom Link (micathom AT gmail com?subject=vim)
" @Website:     http://members.a1.net/t.link/
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Created:     28-Jul-2004.
" @Last Change: 2009-02-15.
" @Revision:    0.9

let b:vikiAnchorRx = '\^\c\s\*@\[a-z]\+\s\*{\s\*%{ANCHOR}\s\*,\.\*\$'

ftplugin/viki.vim	[[[1
412
" viki.vim -- the viki ftplugin
" @Author:      Tom Link (micathom AT gmail com?subject=vim)
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Created:     12-Jän-2004.
" @Last Change: 2009-02-15.
" @Revision: 405

" if !g:vikiEnabled
"     finish
" endif

if exists("b:did_ftplugin") "{{{2
    finish
endif
let b:did_ftplugin = 1
" if exists("b:did_viki_ftplugin")
"     finish
" endif
" let b:did_viki_ftplugin = 1

let b:vikiCommentStart = "%"
let b:vikiCommentEnd   = ""
let b:vikiHeadingMaxLevel = -1
if !exists("b:vikiMaxFoldLevel") | let b:vikiMaxFoldLevel = 5 | endif "{{{2
if !exists("b:vikiInverseFold")  | let b:vikiInverseFold  = 0 | endif "{{{2

exec "setlocal commentstring=". substitute(b:vikiCommentStart, "%", "%%", "g") 
            \ ."%s". substitute(b:vikiCommentEnd, "%", "%%", "g")
exec "setlocal comments=fb:-,fb:+,fb:*,fb:#,fb:?,fb:@,:". b:vikiCommentStart

setlocal foldmethod=expr
setlocal foldexpr=VikiFoldLevel(v:lnum)
setlocal foldtext=VikiFoldText()
setlocal expandtab
" setlocal iskeyword+=#,{
setlocal iskeyword+={
setlocal iskeyword-=_

let &include='\(^\s*#INC.\{-}\(\sfile=\|:\)\)'
" let &include='\(^\s*#INC.\{-}\(\sfile=\|:\)\|\[\[\)'
" set includeexpr=substitute(v:fname,'\].*$','','')

let &define='^\s*\(#Def.\{-}id=\|#\(Fn\|Footnote\).\{-}\(:\|id=\)\|#VAR.\{-}\s\)'

" if !exists('b:vikiHideBody') | let b:vikiHideBody = 0 | endif

" if !hasmapto(":VikiFind")
"     nnoremap <buffer> <c-tab>   :VikiFindNext<cr>
"     nnoremap <buffer> <LocalLeader>vn :VikiFindNext<cr>
"     nnoremap <buffer> <c-s-tab> :VikiFindPrev<cr>
"     nnoremap <buffer> <LocalLeader>vN :VikiFindPrev<cr>
" endif

" compiler deplate

map <buffer> <silent> [[ :call viki#FindPrevHeading()<cr>
map <buffer> <silent> ][ :call viki#FindNextHeading()<cr>
map <buffer> <silent> ]] ][
map <buffer> <silent> [] [[

let b:undo_ftplugin = 'setlocal iskeyword< expandtab< foldtext< foldexpr< foldmethod< comments< commentstring< '
            \ .'define< include<'
            \ .'| unlet b:vikiHeadingMaxLevel b:vikiCommentStart b:vikiCommentEnd b:vikiInverseFold b:vikiMaxFoldLevel '
            \ .' b:vikiEnabled '
            \ .'| unmap <buffer> [['
            \ .'| unmap <buffer> ]]'
            \ .'| unmap <buffer> ]['
            \ .'| unmap <buffer> []'

let b:vikiEnabled = 2

if exists('*VikiFoldLevel') "{{{2
    finish
endif

function! VikiFoldText() "{{{3
  let line = getline(v:foldstart)
  if synIDattr(synID(v:foldstart, 1, 1), 'name') =~ '^vikiFiles'
      let line = fnamemodify(viki#FilesGetFilename(line), ':h')
  else
      let ctxtlev = tlib#var#Get('vikiFoldsContext', 'wbg')
      let ctxt    = get(ctxtlev, v:foldlevel, 0)
      " TLogVAR ctxt
      " TLogDBG type(ctxt)
      if type(ctxt) == 3
          let [ctxtbeg, ctxtend] = ctxt
      else
          let ctxtbeg = 1
          let ctxtend = ctxt
      end
      let line = matchstr(line, '^\s*\zs.*$')
      for li in range(ctxtbeg, ctxtend)
          let li = v:foldstart + li
          if li > v:foldend
              break
          endif
          let lp = matchstr(getline(li), '^\s*\zs.\{-}\ze\s*$')
          if !empty(lp)
              let lp = substitute(lp, '\s\+', ' ', 'g')
              let line .= ' | '. lp
          endif
      endfor
  endif
  return v:folddashes . line
endf

function! s:VikiFolds() "{{{3
    let vikiFolds = tlib#var#Get('vikiFolds', 'bg')
    " TLogVAR vikiFolds
    if vikiFolds == 'ALL'
        let vikiFolds = 'hlsfb'
        " let vikiFolds = 'hHlsfb'
    elseif vikiFolds == 'DEFAULT'
        let vikiFolds = 'hf'
    endif
    " TLogVAR vikiFolds
    return vikiFolds
endf

function! s:SetMaxLevel() "{{{3
    let pos = getpos('.')
    " TLogVAR b:vikiHeadingStart
    let vikiHeadingRx = '\V\^'. b:vikiHeadingStart .'\+\ze\s'
    let b:vikiHeadingMaxLevel = 0
    exec 'keepjumps g/'. vikiHeadingRx .'/let l = matchend(getline("."), vikiHeadingRx) | if l > b:vikiHeadingMaxLevel | let b:vikiHeadingMaxLevel = l | endif'
    " TLogVAR b:vikiHeadingMaxLevel
    call setpos('.', pos)
endf

if g:vikiFoldMethodVersion == 5

    function! VikiFoldLevel(lnum) "{{{3
        " TLogVAR a:lnum
        let vikiFolds = s:VikiFolds()
        if vikiFolds =~# 'h'
            " TLogVAR b:vikiHeadingStart
            let lt = getline(a:lnum)
            let fh = matchend(lt, '\V\^'. b:vikiHeadingStart .'\+\ze\s')
            if fh != -1
                " TLogVAR fh, b:vikiHeadingMaxLevel
                if b:vikiHeadingMaxLevel == -1
                    " TLogDBG 'SetMaxLevel'
                    call s:SetMaxLevel()
                endif
                if fh > b:vikiHeadingMaxLevel
                    let b:vikiHeadingMaxLevel = fh
                endif
                if vikiFolds =~# 'H'
                    " TLogDBG 'inverse folds'
                    let fh = b:vikiHeadingMaxLevel - fh + 1
                endif
                " TLogVAR fh, lt
                return '>'.fh
            endif
            let body_level = indent(a:lnum) / &sw + 1
            return b:vikiHeadingMaxLevel + body_level
        endif
    endf

elseif g:vikiFoldMethodVersion == 4

    function! VikiFoldLevel(lnum) "{{{3
        " TLogVAR a:lnum
        let vikiFolds = s:VikiFolds()
        if vikiFolds =~# 'h'
            " TLogVAR b:vikiHeadingStart
            let lt = getline(a:lnum)
            let fh = matchend(lt, '\V\^'. b:vikiHeadingStart .'\+\ze\s')
            if fh != -1
                " TLogVAR fh, b:vikiHeadingMaxLevel
                if b:vikiHeadingMaxLevel == -1
                    " TLogDBG 'SetMaxLevel'
                    call s:SetMaxLevel()
                endif
                if fh > b:vikiHeadingMaxLevel
                    let b:vikiHeadingMaxLevel = fh
                endif
                if vikiFolds =~# 'H'
                    " TLogDBG 'inverse folds'
                    let fh = b:vikiHeadingMaxLevel - fh + 1
                endif
                " TLogVAR fh, lt
                return '>'.fh
            endif
            if b:vikiHeadingMaxLevel <= 0
                return b:vikiHeadingMaxLevel + 1
            else
                return '='
            endif
        endif
    endf

elseif g:vikiFoldMethodVersion == 3

    function! VikiFoldLevel(lnum) "{{{3
        let lt = getline(a:lnum)
        if lt !~ '\S'
            return '='
        endif
        let fh = matchend(lt, '\V\^'. b:vikiHeadingStart .'\+\ze\s')
        if fh != -1
            " let fh += 1
            if b:vikiHeadingMaxLevel == -1
                call s:SetMaxLevel()
            endif
            if fh > b:vikiHeadingMaxLevel
                let b:vikiHeadingMaxLevel = fh
                " TLogVAR b:vikiHeadingMaxLevel
            endif
            " TLogVAR fh
            return fh
        endif
        let li = indent(a:lnum)
        let tf = b:vikiHeadingMaxLevel + 1 + (li / &sw)
        " TLogVAR tf
        return tf
    endf

elseif g:vikiFoldMethodVersion == 2

    function! VikiFoldLevel(lnum) "{{{3
        let lt = getline(a:lnum)
        let fh = matchend(lt, '\V\^'. b:vikiHeadingStart .'\+\ze\s')
        if fh != -1
            return fh
        endif
        let ll = prevnonblank(a:lnum)
        if ll != a:lnum
            return '='
        endif
        let li = indent(a:lnum)
        let pl = prevnonblank(a:lnum - 1)
        let pi = indent(pl)
        if li == pi || pl == 0
            return '='
        elseif li > pi
            return 'a'. ((li - pi) / &sw)
        else
            return 's'. ((pi - li) / &sw)
        endif
    endf

else

    function! VikiFoldLevel(lnum) "{{{3
        let lc = getpos('.')
        " TLogVAR lc
        let w0 = line('w0')
        let lr = &lazyredraw
        set lazyredraw
        try
            let vikiFolds = s:VikiFolds()
            if vikiFolds == ''
                " TLogDBG 'no folds'
                return
            endif
            if b:vikiHeadingMaxLevel == -1
                call s:SetMaxLevel()
            endif
            if vikiFolds =~# 'f'
                let idt = indent(a:lnum)
                if synIDattr(synID(a:lnum, idt, 1), 'name') =~ '^vikiFiles'
                    call s:SetHeadingMaxLevel(1)
                    " TLogDBG 'vikiFiles: '. idt
                    return b:vikiHeadingMaxLevel + idt / &shiftwidth
                endif
            endif
            if stridx(vikiFolds, 'h') >= 0
                if vikiFolds =~? 'h'
                    let fl = s:ScanHeading(a:lnum, a:lnum, vikiFolds)
                    if fl != ''
                        " TLogDBG 'heading: '. fl
                        return fl
                    endif
                endif
                if vikiFolds =~# 'l' 
                    let list = s:MatchList(a:lnum)
                    if list > 0
                        call s:SetHeadingMaxLevel(1)
                        " TLogVAR list
                        " return '>'. (b:vikiHeadingMaxLevel + (list / &sw))
                        return (b:vikiHeadingMaxLevel + (list / &sw))
                    elseif getline(a:lnum) !~ '^[[:blank:]]' && s:MatchList(a:lnum - 1) > 0
                        let fl = s:ScanHeading(a:lnum - 1, 1, vikiFolds)
                        if fl != ''
                            if fl[0] == '>'
                                let fl = strpart(fl, 1)
                            endif
                            " TLogDBG 'list indent: '. fl
                            return '<'. (fl + 1)
                        endif
                    endif
                endif
                " I have no idea what this is about.
                " Is this about "inverse" folding?
                " if vikiFolds =~# 's'
                "     if exists('b:vikiFoldDef')
                "         exec b:vikiFoldDef
                "         if vikiFoldLine == a:lnum
                "             return vikiFoldLevel
                "         endif
                "     endif
                "     let i = 1
                "     while i > a:lnum
                "         let vfl = VikiFoldLevel(a:lnum - i)
                "         if vfl[0] == '>'
                "             let b:vikiFoldDef = 'let vikiFoldLine='. a:lnum 
                "                         \ .'|let vikiFoldLevel="'. vfl .'"'
                "             return vfl
                "         elseif vfl == '='
                "             let i = i + 1
                "         endif
                "     endwh
                " endif
                call s:SetHeadingMaxLevel(1)
                " if b:vikiHeadingMaxLevel == 0
                "     return 0
                " elseif vikiFolds =~# 'b'
                if vikiFolds =~# 'b'
                    let bl = exists('b:vikiFoldBodyLevel') ? b:vikiFoldBodyLevel : g:vikiFoldBodyLevel
                    if bl > 0
                        " TLogDBG 'body: '. bl
                        return bl
                    else
                        " TLogDBG 'body fallback: '. b:vikiHeadingMaxLevel
                        return b:vikiHeadingMaxLevel + 1
                    endif
                else
                    " TLogDBG 'else'
                    return "="
                endif
            endif
            " TLogDBG 'zero'
            return 0
        finally
            exec 'norm! '. w0 .'zt'
            " TLogVAR lc
            call setpos('.', lc)
            let &lazyredraw = lr
        endtry
    endfun

    function! s:ScanHeading(lnum, top, vikiFolds) "{{{3
        " TLogVAR a:lnum, a:top
        let [lhead, head] = s:SearchHead(a:lnum, a:top)
        " TLogVAR head
        if head > 0
            if head > b:vikiHeadingMaxLevel
                let b:vikiHeadingMaxLevel = head
            endif
            if b:vikiInverseFold || a:vikiFolds =~# 'H'
                if b:vikiMaxFoldLevel > head
                    return ">". (b:vikiMaxFoldLevel - head)
                else
                    return ">0"
                end
            else
                return ">". head
            endif
        endif
        return ''
    endf

    function! s:SetHeadingMaxLevel(once) "{{{3
        if a:once && b:vikiHeadingMaxLevel == 0
            return
        endif
        let pos = getpos('.')
        " TLogVAR pos
        try
            silent! keepjumps exec 'g/\V\^'. b:vikiHeadingStart .'\+\s/call s:SetHeadingMaxLevelAtCurrentLine(line(".")'
        finally
            " TLogVAR pos
            call setpos('.', pos)
        endtry
    endf

    function! s:SetHeadingMaxLevelAtCurrentLine(lnum) "{{{3
        let m = s:MatchHead(lnum)
        if m > b:vikiHeadingMaxLevel
            let b:vikiHeadingMaxLevel = m
        endif
    endf

    function! s:SearchHead(lnum, top) "{{{3
        let pos = getpos('.')
        " TLogVAR pos
        try
            exec a:lnum
            norm! $
            let ln = search('\V\^'. b:vikiHeadingStart .'\+\s', 'bWcs', a:top)
            if ln
                return [ln, s:MatchHead(ln)]
            endif
            return [0, 0]
        finally
            " TLogVAR pos
            call setpos('.', pos)
        endtry
    endf

    function! s:MatchHead(lnum) "{{{3
        " let head = matchend(getline(a:lnum), '\V\^'. escape(b:vikiHeadingStart, '\') .'\ze\s\+')
        return matchend(getline(a:lnum), '\V\^'. b:vikiHeadingStart .'\+\ze\s')
    endf

    function! s:MatchList(lnum) "{{{3
        let rx = '^[[:blank:]]\+\ze\(#[A-F]\d\?\|#\d[A-F]\?\|[-+*#?@]\|[0-9#]\+\.\|[a-zA-Z?]\.\|.\{-1,}[[:blank:]]::\)[[:blank:]]'
        return matchend(getline(a:lnum), rx)
    endf

endif
indent/viki.vim	[[[1
26
" viki.vim -- viki indentation
" @Author:      Tom Link (micathom AT gmail com?subject=vim)
" @Website:     http://members.a1.net/t.link/
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Created:     16-Jän-2004.
" @Last Change: 2009-02-15.
" @Revision: 0.264

if !g:vikiEnabled
    finish
endif

if exists("b:did_indent") || exists("g:vikiNoIndent")
    finish
endif
let b:did_indent = 1

" Possible values: 'sw', '::'
if !exists("g:vikiIndentDesc") | let g:vikiIndentDesc = 'sw' | endif "{{{2

setlocal indentexpr=viki#GetIndent()
" setlocal indentkeys&
setlocal indentkeys=0=#\ ,0=?\ ,0=<*>\ ,0=-\ ,0=+\ ,0=@\ ,=::\ ,!^F,o,O
" setlocal indentkeys=0=#<space>,0=?<space>,0=<*><space>,0=-<space>,=::<space>,!^F,o,O
" setlocal indentkeys=0=#<space>,0=?<space>,0=<*><space>,0=-<space>,=::<space>,!^F,o,O,e

plugin/viki.vim	[[[1
1040
" Viki.vim -- Some kind of personal wiki for Vim
" @Author:      Tom Link (micathom AT gmail com?subject=vim)
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Created:     08-Dec-2003.
" @Last Change: 2009-03-20.
" @Revision:    2627
"
" GetLatestVimScripts: 861 1 viki.vim
"
" Short Description:
" This plugin adds wiki-like hypertext capabilities to any document.  Just 
" type :VikiMinorMode and all wiki names will be highlighted. If you press 
" <c-cr> (or <LocalLeader>vf) when the cursor is over a wiki name, you 
" jump to (or create) the referred page. When invoked via :set ft=viki, 
" additional highlighting is provided.
"
" Requirements:
" - tlib.vim (vimscript #1863)
" 
" Optional Enhancements:
" - imaps.vim (vimscript #244 or #475 for |:VimQuote|)
" - kpsewhich (not a vim plugin :-) for vikiLaTeX
"
" TODO:
" - File names containing # (the # is interpreted as URL component)
" - Per Interviki simple name patterns
" - Allow Wiki links like ::Word or even ::word (not in minor mode due 
"   possible conflict with various programming languages?)
" - :VikiRename command: rename links/files (requires a cross-plattform grep 
"   or similar; or one could a global register)
" - don't know how to deal with viki names that span several lines (e.g.  in 
"   LaTeX mode)

if &cp || exists("loaded_viki") "{{{2
    finish
endif
if !exists('g:loaded_tlib') || g:loaded_tlib < 15
    runtime plugin/02tlib.vim
    if !exists('g:loaded_tlib') || g:loaded_tlib < 15
        echoerr 'tlib >= 0.15 is required'
        finish
    endif
endif
let loaded_viki = 311

" This is what we consider nil, in the absence of nil in vimscript
let g:vikiDefNil  = ''

" In a previous version this was used as list separator and as nil too
let g:vikiDefSep  = "\n"

" let s:vikiSelfEsc = '\'

" In extended viki links this is considered as a reference to the current 
" document. This is likely to go away.
let g:vikiSelfRef = '.'

" let s:vikiEnabledID = loaded_viki .'_'. strftime('%c')


" Configuration {{{1
" If zero, viki is disabled, though the code is loaded.
if !exists("g:vikiEnabled") "{{{2
    let g:vikiEnabled = 1
endif

" Support for the taglist plugin.
if !exists("tlist_viki_settings") "{{{2
    let tlist_viki_settings="deplate;s:structure"
endif

" A simple viki name is made from a series of upper and lower characters 
" (i.e. CamelCase-names). These two variables define what is considered as 
" upper and lower-case characters. We don't rely on the builtin 
" functionality for this.
if !exists("g:vikiUpperCharacters") "{{{2
    let g:vikiUpperCharacters = "A-Z"
endif
if !exists("g:vikiLowerCharacters") "{{{2
    let g:vikiLowerCharacters = "a-z"
endif

" Characters allowed in anchors
" Defaults to:
" [b:vikiLowerCharacters][b:vikiLowerCharacters +  b:vikiUpperCharacters + '_0-9]*
if !exists('g:vikiAnchorNameRx')
    let g:vikiAnchorNameRx = '' "{{{2
endif

if !exists('g:vikiUrlRestRx')
    let g:vikiUrlRestRx = '['. g:vikiLowerCharacters . g:vikiUpperCharacters .'0-9?%_=&+-]*'  "{{{2
endif

" The prefix for the menu of intervikis. Set to '' in order to remove the 
" menu.
if !exists("g:vikiMenuPrefix") "{{{2
    let g:vikiMenuPrefix = "Plugin.Viki."
endif

" Make submenus for N letters of the interviki names.
if !exists('g:vikiMenuLevel')
    let g:vikiMenuLevel = 1   "{{{2
endif

" URLs matching these protocols are handled by VikiOpenSpecialProtocol()
if !exists("g:vikiSpecialProtocols") "{{{2
    let g:vikiSpecialProtocols = 'https\?\|ftps\?\|nntp\|mailto\|mailbox\|file'
endif

" Exceptions from g:vikiSpecialProtocols
if !exists("g:vikiSpecialProtocolsExceptions") "{{{2
    let g:vikiSpecialProtocolsExceptions = ""
endif

" Files matching these suffixes are handled by viki#OpenSpecialFile()
if !exists("g:vikiSpecialFiles") "{{{2
    let g:vikiSpecialFiles = [
                \ 'aac',
                \ 'aif',
                \ 'aiff',
                \ 'au',
                \ 'avi',
                \ 'bmp',
                \ 'dia',
                \ 'doc',
                \ 'dvi',
                \ 'eps',
                \ 'eps',
                \ 'gif',
                \ 'htm',
                \ 'html',
                \ 'jpeg',
                \ 'jpg',
                \ 'm3u',
                \ 'mp1',
                \ 'mp2',
                \ 'mp3',
                \ 'mp4',
                \ 'mpeg',
                \ 'mpg',
                \ 'odg',
                \ 'ods',
                \ 'odt',
                \ 'ogg',
                \ 'pdf',
                \ 'png',
                \ 'ppt',
                \ 'ps',
                \ 'rtf',
                \ 'voc',
                \ 'wav',
                \ 'wma',
                \ 'wmf',
                \ 'wmv',
                \ 'xhtml',
                \ 'xls',
                \ ]
endif

" Exceptions from g:vikiSpecialFiles
if !exists("g:vikiSpecialFilesExceptions") "{{{2
    let g:vikiSpecialFilesExceptions = ""
endif

if !exists('g:viki_highlight_hyperlink_light') "{{{2
    " let g:viki_highlight_hyperlink_light = 'term=bold,underline cterm=bold,underline gui=bold,underline ctermfg=DarkBlue guifg=DarkBlue'
    let g:viki_highlight_hyperlink_light = 'term=underline cterm=underline gui=underline ctermfg=DarkBlue guifg=DarkBlue'
endif
if !exists('g:viki_highlight_hyperlink_dark') "{{{2
    " let g:viki_highlight_hyperlink_dark = 'term=bold,underline cterm=bold,underline gui=bold,underline ctermfg=DarkBlue guifg=LightBlue'
    let g:viki_highlight_hyperlink_dark = 'term=underline cterm=underline gui=underline ctermfg=LightBlue guifg=#bfbfff'
endif

if !exists('g:viki_highlight_inexistent_light') "{{{2
    " let g:viki_highlight_inexistent_light = 'term=bold,underline cterm=bold,underline gui=bold,underline ctermfg=DarkRed guifg=DarkRed'
    let g:viki_highlight_inexistent_light = 'term=underline cterm=underline gui=underline ctermfg=DarkRed guifg=DarkRed'
endif
if !exists('g:viki_highlight_inexistent_dark') "{{{2
    " let g:viki_highlight_inexistent_dark = 'term=bold,underline cterm=bold,underline gui=bold,underline ctermfg=Red guifg=Red'
    let g:viki_highlight_inexistent_dark = 'term=underline cterm=underline gui=underline ctermfg=Red guifg=Red'
endif

" If set to true, any files loaded by viki will become viki enabled (in 
" minor mode); this was the default behaviour in earlier versions
if !exists('g:vikiPromote') "{{{2
    let g:vikiPromote = 0
endif

" If non-nil, use the parent document's suffix.
if !exists("g:vikiUseParentSuffix") | let g:vikiUseParentSuffix = 0      | endif "{{{2

" Default file suffix (including the optional period, e.g. '.txt').
if !exists("g:vikiNameSuffix")      | let g:vikiNameSuffix = ""          | endif "{{{2

" Prefix for anchors
if !exists("g:vikiAnchorMarker")    | let g:vikiAnchorMarker = "#"       | endif "{{{2

" If non-nil, search anchors anywhere in the text too (without special 
" markup)
if !exists("g:vikiFreeMarker")      | let g:vikiFreeMarker = 0           | endif "{{{2

if !exists('g:vikiPostFindAnchor') "{{{2
    let g:vikiPostFindAnchor = 'norm! zz'
endif

" List of enabled viki name types
" c ... Camel case
" s ... Simple names
" S ... Quoted simple names
" e ... Extended names
" u ... URLs
" i ... Intervikis
" x ... Commands
" w ... "hyperwords"
" f ... Filenames as "hyperwords"
if !exists("g:vikiNameTypes")       | let g:vikiNameTypes = "csSeuixwf"  | endif "{{{2

" Which directory explorer to use to edit directories
if !exists("g:vikiExplorer")        | let g:vikiExplorer = "Sexplore"    | endif "{{{2
" if !exists("g:vikiExplorer")        | let g:vikiExplorer = "split"    | endif "{{{2
" if !exists("g:vikiExplorer")        | let g:vikiExplorer = "edit"          | endif "{{{2
"
" If hide or update: use the respective command when leaving a buffer
if !exists("g:vikiHide")            | let g:vikiHide = ''                | endif "{{{2

" Don't use g:vikiHide for commands matching this rx
if !exists("g:vikiNoWrapper")       | let g:vikiNoWrapper = '\cexplore'  | endif "{{{2

" Cache information about a document's inexistent names
if !exists("g:vikiCacheInexistent") | let g:vikiCacheInexistent = 0      | endif "{{{2

" Mark up inexistent names.
if !exists("g:vikiMarkInexistent")  | let g:vikiMarkInexistent = 1       | endif "{{{2

" If non-nil, map keys that trigger the evaluation of inexistent names
if !exists("g:vikiMapInexistent")   | let g:vikiMapInexistent = 1        | endif "{{{2

" Map these keys for g:vikiMapInexistent to LineQuick
if !exists("g:vikiMapKeys")         | let g:vikiMapKeys = "]).,;:!?\"' " | endif "{{{2

" Map these keys for g:vikiMapInexistent to ParagraphVisible
if !exists("g:vikiMapQParaKeys")    | let g:vikiMapQParaKeys = "\n"      | endif "{{{2

" Install hooks for these conditions (requires hookcursormoved to be 
" installed)
" "linechange" could cause some slowdown.
if !exists("g:vikiHCM") "{{{2
    let g:vikiHCM = ['syntaxleave_oneline']
endif

" Check the viki name before inserting this character
if !exists("g:vikiMapBeforeKeys")   | let g:vikiMapBeforeKeys = ']'      | endif "{{{2

" Some functions a gathered in families/classes. See vikiLatex.vim for 
" an example.
if !exists("g:vikiFamily")          | let g:vikiFamily = ""              | endif "{{{2

" The directory separator
if !exists("g:vikiDirSeparator")    | let g:vikiDirSeparator = "/"       | endif "{{{2

" The version of Deplate markup
if !exists("g:vikiTextstylesVer")   | let g:vikiTextstylesVer = 2        | endif "{{{2

" if !exists("g:vikiBasicSyntax")     | let g:vikiBasicSyntax = 0          | endif "{{{2
" If non-nil, display headings of different levels in different colors
if !exists("g:vikiFancyHeadings")   | let g:vikiFancyHeadings = 0        | endif "{{{2

" Choose folding method version
if !exists("g:vikiFoldMethodVersion") | let g:vikiFoldMethodVersion = 4  | endif "{{{2

" What is considered for folding.
" This variable is only used if g:vikiFoldMethodVersion is 1.
if !exists("g:vikiFolds")           | let g:vikiFolds = 'hf'             | endif "{{{2

" Context lines for folds
if !exists("g:vikiFoldsContext") "{{{2
    let g:vikiFoldsContext = [2, 2, 2, 2]
endif

" Consider fold levels bigger that this as text body, levels smaller 
" than this as headings
" This variable is only used if g:vikiFoldMethodVersion is 1.
if !exists("g:vikiFoldBodyLevel")   | let g:vikiFoldBodyLevel = 6        | endif "{{{2

" The default viki page (as absolute filename)
if !exists("g:vikiHomePage")        | let g:vikiHomePage = ''            | endif "{{{2

" The default filename for an interviki's index name
if !exists("g:vikiIndex")           | let g:vikiIndex = 'index'          | endif "{{{2

" How often the feedback is changed when marking inexisting links
if !exists("g:vikiFeedbackMin")     | let g:vikiFeedbackMin = &lines     | endif "{{{2

" The map leader for most viki key maps.
if !exists("g:vikiMapLeader")       | let g:vikiMapLeader = '<LocalLeader>v' | endif "{{{2

" If non-nil, anchors like #mX are turned into vim marks
if !exists("g:vikiAutoMarks")       | let g:vikiAutoMarks = 1            | endif "{{{2

" if !exists("g:vikiOpenInWindow")    | let g:vikiOpenInWindow = ''        | endif "{{{2
if !exists("g:vikiHighlightMath")   | let g:vikiHighlightMath = ''       | endif "{{{2

" If non-nil, cache back-links information
if !exists("g:vikiSaveHistory")     | let g:vikiSaveHistory = 0          | endif "{{{2

" The variable that keeps back-links information
if !exists("g:VIKIBACKREFS")        | let g:VIKIBACKREFS = {}            | endif "{{{2

" A list of files that contain special viki names
if v:version >= 700 && !exists("g:vikiHyperWordsFiles") "{{{2
    let g:vikiHyperWordsFiles = [
                \ get(split(&rtp, ','), 0).'/vikiWords.txt',
                \ './.vikiWords',
                \ ]
endif

" Definition of intervikis. (This variable won't be evaluated until 
" autoload/viki.vim is loaded).
if !exists('g:viki_intervikis')
    let g:viki_intervikis = {}   "{{{2
endif

" Define which keys to map
if !exists("g:vikiMapFunctionality") "{{{2
    " b     ... go back
    " c     ... follow link (c-cr)
    " e     ... edit
    " F     ... find
    " f     ... follow link (<LocalLeader>v)
    " i     ... check for inexistant destinations
    " I     ... map keys in g:vikiMapKeys and g:vikiMapQParaKeys
    " m[fb] ... map mouse (depends on f or b)
    " p     ... edit parent (or backlink)
    " q     ... quote
    " tF    ... tab as find
    " Files ... #Files related
    " let g:vikiMapFunctionality      = 'mf mb tF c q e i I Files'
    let g:vikiMapFunctionality      = 'ALL'
endif
" Define which keys to map in minor mode (invoked via :VikiMinorMode)
if !exists("g:vikiMapFunctionalityMinor") "{{{2
    " let g:vikiMapFunctionalityMinor = 'f b p mf mb tF c q e i'
    let g:vikiMapFunctionalityMinor = 'f b p mf mb tF c q e'
endif


" Special file handlers {{{1
if !exists('g:vikiOpenFileWith_ws') && exists(':WsOpen') "{{{2
    function! VikiOpenAsWorkspace(file)
        exec 'WsOpen '. escape(a:file, ' &!%')
        exec 'lcd '. escape(fnamemodify(a:file, ':p:h'), ' &!%')
    endf
    let g:vikiOpenFileWith_ws = "call VikiOpenAsWorkspace('%{FILE}')"
    call add(g:vikiSpecialFiles, 'ws')
endif
if type(g:vikiSpecialFiles) != 3
    echoerr 'Viki: g:vikiSpecialFiles must be a list'
endif
" TAssert IsList(g:vikiSpecialFiles)

if !exists("g:vikiOpenFileWith_ANY") "{{{2
    if exists('g:netrw_browsex_viewer')
        let g:vikiOpenFileWith_ANY = "exec 'silent !'. g:netrw_browsex_viewer .' '. shellescape('%{FILE}')"
    elseif has("win32") || has("win16") || has("win64")
        let g:vikiOpenFileWith_ANY = "exec 'silent ! start \"\" '. shellescape('%{FILE}')"
    elseif has("mac")
        let g:vikiOpenFileWith_ANY = "exec 'silent !open '. shellescape('%{FILE}')"
    elseif $GNOME_DESKTOP_SESSION_ID != ""
        let g:vikiOpenFileWith_ANY = "exec 'silent !gnome-open '. shellescape('%{FILE}')"
    elseif $KDEDIR != ""
        let g:vikiOpenFileWith_ANY = "exec 'silent !kfmclient exec '. shellescape('%{FILE}')"
    endif
endif

if !exists('*VikiOpenSpecialFile') "{{{2
    function! VikiOpenSpecialFile(file) "{{{3
        " let proto = tolower(matchstr(a:file, '\c\.\zs[a-z]\+$'))
        let proto = tolower(fnamemodify(a:file, ':e'))
        if exists('g:vikiOpenFileWith_'. proto)
            let prot = g:vikiOpenFileWith_{proto}
        elseif exists('g:vikiOpenFileWith_ANY')
            let prot = g:vikiOpenFileWith_ANY
        else
            let prot = ''
        endif
        if prot != ''
            " let openFile = viki#SubstituteArgs(prot, 'FILE', fnameescape(a:file))
            let openFile = viki#SubstituteArgs(prot, 'FILE', a:file)
            " TLogVAR openFile
            call viki#ExecExternal(openFile)
        else
            throw 'Viki: Please define g:vikiOpenFileWith_'. proto .' or g:vikiOpenFileWith_ANY!'
        endif
    endf
endif


" Special protocol handlers {{{1
if !exists('g:vikiOpenUrlWith_mailbox') "{{{2
    let g:vikiOpenUrlWith_mailbox="call VikiOpenMailbox('%{URL}')"
    function! VikiOpenMailbox(url) "{{{3
        exec viki#DecomposeUrl(strpart(a:url, 10))
        let idx = matchstr(args, 'number=\zs\d\+$')
        if filereadable(filename)
            call viki#OpenLink(filename, '', 0, 'go '.idx)
        else
            throw 'Viki: Can't find mailbox url: '.filename
        endif
    endf
endif

" Possible values: special*, query, normal
if !exists("g:vikiUrlFileAs") | let g:vikiUrlFileAs = 'special' | endif "{{{2

if !exists("g:vikiOpenUrlWith_file") "{{{2
    let g:vikiOpenUrlWith_file="call VikiOpenFileUrl('%{URL}')"
    function! VikiOpenFileUrl(url) "{{{3
        " TLogVAR url
        if viki#IsSpecialFile(a:url)
            if g:vikiUrlFileAs == 'special'
                let as_special = 1
            elseif g:vikiUrlFileAs == 'query'
                echo a:url
                let as_special = input('Treat URL as special file? (Y/n) ')
                let as_special = (as_special[0] !=? 'n')
            else
                let as_special = 0
            endif
            " TLogVAR as_special
            if as_special
                call VikiOpenSpecialFile(a:url)
                return
            endif
        endif
        exec viki#DecomposeUrl(strpart(a:url, 7))
        if filereadable(filename) || isdirectory(filename)
            call viki#OpenLink(filename, anchor)
        else
            throw "Viki: Can't find file url: ". filename
        endif
    endf
endif

if !exists("g:vikiOpenUrlWith_ANY") "{{{2
    " let g:vikiOpenUrlWith_ANY = "exec 'silent !". g:netrw_browsex_viewer ." '. escape('%{URL}', ' &!%')"
    if has("win32")
        let g:vikiOpenUrlWith_ANY = "exec 'silent !rundll32 url.dll,FileProtocolHandler '. shellescape('%{URL}')"
    elseif has("mac")
        let g:vikiOpenUrlWith_ANY = "exec 'silent !open '. escape('%{URL}', ' &!%')"
    elseif $GNOME_DESKTOP_SESSION_ID != ""
        let g:vikiOpenUrlWith_ANY = "exec 'silent !gnome-open '. shellescape('%{URL}')"
    elseif $KDEDIR != ""
        let g:vikiOpenUrlWith_ANY = "exec 'silent !kfmclient exec '. shellescape('%{URL}')"
    endif
endif

if !exists("*VikiOpenSpecialProtocol") "{{{2
    function! VikiOpenSpecialProtocol(url) "{{{3
        " TLogVAR a:url
        " TLogVAR a:url
        let proto = tolower(matchstr(a:url, '\c^[a-z]\{-}\ze:'))
        let prot  = 'g:vikiOpenUrlWith_'. proto
        let protp = exists(prot)
        if !protp
            let prot  = 'g:vikiOpenUrlWith_ANY'
            let protp = exists(prot)
        endif
        if protp
            exec 'let openURL = '. prot
            " let url = shellescape(a:url)
            let url = a:url
            " TLogVAR url, a:url
            let openURL = viki#SubstituteArgs(openURL, 'URL', url)
            " TLogVAR openURL
            call viki#ExecExternal(openURL)
        else
            throw 'Viki: Please define g:vikiOpenUrlWith_'. proto .' or g:vikiOpenUrlWith_ANY!'
        endif
    endf
endif


" This is mostly a legacy function. Using set ft=viki should work too.
" Set filetype=viki
function! VikiMode(...) "{{{3
    TVarArg 'family'
    " if exists('b:vikiEnabled')
    "     if b:vikiEnabled
    "         return 0
    "     endif
    "     " if b:vikiEnabled && a:state < 0
    "     "     return 0
    "     " endif
    "     " echom "VIKI: Viki mode already set."
    " endif
    unlet! b:did_ftplugin
    if !empty(family)
        let b:vikiFamily = family
    endif
    set filetype=viki
endf


if g:vikiMenuPrefix != '' "{{{2
    exec 'amenu '. g:vikiMenuPrefix .'Home :VikiHome<cr>'
    exec 'amenu '. g:vikiMenuPrefix .'-SepViki1- :'
endif


command! -nargs=+ VikiDefine call viki#Define(<f-args>)
command! -count VikiFindNext call viki#DispatchOnFamily('Find', '', '',  <count>)
command! -count VikiFindPrev call viki#DispatchOnFamily('Find', '', 'b', <count>)

" command! -nargs=* -range=% VikiMarkInexistent
"             \ call VikiSaveCursorPosition()
"             \ | call <SID>VikiMarkInexistent(<line1>, <line2>, <f-args>)
"             \ | call VikiRestoreCursorPosition()
"             \ | call <SID>ResetSavedCursorPosition()
command! -nargs=* -range=% VikiMarkInexistent call viki#MarkInexistentInRange(<line1>, <line2>)

command! -nargs=? -bar VikiMinorMode call viki#DispatchOnFamily('MinorMode', empty(<q-args>) && exists('b:vikiFamily') ? b:vikiFamily : <q-args>, 1)
command! -nargs=? -bar VikiMinorModeMaybe echom "Deprecated command: VikiMinorModeMaybe" | VikiMinorMode <q-args>
command! VikiMinorModeViki call viki_viki#MinorMode(1)
command! VikiMinorModeLaTeX call viki_latex#MinorMode(1)
command! VikiMinorModeAnyWord call viki_anyword#MinorMode(1)

" this requires imaps to be installed
command! -range VikiQuote :call VEnclose("[-", "-]", "[-", "-]")

command! -nargs=? -bar VikiMode call VikiMode(<q-args>)
command! -nargs=? -bar VikiModeMaybe echom "Deprecated command: VikiModeMaybe: Please use 'set ft=viki' instead" | call VikiMode(<q-args>)

command! -narg=? VikiGoBack call viki#GoBack(<f-args>)

command! VikiJump call viki#MaybeFollowLink(0,1)

command! VikiIndex :call viki#Index()

command! -nargs=1 -bang -complete=customlist,viki#EditComplete VikiEdit :call viki#Edit(<q-args>, "<bang>")
command! -nargs=1 -bang -complete=customlist,viki#EditComplete VikiEditInVim :call viki#Edit(<q-args>, "<bang>", 0, 1)
command! -nargs=1 -bang -complete=customlist,viki#EditComplete VikiEditTab :call viki#Edit(<q-args>, "<bang>", 'tab')
command! -nargs=1 -bang -complete=customlist,viki#EditComplete VikiEditInWin1 :call viki#Edit(<q-args>, "<bang>", 1)
command! -nargs=1 -bang -complete=customlist,viki#EditComplete VikiEditInWin2 :call viki#Edit(<q-args>, "<bang>", 2)
command! -nargs=1 -bang -complete=customlist,viki#EditComplete VikiEditInWin3 :call viki#Edit(<q-args>, "<bang>", 3)
command! -nargs=1 -bang -complete=customlist,viki#EditComplete VikiEditInWin4 :call viki#Edit(<q-args>, "<bang>", 4)

command! -nargs=1 -complete=customlist,viki#BrowseComplete VikiBrowse :call viki#Browse(<q-args>)

command! VikiHome :call viki#Edit('*', '!')
command! VIKI :call viki#Edit('*', '!')

command! VikiFilesUpdate call viki#FilesUpdate()
command! VikiFilesUpdateAll call viki#FilesUpdateAll()

command! -nargs=* -bang -complete=command VikiFileExec call viki#FilesExec(<q-args>, '<bang>', 1)
command! -nargs=* -bang -complete=command VikiFilesExec call viki#FilesExec(<q-args>, '<bang>')
command! -nargs=* -bang VikiFilesCmd call viki#FilesCmd(<q-args>, '<bang>')
command! -nargs=* -bang VikiFilesCall call viki#FilesCall(<q-args>, '<bang>')


augroup viki
    au!
    autocmd BufEnter * call viki#MinorModeReset()
    autocmd BufEnter * call viki#CheckInexistent()
    autocmd BufLeave * if &filetype == 'viki' | let b:vikiCheckInexistent = line(".") | endif
    autocmd BufWritePost,BufUnload * if &filetype == 'viki' | call viki#SaveCache() | endif
    autocmd VimLeavePre * let g:vikiEnabled = 0
    if g:vikiSaveHistory
        autocmd VimEnter * if exists('VIKIBACKREFS_STRING') | exec 'let g:VIKIBACKREFS = '. VIKIBACKREFS_STRING | unlet VIKIBACKREFS_STRING | endif
        autocmd VimLeavePre * let VIKIBACKREFS_STRING = string(g:VIKIBACKREFS)
    endif
    " As viki uses its own styles, we have to reset &filetype.
    autocmd ColorScheme * if &filetype == 'viki' | set filetype=viki | endif
augroup END


finish "{{{1
______________________________________________________________________________

* Change Log
1.0
- Extended names: For compatibility reasons with other wikis, the anchor is 
now in the reference part.
- For compatibility reasons with other wikis, prepending an anchor with 
b:commentStart is optional.
- g:vikiUseParentSuffix
- Renamed variables & functions (basically s/Wiki/Viki/g)
- added a ftplugin stub, moved the description to a help file
- "[--]" is reference to current file
- Folding support (at section level)
- Intervikis
- More highlighting
- g:vikiFamily, b:vikiFamily
- VikiGoBack() (persistent history data)
- rudimentary LaTeX support ("soft" viki names)

1.1
- g:vikiExplorer (for viewing directories)
- preliminary support for "soft" anchors (b:vikiAnchorRx)
- improved VikiOpenSpecialProtocol(url); g:vikiOpenUrlWith_{PROTOCOL}, 
g:vikiOpenUrlWith_ANY
- improved VikiOpenSpecialFile(file); g:vikiOpenFileWith_{SUFFIX}, 
g:vikiOpenFileWith_ANY
- anchors may contain upper characters (but must begin with a lower char)
- some support for Mozilla ThunderBird mailbox-URLs (this requires spaces to 
be encoded as %20)
- changed g:vikiDefSep to '‡‡‡'

1.2
- syntax file: fix nested regexp problem
- deplate: conversion to html/latex; download from 
http://sourceforge.net/projects/deplate/
- made syntax a little bit more restrictive (*WORD* now matches /\*\w+\*/ 
instead of /\*\S+\*/)
- interviki definitions can now be buffer local variables, too
- fixed <SID>DecodeFileUrl(dest)
- some kind of compiler plugin (uses deplate)
- removed g/b:vikiMarkupEndsWithNewline variable
- saved all files in unix format (thanks to Grant Bowman for the hint)
- removed international characters from g:vikiLowerCharacters and 
g:vikiUpperCharacters because of difficulties with different encodings (thanks 
to Grant Bowman for pointing out this problem); non-english-speaking users have 
to set these variables in their vimrc file

1.3
- basic ctags support (see |viki-tags|)
- mini-ftplugin for bibtex files (use record labels as anchors)
- added mapping <LocalLeader><c-cr>: follow link in other window (if any)
- disabled the highlighting of italic char styles (i.e., /text/)
- the ftplugin doesn't set deplate as the compiler; renamed the compiler plugin to deplate
- syntax: sync minlines=50
- fix: VikiFoldLevel()

1.3.1
- fixed bug when VikiBack was called without a definitiv back-reference
- fixed problems with latin-1 characters

1.4
- fixed problem with table highlighting that could cause vim to hang
- it is now possible to selectivly disable simple or quoted viki names
- indent plugin

1.5
- distinguish between links to existing and non-existing files
- added key bindings <LL>vs (split) and <LL>vv (split vertically)
- added key bindings <LL>v1 through to <LL>v4: open the viki link under cursor 
in the windows 1 to 4
- handle variables g:vikiSplit, b:vikiSplit
- don't indent regions
- regions can be indented
- When a file doesn't exist, ESC or "n" aborts creation

1.5.1
- depends on multvals >= 3.8.0
- new viki family "AnyWord" (see |viki-any-word|), which turns any word into a 
potential viki link
- <LocalLeader>vq, VikiQuote: mark selected text as a quoted viki name 
(requires imaps.vim, vimscript #244 or vimscript #475)
- check for null links when pressing <space>, <cr>, ], and some other keys 
(defined in g:vikiMapKeys)
- a global suffix for viki files can be defined by g:vikiNameSuffix
- fix syntax problem when checking for links to inexistent files

1.5.2
- changed default markup of textstyles: __emphasize__, ''code''; the 
previous markup can be re-enabled by setting g:vikiTextstylesVer to 1)
- fixed problem with VikiQuote
- on follow link check for yet unsaved buffers too

1.6
- b:vikiInverseFold: Inverse folding of subsections
- support for some regions/commands/macros: #INC/#INCLUDE, #IMG, #Img 
(requires an id to be defined), {img}
- g:vikiFreeMarker: Search for the plain anchor text if no explicitly marked 
anchor could be found.
- new command: VikiEdit NAME ... allows editing of arbitrary viki names (also 
understands extended and interviki formats)
- setting the b:vikiNoSimpleNames to true prevents viki from recognizing 
simple viki names
- made some script local functions global so that it should be easier to 
integrate viki with other plugins
- fixed moving cursor on <SID>VikiMarkInexistent()
- fixed typo in b:VikiEnabled, which should be b:vikiEnabled (thanks to Ned 
Konz)

1.6.1
- removed forgotten debug message
- fixed indentation bug

1.6.2
- b:vikiDisableType
- Put AnyWord-related stuff into a file of its own.
- indentation for notices (!!!, ??? etc.)

1.6.3
- When creating a new file by following a link, the desired window number was 
ignored
- (VikiOpenSpecialFile) Escape blanks in the filename
- Set &include and &define (ftplugin)
- Set g:vikiFolds to '' to avoid using Headings for folds (which may cause a 
major slowdown on slower machines)
- renamed <SID>DecodeFileUrl(dest) to VikiDecomposeUrl()
- fixed problem with table highlighting
- file type URLs (file://) are now treated like special files
- indent: if g:vikiIndentDesc is '::', align a definition's description to the 
first non-blank position after the '::' separator

1.7
- g:vikiHomePage: If you call VikiEdit! (with "bang"), the homepage is opened 
first so that its customizations are in effect. Also, if you call :VikiHome or 
:VikiEdit *, the homepage is opened.
- basic highlighting & indentation of emacs-planner style task lists (sort of)
- command line completion for :VikiEdit
- new command/function VikiDefine for defining intervikis
- added <LocalLeader>ve map for :VikiEdit
- fixed problem in VikiEdit (when the cursor was on a valid viki link, the 
text argument was ignored)
- fixed opening special files/urls in a designated window
- fixed highlighting of comments
- vikiLowerCharacters and vikiUpperCharacters can be buffer local
- fixed problem when an url contained an ampersand
- fixed error message when the &hidden option wasn't set (see g:vikiHide)

1.8
- Fold lists too (see also g:vikiFolds)
- Allow interviki names in extended viki names (e.g., 
[[WIKI::WikiName][Display Name]])
- Renamed <SID>GetSimpleRx4SimpleWikiName() to 
VikiGetSimpleRx4SimpleWikiName() (required in some occasions; increased the 
version number so that we can check against it)
- Fix: Problem with urls/fnames containing '!' and other special characters 
(which now have to be escaped by the handler; so if you defined a custom 
handler, e.g. g:vikiOpenFileWith_ANY, please adapt its definition)
- Fix: VikiEdit! opens the homepage only when b:vikiEnabled is defined in the 
current buffer (we assume that for the homepage the global configuration is in 
effect)
- Fix: Problem when g:vikiMarkInexistent was false/0
- Fix: Removed \c from the regular expression for extended names, which caused 
FindNext to malfunction and caused a serious slowdown when matching of 
bad/unknown links
- Fix: Re-set viki minor mode after entering a buffer
- The state argument in Viki(Minor)Mode is now mostly ignored
- Fix: A simple name's anchor was ignored

1.9
- Register mp3, ogg and some other multimedia related suffixes as 
special files
- Add a menu of Intervikis if g:vikiMenuPrefix is != ''
- g:vikiMapKeys can contain "\n" and " " (supplement g:vikiMapKeys with 
the variables g:vikiMapQParaKeys and g:vikiMapBeforeKeys)
- FIX: <SID>IsSupportedType
- FIX: Only the first inexistent link in a line was highlighted
- FIX: Set &buflisted when editing an existing buffer
- FIX: VikiDefine: Non-viki index names weren't quoted
- FIX: In "minor mode", vikiFamily wasn't correctly set in some 
situations; other problems related to b:vikiFamily
- FIX: AnyWord works again
- Removed: VikiMinorModeMaybe
- VikiDefine now takes an optional fourth argument (an index file; 
default=Index) and automatically creates a vim command with the name of 
the interviki that opens this index file

1.10
- Pseudo anchors (not supported by deplate):
-- Jump to a line number, e.g. [[file#l=10]] or [[file#line=10]]
-- Find an regexp, e.g. [[file#rx=\\d]]
-- Execute some vim code, e.g. [[file#vim=call Whatever()]]
-- You can define your own handlers: VikiAnchor_{type}(arg)
- g:vikiFolds: new 'b' flag: the body has a higher level than all 
headings (gives you some kind of outliner experience; the default value 
for g:vikiFolds was changed to 'h')
- FIX: VikiFindAnchor didn't work properly in some situations
- FIX: Escape blanks when following a link (this could cause problems in 
some situations, not always)
- FIX: Don't try to mark inexistent links when pressing enter if the current 
line is empty.
- FIX: Restore vertical cursor position in window after looking for 
inexistent links.
- FIX: Backslashes got lost in some situations.

1.11
- Enable [[INTERVIKI::]]
- VikiEdit also creates commands for intervikis that have no index
- Respect "!" and "*" modifiers in extended viki links
- New g:vikiMapFunctionalityMinor variable
- New g:vikiMapLeader variable
- CHANGE: Don't map VikiMarkInexistent in minor mode (see 
g:vikiMapFunctionalityMinor)
- CHANGE: new attributes for g:vikiMapFunctionality: c, m[fb], i, I
- SYNTAX: cterm support for todo lists, emphasize
- FIX: Erroneous cursor movement
- FIX: VikiEdit didn't check if a file was already opened, which caused 
a file to be opened in two buffers under certain conditions
- FIX: Error in <SID>MapMarkInexistent()
- FIX: VikiEdit: Non-viki names were not quoted
- FIX: Use fnamemodify() to expand tildes in filenames
- FIX: Inexistent quoted viki names with an interviki prefix weren't 
properly highlighted
- FIX: Minor problem with suffixes & extended viki names
- FIX: Use keepjumps
- FIX: Catch E325
- FIX: Don't catch errors in <SID>EditWrapper() if the command matches 
g:vikiNoWrapper (due to possible compatibility problems eg with :Explore 
in vim 6.4)
- OBSOLETE: Negative arguments to VikiMode or VikiMinorMode are obsolete 
(or they became the default to be precise)
- OBSOLETE: g:vikiMapMouse
- REMOVED: mapping to <LocalLeader><c-cr>
- DEPRECATED: VikiModeMaybe

1.12
- Define some keywords in syntax file (useful for omnicompletion)
- Define :VIKI command as an alias for :VikiHome
- FIX: Problem with names containing spaces
- FIX: Extended names with suffix & interviki
- FIX: Indentation of priority lists.
- FIX: VikiDefine created wrong (old-fashioned) VikiEdit commands under 
certain conditions.
- FIX: Directories in extended viki names + interviki names were marked 
as inexistent
- FIX: Syntax highlighting of regions or commands the headline of which 
spanned several lines
- Added ppt to g:vikiSpecialFiles.

1.13
- Intervikis can now be defined as function ('*Function("%s")', this 
breaks conversion via deplate) or format string ('%/foo/%s/bar', not yet 
supported by deplate)
- Task lists take optional tags, eg #A [tag] foo; they may also be 
tagged with the letters G-Z, which are highlighted as general task (not 
supported by deplate)
- Automatically set marks for labels prefixed with "m" (eg #ma -> 'a, 
#mB -> 'B)
- Two new g:vikiNameTypes: w = (Hyper)Words, f = File names in cwd as 
hyperwords (experimental, not implemented in deplate)
- In extended viki names: add the suffix only if the destination hasn't 
got one
- A buffer local b:vikiOpenInWindow allows links to be redirected to a 
certain window (ie, if b:vikiOpenInWindow = 2, pressing <c-cr> behaves 
like <LocalLeader>v2); this is useful if you use some kind of 
directory/catalog metafile; possible values: absolute number, +/- 
relative number, "last"
- Switched back to old regexp for simple names in order to avoid 
highlighting of names like LaTeX
- VikiEdit opens the homepage only if b:vikiFamily is set
- Map <LocalLeader>vF to <LocalLeader>vn<LocalLeader>vf
- Improved syntax for (nested) macros
- Set &suffixesadd so that you can use vim's own gf in some situations
- SYNTAX: Allow empty lines as region delimiters (deplate 0.8.1)
- FIX: simple viki names with anchors where not recognised
- FIX: don't mark simple (inter)viki names as inexistent that expand to 
links matching g:vikiSpecialProtocols
- FIX: file names containing %
- FIX: added a patch (VikiMarkInexistentInElement) by Kevin Kleinfelter 
for compatibility with an unpatched vim70 (untested)
- FIX: disabling simple names (s) also properly disables the name types: 
Scwf

2.0
- Got rid of multvals & genutils dependencies (use vim7 lists instead)
- New dependency: tlib.vim (vimscript #1863)
- INCOMPATIBLE CHANGE: The format of g:vikiMapFunctionality has changed.
- INCOMPATIBLE CHANGE: g:vikiSpecialFiles is now a list!
- Viki now has a special #Files region that can be automatically 
updated. This way we can start thinking about using viki for as 
project/file management tool. This is for vim only and not supported yet 
in deplate. New related maps & commands: :VikiFilesUpdate (<LL>vu), 
:VikiFilesUpdateAll (<LL>vU), :VikiFilesCmd, :VikiFilesCall, 
:VikiFilesExec (<LL>vx), and VikiFileExec.
- VikiGoParent() (mapped to <LL>v<bs> or <LL>v<up>): If b:vikiParent is 
defined, open this viki name, otherwise follow the backlink.
- New :VikiEditTab command.
- Map <LL>vt to open in tab.
- Map <LL>v<left> to open go back.
- Keys listed in g:vikiMapQParaKeys are now mapped to 
s:VikiMarkInexistentInParagraphVisible() which checks only the visible 
area and thus avoids scrolling.
- Highlight lines containing blanks (which vim doesn't treat as 
paragraph separators)
- When following a link, check if it is an special viki name before 
assuming it's a simple one.
- Map [[, ]], [], ][
- If an interviki has an index file, a viki name like [[INTERVIKI::]] 
will now open the index file. In order to browse the directory, use 
[[INTERVIKI::.]]. If no index file is defined, the directory will be 
opened either way.
- Set the default value of g:vikiFeedbackMin to &lines.
- Added ws as special files to be opened with :WsOpen if existent.
- Replaced most occurences of <SID> with s:
- Use tlib#input#List() for selecting back references.
- g:vikiOpenFileWith_ANY now uses g:netrw_browsex_viewer by default.
- CHANGE: g:vikiSaveHistory: We now rely on viminfo's "!" option to save 
back-references.
- FIX: VikiEdit now works properly with protocols that are to be opened 
with an external viewer
- FIX: VikiEdit completion, which is more usable now

2.1
- Cache inexistent patterns (experimental)
- s:EditWrapper: Don't escape ' '.
- FIX: VikiMode(): Error message about b:did_ftplugin not being defined
- FIX: Check if g:netrw_browsex_viewer is defined (thanks to Erik Olsson 
for pointing this and some other problems out)
- ftplugin/viki.vim: FIX: Problem with heading in the last line.  
Disabled vikiFolds type 's' (until I find out what this was about)
- Always check the current line for inexistent links when re-entering a 
viki buffer

2.2
- Re-Enabled the previously (2.1) made and then disabled change 
concerning re-entering a viki buffer
- Don't try to use cached values for buffers that have no file attached 
yet (thanks to Erik Olsson)
- Require tlib >= 0.8

2.3
- Require tlib >= 0.9
- FIX: Use absolute file names when editing a local file (avoid problem 
when opening a file in a different window with a different CWD).
- New folding routine. Use the old folding method by setting 
g:vikiFoldMethodVersion to 1.

2.4
- The shortcuts automatically defined by VikiDefine may now take an 
optional argument (the file on an interviki) (:WIKI thus is the same as 
:VikiEdit WIKI:: and supports the same command-line completion)
- Read ".vikiWords" in parent directories (top-down); 
g:vikiHyperWordsFiles: Changed order (read global words first)
- In .vikiWords: destination can be an interviki name (if not, it is 
assumed to be a relative filename); if destination is -, the word will 
be removed from the jump table; blanks in "hyperwords" will be replaced 
with \s\+ in the regular expression.
- New :VikiBrowse command.
- FIX: wrong value for &comments
- FIX: need to reset filetype on color-scheme change (because of viki's 
own styles)
- FIX: Caching of inexistent viki names.
- In minor mode, don't map keys that trigger a check for inexistent 
links.
- Don't highlight textstyles (emphasized, typewriter) in comments.
- Removed configuration by: VikiInexistentColor(), 
g:vikiInexistentColor, VikiHyperLinkColor(), g:vikiHyperLinkColor; use 
g:viki_highlight_hyperlink_light, g:viki_highlight_hyperlink_dark, 
g:viki_highlight_inexistent_light, g:viki_highlight_inexistent_dark 
instead. By default, links are no longer made bold.
- The new default fold expression (g:vikiFoldMethodVersion=4) support 
only hH folds (normal and inverse headings based; see g:vikiFolds). 
Previous fold methods can be used by setting g:vikiFoldMethodVersion.

3.0
- VikiFolds() rev4: The text body is set to max heading level + 1 in 
order to avoid lookups and thus speed-up the code.
- g:vikiPromote: Don't set viki minor modes for any files opened via 
viki, unless this variable is set
- Added support for 'l' vikiFolds to the default fold expression.
- Added support for the {ref} macro (the referenced label has to be in 
the same file though)
- INCOMPATIBLE CHANGE: Moved most function to autoload/viki.vim; moved 
support for deplate/viki markup to vikiDeplate.vim.
- The argument of the VikiMode() has changed. (But this function 
shouldn't be used anyway.)
- With g:vikiFoldMethodVersion=4 (the default), the text body is at the 
level of the heading. This uses "=" for the body, which can be a problem 
on slow machines. With g:vikiFoldMethodVersion=5, the body is below the 
lowest heading, which can cause other problem.
- :VikiEditInVim ... edit special files in vim
- Set the default value for g:vikiCacheInexistent in order not to 
surprise users with the abundance of cached data.
- Require tlib 0.15
- Use tlib#progressbar
- Improved (poor-man's) tex/math syntax highlighting
- Removed norm! commands form s:MarkInexistent().
- FIX: Wrong value for b:vikiSimpleNameAnchorIdx when simple viki names 
weren't disabled.
- Optionally use hookcursormoved for improved detection of hyperlinks to 
inexistent sources. If this plugin causes difficulties, please tell me 
and temporarily remove it.
- Use matchlist() instead of substitute(), which could speed things up a 
little.

3.1
- Slightly improved performance of s:MarkInexistent() and 
viki#HookCheckPreviousPosition().

3.2
- viki_viki.vim: Wrong value for b:vikiCmdDestIdx and 
b:vikiCmdAnchorIdx.
- Moved :VikiMinorModeViki, :VikiMinorModeLaTeX, and 
:VikiMinorModeAnyWord to plugin/viki.vim

3.3
- Use hookcursormoved >= 0.3
- Backslash-save command-line completion
- Mark unknown intervikis as inexistent

3.4
- Promote anchors to VikiOpenSpecialProtocol().
- viki_viki: Enabled #INCLUDE
- Put the poor-man's math highlighting into syntax/texmath.vim so that 
it can be included from other syntax files.
- Cascade menu of intervikis
- FIX: don't register viki names as known/unknown more than once

3.5
- Don't try to append an empty anchor to an url (Thanks RM Schmid).
- New variable g:viki_intervikis to define intervikis in ~/.vimrc.
- Minor updates to the help file.

3.6
- Forgot to define a default value for g:viki_intervikis.

3.7
- In a file that doesn't contain headings, return 0 instead of '=' as 
default value if g:vikiFoldMethodVersion == 4.
- FIX: "=" in if expressions in certain versions of VikiFoldLevel()

3.8
- FIX: viki#MarkInexistentInElement() for pre 7.0.009 vim (thanks to M 
Brandmeyer)
- FIX: Make sure tlib is loaded even if it is installed in a different 
rtp-directory (thanks to M Brandmeyer)
- Added dia to g:vikiSpecialFiles
- FIX: Scrambled window when opening an url from vim (thanks A Moell)

3.9
- VikiOpenSpecialFile() uses fnameescape()

3.10
- FIX: automatically set marks (#m? type of anchors)
- Anchor regexp can be configured via g:vikiAnchorNameRx

3.11
- Disabled regions' #END-syntax
- Don't define interviki commands if a command of the same name already 
exists.
- Default values for g:vikiOpenUrlWith_ANY and g:vikiOpenFileWith_ANY on 
Macs (thanks mboniou)
- Correct default value for g:vikiOpenFileWith_ANY @ Windows

" vim: ff=unix
syntax/viki.vim	[[[1
333
" viki.vim -- the viki syntax file
" @Author:      Tom Link (micathom AT gmail com?subject=vim)
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Created:     30-Dez-2003.
" @Last Change: 2009-02-15.
" @Revision: 0.864

if !g:vikiEnabled
    finish
endif

if version < 600
    syntax clear
elseif exists("b:current_syntax")
    finish
endif

" This command sets up buffer variables and adds some basic highlighting.
let b:vikiEnabled = 0
call viki#DispatchOnFamily('MinorMode', '', 2)
let b:vikiEnabled = 2

runtime syntax/texmath.vim

" On slow machine the extended syntax highlighting can cause some major 
" slowdown (I'm not really sure what is causing this, but it can be 
" avoided anyway by highlighting only the basic syntax)
" if g:vikiBasicSyntax
"     finish
" endif

syn match vikiSemiParagraph /^\s\+$/

syn match vikiEscape /\\/ contained containedin=vikiEscapedChar
syn match vikiEscapedChar /\\\_./ contains=vikiEscape,vikiChar

" exe 'syn match vikiAnchor /^\('. escape(b:vikiCommentStart, '\/.*^$~[]') .'\)\?[[:blank:]]*#'. b:vikiAnchorNameRx .'/'
exe 'syn match vikiAnchor /^[[:blank:]]*%\?[[:blank:]]*#'. b:vikiAnchorNameRx .'.*/'
" syn match vikiMarkers /\(\([#?!+]\)\2\{2,2}\)/
syn match vikiMarkers /\V\(###\|???\|!!!\|+++\)/
" syn match vikiSymbols /\(--\|!=\|==\+\|\~\~\+\|<-\+>\|<=\+>\|<\~\+>\|<-\+\|-\+>\|<=\+\|=\+>\|<\~\+\|\~\+>\|\.\.\.\)/
syn match vikiSymbols /\V\(--\|!=\|==\+\|~~\+\|<-\+>\|<=\+>\|<~\+>\|<-\+\|-\+>\|<=\+\|=\+>\|<~\+\|~\+>\|...\|&\(#\d\+\|\w\+\);\)/

syn cluster vikiHyperLinks contains=vikiLink,vikiExtendedLink,vikiURL,vikiInexistentLink

if b:vikiTextstylesVer == 1
    syn match vikiBold /\(^\|\W\zs\)\*\(\\\*\|\w\)\{-1,}\*/
    syn region vikiContinousBold start=/\(^\|\W\zs\)\*\*[^ 	*]/ end=/\*\*\|\n\{2,}/ skip=/\\\n/
    syn match vikiUnderline /\(^\|\W\zs\)_\(\\_\|[^_\s]\)\{-1,}_/
    syn region vikiContinousUnderline start=/\(^\|\W\zs\)__[^ 	_]/ end=/__\|\n\{2,}/ skip=/\\\n/
    syn match vikiTypewriter /\(^\|\W\zs\)=\(\\=\|\w\)\{-1,}=/
    syn region vikiContinousTypewriter start=/\(^\|\W\zs\)==[^ 	=]/ end=/==\|\n\{2,}/ skip=/\\\n/
    syn cluster vikiTextstyles contains=vikiBold,vikiContinousBold,vikiTypewriter,vikiContinousTypewriter,vikiUnderline,vikiContinousUnderline,vikiEscapedChar
else
    syn region vikiBold start=/\(^\|\W\zs\)__[^ 	_]/ end=/__\|\n\{2,}/ skip=/\\_\|\\\n/ contains=vikiEscapedChar
    syn region vikiTypewriter start=/\(^\|[^\w`]\zs\)''[^ 	']/ end=/''\|\n\{2,}/ skip=/\\'\|\\\n/ contains=vikiEscapedChar
    syn cluster vikiTextstyles contains=vikiBold,vikiTypewriter,vikiEscapedChar
endif

syn cluster vikiText contains=@vikiTextstyles,@vikiHyperLinks,vikiMarkers

" exe 'syn match vikiComment /\V\^\[[:blank:]]\*'. escape(b:vikiCommentStart, '\/') .'\.\*/ contains=@vikiText'
" syn match vikiComment /^[[:blank:]]*%.*$/ contains=@vikiText
syn match vikiComment /^[[:blank:]]*%.*$/ contains=@vikiHyperLinks,vikiMarkers,vikiEscapedChar

" syn region vikiString start=+^[[:blank:]]\+"\|"+ end=+"[.?!]\?[[:blank:]]\+$\|"+ contains=@vikiText
" syn region vikiString start=+^"\|\s"\|[({\[]\zs"+ end=+"+ contains=@vikiText
syn region vikiString start=+^"\|\s"\|[({\[]\zs"\|[^[:alnum:]]\zs"\ze[[:alnum:]]+ end=+"+ contains=@vikiText

let b:vikiHeadingStart = '*'
if g:vikiFancyHeadings
    let hd=escape(b:vikiHeadingStart, '\/')
    exe 'syn region vikiHeading1 start=/\V\^'. hd .'\[[:blank:]]\+/ end=/\n/ contains=@vikiText'
    exe 'syn region vikiHeading2 start=/\V\^'. hd.hd .'\[[:blank:]]\+/ end=/\n/ contains=@vikiText'
    exe 'syn region vikiHeading3 start=/\V\^'. hd.hd.hd .'\[[:blank:]]\+/ end=/\n/ contains=@vikiText'
    exe 'syn region vikiHeading4 start=/\V\^'. hd.hd.hd.hd .'\[[:blank:]]\+/ end=/\n/ contains=@vikiText'
    exe 'syn region vikiHeading5 start=/\V\^'. hd.hd.hd.hd.hd .'\[[:blank:]]\+/ end=/\n/ contains=@vikiText'
    exe 'syn region vikiHeading6 start=/\V\^'. hd.hd.hd.hd.hd.hd .'\[[:blank:]]\+/ end=/\n/ contains=@vikiText'
else
    exe 'syn region vikiHeading start=/\V\^'. escape(b:vikiHeadingStart, '\/') .'\+\[[:blank:]]\+/ end=/\n/ contains=@vikiText'
endif

syn match vikiList /^[[:blank:]]\+\([-+*#?@]\|[0-9#]\+\.\|[a-zA-Z?]\.\)\ze[[:blank:]]/
syn match vikiDescription /^[[:blank:]]\+\(\\\n\|.\)\{-1,}[[:blank:]]::\ze[[:blank:]]/ contains=@vikiHyperLinks,vikiEscapedChar,vikiComment

" \( \+#\S\+\)\?
syn match vikiPriorityListTodoGen /^[[:blank:]]\+\zs#\(T: \+.\{-}\u.\{-}:\|\d*\u\d*\( \+\(_\|[0-9%-]\+\)\)\?\)\( \+\[[^[].\{-}\]\)\?\ze /
syn match vikiPriorityListTodoA /^[[:blank:]]\+\zs#\(T: \+.\{-}A.\{-}:\|\d*A\d*\( \+\(_\|[0-9%-]\+\)\)\?\)\( \+\[[^[].\{-}\]\)\?\ze /
syn match vikiPriorityListTodoB /^[[:blank:]]\+\zs#\(T: \+.\{-}B.\{-}:\|\d*B\d*\( \+\(_\|[0-9%-]\+\)\)\?\)\( \+\[[^[].\{-}\]\)\?\ze /
syn match vikiPriorityListTodoC /^[[:blank:]]\+\zs#\(T: \+.\{-}C.\{-}:\|\d*C\d*\( \+\(_\|[0-9%-]\+\)\)\?\)\( \+\[[^[].\{-}\]\)\?\ze /
syn match vikiPriorityListTodoD /^[[:blank:]]\+\zs#\(T: \+.\{-}D.\{-}:\|\d*D\d*\( \+\(_\|[0-9%-]\+\)\)\?\)\( \+\[[^[].\{-}\]\)\?\ze /
syn match vikiPriorityListTodoE /^[[:blank:]]\+\zs#\(T: \+.\{-}E.\{-}:\|\d*E\d*\( \+\(_\|[0-9%-]\+\)\)\?\)\( \+\[[^[].\{-}\]\)\?\ze /
syn match vikiPriorityListTodoF /^[[:blank:]]\+\zs#\(T: \+.\{-}F.\{-}:\|\d*F\d*\( \+\(_\|[0-9%-]\+\)\)\?\)\( \+\[[^[].\{-}\]\)\?\ze /

syn match vikiPriorityListDoneGen /^[[:blank:]]\+\zs#\(T: \+x\([0-9%-]\+\)\?.\{-}\u.\{-}:\|\(T: \+\)\?\d*\u\d* \+x[0-9%-]*\):\? .*/
syn match vikiPriorityListDoneX /^[[:blank:]]\+\zs#X\d\?\s.*/
syn match vikiPriorityListDoneA /^[[:blank:]]\+\zs#\(T: \+x\([0-9%-]\+\)\?.\{-}A.\{-}:\|\(T: \+\)\?\d*A\d* \+x[0-9%-]*\):\? .*/
syn match vikiPriorityListDoneB /^[[:blank:]]\+\zs#\(T: \+x\([0-9%-]\+\)\?.\{-}B.\{-}:\|\(T: \+\)\?\d*B\d* \+x[0-9%-]*\):\? .*/
syn match vikiPriorityListDoneC /^[[:blank:]]\+\zs#\(T: \+x\([0-9%-]\+\)\?.\{-}C.\{-}:\|\(T: \+\)\?\d*C\d* \+x[0-9%-]*\):\? .*/
syn match vikiPriorityListDoneD /^[[:blank:]]\+\zs#\(T: \+x\([0-9%-]\+\)\?.\{-}D.\{-}:\|\(T: \+\)\?\d*D\d* \+x[0-9%-]*\):\? .*/
syn match vikiPriorityListDoneE /^[[:blank:]]\+\zs#\(T: \+x\([0-9%-]\+\)\?.\{-}E.\{-}:\|\(T: \+\)\?\d*E\d* \+x[0-9%-]*\):\? .*/
syn match vikiPriorityListDoneF /^[[:blank:]]\+\zs#\(T: \+x\([0-9%-]\+\)\?.\{-}F.\{-}:\|\(T: \+\)\?\d*F\d* \+x[0-9%-]*\):\? .*/

syn match vikiTableRowSep /||\?/ contained containedin=vikiTableRow,vikiTableHead
syn region vikiTableHead start=/^[[:blank:]]*|| / skip=/\\\n/ end=/\(^\| \)||[[:blank:]]*$/
            \ transparent keepend
            " \ contains=ALLBUT,vikiTableRow,vikiTableHead 
syn region vikiTableRow  start=/^[[:blank:]]*| / skip=/\\\n/ end=/\(^\| \)|[[:blank:]]*$/
            \ transparent keepend
            " \ contains=ALLBUT,vikiTableRow,vikiTableHead

syn keyword vikiCommandNames 
            \ #CAP #CAPTION #LANG #LANGUAGE #INC #INCLUDE #DOC #VAR #KEYWORDS #OPT 
            \ #PUT #CLIP #SET #GET #XARG #XVAL #ARG #VAL #BIB #TITLE #TI #AUTHOR 
            \ #AU #AUTHORNOTE #AN #DATE #IMG #IMAGE #FIG #FIGURE #MAKETITLE 
            \ #MAKEBIB #LIST #DEFLIST #REGISTER #DEFCOUNTER #COUNTER #TABLE #IDX 
            \ #AUTOIDX #NOIDX #DONTIDX #WITH #ABBREV #MODULE #MOD #LTX #INLATEX 
            \ #PAGE #NOP
            \ contained containedin=vikiCommand

syn keyword vikiRegionNames
            \ #Doc #Var #Native #Ins #Write #Code #Inlatex #Ltx #Img #Image #Fig 
            \ #Figure #Footnote #Fn #Foreach #Table #Verbatim #Verb #Abstract 
            \ #Quote #Qu #R #Ruby #Clip #Put #Set #Header #Footer #Swallow #Skip 
            \ contained containedin=vikiMacroDelim,vikiRegion,vikiRegionWEnd,vikiRegionAlt

syn keyword vikiMacroNames 
            \ {fn {cite {attr {attrib {date {doc {var {arg {val {xarg {xval {opt 
            \ {msg {clip {get {ins {native {ruby {ref {anchor {label {lab {nl {ltx 
            \ {math {$ {list {item {term {, {sub {^ {sup {super {% {stacked {: 
            \ {text {plain {\\ {em {emph {_ {code {verb {img {cmt {pagenumber 
            \ {pagenum {idx {let {counter 
            \ contained containedin=vikiMacro,vikiMacroDelim

syn match vikiSkeleton /{{\_.\{-}[^\\]}}/

syn region vikiMacro matchgroup=vikiMacroDelim start=/{\W\?[^:{}]*:\?/ end=/}/ 
            \ transparent contains=@vikiText,vikiMacroNames,vikiMacro

syn region vikiRegion matchgroup=vikiMacroDelim 
            \ start=/^[[:blank:]]*#\([A-Z]\([a-z][A-Za-z]*\)\?\>\|!!!\)\(\\\n\|.\)\{-}<<\z(.*\)$/ 
            \ end=/^[[:blank:]]*\z1[[:blank:]]*$/ 
            \ contains=@vikiText,vikiRegionNames
" syn region vikiRegionWEnd matchgroup=vikiMacroDelim 
"             \ start=/^[[:blank:]]*#\([A-Z]\([a-z][A-Za-z]*\)\?\>\|!!!\)\(\\\n\|.\)\{-}:[[:blank:]]*$/ 
"             \ end=/^[[:blank:]]*#End[[:blank:]]*$/ 
"             \ contains=@vikiText,vikiRegionNames
syn region vikiRegionAlt matchgroup=vikiMacroDelim 
            \ start=/^[[:blank:]]*\z(=\{4,}\)[[:blank:]]*\([A-Z][a-z]*\>\|!!!\)\(\\\n\|.\)\{-}$/ 
            \ end=/^[[:blank:]]*\z1\([[:blank:]].*\)\?$/ 
            \ contains=@vikiText,vikiRegionNames

syn match vikiCommand /^\C[[:blank:]]*#\([A-Z]\{2,}\)\>\(\\\n\|.\)*/
            \ contains=vikiCommandNames

syn match vikiFilesMarkers /\[\[\([^\/]\+\/\)*\|\]!\]/ contained containedin=vikiFiles
syn match vikiFilesIndicators /{.\{-}}/ contained containedin=vikiFiles
syn match vikiFiles /^\s*\[\[.\{-}\]!\].*$/
            \ contained containedin=vikiFilesRegion contains=vikiFilesMarkers,vikiFilesIndicators
syn region vikiFilesRegion matchgroup=vikiMacroDelim
            \ start=/^[[:blank:]]*#Files\>\(\\\n\|.\)\{-}<<\z(.*\)$/ 
            \ end=/^[[:blank:]]*\z1[[:blank:]]*$/ 
            \ contains=vikiFiles


if g:vikiHighlightMath == 'latex'
    syn region vikiTexFormula matchgroup=Comment
                \ start=/\z(\$\$\?\)/ end=/\z1/
                \ contains=@texmathMath
    syn sync match vikiTexFormula grouphere NONE /^\s*$/
endif

syn region vikiTexRegion matchgroup=vikiMacroDelim
            \ start=/^[[:blank:]]*#Ltx\>\(\\\n\|.\)\{-}<<\z(.*\)$/ 
            \ end=/^[[:blank:]]*\z1[[:blank:]]*$/ 
            \ contains=@texmathMath
syn region vikiTexMacro matchgroup=vikiMacroDelim
            \ start=/{\(ltx\)\([^:{}]*:\)\?/ end=/}/ 
            \ transparent contains=vikiMacroNames,@texmath
syn region vikiTexMathMacro matchgroup=vikiMacroDelim
            \ start=/{\(math\>\|\$\)\([^:{}]*:\)\?/ end=/}/ 
            \ transparent contains=vikiMacroNames,@texmathMath


syntax sync minlines=2
" syntax sync maxlines=50
" syntax sync match vikiParaBreak /^\s*$/
" syntax sync linecont /\\$/


" Define the default highlighting.
" For version 5.7 and earlier: only when not done already
" For version 5.8 and later: only when an item doesn't have highlighting yet
if version >= 508 || !exists("did_viki_syntax_inits")
  if version < 508
      let did_viki_syntax_inits = 1
      command! -nargs=+ HiLink hi link <args>
  else
      command! -nargs=+ HiLink hi def link <args>
  endif
  
  if &background == "light"
      let s:cm1="Dark"
      let s:cm2="Light"
  else
      let s:cm1="Light"
      let s:cm2="Dark"
  endif

  if exists("g:vikiHeadingFont")
      let s:hdfont = " font=". g:vikiHeadingFont
  else
      let s:hdfont = ""
  endif
  
  if exists("g:vikiTypewriterFont")
      let s:twfont = " font=". g:vikiTypewriterFont
  else
      let s:twfont = ""
  endif

  HiLink vikiSemiParagraph NonText
  HiLink vikiEscapedChars Normal
  exe "hi vikiEscape ctermfg=". s:cm2 ."grey guifg=". s:cm2 ."grey"
  exe "hi vikiList term=bold cterm=bold gui=bold ctermfg=". s:cm1 ."Cyan guifg=". s:cm1 ."Cyan"
  HiLink vikiDescription vikiList
  if g:vikiFancyHeadings
      if &background == "light"
          let hdhl="term=bold,underline cterm=bold gui=bold ctermfg=". s:cm1 ."Magenta guifg=".s:cm1."Magenta". s:hdfont
          exe "hi vikiHeading1 ". hdhl ." guibg=#ffff00"
          exe "hi vikiHeading2 ". hdhl ." guibg=#ffff30"
          exe "hi vikiHeading3 ". hdhl ." guibg=#ffff60"
          exe "hi vikiHeading4 ". hdhl ." guibg=#ffff90"
          exe "hi vikiHeading5 ". hdhl ." guibg=#ffffb0"
          exe "hi vikiHeading6 ". hdhl ." guibg=#ffffe0"
      else
          let hdhl="term=bold,underline cterm=bold gui=bold ctermfg=DarkMagenta guifg=DarkMagenta". s:hdfont
          exe "hi vikiHeading1 ". hdhl ." guibg=#ffff00"
          exe "hi vikiHeading2 ". hdhl ." guibg=#aadd00"
          exe "hi vikiHeading3 ". hdhl ." guibg=#88aa00"
          exe "hi vikiHeading4 ". hdhl ." guibg=#558800"
          exe "hi vikiHeading5 ". hdhl ." guibg=#225500"
          exe "hi vikiHeading6 ". hdhl ." guibg=#002200"
      endif
  else
      exe "hi vikiHeading term=bold,underline cterm=bold gui=bold ctermfg=". s:cm1 ."Magenta guifg=".s:cm1."Magenta". s:hdfont
  endif
  
  let vikiPriorityListTodo = ' term=bold,underline cterm=bold gui=bold guifg=Black ctermfg=Black '
  exec 'hi vikiPriorityListTodoGen'. vikiPriorityListTodo  .'ctermbg=LightRed guibg=LightRed'
  exec 'hi vikiPriorityListTodoA'. vikiPriorityListTodo  .'ctermbg=Red guibg=Red'
  exec 'hi vikiPriorityListTodoB'. vikiPriorityListTodo  .'ctermbg=Brown guibg=Orange'
  exec 'hi vikiPriorityListTodoC'. vikiPriorityListTodo  .'ctermbg=Yellow guibg=Yellow'
  exec 'hi vikiPriorityListTodoD'. vikiPriorityListTodo  .'ctermbg=LightMagenta guibg=LightMagenta'
  exec 'hi vikiPriorityListTodoE'. vikiPriorityListTodo  .'ctermbg=LightYellow guibg=LightYellow'
  exec 'hi vikiPriorityListTodoF'. vikiPriorityListTodo  .'ctermbg=LightGreen guibg=LightGreen'
 
  " let vikiPriorityListDone = ' guifg='. s:cm1 .'Gray '
  " exec 'hi vikiPriorityListDoneA'. vikiPriorityListDone
  " exec 'hi vikiPriorityListDoneB'. vikiPriorityListDone
  " exec 'hi vikiPriorityListDoneC'. vikiPriorityListDone
  " exec 'hi vikiPriorityListDoneD'. vikiPriorityListDone
  " exec 'hi vikiPriorityListDoneE'. vikiPriorityListDone
  " exec 'hi vikiPriorityListDoneF'. vikiPriorityListDone
  HiLink vikiPriorityListDoneA Comment
  HiLink vikiPriorityListDoneB Comment
  HiLink vikiPriorityListDoneC Comment
  HiLink vikiPriorityListDoneD Comment
  HiLink vikiPriorityListDoneE Comment
  HiLink vikiPriorityListDoneF Comment
  HiLink vikiPriorityListDoneGen Comment
  HiLink vikiPriorityListDoneX Comment
  
  exe "hi vikiTableRowSep term=bold cterm=bold gui=bold ctermbg=". s:cm2 ."Grey guibg=". s:cm2 ."Grey"
  
  exe "hi vikiSymbols term=bold cterm=bold gui=bold ctermfg=". s:cm1 ."Red guifg=". s:cm1 ."Red"
  hi vikiMarkers term=bold cterm=bold gui=bold ctermfg=DarkRed guifg=DarkRed ctermbg=yellow guibg=yellow
  hi vikiAnchor term=italic cterm=italic gui=italic ctermfg=grey guifg=grey
  HiLink vikiComment Comment
  HiLink vikiString String
  
  if b:vikiTextstylesVer == 1
      hi vikiContinousBold term=bold cterm=bold gui=bold
      hi vikiContinousUnderline term=underline cterm=underline gui=underline
      exe "hi vikiContinousTypewriter term=underline ctermfg=". s:cm1 ."Grey guifg=". s:cm1 ."Grey". s:twfont
      HiLink vikiBold vikiContinousBold
      HiLink vikiUnderline vikiContinousUnderline 
      HiLink vikiTypewriter vikiContinousTypewriter
  else
      " hi vikiBold term=italic,bold cterm=italic,bold gui=italic,bold
      hi vikiBold term=bold,underline cterm=bold,underline gui=bold
      exe "hi vikiTypewriter term=underline ctermfg=". s:cm1 ."Grey guifg=". s:cm1 ."Grey". s:twfont
  endif

  HiLink vikiMacroHead Statement
  HiLink vikiMacroDelim Identifier
  HiLink vikiSkeleton Special
  HiLink vikiCommand Statement
  HiLink vikiRegion Statement
  HiLink vikiRegionWEnd vikiRegion
  HiLink vikiRegionAlt vikiRegion
  HiLink vikiFilesRegion Statement
  HiLink vikiFiles Constant
  HiLink vikiFilesMarkers Ignore
  HiLink vikiFilesIndicators Special
  " HiLink vikiCommandNames Constant
  " HiLink vikiRegionNames Constant
  " HiLink vikiMacroNames Constant
  HiLink vikiCommandNames Identifier
  HiLink vikiRegionNames Identifier
  HiLink vikiMacroNames Identifier

  " Statement PreProc
  HiLink vikiTexSup Type
  HiLink vikiTexSub Type
  " HiLink vikiTexArgDelimiters Comment
  HiLink vikiTexCommand Statement
  HiLink vikiTexText Normal
  HiLink vikiTexMathFont Type
  HiLink vikiTexMathWord Identifier
  HiLink vikiTexUnword Constant
  HiLink vikiTexPairs PreProc

  delcommand HiLink
endif

" if g:vikiMarkInexistent && !exists("b:vikiCheckInexistent")
if g:vikiMarkInexistent
    call viki#MarkInexistentInitial()
endif

let b:current_syntax = 'viki'

syntax/texmath.vim	[[[1
62
" texmath.vim
" @Author:      Tom Link (mailto:micathom AT gmail com?subject=[vim])
" @Website:     http://www.vim.org/account/profile.php?user_id=4037
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Created:     2007-11-15.
" @Last Change: 2009-02-15.
" @Revision:    0.0.16

" Use only as embedded syntax to be included from other syntax files.

" if version < 600
"     syntax clear
" elseif exists("b:current_syntax")
"     finish
" endif
if exists(':HiLink')
    let s:delhilink = 0
else
    let s:delhilink = 1
    if version < 508
        command! -nargs=+ HiLink hi link <args>
    else
        command! -nargs=+ HiLink hi def link <args>
    endif
endif


" syn match texmathArgDelimiters /[{}\[\]]/ contained containedin=texmathMath
syn match texmathCommand /\\[[:alnum:]]\+/ contained containedin=texmath
syn match texmathMathFont /\\\(math[[:alnum:]]\+\|Bbb\|frak\)/ contained containedin=texmath
syn match texmathMathWord /[[:alnum:].]\+/ contained containedin=texmathMath
syn match texmathUnword /\(\\\\\|[^[:alnum:]${}()[\]^_\\]\+\)/ contained containedin=texmath
syn match texmathPairs /\([<>()[\]]\|\\[{}]\|\\[lr]\(brace\|vert\|Vert\|angle\|ceil\|floor\|group\|moustache\)\)/
            \ contained containedin=texmath
syn match texmathSub /_/ contained containedin=texmathMath
syn match texmathSup /\^/ contained containedin=texmathMath
syn region texmathText matchgroup=Statement
            \ start=/\\text{/ end=/}/ skip=/\\[{}]/
            \ contained containedin=texmath
syn region texmathArgDelimiters matchgroup=Delimiter
            \ start=/\\\@<!{/ end=/\\\@<!}/ skip=/\\[{}]/
            \ contained contains=@texmathMath containedin=texmath
syn cluster texmath contains=texmathArgDelimiters,texmathCommand,texmathMathFont,texmathPairs,texmathUnword,texmathText
syn cluster texmathMath contains=@texmath,texmathMathWord,texmathSup,texmathSub

" Statement PreProc
HiLink texmathSup Type
HiLink texmathSub Type
" HiLink texmathArgDelimiters Comment
HiLink texmathCommand Statement
HiLink texmathText Normal
HiLink texmathMathFont Type
HiLink texmathMathWord Identifier
HiLink texmathUnword Constant
HiLink texmathPairs PreProc


if s:delhilink
    delcommand HiLink
endif
" let b:current_syntax = 'texmath'

