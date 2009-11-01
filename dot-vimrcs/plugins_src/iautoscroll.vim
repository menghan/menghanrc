" Filename: iautoscroll.vim
" Author: Yu Yuwei <acevery@gmail.com>
" Verson: 0.3
" Last Modify: Oct 06, 2008
" Function: Scrolling to center when cursor hit the last line in window
"      while inserting
" Usage: in your ~/.vimrc, let g:IAutoScrollMode="<mode>", where <mode>
"        is "center" for scroll to center, or "top" for scroll to top,
"        "off" to disable this plugin.
" Changlog:
"   0.3: Oct 06, 2008
"       fix logical error using "off"
"       move cursor to original place after scrolling
"   0.2: Sep 20, 2008
"       support to scroll to top
" ----------
"

if !exists("IAutoScrollMode")
    let IAutoScrollMode = "center"
endif

autocmd! CursorMovedI * silent call ICheck_Scroll()

function ICheck_Scroll()
    " we only check scroll when enabled:)
    if g:IAutoScrollMode != "off"
        " first, get the line number in window
        let cursor_line_no = winline()
        " second, get the window height
        let winht = winheight(winnr())
        " third get the current line and column
        let cur_line = line('.')
        let cur_col = col('.')
        " if we hit the bottom, just move to center
        if cursor_line_no == winht
            if g:IAutoScrollMode == "center"
                exec "normal zz"
            elseif g:IAutoScrollMode == "top"
                exec "normal zt"
            else
                exec "normal zz"
            endif
            " we need move cursor back to the original place,
            " otherwise insert mode in new line
            " would put cursor one space ahead. 
            exec "call cursor(cur_line,cur_col)"
        endif
    endif
endfunction
