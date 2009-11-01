" Vimball Archiver by Charles E. Campbell, Jr., Ph.D.
UseVimball
finish
plugin/02tlib.vim	[[[1
536
" tlib.vim -- Some utility functions
" @Author:      Tom Link (micathom AT gmail com?subject=[vim])
" @Website:     http://www.vim.org/account/profile.php?user_id=4037
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Created:     2007-04-10.
" @Last Change: 2009-02-25.
" @Revision:    561
" GetLatestVimScripts: 1863 1 tlib.vim
"
" Please see also ../test/tlib.vim for usage examples.
"
" TODO:
" - tlib#input#List(): RightMouse -> Make commands accessible via 
"   popup-menu
" - List isn't updated on some occassions (eg tselectfiles + pick file 
"   per mouse) when resetting the state from an post-process agent
" - tlib#agent#SwitchLayout(): switch between horizontal and vertical 
"   layout for the list
" - tlib#cache#Purge(): delete old cache files (for the moment use find)
" - tlib#file#Relative(): currently relies on cwd to be set
" - tlib#input#EditList(): Disable selection by index number
" - tlib#input#List(): Some kind of command line to edit some 
"   preferences (sort etc.) on the fly

if &cp || exists("loaded_tlib")
    finish
endif
if v:version < 700 "{{{2
    echoerr "tlib requires Vim >= 7"
    finish
endif
let loaded_tlib = 30
let s:save_cpo = &cpo
set cpo&vim


" Commands~ {{{1

" :display: TRequire NAME [VERSION [FILE]]
" Make a certain vim file is loaded.
"
" Conventions: If FILE isn't defined, plugin/NAME.vim is loaded. The 
" file must provide a variable loaded_{NAME} that represents the version 
" number.
command! -nargs=+ TRequire let s:require = [<f-args>]
            \ | if !exists('loaded_'. get(s:require, 0))
                \ | exec 'runtime '. get(s:require, 2, 'plugin/'. get(s:require, 0) .'.vim')
                \ | if !exists('loaded_'. get(s:require, 0)) || loaded_{get(s:require, 0)} < get(s:require, 1, loaded_{get(s:require, 0)})
                    \ | echoerr 'Require '.  get(s:require, 0) .' >= '. get(s:require, 1, 'any version will do')
                    \ | finish
                    \ | endif
                \ | endif | unlet s:require


" :display: :TLet VAR = VALUE
" Set a variable only if it doesn't already exist.
" EXAMPLES: >
"   TLet foo = 1
"   TLet foo = 2
"   echo foo
"   => 1
command! -nargs=+ TLet if !exists(matchstr(<q-args>, '^[^=[:space:]]\+')) | exec 'let '. <q-args> | endif


" Open a scratch buffer (a buffer without a file).
"   TScratch  ... use split window
"   TScratch! ... use the whole frame
" This command takes an (inner) dictionnary as optional argument.
" EXAMPLES: >
"   TScratch 'scratch': '__FOO__'
"   => Open a scratch buffer named __FOO__
command! -bar -nargs=* -bang TScratch call tlib#scratch#UseScratch({'scratch_split': '<bang>' != '!', <args>})


" :display: :TVarArg VAR1, [VAR2, DEFAULT2] ...
" A convenience wrapper for |tlib#arg#Let|.
" EXAMPLES: >
"   function! Foo(...)
"       TVarArg ['a', 1], 'b'
"       echo 'a='. a
"       echo 'b='. b
"   endf
command! -nargs=+ TVarArg exec tlib#arg#Let([<args>])


" :display: :TKeyArg DICT, VAR1, [VAR2, DEFAULT2] ...
" A convenience wrapper for |tlib#arg#Let|.
" EXAMPLES: >
"   function! Foo(keyargs)
"       TKeyArg a:keyargs, ['a', 1], 'b'
"       echo 'a='. a
"       echo 'b='. b
"   endf
command! -nargs=+ TKeyArg exec tlib#arg#Key([<args>])


" :display: TBrowseOutput COMMAND
" Ever wondered how to effciently browse the output of a command 
" without redirecting it to a file? This command takes a command as 
" argument and presents the output via |tlib#input#List()| so that you 
" can easily search for a keyword (e.g. the name of a variable or 
" function) and the like.
"
" If you press enter, the selected line will be copied to the command 
" line. Press ESC to cancel browsing.
"
" EXAMPLES: >
"   TBrowseOutput 20verb TeaseTheCulprit
command! -nargs=1 -complete=command TBrowseOutput call tlib#cmd#BrowseOutput(<q-args>)



" Variables~ {{{1

" When 1, automatically select a the last remaining item after applying 
" any filters.
TLet g:tlib_pick_last_item = 1

" If a list is bigger than this value, don't try to be smart when 
" selecting an item. Be slightly faster instead.
TLet g:tlib_sortprefs_threshold = 200

" Scratch window position
TLet g:tlib_scratch_pos = 'botright'

" Size of the input list window (in percent) from the main size (of &lines).
TLet g:tlib_inputlist_pct = 70

" Size of filename columns when listing filenames
TLet g:tlib_inputlist_width_filename = '&co / 3'
" TLet g:tlib_inputlist_width_filename = 25

" The highlight group to use for showing matches in the input list window.
TLet g:tlib_inputlist_higroup = 'IncSearch'

" If a list contains more items, don't do an incremental "live search", 
" but use |input()| the quere the user for a filter. This is useful on 
" slower machines or with very long lists.
TLet g:tlib_inputlist_livesearch_threshold = 500

" If true, show some indicators about the status of a filename (eg 
" buflisted(), bufloaded() etc.).
" This is disabled by default because vim checks also for the file on 
" disk when doing this.
TLet g:tlib_inputlist_filename_indicators = 0

" Can be "cnf" or "fuzzy".
"   cnf   :: substrings
"   fuzzy :: match characters
TLet g:tlib_inputlist_match = 'cnf'

" Extra tags for |tlib#tag#Retrieve()| (see there). Can also be buffer-local.
TLet g:tlib_tags_extra = ''

" Filter the tag description through |substitute()| for these filetypes. 
" This applies only if the tag cmd field (see |taglist()|) is used.
" :nodefault:
TLet g:tlib_tag_substitute = {
            \ 'java': [['\s*{\s*$', '', '']],
            \ 'ruby': [['\<\(def\|class\|module\)\>\s\+', '', '']],
            \ 'vim':  [
            \   ['^\s*com\%[mand]!\?\(\s\+-\S\+\)*\s*\u\w*\zs.*$', '', ''],
            \   ['^\s*\(let\|aug\%[roup]\|fu\%[nction]!\?\|com\%[mand]!\?\(\s\+-\S\+\)*\)\s*', '', ''],
            \   ['"\?\s*{{{\d.*$', '', ''],
            \ ],
            \ }

" " Alternative rx for keywords, in case 'iskeyword' is inadequate for 
" " the purposes of tlib but you don't want to change it's value.
" TLet g:tlib_keyword_rx = {
"             \ 'vim': '\(\w\|#\)',
"             \ }

TLet g:tlib_filename_sep = '/'
" TLet g:tlib_filename_sep = exists('+shellslash') && !&shellslash ? '\' : '/'   " {{{2

" The cache directory. If empty, use |tlib#dir#MyRuntime|.'/cache'
TLet g:tlib_cache = ''

" Where to display the line when using |tlib#buffer#ViewLine|.
" For possible values for position see |scroll-cursor|.
TLet g:tlib_viewline_position = 'zz'

" :doc:
" Keys for |tlib#input#List|~

TLet g:tlib_inputlist_and = ' '
TLet g:tlib_inputlist_or  = '|'
TLet g:tlib_inputlist_not = '-'

" When editing a list with |tlib#input#List|, typing these numeric chars 
" (as returned by getchar()) will select an item based on its index, not 
" based on its name. I.e. in the default setting, typing a "4" will 
" select the fourth item, not the item called "4".
" In order to make keys 0-9 filter the items in the list and make 
" <m-[0-9]> select an item by its index, remove the keys 48 to 57 from 
" this dictionary.
" Format: [KEY] = BASE ... the number is calculated as KEY - BASE.
" :nodefault:
TLet g:tlib_numeric_chars = {
            \ 48: 48,
            \ 49: 48,
            \ 50: 48,
            \ 51: 48,
            \ 52: 48,
            \ 53: 48,
            \ 54: 48,
            \ 55: 48,
            \ 56: 48,
            \ 57: 48,
            \ 176: 176,
            \ 177: 176,
            \ 178: 176,
            \ 179: 176,
            \ 180: 176,
            \ 181: 176,
            \ 182: 176,
            \ 183: 176,
            \ 184: 176,
            \ 185: 176,
            \}

" :nodefault:
TLet g:tlib_keyagents_InputList_s = {
            \ "\<PageUp>":   'tlib#agent#PageUp',
            \ "\<PageDown>": 'tlib#agent#PageDown',
            \ "\<Up>":       'tlib#agent#Up',
            \ "\<Down>":     'tlib#agent#Down',
            \ "\<c-Up>":     'tlib#agent#UpN',
            \ "\<c-Down>":   'tlib#agent#DownN',
            \ "\<Left>":     'tlib#agent#ShiftLeft',
            \ "\<Right>":    'tlib#agent#ShiftRight',
            \ 18:            'tlib#agent#Reset',
            \ 242:           'tlib#agent#Reset',
            \ 17:            'tlib#agent#Input',
            \ 241:           'tlib#agent#Input',
            \ 27:            'tlib#agent#Exit',
            \ 26:            'tlib#agent#Suspend',
            \ 250:           'tlib#agent#Suspend',
            \ 15:            'tlib#agent#SuspendToParentWindow',  
            \ 63:            'tlib#agent#Help',
            \ "\<F1>":       'tlib#agent#Help',
            \ "\<bs>":       'tlib#agent#ReduceFilter',
            \ "\<del>":      'tlib#agent#ReduceFilter',
            \ "\<c-bs>":     'tlib#agent#PopFilter',
            \ "\<m-bs>":     'tlib#agent#PopFilter',
            \ "\<c-del>":    'tlib#agent#PopFilter',
            \ "\<m-del>":    'tlib#agent#PopFilter',
            \ 191:           'tlib#agent#Debug',
            \ char2nr(g:tlib_inputlist_or):  'tlib#agent#OR',
            \ char2nr(g:tlib_inputlist_and): 'tlib#agent#AND',
            \ }

" Number of items to move when pressing <c-up/down> in the input list window.
TLet g:tlib_scroll_lines = 10

" :nodefault:
TLet g:tlib_keyagents_InputList_m = {
            \ 35:          'tlib#agent#Select',
            \ "\<s-up>":   'tlib#agent#SelectUp',
            \ "\<s-down>": 'tlib#agent#SelectDown',
            \ 1:           'tlib#agent#SelectAll',
            \ 225:         'tlib#agent#SelectAll',
            \ }
" "\<c-space>": 'tlib#agent#Select'

" :nodefault:
TLet g:tlib_handlers_EditList = [
            \ {'key': 5,  'agent': 'tlib#agent#EditItem',    'key_name': '<c-e>', 'help': 'Edit item'},
            \ {'key': 4,  'agent': 'tlib#agent#DeleteItems', 'key_name': '<c-d>', 'help': 'Delete item(s)'},
            \ {'key': 14, 'agent': 'tlib#agent#NewItem',     'key_name': '<c-n>', 'help': 'New item'},
            \ {'key': 24, 'agent': 'tlib#agent#Cut',         'key_name': '<c-x>', 'help': 'Cut item(s)'},
            \ {'key':  3, 'agent': 'tlib#agent#Copy',        'key_name': '<c-c>', 'help': 'Copy item(s)'},
            \ {'key': 22, 'agent': 'tlib#agent#Paste',       'key_name': '<c-v>', 'help': 'Paste item(s)'},
            \ {'pick_last_item': 0},
            \ {'return_agent': 'tlib#agent#EditReturnValue'},
            \ ]



" " TEST:
" TRequire tselectbuffer 6
" echo loaded_tselectbuffer



let &cpo = s:save_cpo
unlet s:save_cpo

finish
-----------------------------------------------------------------------

CHANGES:
0.1
Initial release

0.2
- More list convenience functions
- tlib#EditList()
- tlib#InputList(): properly handle duplicate items; it type contains 
'i', the list index + 1 is returned, not the element

0.3
- tlib#InputList(): Show feedback in statusline instead of the echo area
- tlib#GetVar(), tlib#GetValue()

0.4
- tlib#InputList(): Up/Down keys wrap around list
- tlib#InputList(): FIX: Problem when reducing the filter & using AND
- tlib#InputList(): Made <a-numeric> work (can be configured via 
- tlib#InputList(): special display_format: "filename"
- tlib#Object: experimental support for some kind of OOP
- tlib#World: Extracted some functions from tlib.vim to tlib/World.vim
- tlib#FileJoin(), tlib#FileSplit(), tlib#RelativeFilename()
- tlib#Let()
- tlib#EnsureDirectoryExists(dir)
- tlib#DirName(dir)
- tlib#DecodeURL(url), tlib#EncodeChar(char), tlib#EncodeURL(url)
- FIX: Problem when using shift-up/down with filtered lists

0.5
- tlib#InputList(): FIX: Selecting items in filtered view
- tlib#InputList(): <c-bs>: Remove last AND pattern from filter

0.6
- tlib#InputList(): Disabled <c-space> map
- tlib#InputList(): try to be smart about user itentions only if a 
list's length is < g:tlib_sortprefs_threshold (default: 200)
- tlib#Object: Super() method
- tlib#MyRuntimeDir()
- tlib#GetCacheName(), tlib#CacheSave(), tlib#CacheGet()
- tlib#Args(), tlib#GetArg()
- FIX: tlib#InputList(): Display problem with first item

0.7
- tlib#InputList(): <c-z> ... Suspend/Resume input
- tlib#InputList(): <c-q> ... Input text on the command line (useful on 
slow systems when working with very large lists)
- tlib#InputList(): AND-pattern starting with '!' will work as 'exclude 
matches'
- tlib#InputList(): FIX <c-bs> pop OR-patterns properly
- tlib#InputList(): display_format == filename: don't add '/' to 
directory names (avoid filesystem access)

0.8
- FIX: Return empty cache name for buffers that have no files attached to it
- Some re-arranging

0.9
- Re-arrangements & modularization (this means many function names have 
changed, on the other hand only those functions are loaded that are 
actually needed)
- tlib#input#List(): Added maps with m-modifiers for <c-q>, <c-z>, <c-a>
- tlib#input#List(): Make sure &fdm is manual
- tlib#input#List(): When exiting the list view, consume the next 5 
characters in the queue (if any)
- tlib#input#EditList(): Now has cut, copy, paste functionality.
- Added documentation and examples

0.10
- tlib#input#List(): (v)split type of commands leave the original window 
untouched (you may use <c-w> to replace its contents)
- tlib#file#With(): Check whether an existing buffer is loaded.
- Scratch related functions went to tlib/scratch.vim so that they are 
accessible from other scripts.
- Configure the list window height via g:tlib_inputlist_pct (1..100%)

0.11
NEW:
    - The :TLet command replaces :TLLet (which was removed)
    - :TScratch[!] command (with ! don't split but use the whole window)
    - tlib#rx#Escape(text, ?magic='m')
    - tlib#buffer#GetList(?show_hidden=0)
    - tlib#dir#CD(), tlib#dir#Push(), tlib#dir#Pop()
    - tlib#input#ListW: A slightly remodeled version of tlib#input#List 
    that takes a World as second argument.
    - Added some documentation doc/tlib.txt (most of it is automatically 
    compiled from the source files)
CHANGES:
    - tlib#input#List(): The default keys for AND, NOT have changed to 
    be more Google-like (space, minus); the keys can be configured via 
    global variables.
IMPROVEMENTS:
    - In file listings, indicate if a file is loaded, listed, modified 
    etc.
    - tlib#input#List(): Highlight the filter pattern
    - tlib#input#List(): <c-up/down> scrolls g:tlib_scroll_lines 
    (default=10) lines
FIXES:
    - tlib#input#List(): Centering line, clear match, clear & restore 
    the search register
    - tlib#input#List(): Ensure the window layout doesn't change (if the 
    number of windows hasn't changed)
    - tlib#arg#Ex(): Don't escape backslashes by default

0.12
NEW:
    - tlib/tab.vim
CHANGES:
    - Renamed tlib#win#SetWin() to tlib#win#Set()
IMPROVEMENTS:
    - tlib#input#List(): <left>, <right> keys work in some lists
    - tlib#input#List(): If an index_table is provided this will be used 
    instead of the item's list index.
FIXES:
    - tlib#input#List(): Problem with scrolling, when the list was 
    shorter than the window (eg when using a vertical window).
    - tlib#cache#Filename(): Don't rewrite name as relative filename if 
    explicitly given as argument. Avoid double (back)slashes.
    - TLet: simplified

0.13
CHANGES:
    - Scratch: Set &fdc=0.
    - The cache directory can be configured via g:tlib_cache
    - Renamed tlib#buffer#SetBuffer() to tlib#buffer#Set().
FIXES:
    - tlib#input#List(): Select the active item per mouse.
    - TLet: simplified

0.14
NEW:
    - tlib#buffer#InsertText()
CHANGES:
    - tlib#win#[SG]etLayout(): Use a dictionnary, set &cmdheight.
FIXES:
    - Wrong order with pre-defined filters.

0.15
NEW:
    - tlib#string#TrimLeft(), tlib#string#TrimRight(), tlib#string#Strip()
    - Progress bar

0.16
NEW:
    - tlib#string#Printf1()

0.17
NEW:
    - TBrowseOutput
- Some minor changes

0.18
NEW:
    - tlib/time.vim
    - g:tlib_inputlist_livesearch_threshold
CHANGES:
    - tlib#input#ListD(), World: Don't redisplay the list while typing 
    new letters; calculate filter regexps only once before filtering the 
    list.
    - World.vim: Minor changes to how filenames are handled.

0.19
NEW:
    - tag.vim
FIX:
    - dir.vim: Use plain dir name in tlib#dir#Ensure()
    - tlib#input#List(): An initial filter argument creates [[filter]] 
    and not as before [[''], [filter]].
    - tlib#input#List(): When type was "si" and the item was picked by 
    filter, the wrong index was returned.
    - tlib#input#List(): Don't check if chars are typed when displaying 
    the list for the first time.

0.20
- The arguments of tlib#tag#Collect() have changed.
- tlib#input#List(): The view can be "suspended" on initial display.
- tlib#input#List(): Follow/trace cursor functionality

0.21
- tlib#buffer#InsertText(): Respect tabs and (experimental) formatoptions+=or
- tlib/syntax.vim: Syntax-related functions

0.22
- FIX: very magic mode for tlib#rx#Escape() (thanks A Politz)
- FIX: tlib#arg#Ex: escape "!"

0.23
- Respect the setting of g:tlib_inputlist_filename_indicators
- tlib#input#List(): Reset syntax on resume; option to make list window "sticky"
- tlib#agent#ToggleStickyList()
- Simplified tlib#url#Decode()
- tlib#arg#Ex(): use fnameescape() if available

0.24
- s:prototype.SetInitialFilter: accept list as argument
- Maintain buffer MRU if required

0.25
- NEW: tlib#notify#TrimMessage(): trim message to prevent "Press ENTER" 
messages (contributed by Erik Falor)
- NEW: tlib#notify#Echo()
- FIX: World.CloseScratch(): Set window
- FIX: tlib#input#ListW(): Set initial_display = 1 on reset

0.26
- NEW: tlib#normal#WithRegister()
- FIX: Try not to change numbered registers

0.27
- FIX: Cosmetic bug, wrong packaging (thanks Nathan Neff)
- Meaning of World#filter_format changed; new World#filter_options 
- Filtering didn't work as advertised
- tlib#string#Count()

0.28
- tlib#input#List():
-- Improved handling of sticky lists; <cr> and <Leftmouse> resume a 
suspended list and immediately selects the item under the cursor
-- Experimental "seq" matching style: the conjunctions are sequentially 
ordered, they are combined with "OR" (disjunctions), the regexp is 
'magic', and "." is expanded to '.\{-}'
-- Experimental "cnfd" matching style: Same as cnf but with an "elastic" 
dot "." that matches '\.\{-}'
-- Filtering acts as if &ic=1 && $sc=1
-- Weighting is done by the filter
- tlib#agent#Input(): Consume <esc> when aborting input()
- INCOMPATIBLE CHANGE: Changed eligible values of g:tlib_inputlist_match 
to "cnf", "cnfd", "seq" and "fuzzy"
- NEW: tlib#buffer#KeepCursorPosition()
- tlib#buffer#InsertText(): Take care of the extra line when appending 
text to an empty buffer.

0.29
- tlib#string#Strip(): Strip also control characters (newlines etc.)
- tlib#rx#Suffixes(): 'suffixes' as Regexp
- World#RestoreOrigin(): Don't assume &splitbelow

0.30
- World#RestoreOrigin(): Don't assume &splitright

0.31
- :TRequire command
-tlib#input#List: For i-type list views, make sure agents are called 
with the base indices.

doc/tlib.txt	[[[1
1389
*tlib.txt*  tlib -- A library of vim functions
            Author: Tom Link, micathom at gmail com


This library provides some utility functions. There isn't much need to 
install it unless another plugin requires you to do so.

Most of the library is included in autoload files. No autocommands are 
created. With the exception of loading ../plugin/02tlib.vim at startup 
the library has no impact on startup time or anything else.

The change-log is included at the bottom of ../plugin/02tlib.vim
(move the cursor over the file name and type gfG)


-----------------------------------------------------------------------
Install~

Edit the vba file and type: >

    :so %

See :help vimball for details. If you have difficulties, please make 
sure, you have the current version of vimball (vimscript #1502) 
installed.


========================================================================
Contents~

        :TRequire ............................... |:TRequire|
        :TLet ................................... |:TLet|
        :TScratch ............................... |:TScratch|
        :TVarArg ................................ |:TVarArg|
        :TKeyArg ................................ |:TKeyArg|
        :TBrowseOutput .......................... |:TBrowseOutput|
        g:tlib_pick_last_item ................... |g:tlib_pick_last_item|
        g:tlib_sortprefs_threshold .............. |g:tlib_sortprefs_threshold|
        g:tlib_scratch_pos ...................... |g:tlib_scratch_pos|
        g:tlib_inputlist_pct .................... |g:tlib_inputlist_pct|
        g:tlib_inputlist_width_filename ......... |g:tlib_inputlist_width_filename|
        g:tlib_inputlist_higroup ................ |g:tlib_inputlist_higroup|
        g:tlib_inputlist_livesearch_threshold ... |g:tlib_inputlist_livesearch_threshold|
        g:tlib_inputlist_filename_indicators .... |g:tlib_inputlist_filename_indicators|
        g:tlib_inputlist_match .................. |g:tlib_inputlist_match|
        g:tlib_tags_extra ....................... |g:tlib_tags_extra|
        g:tlib_tag_substitute ................... |g:tlib_tag_substitute|
        g:tlib_filename_sep ..................... |g:tlib_filename_sep|
        g:tlib_cache ............................ |g:tlib_cache|
        g:tlib_viewline_position ................ |g:tlib_viewline_position|
        g:tlib_inputlist_and .................... |g:tlib_inputlist_and|
        g:tlib_inputlist_or ..................... |g:tlib_inputlist_or|
        g:tlib_inputlist_not .................... |g:tlib_inputlist_not|
        g:tlib_numeric_chars .................... |g:tlib_numeric_chars|
        g:tlib_keyagents_InputList_s ............ |g:tlib_keyagents_InputList_s|
        g:tlib_scroll_lines ..................... |g:tlib_scroll_lines|
        g:tlib_keyagents_InputList_m ............ |g:tlib_keyagents_InputList_m|
        g:tlib_handlers_EditList ................ |g:tlib_handlers_EditList|
        tlib#Filter_cnf#New ..................... |tlib#Filter_cnf#New()|
        tlib#Filter_cnfd#New .................... |tlib#Filter_cnfd#New()|
        tlib#Filter_fuzzy#New ................... |tlib#Filter_fuzzy#New()|
        tlib#Filter_seq#New ..................... |tlib#Filter_seq#New()|
        tlib#Object#New ......................... |tlib#Object#New()|
        prototype.New
        prototype.Inherit
        prototype.Extend
        prototype.IsA
        prototype.IsRelated
        prototype.RespondTo
        prototype.Super
        prototype.Methods
        tlib#World#New .......................... |tlib#World#New()|
        tlib#agent#Exit ......................... |tlib#agent#Exit()|
        tlib#agent#CopyItems .................... |tlib#agent#CopyItems()|
        tlib#agent#PageUp ....................... |tlib#agent#PageUp()|
        tlib#agent#PageDown ..................... |tlib#agent#PageDown()|
        tlib#agent#Up ........................... |tlib#agent#Up()|
        tlib#agent#Down ......................... |tlib#agent#Down()|
        tlib#agent#UpN .......................... |tlib#agent#UpN()|
        tlib#agent#DownN ........................ |tlib#agent#DownN()|
        tlib#agent#ShiftLeft .................... |tlib#agent#ShiftLeft()|
        tlib#agent#ShiftRight ................... |tlib#agent#ShiftRight()|
        tlib#agent#Reset ........................ |tlib#agent#Reset()|
        tlib#agent#Input ........................ |tlib#agent#Input()|
        tlib#agent#SuspendToParentWindow ........ |tlib#agent#SuspendToParentWindow()|
        tlib#agent#Suspend ...................... |tlib#agent#Suspend()|
        tlib#agent#Help ......................... |tlib#agent#Help()|
        tlib#agent#OR ........................... |tlib#agent#OR()|
        tlib#agent#AND .......................... |tlib#agent#AND()|
        tlib#agent#ReduceFilter ................. |tlib#agent#ReduceFilter()|
        tlib#agent#PopFilter .................... |tlib#agent#PopFilter()|
        tlib#agent#Debug ........................ |tlib#agent#Debug()|
        tlib#agent#Select ....................... |tlib#agent#Select()|
        tlib#agent#SelectUp ..................... |tlib#agent#SelectUp()|
        tlib#agent#SelectDown ................... |tlib#agent#SelectDown()|
        tlib#agent#SelectAll .................... |tlib#agent#SelectAll()|
        tlib#agent#ToggleStickyList ............. |tlib#agent#ToggleStickyList()|
        tlib#agent#EditItem ..................... |tlib#agent#EditItem()|
        tlib#agent#NewItem ...................... |tlib#agent#NewItem()|
        tlib#agent#DeleteItems .................. |tlib#agent#DeleteItems()|
        tlib#agent#Cut .......................... |tlib#agent#Cut()|
        tlib#agent#Copy ......................... |tlib#agent#Copy()|
        tlib#agent#Paste ........................ |tlib#agent#Paste()|
        tlib#agent#EditReturnValue .............. |tlib#agent#EditReturnValue()|
        tlib#agent#ViewFile ..................... |tlib#agent#ViewFile()|
        tlib#agent#EditFile ..................... |tlib#agent#EditFile()|
        tlib#agent#EditFileInSplit .............. |tlib#agent#EditFileInSplit()|
        tlib#agent#EditFileInVSplit ............. |tlib#agent#EditFileInVSplit()|
        tlib#agent#EditFileInTab ................ |tlib#agent#EditFileInTab()|
        tlib#agent#ToggleScrollbind ............. |tlib#agent#ToggleScrollbind()|
        tlib#agent#ShowInfo ..................... |tlib#agent#ShowInfo()|
        tlib#agent#PreviewLine .................. |tlib#agent#PreviewLine()|
        tlib#agent#GotoLine ..................... |tlib#agent#GotoLine()|
        tlib#agent#DoAtLine ..................... |tlib#agent#DoAtLine()|
        tlib#arg#Get ............................ |tlib#arg#Get()|
        tlib#arg#Let ............................ |tlib#arg#Let()|
        tlib#arg#Key ............................ |tlib#arg#Key()|
        tlib#arg#StringAsKeyArgs ................ |tlib#arg#StringAsKeyArgs()|
        tlib#arg#Ex ............................. |tlib#arg#Ex()|
        tlib#autocmdgroup#Init .................. |tlib#autocmdgroup#Init()|
        tlib#buffer#EnableMRU ................... |tlib#buffer#EnableMRU()|
        tlib#buffer#DisableMRU .................. |tlib#buffer#DisableMRU()|
        tlib#buffer#Set ......................... |tlib#buffer#Set()|
        tlib#buffer#Eval ........................ |tlib#buffer#Eval()|
        tlib#buffer#GetList ..................... |tlib#buffer#GetList()|
        tlib#buffer#ViewLine .................... |tlib#buffer#ViewLine()|
        tlib#buffer#HighlightLine ............... |tlib#buffer#HighlightLine()|
        tlib#buffer#DeleteRange ................. |tlib#buffer#DeleteRange()|
        tlib#buffer#ReplaceRange ................ |tlib#buffer#ReplaceRange()|
        tlib#buffer#ScratchStart ................ |tlib#buffer#ScratchStart()|
        tlib#buffer#ScratchEnd .................. |tlib#buffer#ScratchEnd()|
        tlib#buffer#BufDo ....................... |tlib#buffer#BufDo()|
        tlib#buffer#InsertText .................. |tlib#buffer#InsertText()|
        tlib#buffer#InsertText0 ................. |tlib#buffer#InsertText0()|
        tlib#buffer#CurrentByte ................. |tlib#buffer#CurrentByte()|
        tlib#buffer#KeepCursorPosition .......... |tlib#buffer#KeepCursorPosition()|
        tlib#cache#Filename ..................... |tlib#cache#Filename()|
        tlib#cache#Save ......................... |tlib#cache#Save()|
        tlib#cache#Get .......................... |tlib#cache#Get()|
        tlib#char#Get ........................... |tlib#char#Get()|
        tlib#char#IsAvailable ................... |tlib#char#IsAvailable()|
        tlib#char#GetWithTimeout ................ |tlib#char#GetWithTimeout()|
        tlib#cmd#OutputAsList ................... |tlib#cmd#OutputAsList()|
        tlib#cmd#BrowseOutput ................... |tlib#cmd#BrowseOutput()|
        tlib#cmd#UseVertical .................... |tlib#cmd#UseVertical()|
        tlib#cmd#Time ........................... |tlib#cmd#Time()|
        tlib#comments#Comments .................. |tlib#comments#Comments()|
        tlib#dir#CanonicName .................... |tlib#dir#CanonicName()|
        tlib#dir#PlainName ...................... |tlib#dir#PlainName()|
        tlib#dir#Ensure ......................... |tlib#dir#Ensure()|
        tlib#dir#MyRuntime ...................... |tlib#dir#MyRuntime()|
        tlib#dir#CD ............................. |tlib#dir#CD()|
        tlib#dir#Push ........................... |tlib#dir#Push()|
        tlib#dir#Pop ............................ |tlib#dir#Pop()|
        tlib#eval#FormatValue ................... |tlib#eval#FormatValue()|
        tlib#file#Split ......................... |tlib#file#Split()|
        tlib#file#Join .......................... |tlib#file#Join()|
        tlib#file#Relative ...................... |tlib#file#Relative()|
        tlib#file#With .......................... |tlib#file#With()|
        tlib#hook#Run ........................... |tlib#hook#Run()|
        tlib#input#List ......................... |tlib#input#List()|
        tlib#input#ListD ........................ |tlib#input#ListD()|
        tlib#input#ListW ........................ |tlib#input#ListW()|
        tlib#input#EditList ..................... |tlib#input#EditList()|
        tlib#input#Resume ....................... |tlib#input#Resume()|
        tlib#input#CommandSelect ................ |tlib#input#CommandSelect()|
        tlib#input#Edit ......................... |tlib#input#Edit()|
        tlib#list#Inject ........................ |tlib#list#Inject()|
        tlib#list#Compact ....................... |tlib#list#Compact()|
        tlib#list#Flatten ....................... |tlib#list#Flatten()|
        tlib#list#FindAll ....................... |tlib#list#FindAll()|
        tlib#list#Find .......................... |tlib#list#Find()|
        tlib#list#Any ........................... |tlib#list#Any()|
        tlib#list#All ........................... |tlib#list#All()|
        tlib#list#Remove ........................ |tlib#list#Remove()|
        tlib#list#RemoveAll ..................... |tlib#list#RemoveAll()|
        tlib#list#Zip ........................... |tlib#list#Zip()|
        tlib#list#Uniq .......................... |tlib#list#Uniq()|
        tlib#normal#WithRegister ................ |tlib#normal#WithRegister()|
        tlib#notify#Echo ........................ |tlib#notify#Echo()|
        tlib#notify#TrimMessage ................. |tlib#notify#TrimMessage()|
        tlib#progressbar#Init ................... |tlib#progressbar#Init()|
        tlib#progressbar#Display ................ |tlib#progressbar#Display()|
        tlib#progressbar#Restore ................ |tlib#progressbar#Restore()|
        tlib#rx#Escape .......................... |tlib#rx#Escape()|
        tlib#rx#EscapeReplace ................... |tlib#rx#EscapeReplace()|
        tlib#rx#Suffixes ........................ |tlib#rx#Suffixes()|
        tlib#scratch#UseScratch ................. |tlib#scratch#UseScratch()|
        tlib#scratch#CloseScratch ............... |tlib#scratch#CloseScratch()|
        tlib#string#RemoveBackslashes ........... |tlib#string#RemoveBackslashes()|
        tlib#string#Chomp ....................... |tlib#string#Chomp()|
        tlib#string#Format ...................... |tlib#string#Format()|
        tlib#string#Printf1 ..................... |tlib#string#Printf1()|
        tlib#string#TrimLeft .................... |tlib#string#TrimLeft()|
        tlib#string#TrimRight ................... |tlib#string#TrimRight()|
        tlib#string#Strip ....................... |tlib#string#Strip()|
        tlib#string#Count ....................... |tlib#string#Count()|
        tlib#syntax#Collect ..................... |tlib#syntax#Collect()|
        tlib#syntax#Names ....................... |tlib#syntax#Names()|
        tlib#tab#BufMap ......................... |tlib#tab#BufMap()|
        tlib#tab#TabWinNr ....................... |tlib#tab#TabWinNr()|
        tlib#tab#Set ............................ |tlib#tab#Set()|
        tlib#tag#Retrieve ....................... |tlib#tag#Retrieve()|
        tlib#tag#Collect ........................ |tlib#tag#Collect()|
        tlib#tag#Format ......................... |tlib#tag#Format()|
        tlib#time#MSecs ......................... |tlib#time#MSecs()|
        tlib#time#Now ........................... |tlib#time#Now()|
        tlib#time#Diff .......................... |tlib#time#Diff()|
        tlib#time#DiffMSecs ..................... |tlib#time#DiffMSecs()|
        tlib#type#IsNumber ...................... |tlib#type#IsNumber()|
        tlib#type#IsString ...................... |tlib#type#IsString()|
        tlib#type#IsFuncref ..................... |tlib#type#IsFuncref()|
        tlib#type#IsList ........................ |tlib#type#IsList()|
        tlib#type#IsDictionary .................. |tlib#type#IsDictionary()|
        tlib#url#Decode ......................... |tlib#url#Decode()|
        tlib#url#DecodeChar ..................... |tlib#url#DecodeChar()|
        tlib#url#EncodeChar ..................... |tlib#url#EncodeChar()|
        tlib#url#Encode ......................... |tlib#url#Encode()|
        tlib#var#Let ............................ |tlib#var#Let()|
        tlib#var#EGet ........................... |tlib#var#EGet()|
        tlib#var#Get ............................ |tlib#var#Get()|
        tlib#var#List ........................... |tlib#var#List()|
        tlib#win#Set ............................ |tlib#win#Set()|
        tlib#win#GetLayout ...................... |tlib#win#GetLayout()|
        tlib#win#SetLayout ...................... |tlib#win#SetLayout()|
        tlib#win#List ........................... |tlib#win#List()|
        tlib#win#Width .......................... |tlib#win#Width()|


========================================================================
plugin/02tlib.vim~

                                                    *:TRequire*
TRequire NAME [VERSION [FILE]]
    Make a certain vim file is loaded.
    
    Conventions: If FILE isn't defined, plugin/NAME.vim is loaded. The 
    file must provide a variable loaded_{NAME} that represents the version 
    number.

                                                    *:TLet*
:TLet VAR = VALUE
    Set a variable only if it doesn't already exist.
    EXAMPLES: >
      TLet foo = 1
      TLet foo = 2
      echo foo
      => 1
<

                                                    *:TScratch*
:TScratch
    Open a scratch buffer (a buffer without a file).
      TScratch  ... use split window
      TScratch! ... use the whole frame
    This command takes an (inner) dictionnary as optional argument.
    EXAMPLES: >
      TScratch 'scratch': '__FOO__'
      => Open a scratch buffer named __FOO__
<

                                                    *:TVarArg*
:TVarArg VAR1, [VAR2, DEFAULT2] ...
    A convenience wrapper for |tlib#arg#Let|.
    EXAMPLES: >
      function! Foo(...)
          TVarArg ['a', 1], 'b'
          echo 'a='. a
          echo 'b='. b
      endf
<

                                                    *:TKeyArg*
:TKeyArg DICT, VAR1, [VAR2, DEFAULT2] ...
    A convenience wrapper for |tlib#arg#Let|.
    EXAMPLES: >
      function! Foo(keyargs)
          TKeyArg a:keyargs, ['a', 1], 'b'
          echo 'a='. a
          echo 'b='. b
      endf
<

                                                    *:TBrowseOutput*
TBrowseOutput COMMAND
    Ever wondered how to effciently browse the output of a command 
    without redirecting it to a file? This command takes a command as 
    argument and presents the output via |tlib#input#List()| so that you 
    can easily search for a keyword (e.g. the name of a variable or 
    function) and the like.
    
    If you press enter, the selected line will be copied to the command 
    line. Press ESC to cancel browsing.
    
    EXAMPLES: >
      TBrowseOutput 20verb TeaseTheCulprit
<

                                                    *g:tlib_pick_last_item*
g:tlib_pick_last_item          (default: 1)
    When 1, automatically select a the last remaining item after applying 
    any filters.

                                                    *g:tlib_sortprefs_threshold*
g:tlib_sortprefs_threshold     (default: 200)
    If a list is bigger than this value, don't try to be smart when 
    selecting an item. Be slightly faster instead.

                                                    *g:tlib_scratch_pos*
g:tlib_scratch_pos             (default: 'botright')
    Scratch window position

                                                    *g:tlib_inputlist_pct*
g:tlib_inputlist_pct           (default: 70)
    Size of the input list window (in percent) from the main size (of &lines).

                                                    *g:tlib_inputlist_width_filename*
g:tlib_inputlist_width_filename (default: '&co / 3')
    Size of filename columns when listing filenames

                                                    *g:tlib_inputlist_higroup*
g:tlib_inputlist_higroup       (default: 'IncSearch')
    The highlight group to use for showing matches in the input list window.

                                                    *g:tlib_inputlist_livesearch_threshold*
g:tlib_inputlist_livesearch_threshold (default: 500)
    If a list contains more items, don't do an incremental "live search", 
    but use |input()| the quere the user for a filter. This is useful on 
    slower machines or with very long lists.

                                                    *g:tlib_inputlist_filename_indicators*
g:tlib_inputlist_filename_indicators (default: 0)
    If true, show some indicators about the status of a filename (eg 
    buflisted(), bufloaded() etc.).
    This is disabled by default because vim checks also for the file on 
    disk when doing this.

                                                    *g:tlib_inputlist_match*
g:tlib_inputlist_match         (default: 'cnf')
    Can be "cnf" or "fuzzy".
      cnf   :: substrings
      fuzzy :: match characters

                                                    *g:tlib_tags_extra*
g:tlib_tags_extra              (default: '')
    Extra tags for |tlib#tag#Retrieve()| (see there). Can also be buffer-local.

                                                    *g:tlib_tag_substitute*
g:tlib_tag_substitute
    Filter the tag description through |substitute()| for these filetypes. 
    This applies only if the tag cmd field (see |taglist()|) is used.

                                                    *g:tlib_filename_sep*
g:tlib_filename_sep            (default: '/')

                                                    *g:tlib_cache*
g:tlib_cache                   (default: '')
    The cache directory. If empty, use |tlib#dir#MyRuntime|.'/cache'

                                                    *g:tlib_viewline_position*
g:tlib_viewline_position       (default: 'zz')
    Where to display the line when using |tlib#buffer#ViewLine|.
    For possible values for position see |scroll-cursor|.


Keys for |tlib#input#List|~

                                                    *g:tlib_inputlist_and*
g:tlib_inputlist_and           (default: ' ')

                                                    *g:tlib_inputlist_or*
g:tlib_inputlist_or            (default: '|')

                                                    *g:tlib_inputlist_not*
g:tlib_inputlist_not           (default: '-')

                                                    *g:tlib_numeric_chars*
g:tlib_numeric_chars
    When editing a list with |tlib#input#List|, typing these numeric chars 
    (as returned by getchar()) will select an item based on its index, not 
    based on its name. I.e. in the default setting, typing a "4" will 
    select the fourth item, not the item called "4".
    In order to make keys 0-9 filter the items in the list and make 
    <m-[0-9]> select an item by its index, remove the keys 48 to 57 from 
    this dictionary.
    Format: [KEY] = BASE ... the number is calculated as KEY - BASE.

                                                    *g:tlib_keyagents_InputList_s*
g:tlib_keyagents_InputList_s

                                                    *g:tlib_scroll_lines*
g:tlib_scroll_lines            (default: 10)
    Number of items to move when pressing <c-up/down> in the input list window.

                                                    *g:tlib_keyagents_InputList_m*
g:tlib_keyagents_InputList_m

                                                    *g:tlib_handlers_EditList*
g:tlib_handlers_EditList


========================================================================
autoload/tlib/Filter_cnf.vim~

                                                    *tlib#Filter_cnf#New()*
tlib#Filter_cnf#New(...)
    The search pattern for |tlib#input#List()| is in conjunctive normal 
    form: (P1 OR P2 ...) AND (P3 OR P4 ...) ...
    The pattern is a '/\V' very no-'/magic' regexp pattern.
    
    This is also the base class for other filters.


========================================================================
autoload/tlib/Filter_cnfd.vim~

                                                    *tlib#Filter_cnfd#New()*
tlib#Filter_cnfd#New(...)
    The same as |tlib#FilterCNF#New()| but a dot is expanded to '\.\{-}'. 
    As a consequence, patterns cannot match dots.
    The pattern is a '/\V' very no-'/magic' regexp pattern.


========================================================================
autoload/tlib/Filter_fuzzy.vim~

                                                    *tlib#Filter_fuzzy#New()*
tlib#Filter_fuzzy#New(...)
    Support for "fuzzy" pattern matching in |tlib#input#List()|. 
    Characters are interpreted as if connected with '.\{-}'.


========================================================================
autoload/tlib/Filter_seq.vim~

                                                    *tlib#Filter_seq#New()*
tlib#Filter_seq#New(...)
    The search pattern for |tlib#input#List()| is interpreted as a 
    disjunction of 'magic' regular expressions with the exception of a dot 
    ".", which is interpreted as ".\{-}".
    The pattern is a '/magic' regexp pattern.


========================================================================
autoload/tlib/Object.vim~
Provides a prototype plus some OO-like methods.

                                                    *tlib#Object#New()*
tlib#Object#New(?fields={})
    This function creates a prototype that provides some kind of 
    inheritance mechanism and a way to call parent/super's methods.
    
    The usage demonstrated in the following example works best, when every 
    class/prototype is defined in a file of its own.
    
    The reason for why there is a dedicated constructor function is that 
    this layout facilitates the use of templates and that methods are 
    hidden from the user. Other solutions are possible.
    
    EXAMPLES: >
        let s:prototype = tlib#Object#New({
                    \ '_class': ['FooBar'],
                    \ 'foo': 1, 
                    \ 'bar': 2, 
                    \ })
        " Constructor
        function! FooBar(...)
            let object = s:prototype.New(a:0 >= 1 ? a:1 : {})
            return object
        endf
        function! s:prototype.babble() {
          echo "I think, therefore I am ". (self.foo * self.bar) ." months old."
        }
    
<    This could now be used like this: >
        let myfoo = FooBar({'foo': 3})
        call myfoo.babble()
        => I think, therefore I am 6 months old.
        echo myfoo.IsA('FooBar')
        => 1
        echo myfoo.IsA('object')
        => 1
        echo myfoo.IsA('Foo')
        => 0
        echo myfoo.RespondTo('babble')
        => 1
        echo myfoo.RespondTo('speak')
        => 0
<


prototype.New


prototype.Inherit


prototype.Extend


prototype.IsA


prototype.IsRelated


prototype.RespondTo


prototype.Super


prototype.Methods


========================================================================
autoload/tlib/World.vim~
A prototype used by |tlib#input#List|.
Inherits from |tlib#Object#New|.

                                                    *tlib#World#New()*
tlib#World#New(...)


========================================================================
autoload/tlib/agent.vim~
Various agents for use as key handlers in tlib#input#List()

                                                    *tlib#agent#Exit()*
tlib#agent#Exit(world, selected)

                                                    *tlib#agent#CopyItems()*
tlib#agent#CopyItems(world, selected)

                                                    *tlib#agent#PageUp()*
tlib#agent#PageUp(world, selected)

                                                    *tlib#agent#PageDown()*
tlib#agent#PageDown(world, selected)

                                                    *tlib#agent#Up()*
tlib#agent#Up(world, selected, ...)

                                                    *tlib#agent#Down()*
tlib#agent#Down(world, selected, ...)

                                                    *tlib#agent#UpN()*
tlib#agent#UpN(world, selected)

                                                    *tlib#agent#DownN()*
tlib#agent#DownN(world, selected)

                                                    *tlib#agent#ShiftLeft()*
tlib#agent#ShiftLeft(world, selected)

                                                    *tlib#agent#ShiftRight()*
tlib#agent#ShiftRight(world, selected)

                                                    *tlib#agent#Reset()*
tlib#agent#Reset(world, selected)

                                                    *tlib#agent#Input()*
tlib#agent#Input(world, selected)

                                                    *tlib#agent#SuspendToParentWindow()*
tlib#agent#SuspendToParentWindow(world, selected)
    Suspend (see |tlib#agent#Suspend|) the input loop and jump back to the 
    original position in the parent window.

                                                    *tlib#agent#Suspend()*
tlib#agent#Suspend(world, selected)
    Suspend lets you temporarily leave the input loop of 
    |tlib#input#List|. You can resume editing the list by pressing <c-z>, 
    <m-z>. <space>, <c-LeftMouse> or <MiddleMouse> in the suspended window.
    <cr> and <LeftMouse> will immediatly select the item under the cursor.
<    will select the item but the window will remain opened.

                                                    *tlib#agent#Help()*
tlib#agent#Help(world, selected)

                                                    *tlib#agent#OR()*
tlib#agent#OR(world, selected)

                                                    *tlib#agent#AND()*
tlib#agent#AND(world, selected)

                                                    *tlib#agent#ReduceFilter()*
tlib#agent#ReduceFilter(world, selected)

                                                    *tlib#agent#PopFilter()*
tlib#agent#PopFilter(world, selected)

                                                    *tlib#agent#Debug()*
tlib#agent#Debug(world, selected)

                                                    *tlib#agent#Select()*
tlib#agent#Select(world, selected)

                                                    *tlib#agent#SelectUp()*
tlib#agent#SelectUp(world, selected)

                                                    *tlib#agent#SelectDown()*
tlib#agent#SelectDown(world, selected)

                                                    *tlib#agent#SelectAll()*
tlib#agent#SelectAll(world, selected)

                                                    *tlib#agent#ToggleStickyList()*
tlib#agent#ToggleStickyList(world, selected)

                                                    *tlib#agent#EditItem()*
tlib#agent#EditItem(world, selected)

                                                    *tlib#agent#NewItem()*
tlib#agent#NewItem(world, selected)
    Insert a new item below the current one.

                                                    *tlib#agent#DeleteItems()*
tlib#agent#DeleteItems(world, selected)

                                                    *tlib#agent#Cut()*
tlib#agent#Cut(world, selected)

                                                    *tlib#agent#Copy()*
tlib#agent#Copy(world, selected)

                                                    *tlib#agent#Paste()*
tlib#agent#Paste(world, selected)

                                                    *tlib#agent#EditReturnValue()*
tlib#agent#EditReturnValue(world, rv)

                                                    *tlib#agent#ViewFile()*
tlib#agent#ViewFile(world, selected)

                                                    *tlib#agent#EditFile()*
tlib#agent#EditFile(world, selected)

                                                    *tlib#agent#EditFileInSplit()*
tlib#agent#EditFileInSplit(world, selected)

                                                    *tlib#agent#EditFileInVSplit()*
tlib#agent#EditFileInVSplit(world, selected)

                                                    *tlib#agent#EditFileInTab()*
tlib#agent#EditFileInTab(world, selected)

                                                    *tlib#agent#ToggleScrollbind()*
tlib#agent#ToggleScrollbind(world, selected)

                                                    *tlib#agent#ShowInfo()*
tlib#agent#ShowInfo(world, selected)

                                                    *tlib#agent#PreviewLine()*
tlib#agent#PreviewLine(world, selected)

                                                    *tlib#agent#GotoLine()*
tlib#agent#GotoLine(world, selected)
    If not called from the scratch, we assume/guess that we don't have to 
    suspend the input-evaluation loop.

                                                    *tlib#agent#DoAtLine()*
tlib#agent#DoAtLine(world, selected)


========================================================================
autoload/tlib/arg.vim~

                                                    *tlib#arg#Get()*
tlib#arg#Get(n, var, ?default="", ?test='')
    Set a positional argument from a variable argument list.
    See tlib#string#RemoveBackslashes() for an example.

                                                    *tlib#arg#Let()*
tlib#arg#Let(list, ?default='')
    Set a positional arguments from a variable argument list.
    See tlib#input#List() for an example.

                                                    *tlib#arg#Key()*
tlib#arg#Key(dict, list, ?default='')
    See |:TKeyArg|.

                                                    *tlib#arg#StringAsKeyArgs()*
tlib#arg#StringAsKeyArgs(string, ?keys=[], ?evaluate=0)

                                                    *tlib#arg#Ex()*
tlib#arg#Ex(arg, ?chars='%#! ')
    Escape some characters in a string.
    
    Use |fnamescape()| if available.
    
    EXAMPLES: >
      exec 'edit '. tlib#arg#Ex('foo%#bar.txt')
<


========================================================================
autoload/tlib/autocmdgroup.vim~

                                                    *tlib#autocmdgroup#Init()*
tlib#autocmdgroup#Init()


========================================================================
autoload/tlib/buffer.vim~

                                                    *tlib#buffer#EnableMRU()*
tlib#buffer#EnableMRU()

                                                    *tlib#buffer#DisableMRU()*
tlib#buffer#DisableMRU()

                                                    *tlib#buffer#Set()*
tlib#buffer#Set(buffer)
    Set the buffer to buffer and return a command as string that can be 
    evaluated by |:execute| in order to restore the original view.

                                                    *tlib#buffer#Eval()*
tlib#buffer#Eval(buffer, code)
    Evaluate CODE in BUFFER.
    
    EXAMPLES: >
      call tlib#buffer#Eval('foo.txt', 'echo b:bar')
<

                                                    *tlib#buffer#GetList()*
tlib#buffer#GetList(?show_hidden=0, ?show_number=0, " ?order='bufnr')

                                                    *tlib#buffer#ViewLine()*
tlib#buffer#ViewLine(line, ?position='z')
    line is either a number or a string that begins with a number.
    For possible values for position see |scroll-cursor|.
    See also |g:tlib_viewline_position|.

                                                    *tlib#buffer#HighlightLine()*
tlib#buffer#HighlightLine(line)

                                                    *tlib#buffer#DeleteRange()*
tlib#buffer#DeleteRange(line1, line2)
    Delete the lines in the current buffer. Wrapper for |:delete|.

                                                    *tlib#buffer#ReplaceRange()*
tlib#buffer#ReplaceRange(line1, line2, lines)
    Replace a range of lines.

                                                    *tlib#buffer#ScratchStart()*
tlib#buffer#ScratchStart()
    Initialize some scratch area at the bottom of the current buffer.

                                                    *tlib#buffer#ScratchEnd()*
tlib#buffer#ScratchEnd()
    Remove the in-buffer scratch area.

                                                    *tlib#buffer#BufDo()*
tlib#buffer#BufDo(exec)
    Run exec on all buffers via bufdo and return to the original buffer.

                                                    *tlib#buffer#InsertText()*
tlib#buffer#InsertText(text, keyargs)
    Keyargs:
      'shift': 0|N
      'col': col('.')|N
      'lineno': line('.')|N
      'indent': 0|1
      'pos': 'e'|'s' ... Where to locate the cursor (somewhat like s and e in {offset})
    Insert text (a string) in the buffer.

                                                    *tlib#buffer#InsertText0()*
tlib#buffer#InsertText0(text, ...)

                                                    *tlib#buffer#CurrentByte()*
tlib#buffer#CurrentByte()

                                                    *tlib#buffer#KeepCursorPosition()*
tlib#buffer#KeepCursorPosition(cmd)
    Evaluate cmd while maintaining the cursor position and jump registers.


========================================================================
autoload/tlib/cache.vim~

                                                    *tlib#cache#Filename()*
tlib#cache#Filename(type, ?file=%, ?mkdir=0)

                                                    *tlib#cache#Save()*
tlib#cache#Save(cfile, dictionary)

                                                    *tlib#cache#Get()*
tlib#cache#Get(cfile)


========================================================================
autoload/tlib/char.vim~

                                                    *tlib#char#Get()*
tlib#char#Get(?timeout=0)
    Get a character.
    
    EXAMPLES: >
      echo tlib#char#Get()
      echo tlib#char#Get(5)
<

                                                    *tlib#char#IsAvailable()*
tlib#char#IsAvailable()

                                                    *tlib#char#GetWithTimeout()*
tlib#char#GetWithTimeout(timeout, ...)


========================================================================
autoload/tlib/cmd.vim~

                                                    *tlib#cmd#OutputAsList()*
tlib#cmd#OutputAsList(command)

                                                    *tlib#cmd#BrowseOutput()*
tlib#cmd#BrowseOutput(command)
    See |:TBrowseOutput|.

                                                    *tlib#cmd#UseVertical()*
tlib#cmd#UseVertical(?rx='')
    Look at the history whether the command was called with vertical. If 
    an rx is provided check first if the last entry in the history matches 
    this rx.

                                                    *tlib#cmd#Time()*
tlib#cmd#Time(cmd)
    Print the time in seconds a command takes.


========================================================================
autoload/tlib/comments.vim~

                                                    *tlib#comments#Comments()*
tlib#comments#Comments(...)
    function! tlib#comments#Comments(?rx='')


========================================================================
autoload/tlib/dir.vim~

                                                    *tlib#dir#CanonicName()*
tlib#dir#CanonicName(dirname)
    EXAMPLES: >
      tlib#dir#CanonicName('foo/bar')
      => 'foo/bar/'
<

                                                    *tlib#dir#PlainName()*
tlib#dir#PlainName(dirname)
    EXAMPLES: >
      tlib#dir#PlainName('foo/bar/')
      => 'foo/bar'
<

                                                    *tlib#dir#Ensure()*
tlib#dir#Ensure(dir)
    Create a directory if it doesn't already exist.

                                                    *tlib#dir#MyRuntime()*
tlib#dir#MyRuntime()
    Return the first directory in &rtp.

                                                    *tlib#dir#CD()*
tlib#dir#CD(dir, ?locally=0)

                                                    *tlib#dir#Push()*
tlib#dir#Push(dir, ?locally=0)

                                                    *tlib#dir#Pop()*
tlib#dir#Pop()


========================================================================
autoload/tlib/eval.vim~

                                                    *tlib#eval#FormatValue()*
tlib#eval#FormatValue(value, ...)


========================================================================
autoload/tlib/file.vim~

                                                    *tlib#file#Split()*
tlib#file#Split(filename)
    EXAMPLES: >
      tlib#file#Split('foo/bar/filename.txt')
      => ['foo', 'bar', 'filename.txt']
<

                                                    *tlib#file#Join()*
tlib#file#Join(filename_parts, ?strip_slashes=0)
    EXAMPLES: >
      tlib#file#Join(['foo', 'bar', 'filename.txt'])
      => 'foo/bar/filename.txt'
<

                                                    *tlib#file#Relative()*
tlib#file#Relative(filename, basedir)
    EXAMPLES: >
      tlib#file#Relative('foo/bar/filename.txt', 'foo')
      => 'bar/filename.txt'
<

                                                    *tlib#file#With()*
tlib#file#With(fcmd, bcmd, files, ?world={})


========================================================================
autoload/tlib/hook.vim~

                                                    *tlib#hook#Run()*
tlib#hook#Run(hook, ?dict={})
    Execute dict[hook], w:{hook}, b:{hook}, or g:{hook} if existent.


========================================================================
autoload/tlib/input.vim~
Input-related, select from a list etc.

                                                    *tlib#input#List()*
tlib#input#List(type. ?query='', ?list=[], ?handlers=[], ?default="", ?timeout=0)
    Select a single or multiple items from a list. Return either the list 
    of selected elements or its indexes.
    
    By default, typing numbers will select an item by its index. See 
    |g:tlib_numeric_chars| to find out how to change this.
    
    The item is automatically selected if the numbers typed equals the 
    number of digits of the list length. I.e. if a list contains 20 items, 
    typing 1 will first highlight item 1 but it won't select/use it 
    because 1 is an ambiguous input in this context. If you press enter, 
    the first item will be selected. If you press another digit (e.g. 0), 
    item 10 will be selected. Another way to select item 1 would be to 
    type 01. If the list contains only 9 items, typing 1 would select the 
    first item right away.
    
    type can be:
        s  ... Return one selected element
        si ... Return the index of the selected element
        m  ... Return a list of selcted elements
        mi ... Return a list of indexes
    
    Several pattern matching styles are supported. See:
      - |tlib#Filter_cnf#New()|
      - |tlib#Filter_cnfd#New()|
      - |tlib#Filter_fuzzy#New()|
      - |tlib#Filter_seq#New()|
    
    EXAMPLES: >
      echo tlib#input#List('s', 'Select one item', [100,200,300])
      echo tlib#input#List('si', 'Select one item', [100,200,300])
      echo tlib#input#List('m', 'Select one or more item(s)', [100,200,300])
      echo tlib#input#List('mi', 'Select one or more item(s)', [100,200,300])
<

                                                    *tlib#input#ListD()*
tlib#input#ListD(dict)
    A wrapper for |tlib#input#ListW()| that builds |tlib#World#New| from 
    dict.

                                                    *tlib#input#ListW()*
tlib#input#ListW(world, ?command='')
    The second argument, command is meant for internal use only.
    The same as |tlib#input#List| but the arguments are packed into world 
    (an instance of tlib#World as returned by |tlib#World#New|).

                                                    *tlib#input#EditList()*
tlib#input#EditList(query, list, ?timeout=0)
    Edit a list.
    
    EXAMPLES: >
      echo tlib#input#EditList('Edit:', [100,200,300])
<

                                                    *tlib#input#Resume()*
tlib#input#Resume(name, pick)

                                                    *tlib#input#CommandSelect()*
tlib#input#CommandSelect(command, ?keyargs={})
    Take a command, view the output, and let the user select an item from 
    its output.
    
    EXAMPLE: >
        command! TMarks exec 'norm! `'. matchstr(tlib#input#CommandSelect('marks'), '^ \+\zs.')
        command! TAbbrevs exec 'norm i'. matchstr(tlib#input#CommandSelect('abbrev'), '^\S\+\s\+\zs\S\+')
<

                                                    *tlib#input#Edit()*
tlib#input#Edit(name, value, callback, ?cb_args=[])
    
    Edit a value (asynchronously) in a scratch buffer. Use name for 
    identification. Call callback when done (or on cancel).
    In the scratch buffer:
    Press <c-s> or <c-w><cr> to enter the new value, <c-w>c to cancel 
    editing.
    EXAMPLES: >
      fun! FooContinue(success, text)
          if a:success
              let b:var = a:text
          endif
      endf
      call tlib#input#Edit('foo', b:var, 'FooContinue')
<


========================================================================
autoload/tlib/list.vim~

                                                    *tlib#list#Inject()*
tlib#list#Inject(list, initial_value, funcref)
    EXAMPLES: >
      echo tlib#list#Inject([1,2,3], 0, function('Add')
      => 6
<

                                                    *tlib#list#Compact()*
tlib#list#Compact(list)
    EXAMPLES: >
      tlib#list#Compact([0,1,2,3,[], {}, ""])
      => [1,2,3]
<

                                                    *tlib#list#Flatten()*
tlib#list#Flatten(list)
    EXAMPLES: >
      tlib#list#Flatten([0,[1,2,[3,""]]])
      => [0,1,2,3,""]
<

                                                    *tlib#list#FindAll()*
tlib#list#FindAll(list, filter, ?process_expr="")
    Basically the same as filter()
    
    EXAMPLES: >
      tlib#list#FindAll([1,2,3], 'v:val >= 2')
      => [2, 3]
<

                                                    *tlib#list#Find()*
tlib#list#Find(list, filter, ?default="", ?process_expr="")
    
    EXAMPLES: >
      tlib#list#Find([1,2,3], 'v:val >= 2')
      => 2
<

                                                    *tlib#list#Any()*
tlib#list#Any(list, expr)
    EXAMPLES: >
      tlib#list#Any([1,2,3], 'v:val >= 2')
      => 1
<

                                                    *tlib#list#All()*
tlib#list#All(list, expr)
    EXAMPLES: >
      tlib#list#All([1,2,3], 'v:val >= 2')
      => 0
<

                                                    *tlib#list#Remove()*
tlib#list#Remove(list, element)
    EXAMPLES: >
      tlib#list#Remove([1,2,1,2], 2)
      => [1,1,2]
<

                                                    *tlib#list#RemoveAll()*
tlib#list#RemoveAll(list, element)
    EXAMPLES: >
      tlib#list#RemoveAll([1,2,1,2], 2)
      => [1,1]
<

                                                    *tlib#list#Zip()*
tlib#list#Zip(lists, ?default='')
    EXAMPLES: >
      tlib#list#Zip([[1,2,3], [4,5,6]])
      => [[1,4], [2,5], [3,6]]
<

                                                    *tlib#list#Uniq()*
tlib#list#Uniq(list, ...)


========================================================================
autoload/tlib/normal.vim~

                                                    *tlib#normal#WithRegister()*
tlib#normal#WithRegister(cmd, ...)


========================================================================
autoload/tlib/notify.vim~

                                                    *tlib#notify#Echo()*
tlib#notify#Echo(text, ...)
    Print text in the echo area. Temporarily disable 'ruler' and 'showcmd' 
    in order to prevent |press-enter| messages.

                                                    *tlib#notify#TrimMessage()*
tlib#notify#TrimMessage(message)
    Contributed by Erik Falor:
    If the line containing the message is too long, echoing it will cause 
    a 'Hit ENTER' prompt to appear.  This function cleans up the line so 
    that doesn't happen.
    The echoed line is too long if it is wider than the width of the 
    window, minus cmdline space taken up by the ruler and showcmd 
    features.


========================================================================
autoload/tlib/progressbar.vim~

                                                    *tlib#progressbar#Init()*
tlib#progressbar#Init(max, ...)
    EXAMPLE: >
        call tlib#progressbar#Init(20)
        try
            for i in range(20)
                call tlib#progressbar#Display(i)
                call DoSomethingThatTakesSomeTime(i)
            endfor
        finally
            call tlib#progressbar#Restore()
        endtry
<

                                                    *tlib#progressbar#Display()*
tlib#progressbar#Display(value, ...)

                                                    *tlib#progressbar#Restore()*
tlib#progressbar#Restore()


========================================================================
autoload/tlib/rx.vim~

                                                    *tlib#rx#Escape()*
tlib#rx#Escape(text, ?magic='m')
    magic can be one of: m, M, v, V
    See :help 'magic'

                                                    *tlib#rx#EscapeReplace()*
tlib#rx#EscapeReplace(text, ?magic='m')
    Escape return |sub-replace-special|.

                                                    *tlib#rx#Suffixes()*
tlib#rx#Suffixes(...)


========================================================================
autoload/tlib/scratch.vim~

                                                    *tlib#scratch#UseScratch()*
tlib#scratch#UseScratch(?keyargs={})
    Display a scratch buffer (a buffer with no file). See :TScratch for an 
    example.
    Return the scratch's buffer number.

                                                    *tlib#scratch#CloseScratch()*
tlib#scratch#CloseScratch(keyargs, ...)
    Close a scratch buffer as defined in keyargs (usually a World).


========================================================================
autoload/tlib/string.vim~

                                                    *tlib#string#RemoveBackslashes()*
tlib#string#RemoveBackslashes(text, ?chars=' ')
    Remove backslashes from text (but only in front of the characters in 
    chars).

                                                    *tlib#string#Chomp()*
tlib#string#Chomp(string)

                                                    *tlib#string#Format()*
tlib#string#Format(template, dict)

                                                    *tlib#string#Printf1()*
tlib#string#Printf1(format, string)
    This function deviates from |printf()| in certain ways.
    Additional items:
        %{rx}      ... insert escaped regexp
        %{fuzzyrx} ... insert typo-tolerant regexp

                                                    *tlib#string#TrimLeft()*
tlib#string#TrimLeft(string)

                                                    *tlib#string#TrimRight()*
tlib#string#TrimRight(string)

                                                    *tlib#string#Strip()*
tlib#string#Strip(string)

                                                    *tlib#string#Count()*
tlib#string#Count(string, rx)


========================================================================
autoload/tlib/syntax.vim~

                                                    *tlib#syntax#Collect()*
tlib#syntax#Collect()

                                                    *tlib#syntax#Names()*
tlib#syntax#Names(?rx='')


========================================================================
autoload/tlib/tab.vim~

                                                    *tlib#tab#BufMap()*
tlib#tab#BufMap()
    Return a dictionary of bufnumbers => [[tabpage, winnr] ...]

                                                    *tlib#tab#TabWinNr()*
tlib#tab#TabWinNr(buffer)
    Find a buffer's window at some tab page.

                                                    *tlib#tab#Set()*
tlib#tab#Set(tabnr)


========================================================================
autoload/tlib/tag.vim~

                                                    *tlib#tag#Retrieve()*
tlib#tag#Retrieve(rx, ?extra_tags=0)
    Get all tags matching rx. Basically, this function simply calls 
    |taglist()|, but when extra_tags is true, the list of the tag files 
    (see 'tags') is temporarily expanded with |g:tlib_tags_extra|.
    
    Example use:
    If want to include tags for, eg, JDK, normal tags use can become slow. 
    You could proceed as follows:
        1. Create a tags file for the JDK sources. When creating the tags 
        file, make sure to include inheritance information and the like 
        (command-line options like --fields=+iaSm --extra=+q should be ok).
        In this example, we want tags only for public methods (there are 
        most likely better ways to do this): >
             ctags -R --fields=+iaSm --extra=+q ${JAVA_HOME}/src
             head -n 6 tags > tags0
             grep access:public tags >> tags0
<       2. Say 'tags' included project specific tags files. In 
         ~/vimfiles/after/ftplugin/java.vim insert: >
             let b:tlib_tags_extra = $JAVA_HOME .'/tags0'
<       3. When this function is invoked as >
             echo tlib#tag#Retrieve('print')
<       It will return only project-local tags. If it is invoked as >
             echo tlib#tag#Retrieve('print', 1)
<       tags from the JDK will be included.

                                                    *tlib#tag#Collect()*
tlib#tag#Collect(constraints, ?use_extra=1, ?match_front=1)
    Retrieve tags that meet the the constraints (a dictionnary of fields and 
    regexp, with the exception of the kind field that is a list of chars). 
    For the use of the optional use_extra argument see 
    |tlib#tag#Retrieve()|.

                                                    *tlib#tag#Format()*
tlib#tag#Format(tag)


========================================================================
autoload/tlib/time.vim~

                                                    *tlib#time#MSecs()*
tlib#time#MSecs()

                                                    *tlib#time#Now()*
tlib#time#Now()

                                                    *tlib#time#Diff()*
tlib#time#Diff(a, b, ...)

                                                    *tlib#time#DiffMSecs()*
tlib#time#DiffMSecs(a, b, ...)


========================================================================
autoload/tlib/type.vim~

                                                    *tlib#type#IsNumber()*
tlib#type#IsNumber(expr)

                                                    *tlib#type#IsString()*
tlib#type#IsString(expr)

                                                    *tlib#type#IsFuncref()*
tlib#type#IsFuncref(expr)

                                                    *tlib#type#IsList()*
tlib#type#IsList(expr)

                                                    *tlib#type#IsDictionary()*
tlib#type#IsDictionary(expr)


========================================================================
autoload/tlib/url.vim~

                                                    *tlib#url#Decode()*
tlib#url#Decode(url)
    Decode an encoded URL.

                                                    *tlib#url#DecodeChar()*
tlib#url#DecodeChar(char)
    Decode a single character.

                                                    *tlib#url#EncodeChar()*
tlib#url#EncodeChar(char)
    Encode a single character.

                                                    *tlib#url#Encode()*
tlib#url#Encode(url, ...)
    Encode an url.


========================================================================
autoload/tlib/var.vim~

                                                    *tlib#var#Let()*
tlib#var#Let(name, val)
    Define a variable called NAME if yet undefined.
    You can also use the :TLLet command.
    
    EXAMPLES: >
      exec tlib#var#Let('g:foo', 1)
      TLet g:foo = 1
<

                                                    *tlib#var#EGet()*
tlib#var#EGet(var, namespace, ?default='')
    Retrieve a variable by searching several namespaces.
    
    EXAMPLES: >
      let g:foo = 1
      let b:foo = 2
      let w:foo = 3
      echo eval(tlib#var#EGet('foo', 'vg'))  => 1
      echo eval(tlib#var#EGet('foo', 'bg'))  => 2
      echo eval(tlib#var#EGet('foo', 'wbg')) => 3
<

                                                    *tlib#var#Get()*
tlib#var#Get(var, namespace, ?default='')
    Retrieve a variable by searching several namespaces.
    
    EXAMPLES: >
      let g:foo = 1
      let b:foo = 2
      let w:foo = 3
      echo tlib#var#Get('foo', 'bg')  => 1
      echo tlib#var#Get('foo', 'bg')  => 2
      echo tlib#var#Get('foo', 'wbg') => 3
<

                                                    *tlib#var#List()*
tlib#var#List(rx, ?prefix='')
    Get a list of variables matching rx.
    EXAMPLE:
      echo tlib#var#List('tlib_', 'g:')


========================================================================
autoload/tlib/win.vim~

                                                    *tlib#win#Set()*
tlib#win#Set(winnr)
    Return vim code to jump back to the original window.

                                                    *tlib#win#GetLayout()*
tlib#win#GetLayout(?save_view=0)

                                                    *tlib#win#SetLayout()*
tlib#win#SetLayout(layout)

                                                    *tlib#win#List()*
tlib#win#List()

                                                    *tlib#win#Width()*
tlib#win#Width(wnr)



vim:tw=78:fo=tcq2:isk=!-~,^*,^|,^":ts=8:ft=help:norl:
test/tlib.vim	[[[1
219
" tLib.vim
" @Author:      Thomas Link (mailto:micathom AT gmail com?subject=vim-tLib)
" @Website:     http://www.vim.org/account/profile.php?user_id=4037
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Created:     2006-12-17.
" @Last Change: 2008-11-23.
" @Revision:    129

if !exists("loaded_tassert")
    echoerr 'tAssert (vimscript #1730) is required'
endif


TAssertBegin! "tlib"


" List {{{2
fun! Add(a,b)
    return a:a + a:b
endf
TAssert IsEqual(tlib#list#Inject([], 0, function('Add')), 0)
TAssert IsEqual(tlib#list#Inject([1,2,3], 0, function('Add')), 6)
delfunction Add

TAssert IsEqual(tlib#list#Compact([]), [])
TAssert IsEqual(tlib#list#Compact([0,1,2,3,[], {}, ""]), [1,2,3])

TAssert IsEqual(tlib#list#Flatten([]), [])
TAssert IsEqual(tlib#list#Flatten([1,2,3]), [1,2,3])
TAssert IsEqual(tlib#list#Flatten([1,2, [1,2,3], 3]), [1,2,1,2,3,3])
TAssert IsEqual(tlib#list#Flatten([0,[1,2,[3,""]]]), [0,1,2,3,""])

TAssert IsEqual(tlib#list#FindAll([1,2,3], 'v:val >= 2'), [2,3])
TAssert IsEqual(tlib#list#FindAll([1,2,3], 'v:val >= 2', 'v:val * 10'), [20,30])

TAssert IsEqual(tlib#list#Find([1,2,3], 'v:val >= 2'), 2)
TAssert IsEqual(tlib#list#Find([1,2,3], 'v:val >= 2', 0, 'v:val * 10'), 20)
TAssert IsEqual(tlib#list#Find([1,2,3], 'v:val >= 5', 10), 10)

TAssert IsEqual(tlib#list#Any([1,2,3], 'v:val >= 2'), 1)
TAssert IsEqual(tlib#list#Any([1,2,3], 'v:val >= 5'), 0)

TAssert IsEqual(tlib#list#All([1,2,3], 'v:val < 5'), 1)
TAssert IsEqual(tlib#list#All([1,2,3], 'v:val >= 2'), 0)

TAssert IsEqual(tlib#list#Remove([1,2,1,2], 2), [1,1,2])
TAssert IsEqual(tlib#list#RemoveAll([1,2,1,2], 2), [1,1])

TAssert IsEqual(tlib#list#Zip([[1,2,3], [4,5,6]]), [[1,4], [2,5], [3,6]])
TAssert IsEqual(tlib#list#Zip([[1,2,3], [4,5,6,7]]), [[1,4], [2,5], [3,6], ['', 7]])
TAssert IsEqual(tlib#list#Zip([[1,2,3], [4,5,6,7]], -1), [[1,4], [2,5], [3,6], [-1,7]])
TAssert IsEqual(tlib#list#Zip([[1,2,3,7], [4,5,6]], -1), [[1,4], [2,5], [3,6], [7,-1]])


" Vars {{{2
let g:foo = 1
let g:bar = 2
let b:bar = 3
let s:bar = 4

TAssert IsEqual(tlib#var#Get('bar', 'bg'), 3)
TAssert IsEqual(tlib#var#Get('bar', 'g'), 2)
TAssert IsEqual(tlib#var#Get('foo', 'bg'), 1)
TAssert IsEqual(tlib#var#Get('foo', 'g'), 1)
TAssert IsEqual(tlib#var#Get('none', 'l'), '')

TAssert IsEqual(eval(tlib#var#EGet('bar', 'bg')), 3)
TAssert IsEqual(eval(tlib#var#EGet('bar', 'g')), 2)
" TAssert IsEqual(eval(tlib#var#EGet('bar', 'sg')), 4)
TAssert IsEqual(eval(tlib#var#EGet('foo', 'bg')), 1)
TAssert IsEqual(eval(tlib#var#EGet('foo', 'g')), 1)
TAssert IsEqual(eval(tlib#var#EGet('none', 'l')), '')

unlet g:foo
unlet g:bar
unlet b:bar



" Filenames {{{2
TAssert IsEqual(tlib#file#Split('foo/bar/filename.txt'), ['foo', 'bar', 'filename.txt'])
TAssert IsEqual(tlib#file#Split('/foo/bar/filename.txt'), ['', 'foo', 'bar', 'filename.txt'])
TAssert IsEqual(tlib#file#Split('ftp://foo/bar/filename.txt'), ['ftp:/', 'foo', 'bar', 'filename.txt'])

TAssert IsEqual(tlib#file#Join(['foo', 'bar', 'filename.txt']), 'foo/bar/filename.txt')
TAssert IsEqual(tlib#file#Join(['', 'foo', 'bar', 'filename.txt']), '/foo/bar/filename.txt')
TAssert IsEqual(tlib#file#Join(['ftp:/', 'foo', 'bar', 'filename.txt']), 'ftp://foo/bar/filename.txt')

TAssert IsEqual(tlib#file#Relative('foo/bar/filename.txt', 'foo'), 'bar/filename.txt')
TAssert IsEqual(tlib#file#Relative('foo/bar/filename.txt', 'foo/base'), '../bar/filename.txt')
TAssert IsEqual(tlib#file#Relative('filename.txt', 'foo/base'), '../../filename.txt')
TAssert IsEqual(tlib#file#Relative('/foo/bar/filename.txt', '/boo/base'), '../../foo/bar/filename.txt')
TAssert IsEqual(tlib#file#Relative('/bar/filename.txt', '/boo/base'), '../../bar/filename.txt')
TAssert IsEqual(tlib#file#Relative('/foo/bar/filename.txt', '/base'), '../foo/bar/filename.txt')
TAssert IsEqual(tlib#file#Relative('c:/bar/filename.txt', 'x:/boo/base'), 'c:/bar/filename.txt')



" Prototype-based programming {{{2
let test = tlib#Test#New()
TAssert test.IsA('Test')
TAssert !test.IsA('foo')
TAssert test.RespondTo('RespondTo')
TAssert !test.RespondTo('RespondToNothing')
let test1 = tlib#Test#New()
TAssert test.IsRelated(test1)
let testworld = tlib#World#New()
TAssert !test.IsRelated(testworld)

let testc = tlib#TestChild#New()
TAssert IsEqual(testc.Dummy(), 'TestChild.vim')
TAssert IsEqual(testc.Super('Dummy', []), 'Test.vim')



" Optional arguments {{{2
function! TestGetArg(...) "{{{3
    exec tlib#arg#Get(1, 'foo', 1)
    return foo
endf

function! TestGetArg1(...) "{{{3
    exec tlib#arg#Get(1, 'foo', 1, '!= ""')
    return foo
endf

TAssert IsEqual(TestGetArg(), 1)
TAssert IsEqual(TestGetArg(''), '')
TAssert IsEqual(TestGetArg(2), 2)
TAssert IsEqual(TestGetArg1(), 1)
TAssert IsEqual(TestGetArg1(''), 1)
TAssert IsEqual(TestGetArg1(2), 2)

function! TestArgs(...) "{{{3
    exec tlib#arg#Let([['foo', "o"], ['bar', 2]])
    return repeat(foo, bar)
endf
TAssert IsEqual(TestArgs(), 'oo')
TAssert IsEqual(TestArgs('a'), 'aa')
TAssert IsEqual(TestArgs('a', 3), 'aaa')

function! TestArgs1(...) "{{{3
    exec tlib#arg#Let(['foo', ['bar', 2]])
    return repeat(foo, bar)
endf
TAssert IsEqual(TestArgs1(), '')
TAssert IsEqual(TestArgs1('a'), 'aa')
TAssert IsEqual(TestArgs1('a', 3), 'aaa')

function! TestArgs2(...) "{{{3
    exec tlib#arg#Let(['foo', 'bar'], 1)
    return repeat(foo, bar)
endf
TAssert IsEqual(TestArgs2(), '1')
TAssert IsEqual(TestArgs2('a'), 'a')
TAssert IsEqual(TestArgs2('a', 3), 'aaa')

function! TestArgs3(...)
    TVarArg ['a', 1], 'b'
    return a . b
endf
TAssert IsEqual(TestArgs3(), '1')
TAssert IsEqual(TestArgs3('a'), 'a')
TAssert IsEqual(TestArgs3('a', 3), 'a3')

delfunction TestGetArg
delfunction TestGetArg1
delfunction TestArgs
delfunction TestArgs1
delfunction TestArgs2
delfunction TestArgs3



" Strings {{{2
TAssert IsString(tlib#string#RemoveBackslashes('foo bar'))
TAssert IsEqual(tlib#string#RemoveBackslashes('foo bar'), 'foo bar')
TAssert IsEqual(tlib#string#RemoveBackslashes('foo\ bar'), 'foo bar')
TAssert IsEqual(tlib#string#RemoveBackslashes('foo\ \\bar'), 'foo \\bar')
TAssert IsEqual(tlib#string#RemoveBackslashes('foo\ \\bar', '\ '), 'foo \bar')



" Regexp {{{2
for c in split('^$.*+\()|{}[]~', '\zs')
    let s = printf('%sfoo%sbar%s', c, c, c)
    TAssert (s =~ '\m^'. tlib#rx#Escape(s, 'm') .'$')
    TAssert (s =~ '\M^'. tlib#rx#Escape(s, 'M') .'$')
    TAssert (s =~ '\v^'. tlib#rx#Escape(s, 'v') .'$')
    TAssert (s =~ '\V\^'. tlib#rx#Escape(s, 'V') .'\$')
endfor


" Encode, decode
TAssert IsEqual(tlib#url#Decode('http://example.com/foo+bar%25bar'), 'http://example.com/foo bar%bar')
TAssert IsEqual(tlib#url#Decode('Hello%20World.%20%20Good%2c%20bye.'), 'Hello World.  Good, bye.')

TAssert IsEqual(tlib#url#Encode('foo bar%bar'), 'foo+bar%%bar')
TAssert IsEqual(tlib#url#Encode('Hello World. Good, bye.'), 'Hello+World.+Good%2c+bye.')

TAssertEnd test test1 testc testworld


TAssert IsEqual(tlib#string#Count("fooo", "o"), 3)
TAssert IsEqual(tlib#string#Count("***", "\\*"), 3)
TAssert IsEqual(tlib#string#Count("***foo", "\\*"), 3)
TAssert IsEqual(tlib#string#Count("foo***", "\\*"), 3)


finish "{{{1


" Input {{{2
echo tlib#input#List('s', 'Test', ['barfoobar', 'barFoobar'])
echo tlib#input#List('s', 'Test', ['barfoobar', 'bar foo bar', 'barFoobar'])
echo tlib#input#List('s', 'Test', ['barfoobar', 'bar1Foo1bar', 'barFoobar'])
echo tlib#input#EditList('Test', ['bar1', 'bar2', 'bar3', 'foo1', 'foo2', 'foo3'])


autoload/tlib/file.vim	[[[1
125
" file.vim
" @Author:      Tom Link (micathom AT gmail com?subject=[vim])
" @Website:     http://www.vim.org/account/profile.php?user_id=4037
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Created:     2007-06-30.
" @Last Change: 2009-02-25.
" @Revision:    0.0.65

if &cp || exists("loaded_tlib_file_autoload")
    finish
endif
let loaded_tlib_file_autoload = 1


""" File related {{{1
" For the following functions please see ../../test/tlib.vim for examples.


" EXAMPLES: >
"   tlib#file#Split('foo/bar/filename.txt')
"   => ['foo', 'bar', 'filename.txt']
function! tlib#file#Split(filename) "{{{3
    let prefix = matchstr(a:filename, '^\(\w\+:\)\?/\+')
    " TLogVAR prefix
    if !empty(prefix)
        let filename = a:filename[len(prefix) : -1]
    else
        let filename = a:filename
    endif
    let rv = split(filename, '[\/]')
    " let rv = split(filename, '[\/]', 1)
    if !empty(prefix)
        call insert(rv, prefix[0:-2])
    endif
    return rv
endf


" :display: tlib#file#Join(filename_parts, ?strip_slashes=0)
" EXAMPLES: >
"   tlib#file#Join(['foo', 'bar', 'filename.txt'])
"   => 'foo/bar/filename.txt'
function! tlib#file#Join(filename_parts, ...) "{{{3
    TVarArg 'strip_slashes'
    if strip_slashes
        let rx    = tlib#rx#Escape(g:tlib_filename_sep) .'$'
        let parts = map(copy(a:filename_parts), 'substitute(v:val, rx, "", "")')
        return join(parts, g:tlib_filename_sep)
    else
        return join(a:filename_parts, g:tlib_filename_sep)
    endif
endf


" EXAMPLES: >
"   tlib#file#Relative('foo/bar/filename.txt', 'foo')
"   => 'bar/filename.txt'
function! tlib#file#Relative(filename, basedir) "{{{3
    " TLogVAR a:filename, a:basedir
    " TLogDBG getcwd()
    " TLogDBG expand('%:p')
    let f0 = fnamemodify(a:filename, ':p')
    let fn = fnamemodify(f0, ':t')
    let fd = fnamemodify(f0, ':h')
    let f  = tlib#file#Split(fd)
    " TLogVAR f
    let b0 = fnamemodify(a:basedir, ':p')
    let b  = tlib#file#Split(b0)
    " TLogVAR b
    if f[0] != b[0]
        let rv = f0
    else
        while !empty(f) && !empty(b)
            if f[0] != b[0]
                break
            endif
            call remove(f, 0)
            call remove(b, 0)
        endwh
        let rv = tlib#file#Join(repeat(['..'], len(b)) + f + [fn])
    endif
    " TLogVAR rv
    return rv
endf


function! s:SetScrollBind(world) "{{{3
    let sb = get(a:world, 'scrollbind', &scrollbind)
    if sb != &scrollbind
        let &scrollbind = sb
    endif
endf


" :def: function! tlib#file#With(fcmd, bcmd, files, ?world={})
function! tlib#file#With(fcmd, bcmd, files, ...) "{{{3
    " TLogVAR a:fcmd, a:bcmd, a:files
    exec tlib#arg#Let([['world', {}]])
    for f in a:files
        let bn = bufnr('^'.f.'$')
        " TLogVAR f, bn
        if bn != -1 && buflisted(bn)
            if !empty(a:bcmd)
                " TLogDBG a:bcmd .' '. bn
                exec a:bcmd .' '. bn
                call s:SetScrollBind(world)
            endif
        else
            if filereadable(f)
                if !empty(a:fcmd)
                    " TLogDBG a:fcmd .' '. escape(f, '%#\ ')
                    " exec a:fcmd .' '. escape(f, '%#\ ')
                    " exec a:fcmd .' '. escape(f, '%# ')
                    exec a:fcmd .' '. tlib#arg#Ex(f)
                    call s:SetScrollBind(world)
                endif
            else
                echohl error
                echom 'File not readable: '. f
                echohl NONE
            endif
        endif
    endfor
endf

autoload/tlib/Filter_cnf.vim	[[[1
130
" Filter_cnf.vim
" @Author:      Tom Link (mailto:micathom AT gmail com?subject=[vim])
" @Website:     http://www.vim.org/account/profile.php?user_id=4037
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Created:     2008-11-25.
" @Last Change: 2009-02-15.
" @Revision:    0.0.57

let s:save_cpo = &cpo
set cpo&vim


let s:prototype = tlib#Object#New({'_class': ['Filter_cnf'], 'name': 'cnf'}) "{{{2

" The search pattern for |tlib#input#List()| is in conjunctive normal 
" form: (P1 OR P2 ...) AND (P3 OR P4 ...) ...
" The pattern is a '/\V' very no-'/magic' regexp pattern.
"
" This is also the base class for other filters.
function! tlib#Filter_cnf#New(...) "{{{3
    let object = s:prototype.New(a:0 >= 1 ? a:1 : {})
    return object
endf


" :nodoc:
function! s:prototype.AssessName(world, name) dict "{{{3
    let xa  = 0
    let prefix = self.FilterRxPrefix()
    for flt in a:world.filter_pos
        " let flt = prefix . a:world.GetRx(fltl)
        " if flt =~# '\u' && a:name =~# flt
        "     let xa += 5
        " endif
        if a:name =~ '\^'. flt .'\|'. flt .'\$'
            let xa += 4
        elseif a:name =~ '\<'. flt .'\|'. flt .'\>'
            let xa += 3
        " elseif a:name =~ flt .'\>'
        "     let xa += 2
        elseif a:name =~ '\A'. flt .'\|'. flt .'\A'
            let xa += 1
        endif
        " if flt[0] =~# '\u' && matchstr(a:name, '\V\.\ze'. flt) =~# '\U'
        "     let xa += 1
        " endif
        " if flt[0] =~# '\U' && matchstr(a:name, '\V\.\ze'. flt) =~# '\u'
        "     let xa += 1
        " endif
        " if flt[-1] =~# '\u' && matchstr(a:name, '\V'. flt .'\zs\.') =~# '\U'
        "     let xa += 1
        " endif
        " if flt[-1] =~# '\U' && matchstr(a:name, '\V'. flt .'\zs\.') =~# '\u'
        "     let xa += 1
        " endif
    endfor
    " TLogVAR a:name, xa
    return xa
endf


" :nodoc:
function! s:prototype.Match(world, text) dict "{{{3
    " TLogVAR a:text
    " let sc = &smartcase
    " let ic = &ignorecase
    " if &ignorecase
    "     set smartcase
    " endif
    " try
        for rx in a:world.filter_neg
            " TLogVAR rx
            if a:text =~ rx
                return 0
            endif
        endfor
        for rx in a:world.filter_pos
            " TLogVAR rx
            if a:text !~ rx
                return 0
            endif
        endfor
    " finally
    "     let &smartcase = sc
    "     let &ignorecase = ic
    " endtry
    return 1
endf


" :nodoc:
function! s:prototype.DisplayFilter(filter) dict "{{{3
    let filter1 = deepcopy(a:filter)
    call map(filter1, '"(". join(reverse(v:val), " OR ") .")"')
    return join(reverse(filter1), ' AND ')
endf


" :nodoc:
function! s:prototype.SetFrontFilter(world, pattern) dict "{{{3
    let a:world.filter[0] = reverse(split(a:pattern, '\s*|\s*')) + a:world.filter[0][1 : -1]
endf


" :nodoc:
function! s:prototype.PushFrontFilter(world, char) dict "{{{3
    let a:world.filter[0][0] .= nr2char(a:char)
endf


" :nodoc:
function! s:prototype.ReduceFrontFilter(world) dict "{{{3
    let a:world.filter[0][0] = a:world.filter[0][0][0:-2]
endf


" :nodoc:
function! s:prototype.FilterRxPrefix() dict "{{{3
    return '\V'
endf


" :nodoc:
function! s:prototype.CleanFilter(filter) dict "{{{3
    return a:filter
endf


let &cpo = s:save_cpo
unlet s:save_cpo
autoload/tlib/Filter_cnfd.vim	[[[1
54
" Filter_cnfd.vim
" @Author:      Tom Link (mailto:micathom AT gmail com?subject=[vim])
" @Website:     http://www.vim.org/account/profile.php?user_id=4037
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Created:     2008-11-25.
" @Last Change: 2009-02-15.
" @Revision:    0.0.32

let s:save_cpo = &cpo
set cpo&vim


let s:prototype = tlib#Filter_cnf#New({'_class': ['Filter_cnfd'], 'name': 'cnfd'}) "{{{2

" The same as |tlib#FilterCNF#New()| but a dot is expanded to '\.\{-}'. 
" As a consequence, patterns cannot match dots.
" The pattern is a '/\V' very no-'/magic' regexp pattern.
function! tlib#Filter_cnfd#New(...) "{{{3
    let object = s:prototype.New(a:0 >= 1 ? a:1 : {})
    return object
endf


" :nodoc:
function! s:prototype.SetFrontFilter(world, pattern) dict "{{{3
    let pattern = substitute(a:pattern, '\.', '\\.\\{-}', 'g')
    let a:world.filter[0] = reverse(split(pattern, '\s*|\s*')) + a:world.filter[0][1 : -1]
endf


" :nodoc:
function! s:prototype.PushFrontFilter(world, char) dict "{{{3
    let a:world.filter[0][0] .= a:char == 46 ? '\.\{-}' : nr2char(a:char)
endf


" :nodoc:
function! s:prototype.ReduceFrontFilter(world) dict "{{{3
    let flt = a:world.filter[0][0]
    if flt =~ '\\\.\\{-}$'
        let a:world.filter[0][0] = flt[0:-7]
    else
        let a:world.filter[0][0] = flt[0:-2]
    endif
endf

" :nodoc:
function! s:prototype.CleanFilter(filter) dict "{{{3
    return substitute(a:filter, '\\.\\{-}', '.', 'g')
endf


let &cpo = s:save_cpo
unlet s:save_cpo
autoload/tlib/Filter_fuzzy.vim	[[[1
64
" Filter_fuzzy.vim
" @Author:      Tom Link (mailto:micathom AT gmail com?subject=[vim])
" @Website:     http://www.vim.org/account/profile.php?user_id=4037
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Created:     2008-11-25.
" @Last Change: 2009-02-15.
" @Revision:    0.0.31

let s:save_cpo = &cpo
set cpo&vim


let s:prototype = tlib#Filter_cnf#New({'_class': ['Filter_fuzzy'], 'name': 'fuzzy'}) "{{{2

" Support for "fuzzy" pattern matching in |tlib#input#List()|. 
" Characters are interpreted as if connected with '.\{-}'.
function! tlib#Filter_fuzzy#New(...) "{{{3
    let object = s:prototype.New(a:0 >= 1 ? a:1 : {})
    return object
endf


" :nodoc:
function! s:prototype.DisplayFilter(filter) dict "{{{3
    " TLogVAR a:filter
    let filter1 = deepcopy(a:filter)
    call map(filter1, '"{". join(reverse(v:val), " OR ") ."}"')
    return join(reverse(filter1), ' AND ')
endf


" :nodoc:
function! s:prototype.SetFrontFilter(world, pattern) dict "{{{3
    let a:world.filter[0] = map(reverse(split(a:pattern, '\s*|\s*')), 'join(map(split(v:val, ''\zs''), ''tlib#rx#Escape(v:val, "V")''), ''\.\{-}'')') + a:world.filter[0][1 : -1]
    endif
endf


" :nodoc:
function! s:prototype.PushFrontFilter(world, char) dict "{{{3
    let ch = tlib#rx#Escape(nr2char(a:char), 'V')
    if empty(a:world.filter[0][0])
        let a:world.filter[0][0] .= ch
    else
        let a:world.filter[0][0] .= '\.\{-}'. ch
    endif
endf


" :nodoc:
function! s:prototype.ReduceFrontFilter(world) dict "{{{3
    let a:world.filter[0][0] = substitute(a:world.filter[0][0], '\(\\\.\\{-}\)\?.$', '', '')
endf


" :nodoc:
function! s:prototype.CleanFilter(filter) dict "{{{3
    return substitute(a:filter, '\\\.\\{-}', '', 'g')
endf



let &cpo = s:save_cpo
unlet s:save_cpo
autoload/tlib/Filter_seq.vim	[[[1
94
" Filter_seq.vim
" @Author:      Tom Link (mailto:micathom AT gmail com?subject=[vim])
" @Website:     http://www.vim.org/account/profile.php?user_id=4037
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Created:     2008-11-25.
" @Last Change: 2009-02-15.
" @Revision:    0.0.22

let s:save_cpo = &cpo
set cpo&vim


let s:prototype = tlib#Filter_cnf#New({'_class': ['Filter_seq'], 'name': 'seq'}) "{{{2

" The search pattern for |tlib#input#List()| is interpreted as a 
" disjunction of 'magic' regular expressions with the exception of a dot 
" ".", which is interpreted as ".\{-}".
" The pattern is a '/magic' regexp pattern.
function! tlib#Filter_seq#New(...) "{{{3
    let object = s:prototype.New(a:0 >= 1 ? a:1 : {})
    return object
endf


" :nodoc:
function! s:prototype.Match(world, text) dict "{{{3
    " TLogVAR a:text
    for rx in a:world.filter_neg
        if a:text !~ rx
            " TLogDBG "filter_neg ". rx
            return 1
        endif
    endfor
    for rx in a:world.filter_pos
        if a:text =~ rx
            " TLogDBG "filter_pos ". rx
            return 1
        endif
    endfor
    return 0
endf


" :nodoc:
function! s:prototype.DisplayFilter(filter) dict "{{{3
    let filter1 = deepcopy(a:filter)
    call map(filter1, '"(". join(reverse(v:val), "_") .")"')
    return join(reverse(filter1), ' OR ')
endf


" :nodoc:
function! s:prototype.SetFrontFilter(world, pattern) dict "{{{3
    let a:world.filter[0] = map(reverse(split(a:pattern, '\s*|\s*')), 'join(split(v:val, ''\.''), ''.\{-}'')') + a:world.filter[0][1 : -1]
endf


" :nodoc:
function! s:prototype.PushFrontFilter(world, char) dict "{{{3
    let cc = nr2char(a:char)
    if cc == '.'
        let a:world.filter[0][0] .= '.\{-}'
    else
        let a:world.filter[0][0] .= nr2char(a:char)
    endif
endf


" :nodoc:
function! s:prototype.ReduceFrontFilter(world) dict "{{{3
    let flt = a:world.filter[0][0]
    if flt =~ '\.\\{-}$'
        let a:world.filter[0][0] = flt[0:-6]
    else
        let a:world.filter[0][0] = flt[0:-2]
    endif
endf


" :nodoc:
function! s:prototype.FilterRxPrefix() dict "{{{3
    return ''
endf


" :nodoc:
function! s:prototype.CleanFilter(filter) dict "{{{3
    return substitute(a:filter, '.\\{-}', '.', 'g')
endf



let &cpo = s:save_cpo
unlet s:save_cpo
autoload/tlib/Object.vim	[[[1
163
" Object.vim -- Prototype objects?
" @Author:      Tom Link (micathom AT gmail com?subject=[vim])
" @Website:     http://members.a1.net/t.link/
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Created:     2007-05-01.
" @Last Change: 2009-02-15.
" @Revision:    0.1.121

" :filedoc:
" Provides a prototype plus some OO-like methods.


if &cp || exists("loaded_tlib_object_autoload")
    finish
endif
let loaded_tlib_object_autoload = 1

let s:id_counter = 0
let s:prototype  = {'_class': ['object'], '_super': [], '_id': 0} "{{{2

" :def: function! tlib#Object#New(?fields={})
" This function creates a prototype that provides some kind of 
" inheritance mechanism and a way to call parent/super's methods.
"
" The usage demonstrated in the following example works best, when every 
" class/prototype is defined in a file of its own.
"
" The reason for why there is a dedicated constructor function is that 
" this layout facilitates the use of templates and that methods are 
" hidden from the user. Other solutions are possible.
"
" EXAMPLES: >
"     let s:prototype = tlib#Object#New({
"                 \ '_class': ['FooBar'],
"                 \ 'foo': 1, 
"                 \ 'bar': 2, 
"                 \ })
"     " Constructor
"     function! FooBar(...)
"         let object = s:prototype.New(a:0 >= 1 ? a:1 : {})
"         return object
"     endf
"     function! s:prototype.babble() {
"       echo "I think, therefore I am ". (self.foo * self.bar) ." months old."
"     }
"
" < This could now be used like this: >
"     let myfoo = FooBar({'foo': 3})
"     call myfoo.babble()
"     => I think, therefore I am 6 months old.
"     echo myfoo.IsA('FooBar')
"     => 1
"     echo myfoo.IsA('object')
"     => 1
"     echo myfoo.IsA('Foo')
"     => 0
"     echo myfoo.RespondTo('babble')
"     => 1
"     echo myfoo.RespondTo('speak')
"     => 0
function! tlib#Object#New(...) "{{{3
    return s:prototype.New(a:0 >= 1 ? a:1 : {})
endf


function! s:prototype.New(...) dict "{{{3
    let object = deepcopy(self)
    let s:id_counter += 1
    let object._id = s:id_counter
    if a:0 >= 1 && !empty(a:1)
        " call object.Extend(deepcopy(a:1))
        call object.Extend(a:1)
    endif
    return object
endf


function! s:prototype.Inherit(object) dict "{{{3
    let class = copy(self._class)
    " TLogVAR class
    let objid = self._id
    for c in get(a:object, '_class', [])
        " TLogVAR c
        if index(class, c) == -1
            call add(class, c)
        endif
    endfor
    call extend(self, a:object, 'keep')
    let self._class = class
    " TLogVAR self._class
    let self._id    = objid
    " let self._super = [super] + self._super
    call insert(self._super, a:object)
    return self
endf


function! s:prototype.Extend(dictionary) dict "{{{3
    let super = copy(self)
    let class = copy(self._class)
    " TLogVAR class
    let objid = self._id
    let thisclass = get(a:dictionary, '_class', [])
    for c in type(thisclass) == 3 ? thisclass : [thisclass]
        " TLogVAR c
        if index(class, c) == -1
            call add(class, c)
        endif
    endfor
    call extend(self, a:dictionary)
    let self._class = class
    " TLogVAR self._class
    let self._id    = objid
    " let self._super = [super] + self._super
    call insert(self._super, super)
    return self
endf


function! s:prototype.IsA(class) dict "{{{3
    return index(self._class, a:class) != -1
endf


function! s:prototype.IsRelated(object) dict "{{{3
    return len(filter(a:object._class, 'self.IsA(v:val)')) > 1
endf


function! s:prototype.RespondTo(name) dict "{{{3
    " return has_key(self, a:name) && type(self[a:name]) == 2
    return has_key(self, a:name)
endf


function! s:prototype.Super(method, arglist) dict "{{{3
    for o in self._super
        " TLogVAR o
        if o.RespondTo(a:method)
            " let self._tmp_method = o[a:method]
            " TLogVAR self._tmp_method
            " return call(self._tmp_method, a:arglist, self)
            return call(o[a:method], a:arglist, self)
        endif
    endfor
    echoerr 'tlib#Object: Does not respond to '. a:method .': '. string(self)
endf


function! s:prototype.Methods(...) dict "{{{3
    TVarArg ['pattern', '\d\+']
    let o = items(self)
    call filter(o, 'type(v:val[1]) == 2 && string(v:val[1]) =~ "^function(''\\d\\+'')"')
    let acc = {}
    for e in o
        let id = matchstr(string(e[1]), pattern)
        if !empty(id)
            let acc[id] = e[0]
        endif
    endfor
    return acc
endf

autoload/tlib/Test.vim	[[[1
27
" Test.vim -- A test class
" @Author:      Tom Link (micathom AT gmail com?subject=[vim])
" @Website:     http://members.a1.net/t.link/
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Created:     2007-05-01.
" @Last Change: 2009-02-15.
" @Revision:    0.1.9

" :enddoc:

if &cp || exists("loaded_tlib_Test_autoload")
    finish
endif
let loaded_tlib_Test_autoload = 1


let s:prototype = tlib#Object#New({'_class': ['Test']}) "{{{2
function! tlib#Test#New(...) "{{{3
    let object = s:prototype.New(a:0 >= 1 ? a:1 : {})
    return object
endf


function! s:prototype.Dummy() dict "{{{3
    return 'Test.vim'
endf

autoload/tlib/TestChild.vim	[[[1
27
" TestChild.vim
" @Author:      Tom Link (micathom AT gmail com?subject=[vim])
" @Website:     http://members.a1.net/t.link/
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Created:     2007-05-18.
" @Last Change: 2009-02-15.
" @Revision:    0.1.13

" :enddoc:

if &cp || exists("loaded_tlib_TestChild_autoload")
    finish
endif
let loaded_tlib_TestChild_autoload = 1


let s:prototype = tlib#Test#New({'_class': ['TestChild']}) "{{{2
function! tlib#TestChild#New(...) "{{{3
    let object = s:prototype.New(a:0 >= 1 ? a:1 : {})
    return object
endf


function! s:prototype.Dummy() dict "{{{3
    return 'TestChild.vim'
endf

autoload/tlib/World.vim	[[[1
882
" World.vim -- The World prototype for tlib#input#List()
" @Author:      Tom Link (micathom AT gmail com?subject=[vim])
" @Website:     http://members.a1.net/t.link/
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Created:     2007-05-01.
" @Last Change: 2009-02-25.
" @Revision:    0.1.696

" :filedoc:
" A prototype used by |tlib#input#List|.
" Inherits from |tlib#Object#New|.


if &cp || exists("loaded_tlib_world_autoload")
    finish
endif
let loaded_tlib_world_autoload = 1


let s:prototype = tlib#Object#New({
            \ '_class': 'World',
            \ 'name': 'world',
            \ 'allow_suspend': 1,
            \ 'base': [], 
            \ 'bufnr': -1,
            \ 'display_format': '',
            \ 'filetype': '',
            \ 'filter': [['']],
            \ 'filter_format': '',
            \ 'filter_options': '',
            \ 'follow_cursor': '',
            \ 'index_table': [],
            \ 'initial_filter': [['']],
            \ 'initial_index': 1,
            \ 'initial_display': 1,
            \ 'initialized': 0,
            \ 'key_handlers': [],
            \ 'list': [],
            \ 'matcher': {},
            \ 'next_state': '',
            \ 'numeric_chars': tlib#var#Get('tlib_numeric_chars', 'bg'),
            \ 'offset': 1,
            \ 'offset_horizontal': 0,
            \ 'pick_last_item': tlib#var#Get('tlib_pick_last_item', 'bg'),
            \ 'post_handlers': [],
            \ 'query': '',
            \ 'resize': 0,
            \ 'resize_vertical': 0,
            \ 'retrieve_eval': '',
            \ 'return_agent': '',
            \ 'rv': '',
            \ 'scratch': '__InputList__',
            \ 'scratch_filetype': 'tlibInputList',
            \ 'scratch_vertical': 0,
            \ 'sel_idx': [],
            \ 'show_empty': 0,
            \ 'state': 'display', 
            \ 'state_handlers': [],
            \ 'sticky': 0,
            \ 'timeout': 0,
            \ 'timeout_resolution': 2,
            \ 'type': '', 
            \ 'win_wnr': -1,
            \ })
            " \ 'handlers': [],
            " \ 'filter_options': '\c',

function! tlib#World#New(...)
    let object = s:prototype.New(a:0 >= 1 ? a:1 : {})
    call object.SetMatchMode(tlib#var#Get('tlib_inputlist_match', 'g', 'cnf'))
    return object
endf


" :nodoc:
function! s:prototype.Set_display_format(value) dict "{{{3
    if a:value == 'filename'
        call self.Set_highlight_filename()
        let self.display_format = 'world.FormatFilename(%s)'
    else
        let self.display_format = a:value
    endif
endf


" :nodoc:
function! s:prototype.Set_highlight_filename() dict "{{{3
    let self.tlib_UseInputListScratch = 'call world.Highlight_filename()'
    "             \ 'syntax match TLibMarker /\%>'. (1 + eval(g:tlib_inputlist_width_filename)) .'c |.\{-}| / | hi def link TLibMarker Special'
    " let self.tlib_UseInputListScratch .= '| syntax match TLibDir /\%>'. (4 + eval(g:tlib_inputlist_width_filename)) .'c\S\{-}[\/].*$/ | hi def link TLibDir Directory'
endf


" :nodoc:
function! s:prototype.Highlight_filename() dict "{{{3
    " exec 'syntax match TLibDir /\%>'. (3 + eval(g:tlib_inputlist_width_filename)) .'c \(\S:\)\?[\/].*$/ contained containedin=TLibMarker'
    exec 'syntax match TLibDir /\(\a:\|\.\.\..\{-}\)\?[\/][^&<>*|]*$/ contained containedin=TLibMarker'
    exec 'syntax match TLibMarker /\%>'. (1 + eval(g:tlib_inputlist_width_filename)) .'c |\( \|[[:alnum:]%*+-]*\)| \S.*$/ contains=TLibDir'
    hi def link TLibMarker Special
    hi def link TLibDir Directory
endf


" :nodoc:
function! s:prototype.FormatFilename(file) dict "{{{3
    let fname = fnamemodify(a:file, ":p:t")
    " let fname = fnamemodify(a:file, ":t")
    " if isdirectory(a:file)
    "     let fname .='/'
    " endif
    let dname = fnamemodify(a:file, ":h")
    " let dname = pathshorten(fnamemodify(a:file, ":h"))
    let dnmax = &co - max([eval(g:tlib_inputlist_width_filename), len(fname)]) - 11 - self.index_width - &fdc
    if len(dname) > dnmax
        let dname = '...'. strpart(fnamemodify(a:file, ":h"), len(dname) - dnmax)
    endif
    let marker = []
    if g:tlib_inputlist_filename_indicators
        let bnr = bufnr(a:file)
        " TLogVAR a:file, bnr, self.bufnr
        if bnr != -1
            if bnr == self.bufnr
                call add(marker, '%')
            else
                call add(marker, ' ')
                " elseif buflisted(a:file)
                "     if getbufvar(a:file, "&mod")
                "         call add(marker, '+')
                "     else
                "         call add(marker, 'B')
                "     endif
                " elseif bufloaded(a:file)
                "     call add(marker, 'h')
                " else
                "     call add(marker, 'u')
            endif
        else
            call add(marker, ' ')
        endif
    endif
    call insert(marker, '|')
    call add(marker, '|')
    return printf("%-". eval(g:tlib_inputlist_width_filename) ."s %s %s", fname, join(marker, ''), dname)
endf


" :nodoc:
function! s:prototype.GetSelectedItems(current) dict "{{{3
    if stridx(self.type, 'i') != -1
        let rv = copy(self.sel_idx)
    else
        let rv = map(copy(self.sel_idx), 'self.GetBaseItem(v:val)')
    endif
    if a:current != ''
        let ci = index(rv, a:current)
        if ci != -1
            call remove(rv, ci)
        endif
        call insert(rv, a:current)
    endif
    " TAssert empty(rv) || rv[0] == a:current
    if stridx(self.type, 'i') != -1
        if !empty(self.index_table)
            " TLogVAR rv, self.index_table
            call map(rv, 'self.index_table[v:val - 1]')
            " TLogVAR rv
        endif
    endif
    return rv
endf


" :nodoc:
function! s:prototype.SelectItem(mode, index) dict "{{{3
    let bi = self.GetBaseIdx(a:index)
    " if self.RespondTo('MaySelectItem')
    "     if !self.MaySelectItem(bi)
    "         return 0
    "     endif
    " endif
    " TLogVAR bi
    let si = index(self.sel_idx, bi)
    " TLogVAR self.sel_idx
    " TLogVAR si
    if si == -1
        call add(self.sel_idx, bi)
    elseif a:mode == 'toggle'
        call remove(self.sel_idx, si)
    endif
    return 1
endf


" :nodoc:
function! s:prototype.FormatArgs(format_string, arg) dict "{{{3
    let nargs = len(substitute(a:format_string, '%%\|[^%]', '', 'g'))
    return [a:format_string] + repeat([string(a:arg)], nargs)
endf


" :nodoc:
function! s:prototype.GetRx(filter) dict "{{{3
    return '\('. join(filter(copy(a:filter), 'v:val[0] != "!"'), '\|') .'\)' 
endf


" :nodoc:
function! s:prototype.GetRx0(...) dict "{{{3
    exec tlib#arg#Let(['negative'])
    let rx0 = []
    for filter in self.filter
        " TLogVAR filter
        let rx = join(reverse(filter(copy(filter), '!empty(v:val)')), '\|')
        " TLogVAR rx
        if !empty(rx) && (negative ? rx[0] == g:tlib_inputlist_not : rx[0] != g:tlib_inputlist_not)
            call add(rx0, rx)
        endif
    endfor
    let rx0s = join(rx0, '\|')
    if empty(rx0s)
        return ''
    else
        return self.FilterRxPrefix() .'\('. rx0s .'\)'
    endif
endf


" :nodoc:
function! s:prototype.FormatName(format, value) dict "{{{3
    let world = self
    return eval(call(function("printf"), self.FormatArgs(a:format, a:value)))
endf


" :nodoc:
function! s:prototype.GetItem(idx) dict "{{{3
    return self.list[a:idx - 1]
endf


" :nodoc:
function! s:prototype.GetListIdx(baseidx) dict "{{{3
    " if empty(self.index_table)
        let baseidx = a:baseidx
    " else
    "     let baseidx = 0 + self.index_table[a:baseidx - 1]
    "     " TLogVAR a:baseidx, baseidx, self.index_table 
    " endif
    let rv = index(self.table, baseidx)
    " TLogVAR rv, self.table
    return rv
endf


" :nodoc:
" The first index is 1.
function! s:prototype.GetBaseIdx(idx) dict "{{{3
    " TLogVAR a:idx, self.table, self.index_table
    if !empty(self.table) && a:idx > 0 && a:idx <= len(self.table)
        return self.table[a:idx - 1]
    else
        return 0
    endif
endf


" :nodoc:
function! s:prototype.GetBaseIdx0(idx) dict "{{{3
    return self.GetBaseIdx(a:idx) - 1
endf


" :nodoc:
function! s:prototype.GetBaseItem(idx) dict "{{{3
    return self.base[a:idx - 1]
endf


" :nodoc:
function! s:prototype.SetBaseItem(idx, item) dict "{{{3
    let self.base[a:idx - 1] = a:item
endf


" :nodoc:
function! s:prototype.SetPrefIdx() dict "{{{3
    " let pref = sort(range(1, self.llen), 'self.SortPrefs')
    " let self.prefidx = get(pref, 0, self.initial_index)
    let pref_idx = -1
    let pref_weight = -1
    " TLogVAR self.filter_pos, self.filter_neg
    for idx in range(1, self.llen)
        let item = self.GetItem(idx)
        let weight = self.matcher.AssessName(self, item)
        " TLogVAR item, weight
        if weight > pref_weight
            let pref_idx = idx
            let pref_weight = weight
        endif
    endfor
    " TLogVAR pref_idx
    " TLogDBG self.GetItem(pref_idx)
    if pref_idx == -1
        let self.prefidx = self.initial_index
    else
        let self.prefidx = pref_idx
    endif
endf


" " :nodoc:
" function! s:prototype.GetCurrentItem() dict "{{{3
"     let idx = self.prefidx
"     " TLogVAR idx
"     if stridx(self.type, 'i') != -1
"         return idx
"     elseif !empty(self.list)
"         if len(self.list) >= idx
"             let idx1 = idx - 1
"             let rv = self.list[idx - 1]
"             " TLogVAR idx, idx1, rv, self.list
"             return rv
"         endif
"     else
"         return ''
"     endif
" endf


" :nodoc:
function! s:prototype.CurrentItem() dict "{{{3
    if stridx(self.type, 'i') != -1
        return self.GetBaseIdx(self.llen == 1 ? 1 : self.prefidx)
    else
        if self.llen == 1
            " TLogVAR self.llen
            return self.list[0]
        elseif self.prefidx > 0
            " TLogVAR self.prefidx
            " return self.GetCurrentItem()
            if len(self.list) >= self.prefidx
                let rv = self.list[self.prefidx - 1]
                " TLogVAR idx, rv, self.list
                return rv
            endif
        else
            return ''
        endif
    endif
endf


" :nodoc:
function! s:prototype.FilterRxPrefix() dict "{{{3
    return self.matcher.FilterRxPrefix()
endf


" :nodoc:
function! s:prototype.SetFilter() dict "{{{3
    " let mrx = '\V'. (a:0 >= 1 && a:1 ? '\C' : '')
    let mrx = self.FilterRxPrefix() . self.filter_options
    let self.filter_pos = []
    let self.filter_neg = []
    " TLogVAR self.filter
    for filter in self.filter
        " TLogVAR filter
        let rx = join(reverse(filter(copy(filter), '!empty(v:val)')), '\|')
        if rx =~ '\u'
            let mrx1 = mrx .'\C'
        else
            let mrx1 = mrx
        endif
        " TLogVAR rx
        if rx[0] == g:tlib_inputlist_not
            if len(rx) > 1
                call add(self.filter_neg, mrx1 .'\('. rx[1:-1] .'\)')
            endif
        else
            call add(self.filter_pos, mrx1 .'\('. rx .'\)')
        endif
    endfor
    " TLogVAR self.filter_pos, self.filter_neg
endf


" :nodoc:
function! s:prototype.IsValidFilter() dict "{{{3
    let last = self.FilterRxPrefix() .'\('. self.filter[0][0] .'\)'
    " TLogVAR last
    try
        let a = match("", last)
        return 1
    catch
        return 0
    endtry
endf


" :nodoc:
function! s:prototype.SetMatchMode(match_mode) dict "{{{3
    " TLogVAR a:match_mode
    if !empty(a:match_mode)
        unlet self.matcher
        try
            let self.matcher = tlib#Filter_{a:match_mode}#New()
        catch /^Vim\%((\a\+)\)\=:E117/
            throw 'tlib: Unknown mode for tlib_inputlist_match: '. a:match_mode
        endtry
    endif
endf


" function! s:prototype.Match(text) dict "{{{3
"     return self.matcher.Match(self, text)
" endf


" :nodoc:
function! s:prototype.MatchBaseIdx(idx) dict "{{{3
    let text = self.GetBaseItem(a:idx)
    if !empty(self.filter_format)
        let text = self.FormatName(self.filter_format, text)
    endif
    " TLogVAR text
    " return self.Match(text)
    return self.matcher.Match(self, text)
endf


" :nodoc:
function! s:prototype.BuildTable() dict "{{{3
    call self.SetFilter()
    " TLogVAR self.filter_neg, self.filter_pos
    let self.table = filter(range(1, len(self.base)), 'self.MatchBaseIdx(v:val)')
endf


" :nodoc:
function! s:prototype.ReduceFilter() dict "{{{3
    " TLogVAR self.filter
    if self.filter[0] == [''] && len(self.filter) > 1
        call remove(self.filter, 0)
    elseif empty(self.filter[0][0]) && len(self.filter[0]) > 1
        call remove(self.filter[0], 0)
    else
        call self.matcher.ReduceFrontFilter(self)
    endif
endf


" :nodoc:
" filter is either a string or a list of list of strings.
function! s:prototype.SetInitialFilter(filter) dict "{{{3
    " let self.initial_filter = [[''], [a:filter]]
    if type(a:filter) == 3
        let self.initial_filter = copy(a:filter)
    else
        let self.initial_filter = [[a:filter]]
    endif
endf


" :nodoc:
function! s:prototype.PopFilter() dict "{{{3
    " TLogVAR self.filter
    if len(self.filter[0]) > 1
        call remove(self.filter[0], 0)
    elseif len(self.filter) > 1
        call remove(self.filter, 0)
    else
        let self.filter[0] = ['']
    endif
endf


" :nodoc:
function! s:prototype.FilterIsEmpty() dict "{{{3
    " TLogVAR self.filter
    return self.filter == copy(self.initial_filter)
endf


" :nodoc:
function! s:prototype.DisplayFilter() dict "{{{3
    let filter1 = copy(self.filter)
    call filter(filter1, 'v:val != [""]')
    " TLogVAR self.matcher['_class']
    let rv = self.matcher.DisplayFilter(filter1)
    let rv = self.CleanFilter(rv)
    return rv
endf


" :nodoc:
function! s:prototype.SetFrontFilter(pattern) dict "{{{3
    call self.matcher.SetFrontFilter(self, a:pattern)
endf


" :nodoc:
function! s:prototype.PushFrontFilter(char) dict "{{{3
    call self.matcher.PushFrontFilter(self, a:char)
endf


" :nodoc:
function! s:prototype.CleanFilter(filter) dict "{{{3
    return self.matcher.CleanFilter(a:filter)
endf


" :nodoc:
function! s:prototype.UseScratch() dict "{{{3
    return tlib#scratch#UseScratch(self)
endf


" :nodoc:
function! s:prototype.CloseScratch(...) dict "{{{3
    TVarArg ['reset_scratch', 0]
    " TVarArg ['reset_scratch', 1]
    " TLogVAR reset_scratch
    if self.sticky
        return 0
    else
        let rv = tlib#scratch#CloseScratch(self, reset_scratch)
        if rv
            call self.SwitchWindow('win')
        endif
        return rv
    endif
endf


" :nodoc:
function! s:prototype.UseInputListScratch() dict "{{{3
    let scratch = self.UseScratch()
    " TLogVAR scratch
    syntax match InputlListIndex /^\d\+:/
    syntax match InputlListCursor /^\d\+\* .*$/ contains=InputlListIndex
    syntax match InputlListSelected /^\d\+# .*$/ contains=InputlListIndex
    hi def link InputlListIndex Constant
    hi def link InputlListCursor Search
    hi def link InputlListSelected IncSearch
    " exec "au BufEnter <buffer> call tlib#input#Resume(". string(self.name) .")"
    setlocal nowrap
    " hi def link InputlListIndex Special
    " let b:tlibDisplayListMarks = {}
    let b:tlibDisplayListMarks = []
    call tlib#hook#Run('tlib_UseInputListScratch', self)
    return scratch
endf


" :def: function! s:prototype.Reset(?initial=0)
" :nodoc:
function! s:prototype.Reset(...) dict "{{{3
    TVarArg ['initial', 0]
    " TLogVAR initial
    let self.state     = 'display'
    let self.offset    = 1
    let self.filter    = deepcopy(self.initial_filter)
    let self.idx       = ''
    let self.prefidx   = 0
    let self.initial_display = 1
    call self.UseInputListScratch()
    call self.ResetSelected()
    call self.Retrieve(!initial)
    return self
endf


" :nodoc:
function! s:prototype.ResetSelected() dict "{{{3
    let self.sel_idx   = []
endf


" :nodoc:
function! s:prototype.Retrieve(anyway) dict "{{{3
    " TLogVAR a:anyway, self.base
    " TLogDBG (a:anyway || empty(self.base))
    if (a:anyway || empty(self.base))
        let ra = self.retrieve_eval
        " TLogVAR ra
        if !empty(ra)
            let back  = self.SwitchWindow('win')
            let world = self
            let self.base = eval(ra)
            " TLogVAR self.base
            exec back
            return 1
        endif
    endif
    return 0
endf


" :nodoc:
function! s:prototype.DisplayHelp() dict "{{{3
    " \ 'Help:',
    let help = [
                \ 'Mouse        ... Pick an item            Letter          ... Filter the list',
                \ printf('Number       ... Pick an item            "%s", "%s", %sWORD ... AND, OR, NOT',
                \   g:tlib_inputlist_and, g:tlib_inputlist_or, g:tlib_inputlist_not),
                \ 'Enter        ... Pick the current item   <bs>, <c-bs>    ... Reduce filter',
                \ '<c|m-r>      ... Reset the display       Up/Down         ... Next/previous item',
                \ '<c|m-q>      ... Edit top filter string  Page Up/Down    ... Scroll',
                \ '<Esc>        ... Abort',
                \ ]

    if self.allow_suspend
        call add(help,
                \ '<c|m-z>      ... Suspend/Resume          <c-o>           ... Switch to origin')
    endif

    if stridx(self.type, 'm') != -1
        let help += [
                \ '#, <c-space> ... (Un)Select the current item',
                \ '<c|m-a>      ... (Un)Select all currently visible items',
                \ '<s-up/down>  ... (Un)Select items',
                \ ]
                    " \ '<c-\>        ... Show only selected',
    endif
    for handler in self.key_handlers
        let key = get(handler, 'key_name', '')
        if !empty(key)
            let desc = get(handler, 'help', '')
            call add(help, printf('%-12s ... %s', key, desc))
        endif
    endfor
    let help += [
                \ '',
                \ 'Exact matches and matches at word boundaries is given more weight.',
                \ 'Warning: Please don''t resize the window with the mouse.',
                \ '',
                \ 'Press any key to continue.',
                \ ]
    " call tlib#normal#WithRegister('gg"tdG', 't')
    call tlib#buffer#DeleteRange('1', '$')
    call append(0, help)
    " call tlib#normal#WithRegister('G"tddgg', 't')
    call tlib#buffer#DeleteRange('$', '$')
    1
    call self.Resize(len(help), 0)
endf


" :nodoc:
function! s:prototype.Resize(hsize, vsize) dict "{{{3
    " TLogVAR self.scratch_vertical, a:hsize, a:vsize
    if self.scratch_vertical
        if a:vsize
            exec 'vert resize '. eval(a:vsize)
        endif
    else
        if a:hsize
            exec 'resize '. eval(a:hsize)
        endif
    endif
endf


" :def: function! s:prototype.DisplayList(query, ?list)
" :nodoc:
function! s:prototype.DisplayList(query, ...) dict "{{{3
    " TLogVAR a:query
    " TLogVAR self.state
    let list = a:0 >= 1 ? a:1 : []
    " TLogDBG 'len(list) = '. len(list)
    call self.UseScratch()
    " TLogVAR self.scratch
    " TAssert IsNotEmpty(self.scratch)
    if self.state == 'scroll'
        exec 'norm! '. self.offset .'zt'
    elseif self.state == 'help'
        call self.DisplayHelp()
    else
        " let ll = len(list)
        let ll = self.llen
        " let x  = len(ll) + 1
        let x  = self.index_width + 1
        " TLogVAR ll
        if self.state =~ '\<display\>'
            let resize = get(self, 'resize', 0)
            " TLogVAR resize
            let resize = resize == 0 ? ll : min([ll, resize])
            let resize = min([resize, (&lines * g:tlib_inputlist_pct / 100)])
            " TLogVAR resize, ll, &lines
            call self.Resize(resize, get(self, 'resize_vertical', 0))
            call tlib#normal#WithRegister('gg"tdG', 't')
            let w = winwidth(0) - &fdc
            " let w = winwidth(0) - &fdc - 1
            let lines = copy(list)
            let lines = map(lines, 'printf("%-'. w .'.'. w .'s", substitute(v:val, ''[[:cntrl:][:space:]]'', " ", "g"))')
            " TLogVAR lines
            call append(0, lines)
            call tlib#normal#WithRegister('G"tddgg', 't')
        endif
        " TLogVAR self.prefidx
        let base_pref = self.GetBaseIdx(self.prefidx)
        " TLogVAR base_pref
        if self.state =~ '\<redisplay\>'
            call filter(b:tlibDisplayListMarks, 'index(self.sel_idx, v:val) == -1 && v:val != base_pref')
            " TLogVAR b:tlibDisplayListMarks
            call map(b:tlibDisplayListMarks, 'self.DisplayListMark(x, v:val, ":")')
            " let b:tlibDisplayListMarks = map(copy(self.sel_idx), 'self.DisplayListMark(x, v:val, "#")')
            " call add(b:tlibDisplayListMarks, self.prefidx)
            " call self.DisplayListMark(x, self.GetBaseIdx(self.prefidx), '*')
        endif
        let b:tlibDisplayListMarks = map(copy(self.sel_idx), 'self.DisplayListMark(x, v:val, "#")')
        call add(b:tlibDisplayListMarks, base_pref)
        call self.DisplayListMark(x, base_pref, '*')
        call self.SetOffset()
        " TLogVAR self.offset
        " TLogDBG winheight('.')
        " if self.prefidx > winheight(0)
            " let lt = len(list) - winheight('.') + 1
            " if self.offset > lt
            "     exec 'norm! '. lt .'zt'
            " else
                exec 'norm! '. self.offset .'zt'
            " endif
        " else
        "     norm! 1zt
        " endif
        let rx0 = self.GetRx0()
        " TLogVAR rx0
        if !empty(g:tlib_inputlist_higroup)
            if empty(rx0)
                match none
            elseif self.IsValidFilter()
                exec 'match '. g:tlib_inputlist_higroup .' /\c'. escape(rx0, '/') .'/'
            endif
        endif
        let query   = a:query
        let options = [self.matcher.name]
        if self.sticky
            call add(options, '#')
        endif
        if !empty(options)
            let query .= printf('%%=[%s] ', join(options, ', '))
        endif
        " TLogVAR query
        let &statusline = query
    endif
    redraw
endf


" :nodoc:
function! s:prototype.SetOffset() dict "{{{3
    " TLogVAR self.prefidx, self.offset
    " TLogDBG winheight(0)
    " TLogDBG self.prefidx > self.offset + winheight(0) - 1
    let listtop = len(self.list) - winheight(0) + 1
    if listtop < 1
        let listtop = 1
    endif
    if self.prefidx > listtop
        let self.offset = listtop
    elseif self.prefidx > self.offset + winheight(0) - 1
        let listoff = self.prefidx - winheight(0) + 1
        let self.offset = min([listtop, listoff])
    "     TLogVAR self.prefidx
    "     TLogDBG len(self.list)
    "     TLogDBG winheight(0)
    "     TLogVAR listtop, listoff, self.offset
    elseif self.prefidx < self.offset
        let self.offset = self.prefidx
    endif
    " TLogVAR self.offset
endf


" :nodoc:
function! s:prototype.ClearAllMarks() dict "{{{3
    let x = self.index_width + 1
    call map(range(1, line('$')), 'self.DisplayListMark(x, v:val, ":")')
endf


" :nodoc:
function! s:prototype.MarkCurrent(y) dict "{{{3
    let x = self.index_width + 1
    call self.DisplayListMark(x, a:y, '*')
endf


" :nodoc:
function! s:prototype.DisplayListMark(x, y, mark) dict "{{{3
    " TLogVAR a:y, a:mark
    if a:x > 0 && a:y >= 0
        " TLogDBG a:x .'x'. a:y .' '. a:mark
        let sy = self.GetListIdx(a:y) + 1
        " TLogVAR sy
        if sy >= 1
            call setpos('.', [0, sy, a:x, 0])
            exec 'norm! r'. a:mark
            " exec 'norm! '. a:y .'gg'. a:x .'|r'. a:mark
        endif
    endif
    return a:y
endf


" :nodoc:
function! s:prototype.SwitchWindow(where) dict "{{{3
    " TLogDBG string(tlib#win#List())
    let wnr = get(self, a:where.'_wnr')
    " TLogVAR self, wnr
    return tlib#win#Set(wnr)
endf


" :nodoc:
function! s:prototype.FollowCursor() dict "{{{3
    if !empty(self.follow_cursor)
        let back = self.SwitchWindow('win')
        " TLogVAR back
        " TLogDBG winnr()
        try
            call call(self.follow_cursor, [self, [self.CurrentItem()]])
        finally
            exec back
        endtry
    endif
endf


" :nodoc:
function! s:prototype.SetOrigin(...) dict "{{{3
    TVarArg ['winview', 0]
    " TLogVAR self.win_wnr, self.bufnr
    " TLogDBG bufname('%')
    " TLogDBG winnr()
    " TLogDBG winnr('$')
    let self.win_wnr = winnr()
    let self.bufnr   = bufnr('%')
    let self.cursor  = getpos('.')
    if winview
        let self.winview = tlib#win#GetLayout()
    endif
    " TLogVAR self.win_wnr, self.bufnr, self.winview
    return self
endf


" :nodoc:
function! s:prototype.RestoreOrigin(...) dict "{{{3
    TVarArg ['winview', 0]
    if winview
        " TLogVAR winview
        call tlib#win#SetLayout(self.winview)
    endif
    " TLogVAR self.win_wnr, self.bufnr, self.cursor, &splitbelow
    " TLogDBG "RestoreOrigin0 ". string(tlib#win#List())
    " If &splitbelow or &splitright is false, we cannot rely on 
    " self.win_wnr to be our source buffer since, e.g, opening a buffer 
    " in a split window changes the whole layout.
    " Possible solutions:
    " - Restrict buffer switching to cases when the number of windows 
    "   hasn't changed.
    " - Guess the right window, which we try to do here.
    if &splitbelow == 0 || &splitright == 0
        let wn = bufwinnr(self.bufnr)
        " TLogVAR wn
        if wn == -1
            let wn = 1
        end
    else
        let wn = self.win_wnr
    endif
    if wn != winnr()
        exec wn .'wincmd w'
    endif
    exec 'buffer! '. self.bufnr
    call setpos('.', self.cursor)
    " TLogDBG "RestoreOrigin1 ". string(tlib#win#List())
endf

autoload/tlib/agent.vim	[[[1
490
" agent.vim
" @Author:      Tom Link (micathom AT gmail com?subject=[vim])
" @Website:     http://www.vim.org/account/profile.php?user_id=4037
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Created:     2007-06-24.
" @Last Change: 2009-02-25.
" @Revision:    0.1.168

if &cp || exists("loaded_tlib_agent_autoload") "{{{2
    finish
endif
let loaded_tlib_agent_autoload = 1

" :filedoc:
" Various agents for use as key handlers in tlib#input#List()

" General {{{1

function! tlib#agent#Exit(world, selected) "{{{3
    call a:world.CloseScratch()
    let a:world.state = 'exit escape'
    let a:world.list = []
    " let a:world.base = []
    call a:world.ResetSelected()
    return a:world
endf


function! tlib#agent#CopyItems(world, selected) "{{{3
    let @* = join(a:selected, "\n")
    let a:world.state = 'redisplay'
    return a:world
endf



" InputList related {{{1

function! tlib#agent#PageUp(world, selected) "{{{3
    let a:world.offset -= (winheight(0) / 2)
    let a:world.state = 'scroll'
    return a:world
endf


function! tlib#agent#PageDown(world, selected) "{{{3
    let a:world.offset += (winheight(0) / 2)
    let a:world.state = 'scroll'
    return a:world
endf


function! tlib#agent#Up(world, selected, ...) "{{{3
    TVarArg ['lines', 1]
    let a:world.idx = ''
    if a:world.prefidx > lines
        let a:world.prefidx -= lines
    else
        let a:world.prefidx = len(a:world.list)
    endif
    let a:world.state = 'redisplay'
    return a:world
endf


function! tlib#agent#Down(world, selected, ...) "{{{3
    TVarArg ['lines', 1]
    let a:world.idx = ''
    if a:world.prefidx <= (len(a:world.list) - lines)
        let a:world.prefidx += lines
    else
        let a:world.prefidx = 1
    endif
    let a:world.state = 'redisplay'
    return a:world
endf


function! tlib#agent#UpN(world, selected) "{{{3
    return tlib#agent#Up(a:world, a:selected, g:tlib_scroll_lines)
endf


function! tlib#agent#DownN(world, selected) "{{{3
    return tlib#agent#Down(a:world, a:selected, g:tlib_scroll_lines)
endf


function! tlib#agent#ShiftLeft(world, selected) "{{{3
    let a:world.offset_horizontal -= (winwidth(0) / 2)
    if a:world.offset_horizontal < 0
        let a:world.offset_horizontal = 0
    endif
    let a:world.state = 'display shift'
    return a:world
endf


function! tlib#agent#ShiftRight(world, selected) "{{{3
    let a:world.offset_horizontal += (winwidth(0) / 2)
    let a:world.state = 'display shift'
    return a:world
endf


function! tlib#agent#Reset(world, selected) "{{{3
    let a:world.state = 'reset'
    return a:world
endf


function! tlib#agent#Input(world, selected) "{{{3
    let flt0 = a:world.CleanFilter(a:world.filter[0][0])
    let flt1 = input('Filter: ', flt0)
    echo
    if flt1 != flt0
        if empty(flt1)
            call getchar(0)
        else
            call a:world.SetFrontFilter(flt1)
        endif
    endif
    let a:world.state = 'display'
    return a:world
endf


" Suspend (see |tlib#agent#Suspend|) the input loop and jump back to the 
" original position in the parent window.
function! tlib#agent#SuspendToParentWindow(world, selected) "{{{3
    let world = a:world
    let winnr = world.win_wnr
    " TLogVAR winnr
    if winnr != -1
        let world = tlib#agent#Suspend(world, a:selected)
        if world.state =~ '\<suspend\>'
            call world.SwitchWindow('win')
            " let pos = world.cursor
            " " TLogVAR pos
            " if !empty(pos)
            "     call setpos('.', pos)
            " endif
            return world
        endif
    endif
    let world.state = 'redisplay'
    return world
endf


" Suspend lets you temporarily leave the input loop of 
" |tlib#input#List|. You can resume editing the list by pressing <c-z>, 
" <m-z>. <space>, <c-LeftMouse> or <MiddleMouse> in the suspended window.
" <cr> and <LeftMouse> will immediatly select the item under the cursor.
" < will select the item but the window will remain opened.
function! tlib#agent#Suspend(world, selected) "{{{3
    if a:world.allow_suspend
        " TAssert IsNotEmpty(a:world.scratch)
        " TLogDBG bufnr('%')
        let br = tlib#buffer#Set(a:world.scratch)
        " TLogVAR br, a:world.bufnr, a:world.scratch
        " TLogDBG bufnr('%')
        let b:tlib_suspend = {
                    \ '<m-z>': 0, '<c-z>': 0, '<space>': 0, 
                    \ '<cr>': 1, 
                    \ '<LeftMouse>': 1, '<c-LeftMouse>': 0, '<MiddleMouse>': 0,
                    \ '<': 2}
        for [m, pick] in items(b:tlib_suspend)
            exec 'noremap <buffer> '. m .' :call tlib#input#Resume("world", '. pick .')<cr>'
        endfor
        let b:tlib_world = a:world
        exec br
        let a:world.state = 'exit suspend'
    else
        echom 'Suspend disabled'
        let a:world.state = 'redisplay'
    endif
    return a:world
endf


function! tlib#agent#Help(world, selected) "{{{3
    let a:world.state = 'help'
    return a:world
endf


function! tlib#agent#OR(world, selected) "{{{3
    if !empty(a:world.filter[0])
        call insert(a:world.filter[0], '')
    endif
    let a:world.state = 'display'
    return a:world
endf


function! tlib#agent#AND(world, selected) "{{{3
    if !empty(a:world.filter[0])
        call insert(a:world.filter, [''])
    endif
    let a:world.state = 'display'
    return a:world
endf


function! tlib#agent#ReduceFilter(world, selected) "{{{3
    call a:world.ReduceFilter()
    let a:world.offset = 1
    let a:world.state = 'display'
    return a:world
endf


function! tlib#agent#PopFilter(world, selected) "{{{3
    call a:world.PopFilter()
    let a:world.offset = 1
    let a:world.state = 'display'
    return a:world
endf


function! tlib#agent#Debug(world, selected) "{{{3
    " echo string(world.state)
    echo string(a:world.filter)
    echo string(a:world.idx)
    echo string(a:world.prefidx)
    echo string(a:world.sel_idx)
    call getchar()
    let a:world.state = 'display'
    return a:world
endf


function! tlib#agent#Select(world, selected) "{{{3
    call a:world.SelectItem('toggle', a:world.prefidx)
    " let a:world.state = 'display keepcursor'
    let a:world.state = 'redisplay'
    return a:world
endf


function! tlib#agent#SelectUp(world, selected) "{{{3
    call a:world.SelectItem('toggle', a:world.prefidx)
    if a:world.prefidx > 1
        let a:world.prefidx -= 1
    endif
    let a:world.state = 'redisplay'
    return a:world
endf


function! tlib#agent#SelectDown(world, selected) "{{{3
    call a:world.SelectItem('toggle', a:world.prefidx)
    if a:world.prefidx < len(a:world.list)
        let a:world.prefidx += 1
    endif
    let a:world.state = 'redisplay'
    return a:world
endf


function! tlib#agent#SelectAll(world, selected) "{{{3
    let listrange = range(1, len(a:world.list))
    let mode = empty(filter(copy(listrange), 'index(a:world.sel_idx, a:world.GetBaseIdx(v:val)) == -1'))
                \ ? 'toggle' : 'set'
    for i in listrange
        call a:world.SelectItem(mode, i)
    endfor
    let a:world.state = 'display keepcursor'
    return a:world
endf


function! tlib#agent#ToggleStickyList(world, selected) "{{{3
    let a:world.sticky = !a:world.sticky
    let a:world.state = 'display keepcursor'
    return a:world
endf



" EditList related {{{1

function! tlib#agent#EditItem(world, selected) "{{{3
    let lidx = a:world.prefidx
    " TLogVAR lidx
    " TLogVAR a:world.table
    let bidx = a:world.GetBaseIdx(lidx)
    " TLogVAR bidx
    let item = a:world.GetBaseItem(bidx)
    let item = input(lidx .'@'. bidx .': ', item)
    if item != ''
        call a:world.SetBaseItem(bidx, item)
    endif
    let a:world.state = 'display'
    return a:world
endf


" Insert a new item below the current one.
function! tlib#agent#NewItem(world, selected) "{{{3
    let basepi = a:world.GetBaseIdx(a:world.prefidx)
    let item = input('New item: ')
    call insert(a:world.base, item, basepi)
    let a:world.state = 'reset'
    return a:world
endf


function! tlib#agent#DeleteItems(world, selected) "{{{3
    let remove = copy(a:world.sel_idx)
    let basepi = a:world.GetBaseIdx(a:world.prefidx)
    if index(remove, basepi) == -1
        call add(remove, basepi)
    endif
    " call map(remove, 'a:world.GetBaseIdx(v:val)')
    for idx in reverse(sort(remove))
        call remove(a:world.base, idx - 1)
    endfor
    let a:world.state = 'display'
    call a:world.ResetSelected()
    " let a:world.state = 'reset'
    return a:world
endf


function! tlib#agent#Cut(world, selected) "{{{3
    let world = tlib#agent#Copy(a:world, a:selected)
    return tlib#agent#DeleteItems(world, a:selected)
endf


function! tlib#agent#Copy(world, selected) "{{{3
    let a:world.clipboard = []
    let bidxs = copy(a:world.sel_idx)
    call add(bidxs, a:world.GetBaseIdx(a:world.prefidx))
    for bidx in sort(bidxs)
        call add(a:world.clipboard, a:world.GetBaseItem(bidx))
    endfor
    let a:world.state = 'redisplay'
    return a:world
endf


function! tlib#agent#Paste(world, selected) "{{{3
    if has_key(a:world, 'clipboard')
        for e in reverse(copy(a:world.clipboard))
            call insert(a:world.base, e, a:world.prefidx)
        endfor
    endif
    let a:world.state = 'display'
    call a:world.ResetSelected()
    return a:world
endf


function! tlib#agent#EditReturnValue(world, rv) "{{{3
    return [a:world.state !~ '\<exit\>', a:world.base]
endf



" Files related {{{1

function! tlib#agent#ViewFile(world, selected) "{{{3
    if !empty(a:selected)
        let back = a:world.SwitchWindow('win')
        " TLogVAR back
        call tlib#file#With('edit', 'buffer', a:selected, a:world)
        exec back
        let a:world.state = 'display'
    endif
    return a:world
endf


function! tlib#agent#EditFile(world, selected) "{{{3
    return tlib#agent#Exit(tlib#agent#ViewFile(a:world, a:selected), a:selected)
endf


function! tlib#agent#EditFileInSplit(world, selected) "{{{3
    call a:world.CloseScratch()
    " call tlib#file#With('edit', 'buffer', a:selected[0:0], a:world)
    " call tlib#file#With('split', 'sbuffer', a:selected[1:-1], a:world)
    call tlib#file#With('split', 'sbuffer', a:selected, a:world)
    return tlib#agent#Exit(a:world, a:selected)
endf


function! tlib#agent#EditFileInVSplit(world, selected) "{{{3
    call a:world.CloseScratch()
    " call tlib#file#With('edit', 'buffer', a:selected[0:0], a:world)
    " call tlib#file#With('vertical split', 'vertical sbuffer', a:selected[1:-1], a:world)
    call tlib#file#With('vertical split', 'vertical sbuffer', a:selected, a:world)
    return tlib#agent#Exit(a:world, a:selected)
endf


function! tlib#agent#EditFileInTab(world, selected) "{{{3
    call a:world.CloseScratch()
    call tlib#file#With('tabedit', 'tab sbuffer', a:selected, a:world)
    return tlib#agent#Exit(a:world, a:selected)
endf


function! tlib#agent#ToggleScrollbind(world, selected) "{{{3
    let a:world.scrollbind = get(a:world, 'scrollbind') ? 0 : 1
    let a:world.state = 'redisplay'
    return a:world
endf

function! tlib#agent#ShowInfo(world, selected)
    for f in a:selected
        if filereadable(f)
            let desc = [getfperm(f), strftime('%c', getftime(f)),  getfsize(f) .' bytes', getftype(f)]
            echo fnamemodify(f, ':t') .':'
            echo '  '. join(desc, '; ')
        endif
    endfor
    echohl MoreMsg
    echo 'Press any key to continue'
    echohl NONE
    call getchar()
    let a:world.state = 'redisplay'
    return a:world
endf



" Buffer related {{{1

function! tlib#agent#PreviewLine(world, selected) "{{{3
    let l = a:selected[0]
    let ww = winnr()
    exec a:world.win_wnr .'wincmd w'
    call tlib#buffer#ViewLine(l, 1)
    exec ww .'wincmd w'
    let a:world.state = 'redisplay'
    return a:world
endf


" If not called from the scratch, we assume/guess that we don't have to 
" suspend the input-evaluation loop.
function! tlib#agent#GotoLine(world, selected) "{{{3
    if !empty(a:selected)

        " let l = a:selected[0]
        " " TLogVAR l
        " let back = a:world.SwitchWindow('win')
        " " TLogVAR back
        " " if a:world.win_wnr != winnr()
        " "     let world = tlib#agent#Suspend(a:world, a:selected)
        " "     exec a:world.win_wnr .'wincmd w'
        " " endif
        " call tlib#buffer#ViewLine(l)
        " exec back
        " let a:world.state = 'display'

        let l = a:selected[0]
        if a:world.win_wnr != winnr()
            let world = tlib#agent#Suspend(a:world, a:selected)
            exec a:world.win_wnr .'wincmd w'
        endif
        call tlib#buffer#ViewLine(l, 1)
        
    endif
    return a:world
endf


function! tlib#agent#DoAtLine(world, selected) "{{{3
    if !empty(a:selected)
        let cmd = input('Command: ', '', 'command')
        if !empty(cmd)
            call a:world.SwitchWindow('win')
            let pos = getpos('.')
            for l in a:selected
                call tlib#buffer#ViewLine(l, '')
                exec cmd
            endfor
            call setpos('.', pos)
        endif
    endif
    call a:world.ResetSelected()
    let a:world.state = 'exit'
    return a:world
endf

autoload/tlib/arg.vim	[[[1
102
" arg.vim
" @Author:      Tom Link (micathom AT gmail com?subject=[vim])
" @Website:     http://www.vim.org/account/profile.php?user_id=4037
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Created:     2007-06-30.
" @Last Change: 2009-02-15.
" @Revision:    0.0.50

if &cp || exists("loaded_tlib_arg_autoload")
    finish
endif
let loaded_tlib_arg_autoload = 1


" :def: function! tlib#arg#Get(n, var, ?default="", ?test='')
" Set a positional argument from a variable argument list.
" See tlib#string#RemoveBackslashes() for an example.
function! tlib#arg#Get(n, var, ...) "{{{3
    let default = a:0 >= 1 ? a:1 : ''
    let atest   = a:0 >= 2 ? a:2 : ''
    " TLogVAR default, atest
    if !empty(atest)
        let atest = ' && (a:'. a:n .' '. atest .')'
    endif
    let test = printf('a:0 >= %d', a:n) . atest
    return printf('let %s = %s ? a:%d : %s', a:var, test, a:n, string(default))
endf


" :def: function! tlib#arg#Let(list, ?default='')
" Set a positional arguments from a variable argument list.
" See tlib#input#List() for an example.
function! tlib#arg#Let(list, ...) "{{{3
    let default = a:0 >= 1 ? a:1 : ''
    let list = map(copy(a:list), 'type(v:val) == 3 ? v:val : [v:val, default]')
    let args = map(range(1, len(list)), 'call("tlib#arg#Get", [v:val] + list[v:val - 1])')
    return join(args, ' | ')
endf


" :def: function! tlib#arg#Key(dict, list, ?default='')
" See |:TKeyArg|.
function! tlib#arg#Key(list, ...) "{{{3
    let default = a:0 >= 1 ? a:1 : ''
    let dict = a:list[0]
    let list = map(copy(a:list[1:-1]), 'type(v:val) == 3 ? v:val : [v:val, default]')
    let args = map(list, '"let ". v:val[0] ." = ". string(get(dict, v:val[0], v:val[1]))')
    " TLogVAR dict, list, args
    return join(args, ' | ')
endf


" :def: function! tlib#arg#StringAsKeyArgs(string, ?keys=[], ?evaluate=0)
function! tlib#arg#StringAsKeyArgs(string, ...) "{{{1
    TVarArg ['keys', {}], ['evaluate', 0]
    let keyargs = {}
    let args = split(a:string, '\\\@<! ')
    let arglist = map(args, 'matchlist(v:val, ''^\(\w\+\):\(.*\)$'')')
    " TLogVAR a:string, args, arglist
    for matchlist in arglist
        if len(matchlist) < 3
            throw 'Malformed key arguments: '. string(matchlist) .' in '. a:string
        endif
        let [match, key, val; rest] = matchlist
        if empty(keys) || has_key(keys, key)
            let val = substitute(val, '\\\\', '\\', 'g')
            if evaluate
                let val = eval(val)
            endif
            let keyargs[key] = val
        else
            echom 'Unknown key: '. key .'='. val
        endif
    endfor
    return keyargs
endf



""" Command line {{{1

" :def: function! tlib#arg#Ex(arg, ?chars='%#! ')
" Escape some characters in a string.
"
" Use |fnamescape()| if available.
"
" EXAMPLES: >
"   exec 'edit '. tlib#arg#Ex('foo%#bar.txt')
function! tlib#arg#Ex(arg, ...) "{{{3
    if exists('*fnameescape') && a:0 == 0
        return fnameescape(a:arg)
    else
        " let chars = '%# \'
        let chars = '%#! '
        if a:0 >= 1
            let chars .= a:1
        endif
        return escape(a:arg, chars)
    endif
endf


autoload/tlib/autocmdgroup.vim	[[[1
27
" autocmdgroup.vim
" @Author:      Tom Link (mailto:micathom AT gmail com?subject=[vim])
" @Website:     http://www.vim.org/account/profile.php?user_id=4037
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Created:     2008-08-19.
" @Last Change: 2009-02-15.
" @Revision:    0.0.3

if &cp || exists("loaded_tlib_autocmdgroup_autoload")
    finish
endif
let loaded_tlib_autocmdgroup_autoload = 1
let s:save_cpo = &cpo
set cpo&vim


augroup TLib
    autocmd!
augroup END


function! tlib#autocmdgroup#Init() "{{{3
endf


let &cpo = s:save_cpo
unlet s:save_cpo
autoload/tlib/buffer.vim	[[[1
348
" buffer.vim
" @Author:      Tom Link (micathom AT gmail com?subject=[vim])
" @Website:     http://www.vim.org/account/profile.php?user_id=4037
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Created:     2007-06-30.
" @Last Change: 2009-02-15.
" @Revision:    0.0.268

if &cp || exists("loaded_tlib_buffer_autoload")
    finish
endif
let loaded_tlib_buffer_autoload = 1

let s:bmru = []


function! tlib#buffer#EnableMRU() "{{{3
    call tlib#autocmdgroup#Init()
    autocmd TLib BufEnter * call s:BMRU_Push(bufnr('%'))
endf


function! tlib#buffer#DisableMRU() "{{{3
    autocmd! TLib BufEnter
endf


function! s:BMRU_Push(bnr) "{{{3
    let i = index(s:bmru, a:bnr)
    if i >= 0
        call remove(s:bmru, i)
    endif
    call insert(s:bmru, a:bnr)
endf


function! s:CompareBufferNrByMRU(a, b) "{{{3
    let an = matchstr(a:a, '\s*\zs\d\+\ze')
    let bn = matchstr(a:b, '\s*\zs\d\+\ze')
    let ai = index(s:bmru, 0 + an)
    if ai == -1
        return 1
    else
        let bi = index(s:bmru, 0 + bn)
        if bi == -1
            return -1
        else
            return ai == bi ? 0 : ai > bi ? 1 : -1
        endif
    endif
endf


" Set the buffer to buffer and return a command as string that can be 
" evaluated by |:execute| in order to restore the original view.
function! tlib#buffer#Set(buffer) "{{{3
    let lazyredraw = &lazyredraw
    set lazyredraw
    try
        let cb = bufnr('%')
        let sn = bufnr(a:buffer)
        if sn != cb
            let ws = bufwinnr(sn)
            if ws != -1
                let wb = bufwinnr('%')
                exec ws.'wincmd w'
                return wb.'wincmd w'
            else
                silent exec 'sbuffer! '. sn
                return 'wincmd c'
            endif
        else
            return ''
        endif
    finally
        let &lazyredraw = lazyredraw
    endtry
endf


" :def: function! tlib#buffer#Eval(buffer, code)
" Evaluate CODE in BUFFER.
"
" EXAMPLES: >
"   call tlib#buffer#Eval('foo.txt', 'echo b:bar')
function! tlib#buffer#Eval(buffer, code) "{{{3
    " let cb = bufnr('%')
    " let wb = bufwinnr('%')
    " " TLogVAR cb
    " let sn = bufnr(a:buffer)
    " let sb = sn != cb
    let lazyredraw = &lazyredraw
    set lazyredraw
    let restore = tlib#buffer#Set(a:buffer)
    try
        exec a:code
        " if sb
        "     let ws = bufwinnr(sn)
        "     if ws != -1
        "         try
        "             exec ws.'wincmd w'
        "             exec a:code
        "         finally
        "             exec wb.'wincmd w'
        "         endtry
        "     else
        "         try
        "             silent exec 'sbuffer! '. sn
        "             exec a:code
        "         finally
        "             wincmd c
        "         endtry
        "     endif
        " else
        "     exec a:code
        " endif
    finally
        exec restore
        let &lazyredraw = lazyredraw
    endtry
endf


" :def: function! tlib#buffer#GetList(?show_hidden=0, ?show_number=0, " ?order='bufnr')
function! tlib#buffer#GetList(...)
    TVarArg ['show_hidden', 0], ['show_number', 0], ['order', '']
    let ls_bang = show_hidden ? '!' : ''
    redir => bfs
    exec 'silent ls'. ls_bang
    redir END
    let buffer_list = split(bfs, '\n')
    if order == 'mru'
        if empty(s:bmru)
            call tlib#buffer#EnableMRU()
            echom 'tlib: Installed Buffer MRU logger; disable with: call tlib#buffer#DisableMRU()'
        else
            call sort(buffer_list, function('s:CompareBufferNrByMRU'))
        endif
    endif
    let buffer_nr = map(copy(buffer_list), 'matchstr(v:val, ''\s*\zs\d\+\ze'')')
    " TLogVAR buffer_list
    if show_number
        call map(buffer_list, 'matchstr(v:val, ''\s*\d\+.\{-}\ze\s\+line \d\+\s*$'')')
    else
        call map(buffer_list, 'matchstr(v:val, ''\s*\d\+\zs.\{-}\ze\s\+line \d\+\s*$'')')
    endif
    " TLogVAR buffer_list
    " call map(buffer_list, 'matchstr(v:val, ''^.\{-}\ze\s\+line \d\+\s*$'')')
    " TLogVAR buffer_list
    call map(buffer_list, 'matchstr(v:val, ''^[^"]\+''). printf("%-20s   %s", fnamemodify(matchstr(v:val, ''"\zs.\{-}\ze"$''), ":t"), fnamemodify(matchstr(v:val, ''"\zs.\{-}\ze"$''), ":h"))')
    " TLogVAR buffer_list
    return [buffer_nr, buffer_list]
endf


" :def: function! tlib#buffer#ViewLine(line, ?position='z')
" line is either a number or a string that begins with a number.
" For possible values for position see |scroll-cursor|.
" See also |g:tlib_viewline_position|.
function! tlib#buffer#ViewLine(line, ...) "{{{3
    if a:line
        TVarArg 'pos'
        let ln = matchstr(a:line, '^\d\+')
        let lt = matchstr(a:line, '^\d\+: \zs.*')
        " TLogVAR pos, ln, lt
        exec ln
        if empty(pos)
            let pos = tlib#var#Get('tlib_viewline_position', 'wbg')
        endif
        " TLogVAR pos
        if !empty(pos)
            exec 'norm! '. pos
        endif
        call tlib#buffer#HighlightLine(ln)
        " let @/ = '\%'. ln .'l.*'
    endif
endf


function! tlib#buffer#HighlightLine(line) "{{{3
    " exec '3match MatchParen /^\%'. a:line .'l.*/'
    exec '3match Search /^\%'. a:line .'l.*/'
    autocmd TLib CursorHold,CursorHoldI,CursorMoved,CursorMovedI * 3match none
endf


" Delete the lines in the current buffer. Wrapper for |:delete|.
function! tlib#buffer#DeleteRange(line1, line2) "{{{3
    let r = @t
    try
        exec a:line1.','.a:line2.'delete t'
    finally
        let @t = r
    endtry
endf


" Replace a range of lines.
function! tlib#buffer#ReplaceRange(line1, line2, lines)
    call tlib#buffer#DeleteRange(a:line1, a:line2)
    call append(a:line1 - 1, a:lines)
endf


" Initialize some scratch area at the bottom of the current buffer.
function! tlib#buffer#ScratchStart() "{{{3
    norm! Go
    let b:tlib_inbuffer_scratch = line('$')
    return b:tlib_inbuffer_scratch
endf


" Remove the in-buffer scratch area.
function! tlib#buffer#ScratchEnd() "{{{3
    if !exists('b:tlib_inbuffer_scratch')
        echoerr 'tlib: In-buffer scratch not initalized'
    endif
    call tlib#buffer#DeleteRange(b:tlib_inbuffer_scratch, line('$'))
    unlet b:tlib_inbuffer_scratch
endf


" Run exec on all buffers via bufdo and return to the original buffer.
function! tlib#buffer#BufDo(exec) "{{{3
    let bn = bufnr('%')
    exec 'bufdo '. a:exec
    exec 'buffer! '. bn
endf


" :def: function! tlib#buffer#InsertText(text, keyargs)
" Keyargs:
"   'shift': 0|N
"   'col': col('.')|N
"   'lineno': line('.')|N
"   'indent': 0|1
"   'pos': 'e'|'s' ... Where to locate the cursor (somewhat like s and e in {offset})
" Insert text (a string) in the buffer.
function! tlib#buffer#InsertText(text, ...) "{{{3
    TVarArg ['keyargs', {}]
    TKeyArg keyargs, ['shift', 0], ['col', col('.')], ['lineno', line('.')], ['pos', 'e'],
                \ ['indent', 0]
    " TLogVAR shift, col, lineno, pos, indent
    let post_del_last_line = line('$') == 1
    let line = getline(lineno)
    if col + shift > 0
        let pre  = line[0 : (col - 1 + shift)]
        let post = line[(col + shift): -1]
    else
        let pre  = ''
        let post = line
    endif
    " TLogVAR lineno, line, pre, post
    let text0 = pre . a:text . post
    let text  = split(text0, '\n', 1)
    " TLogVAR text
    let icol = len(pre)
    " exec 'norm! '. lineno .'G'
    call cursor(lineno, col)
    if indent && col > 1
		if &fo =~# '[or]'
			" This doesn't work because it's not guaranteed that the 
			" cursor is set.
			let cline = getline('.')
			norm! a
			"norm! o
			" TAssertExec redraw | sleep 3
			let idt = strpart(getline('.'), 0, col('.') + shift)
			" TLogVAR idt
			let idtl = len(idt)
			-1,.delete
			" TAssertExec redraw | sleep 3
			call append(lineno - 1, cline)
			call cursor(lineno, col)
			" TAssertExec redraw | sleep 3
			if idtl == 0 && icol != 0
				let idt = matchstr(pre, '^\s\+')
				let idtl = len(idt)
			endif
		else
			let [m_0, idt, iline; rest] = matchlist(pre, '^\(\s*\)\(.*\)$')
			let idtl = len(idt)
		endif
		if idtl < icol
			let idt .= repeat(' ', icol - idtl)
		endif
        " TLogVAR idt
        for i in range(1, len(text) - 1)
            let text[i] = idt . text[i]
        endfor
        " TLogVAR text
    endif
    " exec 'norm! '. lineno .'Gdd'
    call tlib#normal#WithRegister('"tdd', 't')
    call append(lineno - 1, text)
    if post_del_last_line
        call tlib#buffer#KeepCursorPosition('$delete')
    endif
    let tlen = len(text)
    let posshift = matchstr(pos, '\d\+')
    if pos =~ '^e'
        exec lineno + tlen - 1
        exec 'norm! 0'. (len(text[-1]) - len(post) + posshift - 1) .'l'
    elseif pos =~ '^s'
        exec lineno
        exec 'norm! '. len(pre) .'|'
        if !empty(posshift)
            exec 'norm! '. posshift .'h'
        endif
    endif
    " TLogDBG string(getline(1, '$'))
endf


function! tlib#buffer#InsertText0(text, ...) "{{{3
    TVarArg ['keyargs', {}]
    let mode = get(keyargs, 'mode', 'i')
    " TLogVAR mode
    if !has_key(keyargs, 'shift')
        let col = col('.')
        " if mode =~ 'i'
        "     let col += 1
        " endif
        let keyargs.shift = col >= col('$') ? 0 : -1
        " let keyargs.shift = col('.') >= col('$') ? 0 : -1
        " TLogVAR col
        " TLogDBG col('.') .'-'. col('$') .': '. string(getline('.'))
    endif
    " TLogVAR keyargs.shift
    return tlib#buffer#InsertText(a:text, keyargs)
endf


function! tlib#buffer#CurrentByte() "{{{3
    return line2byte(line('.')) + col('.')
endf


" Evaluate cmd while maintaining the cursor position and jump registers.
function! tlib#buffer#KeepCursorPosition(cmd) "{{{3
    let pos = getpos('.')
    try
        keepjumps exec a:cmd
    finally
        call setpos('.', pos)
    endtry
endf

autoload/tlib/cache.vim	[[[1
71
" cache.vim
" @Author:      Tom Link (micathom AT gmail com?subject=[vim])
" @Website:     http://www.vim.org/account/profile.php?user_id=4037
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Created:     2007-06-30.
" @Last Change: 2009-02-15.
" @Revision:    0.1.32

if &cp || exists("loaded_tlib_cache_autoload")
    finish
endif
let loaded_tlib_cache_autoload = 1


" :def: function! tlib#cache#Filename(type, ?file=%, ?mkdir=0)
function! tlib#cache#Filename(type, ...) "{{{3
    " TLogDBG 'bufname='. bufname('.')
    let dir = tlib#var#Get('tlib_cache', 'bg')
    if empty(dir)
        let dir = tlib#file#Join([tlib#dir#MyRuntime(), 'cache'])
    endif
    if a:0 >= 1 && !empty(a:1)
        let file  = a:1
    else
        if empty(expand('%:t'))
            return ''
        endif
        let file  = expand('%:p')
        let file  = tlib#file#Relative(file, tlib#file#Join([dir, '..']))
    endif
    " TLogVAR file, dir
    let mkdir = a:0 >= 2 ? a:2 : 0
    let file  = substitute(file, '\.\.\|[:&<>]\|//\+\|\\\\\+', '_', 'g')
    let dirs  = [dir, a:type]
    let dirf  = fnamemodify(file, ':h')
    if dirf != '.'
        call add(dirs, dirf)
    endif
    let dir   = tlib#file#Join(dirs)
    " TLogVAR dir
    let dir   = tlib#dir#PlainName(dir)
    " TLogVAR dir
    let file  = fnamemodify(file, ':t')
    " TLogVAR file, dir
    if mkdir && !isdirectory(dir)
        call mkdir(dir, 'p')
    endif
    let cache_file = tlib#file#Join([dir, file])
    " TLogVAR cache_file
    return cache_file
endf


function! tlib#cache#Save(cfile, dictionary) "{{{3
    if !empty(a:cfile)
        " TLogVAR a:dictionary
        call writefile([string(a:dictionary)], a:cfile, 'b')
    endif
endf


function! tlib#cache#Get(cfile) "{{{3
    if !empty(a:cfile) && filereadable(a:cfile)
        let val = readfile(a:cfile, 'b')
        return eval(join(val, "\n"))
    else
        return {}
    endif
endf


autoload/tlib/char.vim	[[[1
58
" char.vim
" @Author:      Tom Link (micathom AT gmail com?subject=[vim])
" @Website:     http://www.vim.org/account/profile.php?user_id=4037
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Created:     2007-06-30.
" @Last Change: 2009-02-15.
" @Revision:    0.0.30

if &cp || exists("loaded_tlib_char_autoload")
    finish
endif
let loaded_tlib_char_autoload = 1


" :def: function! tlib#char#Get(?timeout=0)
" Get a character.
"
" EXAMPLES: >
"   echo tlib#char#Get()
"   echo tlib#char#Get(5)
function! tlib#char#Get(...) "{{{3
    TVarArg ['timeout', 0], ['resolution', 0]
    if timeout == 0 || !has('reltime')
        return getchar()
    else
        return tlib#char#GetWithTimeout(timeout, resolution)
    endif
    return -1
endf


function! tlib#char#IsAvailable() "{{{3
    let ch = getchar(1)
    return type(ch) == 0 && ch != 0
endf


function! tlib#char#GetWithTimeout(timeout, ...) "{{{3
    TVarArg ['resolution', 2]
    " TLogVAR a:timeout, resolution
    let start = tlib#time#MSecs()
    while 1
        let c = getchar(0)
        if type(c) != 0 || c != 0
            return c
        else
            let now = tlib#time#MSecs()
            let diff = tlib#time#DiffMSecs(now, start, resolution)
            " TLogVAR diff
            if diff > a:timeout
                return -1
            endif
        endif
    endwh
    return -1
endf


autoload/tlib/cmd.vim	[[[1
56
" cmd.vim
" @Author:      Tom Link (micathom AT gmail com?subject=[vim])
" @Website:     http://www.vim.org/account/profile.php?user_id=4037
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Created:     2007-08-23.
" @Last Change: 2009-02-15.
" @Revision:    0.0.21

if &cp || exists("loaded_tlib_cmd_autoload")
    finish
endif
let loaded_tlib_cmd_autoload = 1


function! tlib#cmd#OutputAsList(command) "{{{3
    " let lines = ''
    redir => lines
    silent! exec a:command
    redir END
    return split(lines, '\n')
endf


" See |:TBrowseOutput|.
function! tlib#cmd#BrowseOutput(command) "{{{3
    let list = tlib#cmd#OutputAsList(a:command)
    let cmd = tlib#input#List('s', 'Output of: '. a:command, list)
    if !empty(cmd)
        call feedkeys(':'. cmd)
    endif
endf


" :def: function! tlib#cmd#UseVertical(?rx='')
" Look at the history whether the command was called with vertical. If 
" an rx is provided check first if the last entry in the history matches 
" this rx.
function! tlib#cmd#UseVertical(...) "{{{3
    TVarArg ['rx']
    let h0 = histget(':')
    let rx0 = '\C\<vert\%[ical]\>\s\+'
    if !empty(rx)
        let rx0 .= '.\{-}'.rx
    endif
    " TLogVAR h0, rx0
    return h0 =~ rx0
endf


" Print the time in seconds a command takes.
function! tlib#cmd#Time(cmd) "{{{3
    let start = localtime()
    exec a:cmd
    echom 'Time: '. (localtime() - start) .'s: '. a:cmd
endf

autoload/tlib/comments.vim	[[[1
57
" comments.vim
" @Author:      Tom Link (mailto:micathom AT gmail com?subject=[vim])
" @Website:     http://www.vim.org/account/profile.php?user_id=4037
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Created:     2007-11-15.
" @Last Change: 2009-02-15.
" @Revision:    0.0.24

if &cp || exists("loaded_tlib_comments_autoload")
    finish
endif
let loaded_tlib_comments_autoload = 1
let s:save_cpo = &cpo
set cpo&vim


" function! tlib#comments#Comments(?rx='')
function! tlib#comments#Comments(...)
    TVarArg ['rx', '']
    let comments = {}
    let co = &comments
    while !empty(co)
        " TLogVAR co
        let [m_0, m_key, m_val, m_val1, co0, co; rest] = matchlist(co, '^\([^:]*\):\(\(\\.\|[^,]*\)\+\)\(,\(.*\)$\|$\)')
        " TLogVAR m_key, m_val, co
        if empty(m_key)
            let m_key = ':'
        endif
        if empty(rx) || m_key =~ rx
            let comments[m_key] = m_val
        endif
    endwh
    return comments
endf


" function! tlib#comments#PartitionLine(line) "{{{3
"     if !empty(&commentstring)
"         let cs = '^\(\s*\)\('. printf(tlib#rx#Escape(&commentstring), '\)\(.\{-}\)\(') .'\)\(.*\)$'
"         let ml = matchlist(a:line, cs)
"     else
"         let ml = []
"     endif
"     if !empty(ml)
"         let [m_0, pre, open, line, close, post; rest] = ml
"     else
"         let [m_0, pre, line; rest] = matchstr(a:line, '^\(\s*\)\(.*\)$')
"         for [key, val] in tlib#comments#Comments()
"             if +++
"         endfor
"     endif
"     return {'pre': pre, 'open': open, 'line': line, 'close': close, 'post': post}
" endf


let &cpo = s:save_cpo
unlet s:save_cpo
autoload/tlib/dir.vim	[[[1
83
" dir.vim
" @Author:      Tom Link (micathom AT gmail com?subject=[vim])
" @Website:     http://www.vim.org/account/profile.php?user_id=4037
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Created:     2007-06-30.
" @Last Change: 2009-02-15.
" @Revision:    0.0.29

if &cp || exists("loaded_tlib_dir_autoload")
    finish
endif
let loaded_tlib_dir_autoload = 1

let s:dir_stack = []

" EXAMPLES: >
"   tlib#dir#CanonicName('foo/bar')
"   => 'foo/bar/'
function! tlib#dir#CanonicName(dirname) "{{{3
    if a:dirname !~ '[/\\]$'
        return a:dirname . g:tlib_filename_sep
    endif
    return a:dirname
endf


" EXAMPLES: >
"   tlib#dir#PlainName('foo/bar/')
"   => 'foo/bar'
function! tlib#dir#PlainName(dirname) "{{{3
    let dirname = a:dirname
    while dirname[-1 : -1] == g:tlib_filename_sep
        let dirname = dirname[0 : -2]
    endwh
    return dirname
    " return substitute(a:dirname, tlib#rx#Escape(g:tlib_filename_sep).'\+$', '', '')
endf


" Create a directory if it doesn't already exist.
function! tlib#dir#Ensure(dir) "{{{3
    if !isdirectory(a:dir)
        let dir = tlib#dir#PlainName(a:dir)
        return mkdir(dir, 'p')
    endif
    return 1
endf


" Return the first directory in &rtp.
function! tlib#dir#MyRuntime() "{{{3
    return get(split(&rtp, ','), 0)
endf


" :def: function! tlib#dir#CD(dir, ?locally=0) => CWD
function! tlib#dir#CD(dir, ...) "{{{3
    TVarArg ['locally', 0]
    let cmd = locally ? 'lcd ' : 'cd '
    " let cwd = getcwd()
    let cmd .= tlib#arg#Ex(a:dir)
    " TLogVAR cmd
    exec cmd
    " return cwd
    return getcwd()
endf


" :def: function! tlib#dir#Push(dir, ?locally=0) => CWD
function! tlib#dir#Push(dir, ...) "{{{3
    TVarArg ['locally', 0]
    call add(s:dir_stack, [getcwd(), locally])
    return tlib#dir#CD(a:dir, locally)
endf


" :def: function! tlib#dir#Pop() => CWD
function! tlib#dir#Pop() "{{{3
    let [dir, locally] = remove(s:dir_stack, -1)
    return tlib#dir#CD(dir, locally)
endf


autoload/tlib/eval.vim	[[[1
55
" eval.vim
" @Author:      Tom Link (mailto:micathom AT gmail com?subject=[vim])
" @Website:     http://www.vim.org/account/profile.php?user_id=4037
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Created:     2007-09-16.
" @Last Change: 2009-02-15.
" @Revision:    0.0.34

if &cp || exists("loaded_tlib_eval_autoload")
    finish
endif
let loaded_tlib_eval_autoload = 1


function! tlib#eval#FormatValue(value, ...) "{{{3
    TVarArg ['indent', 0]
    " TLogVAR a:value, indent
    let indent1 = indent + 1
    let indenti = repeat(' ', &sw)
    let type = type(a:value)
    let acc = []
    if type == 0 || type == 1 || type == 2
        " TLogDBG 'Use string() for type='. type
        call add(acc, string(a:value))
    elseif type == 3 "List
        " TLogDBG 'List'
        call add(acc, '[')
        for e in a:value
            call add(acc, printf('%s%s,', indenti, tlib#eval#FormatValue(e, indent1)))
            unlet e
        endfor
        call add(acc, ']')
    elseif type == 4 "Dictionary
        " TLogDBG 'Dictionary'
        call add(acc, '{')
        let indent1 = indent + 1
        for [k, v] in items(a:value)
            call add(acc, printf("%s%s: %s,", indenti, string(k), tlib#eval#FormatValue(v, indent1)))
            unlet k v
        endfor
        call add(acc, '}')
    else
        " TLogDBG 'Unknown type: '. string(a:value)
        call add(acc, string(a:value))
    endif
    if indent > 0
        let is = repeat(' ', indent * &sw)
        for i in range(1,len(acc) - 1)
            let acc[i] = is . acc[i]
        endfor
    endif
    return join(acc, "\n")
endf


autoload/tlib/hook.vim	[[[1
33
" hook.vim
" @Author:      Tom Link (micathom AT gmail com?subject=[vim])
" @Website:     http://www.vim.org/account/profile.php?user_id=4037
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Created:     2007-08-21.
" @Last Change: 2009-02-15.
" @Revision:    0.0.10

if &cp || exists("loaded_tlib_hook_autoload")
    finish
endif
let loaded_tlib_hook_autoload = 1


" :def: function! tlib#hook#Run(hook, ?dict={})
" Execute dict[hook], w:{hook}, b:{hook}, or g:{hook} if existent.
function! tlib#hook#Run(hook, ...) "{{{3
    TVarArg ['dict', {}]
    if has_key(dict, a:hook)
        let hook = dict[a:hook]
    else
        let hook = tlib#var#Get(a:hook, 'wbg')
    endif
    if empty(hook)
        return 0
    else
        let world = dict
        exec hook
        return 1
    endif
endf


autoload/tlib/input.vim	[[[1
680
" input.vim
" @Author:      Tom Link (micathom AT gmail com?subject=[vim])
" @Website:     http://www.vim.org/account/profile.php?user_id=4037
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Created:     2007-06-30.
" @Last Change: 2009-02-25.
" @Revision:    0.0.637

if &cp || exists("loaded_tlib_input_autoload")
    finish
endif
let loaded_tlib_input_autoload = 1

" :filedoc:
" Input-related, select from a list etc.


" Functions related to tlib#input#List(type, ...) "{{{2

" :def: function! tlib#input#List(type. ?query='', ?list=[], ?handlers=[], ?default="", ?timeout=0)
" Select a single or multiple items from a list. Return either the list 
" of selected elements or its indexes.
"
" By default, typing numbers will select an item by its index. See 
" |g:tlib_numeric_chars| to find out how to change this.
"
" The item is automatically selected if the numbers typed equals the 
" number of digits of the list length. I.e. if a list contains 20 items, 
" typing 1 will first highlight item 1 but it won't select/use it 
" because 1 is an ambiguous input in this context. If you press enter, 
" the first item will be selected. If you press another digit (e.g. 0), 
" item 10 will be selected. Another way to select item 1 would be to 
" type 01. If the list contains only 9 items, typing 1 would select the 
" first item right away.
"
" type can be:
"     s  ... Return one selected element
"     si ... Return the index of the selected element
"     m  ... Return a list of selcted elements
"     mi ... Return a list of indexes
"
" Several pattern matching styles are supported. See:
"   - |tlib#Filter_cnf#New()|
"   - |tlib#Filter_cnfd#New()|
"   - |tlib#Filter_fuzzy#New()|
"   - |tlib#Filter_seq#New()|
"
" EXAMPLES: >
"   echo tlib#input#List('s', 'Select one item', [100,200,300])
"   echo tlib#input#List('si', 'Select one item', [100,200,300])
"   echo tlib#input#List('m', 'Select one or more item(s)', [100,200,300])
"   echo tlib#input#List('mi', 'Select one or more item(s)', [100,200,300])
function! tlib#input#List(type, ...) "{{{3
    exec tlib#arg#Let([
        \ ['query', ''],
        \ ['list', []],
        \ ['handlers', []],
        \ ['rv', ''],
        \ ['timeout', 0],
        \ ])
    " let handlers = a:0 >= 1 ? a:1 : []
    " let rv       = a:0 >= 2 ? a:2 : ''
    " let timeout  = a:0 >= 3 ? a:3 : 0
    " let backchar = ["\<bs>", "\<del>"]

    if a:type =~ '^resume'
        let world = b:tlib_{matchstr(a:type, ' \zs.\+')}
    else
        let world = tlib#World#New({
                    \ 'type': a:type,
                    \ 'base': list,
                    \ 'query': query,
                    \ 'timeout': timeout,
                    \ 'rv': rv,
                    \ 'handlers': handlers,
                    \ })
        let scratch_name     = tlib#list#Find(handlers, 'has_key(v:val, "scratch_name")', '', 'v:val.scratch_name')
        if !empty(scratch_name)
            let world.scratch = scratch_name
        endif
        let world.scratch_vertical = tlib#list#Find(handlers, 'has_key(v:val, "scratch_vertical")', 0, 'v:val.scratch_vertical')
        call world.Set_display_format(tlib#list#Find(handlers, 'has_key(v:val, "display_format")', '', 'v:val.display_format'))
        let world.initial_index    = tlib#list#Find(handlers, 'has_key(v:val, "initial_index")', 1, 'v:val.initial_index')
        let world.index_table      = tlib#list#Find(handlers, 'has_key(v:val, "index_table")', [], 'v:val.index_table')
        let world.state_handlers   = filter(copy(handlers),   'has_key(v:val, "state")')
        let world.post_handlers    = filter(copy(handlers),   'has_key(v:val, "postprocess")')
        let world.filter_format    = tlib#list#Find(handlers, 'has_key(v:val, "filter_format")', '', 'v:val.filter_format')
        let world.return_agent     = tlib#list#Find(handlers, 'has_key(v:val, "return_agent")', '', 'v:val.return_agent')
        let world.resize           = tlib#list#Find(handlers, 'has_key(v:val, "resize")', '', 'v:val.resize')
        let world.show_empty       = tlib#list#Find(handlers, 'has_key(v:val, "show_empty")', 0, 'v:val.show_empty')
        let world.pick_last_item   = tlib#list#Find(handlers, 'has_key(v:val, "pick_last_item")', 
                    \ tlib#var#Get('tlib_pick_last_item', 'bg'), 'v:val.pick_last_item')
        let world.numeric_chars    = tlib#list#Find(handlers, 'has_key(v:val, "numeric_chars")', 
                    \ tlib#var#Get('tlib_numeric_chars', 'bg'), 'v:val.numeric_chars')
        let world.key_handlers     = filter(copy(handlers), 'has_key(v:val, "key")')
        let filter                 = tlib#list#Find(handlers, 'has_key(v:val, "filter")', '', 'v:val.filter')
        if !empty(filter)
            " let world.initial_filter = [[''], [filter]]
            let world.initial_filter = [[filter]]
            " TLogVAR world.initial_filter
        endif
    endif
    return tlib#input#ListW(world)
endf


" A wrapper for |tlib#input#ListW()| that builds |tlib#World#New| from 
" dict.
function! tlib#input#ListD(dict) "{{{3
    return tlib#input#ListW(tlib#World#New(a:dict))
endf


" :def: function! tlib#input#ListW(world, ?command='')
" The second argument, command is meant for internal use only.
" The same as |tlib#input#List| but the arguments are packed into world 
" (an instance of tlib#World as returned by |tlib#World#New|).
function! tlib#input#ListW(world, ...) "{{{3
    TVarArg 'cmd'
    let world = a:world
    let world.filetype = &filetype
    call world.SetMatchMode(tlib#var#Get('tlib_inputlist_match', 'wb'))
    call s:Init(world, cmd)
    " TLogVAR world.state, world.sticky, world.initial_index
    let key_agents = copy(g:tlib_keyagents_InputList_s)
    if stridx(world.type, 'm') != -1
        call extend(key_agents, g:tlib_keyagents_InputList_m, 'force')
    endif
    for handler in world.key_handlers
        let k = get(handler, 'key', '')
        if !empty(k)
            let key_agents[k] = handler.agent
        endif
    endfor
    let statusline  = &statusline
    let laststatus  = &laststatus
    let lastsearch  = @/
    let @/ = ''
    let &laststatus = 2
    let world.initial_display = 1

    try
        while !empty(world.state) && world.state !~ '^exit' && (world.show_empty || !empty(world.base))
            " TLogDBG 'while'
            " TLogVAR world.state
            try
                for handler in world.state_handlers
                    let eh = get(handler, 'state', '')
                    if !empty(eh) && world.state =~ eh
                        let ea = get(handler, 'exec', '')
                        if !empty(ea)
                            exec ea
                        else
                            let agent = get(handler, 'agent', '')
                            let world = call(agent, [world, world.GetSelectedItems(world.CurrentItem())])
                            call s:CheckAgentReturnValue(agent, world)
                        endif
                    endif
                endfor

                if world.state =~ '\<reset\>'
                    " TLogDBG 'reset'
                    " call world.Reset(world.state =~ '\<initial\>')
                    call world.Reset()
                    continue
                endif

                let llenw = len(world.base) - winheight(0) + 1
                if world.offset > llenw
                    let world.offset = llenw
                endif
                if world.offset < 1
                    let world.offset = 1
                endif

                " TLogDBG 1
                " TLogVAR world.state
                if world.state == 'scroll'
                    let world.prefidx = world.offset
                    let world.state = 'redisplay'
                endif
                if world.state =~ '\<sticky\>'
                    let world.sticky = 1
                endif
                " TLogVAR world.filter
                " TLogVAR world.sticky
                if world.state =~ '\<pick\>'
                    let world.rv = world.CurrentItem()
                    " TLogVAR world.rv
                    throw 'pick'
                elseif world.state =~ 'display'
                    if world.IsValidFilter() && world.state =~ '^display'

                        call world.BuildTable()
                        " TLogDBG 2
                        " TLogDBG len(world.table)
                        " TLogVAR world.table
                        let world.list  = map(copy(world.table), 'world.GetBaseItem(v:val)')
                        " TLogDBG 3
                        let world.llen = len(world.list)
                        " TLogVAR world.index_table
                        if empty(world.index_table)
                            let dindex = range(1, world.llen)
                            let world.index_width = len(world.llen)
                        else
                            let dindex = world.index_table
                            let world.index_width = len(max(dindex))
                        endif
                        if world.llen == 0 && !world.show_empty
                            call world.ReduceFilter()
                            let world.offset = 1
                            " TLogDBG 'ReduceFilter'
                            continue
                        else
                            if world.llen == 1
                                let world.last_item = world.list[0]
                                if world.pick_last_item
                                    " echom 'Pick last item: '. world.list[0]
                                    let world.prefidx = '1'
                                    " TLogDBG 'pick last item'
                                    throw 'pick'
                                endif
                            else
                                let world.last_item = ''
                            endif
                        endif
                        " TLogDBG 4
                        " TLogVAR world.idx, world.llen, world.state
                        " TLogDBG world.FilterIsEmpty()
                        if world.state == 'display'
                            if world.idx == '' && world.llen < g:tlib_sortprefs_threshold && !world.FilterIsEmpty()
                                call world.SetPrefIdx()
                            else
                                let world.prefidx = world.idx == '' ? world.initial_index : world.idx
                            endif
                            if world.prefidx > world.llen
                                let world.prefidx = world.llen
                            elseif world.prefidx < 1
                                let world.prefidx = 1
                            endif
                        endif
                        " TLogVAR world.initial_index, world.prefidx
                        " TLogDBG 5
                        " TLogDBG len(world.list)
                        " TLogVAR world.list
                        let dlist = copy(world.list)
                        if !empty(world.display_format)
                            let display_format = world.display_format
                            " TLogVAR display_format
                            call map(dlist, 'world.FormatName(display_format, v:val)')
                        endif
                        " TLogVAR world.prefidx
                        " TLogDBG 6
                        if world.offset_horizontal > 0
                            call map(dlist, 'v:val[world.offset_horizontal:-1]')
                        endif
                        " TLogVAR dindex
                        let dlist = map(range(0, world.llen - 1), 'printf("%0'. world.index_width .'d", dindex[v:val]) .": ". dlist[v:val]')
                        " TLogVAR dlist

                    endif

                    " TLogDBG 7
                    " TLogVAR world.prefidx, world.offset
                    " TLogDBG (world.prefidx > world.offset + winheight(0) - 1)
                    " if world.prefidx > world.offset + winheight(0) - 1
                    "     let listtop = world.llen - winheight(0) + 1
                    "     let listoff = world.prefidx - winheight(0) + 1
                    "     let world.offset = min([listtop, listoff])
                    "     TLogVAR world.prefidx
                    "     TLogDBG len(list)
                    "     TLogDBG winheight(0)
                    "     TLogVAR listtop, listoff, world.offset
                    " elseif world.prefidx < world.offset
                    "     let world.offset = world.prefidx
                    " endif
                    " TLogDBG 8
                    if world.initial_display || !tlib#char#IsAvailable()
                        " TLogDBG len(dlist)
                        call world.DisplayList(world.query .' (filter: '. world.DisplayFilter() .'; press "?" for help)', dlist)
                        call world.FollowCursor()
                        let world.initial_display = 0
                        " TLogDBG 9
                    endif
                    let world.state = ''
                else
                    " if world.state == 'scroll'
                    "     let world.prefidx = world.offset
                    " endif
                    call world.DisplayList('')
                    if world.state == 'help'
                        let world.state = 'display'
                    else
                        let world.state = ''
                        call world.FollowCursor()
                    endif
                endif
                " TAssert IsNotEmpty(world.scratch)
                let world.list_wnr = winnr()

                " TLogVAR world.next_state, world.state
                if !empty(world.next_state)
                    let world.state = world.next_state
                    let world.next_state = ''
                endif

                if world.state =~ '\<suspend\>'
                    let world = tlib#agent#SuspendToParentWindow(world, world.rv)
                    continue
                endif

                " TLogVAR world.timeout
                let c = tlib#char#Get(world.timeout, world.timeout_resolution)
                if world.state != ''
                    " continue
                elseif has_key(key_agents, c)
                    let sr = @/
                    silent! let @/ = lastsearch
                    " TLog "Agent: ". string(key_agents[c])
                    let world = call(key_agents[c], [world, world.GetSelectedItems(world.CurrentItem())])
                    call s:CheckAgentReturnValue(c, world)
                    silent! let @/ = sr
                    " continue
                elseif c == 13
                    throw 'pick'
                elseif c == 27
                    let world.state = 'exit empty'
                elseif c == "\<LeftMouse>"
                    let line = getline(v:mouse_lnum)
                    let world.prefidx = substitute(matchstr(line, '^\d\+\ze[*:]'), '^0\+', '', '')
                    " let world.offset  = world.prefidx
                    " TLogVAR v:mouse_lnum, line, world.prefidx
                    if empty(world.prefidx)
                        " call feedkeys(c, 't')
                        let c = tlib#char#Get(world.timeout)
                        let world.state = 'help'
                        continue
                    endif
                    throw 'pick'
                elseif c >= 32
                    let world.state = 'display'
                    let numbase = get(world.numeric_chars, c, -99999)
                    " TLogVAR numbase, world.numeric_chars, c
                    if numbase != -99999
                        let world.idx .= (c - numbase)
                        if len(world.idx) == world.index_width
                            let world.prefidx = world.idx
                            " TLogVAR world.prefidx
                            throw 'pick'
                        endif
                    else
                        let world.idx = ''
                        " TLogVAR world.filter
                        if world.llen > g:tlib_inputlist_livesearch_threshold
                            let pattern = input('Filter: ', world.CleanFilter(world.filter[0][0]) . nr2char(c))
                            if empty(pattern)
                                let world.state = 'exit empty'
                            else
                                call world.SetFrontFilter(pattern)
                                echo
                            endif
                        elseif c == 124
                            call insert(world.filter[0], [])
                        else
                            call world.PushFrontFilter(c)
                        endif
                        " continue
                        if c == 45 && world.filter[0][0] == '-'
                            let world.state = 'redisplay'
                        end
                    endif
                else
                    let world.state = 'redisplay'
                    " let world.state = 'continue'
                endif

            catch /^pick$/
                call world.ClearAllMarks()
                call world.MarkCurrent(world.prefidx)
                let world.state = ''
                " TLogDBG 'Pick item #'. world.prefidx

            finally
                " TLogDBG 'finally 1'
                if world.state =~ '\<suspend\>'
                    " if !world.allow_suspend
                    "     echom "Cannot be suspended"
                    "     let world.state = 'redisplay'
                    " endif
                elseif !empty(world.list) && !empty(world.base)
                    " TLogVAR world.list
                    if empty(world.state)
                        " TLogVAR world.state
                        let world.rv = world.CurrentItem()
                    endif
                    " TLog "postprocess"
                    for handler in world.post_handlers
                        let state = get(handler, 'postprocess', '')
                        " TLogVAR handler
                        " TLogVAR state
                        " TLogVAR world.state
                        if state == world.state
                            let agent = handler.agent
                            let [world, world.rv] = call(agent, [world, world.rv])
                            " TLogVAR world.state, world.rv
                            call s:CheckAgentReturnValue(agent, world)
                        endif
                    endfor
                endif
                " TLogDBG 'state0='. world.state
            endtry
            " TLogDBG 'state1='. world.state
        endwh

        " TLogVAR world.state
        " TLogDBG string(tlib#win#List())
        " TLogDBG 'exit while loop'
        " TLogVAR world.list
        " TLogVAR world.sel_idx
        " TLogVAR world.idx
        " TLogVAR world.prefidx
        " TLogVAR world.rv
        " TLogVAR world.type, world.state, world.return_agent, world.index_table, world.rv
        if world.state =~ '\<\(empty\|escape\)\>'
            let world.sticky = 0
        endif
        if world.state =~ '\<suspend\>'
            " TLogDBG 'return suspended'
            " TLogVAR world.prefidx
            " exec world.prefidx
            return
        elseif world.state =~ '\<empty\>'
            " TLog "empty"
            " TLogDBG 'return empty'
            return stridx(world.type, 'm') != -1 ? [] : stridx(world.type, 'i') != -1 ? 0 : ''
        elseif !empty(world.return_agent)
            " TLog "return_agent"
            " TLogDBG 'return agent'
            " TLogVAR world.return_agent
            call world.CloseScratch()
            " TLogDBG "return_agent ". string(tlib#win#List())
            " TAssert IsNotEmpty(world.scratch)
            return call(world.return_agent, [world, world.GetSelectedItems(world.rv)])
        elseif stridx(world.type, 'w') != -1
            " TLog "return_world"
            " TLogDBG 'return world'
            return world
        elseif stridx(world.type, 'm') != -1
            " TLog "return_multi"
            " TLogDBG 'return multi'
            return world.GetSelectedItems(world.rv)
        elseif stridx(world.type, 'i') != -1
            " TLog "return_index"
            " TLogDBG 'return index'
            if empty(world.index_table)
                return world.rv
            else
                return world.index_table[world.rv - 1]
            endif
        else
            " TLog "return_else"
            " TLogDBG 'return normal'
            return world.rv
        endif

    finally
        let &statusline = statusline
        let &laststatus = laststatus
        silent! let @/  = lastsearch
        " TLogDBG 'finally 2'
        " TLogDBG string(world.Methods())
        " TLogVAR world.state
        " TLogDBG string(tlib#win#List())
        if world.state !~ '\<suspend\>'
            " TLogVAR world.sticky
            if world.sticky
                " TLogDBG "sticky"
                " TLogVAR world.bufnr
                " TLogDBG bufwinnr(world.bufnr)
                if bufwinnr(world.bufnr) == -1
                    " TLogDBG "UseScratch"
                    call world.UseScratch()
                endif
                let world = tlib#agent#SuspendToParentWindow(world, world.GetSelectedItems(world.rv))
            else
                " TLogDBG "non sticky"
                " TLogVAR world.state, world.win_wnr, world.bufnr
                if world.CloseScratch()
                    " TLogVAR world.winview
                    call tlib#win#SetLayout(world.winview)
                endif
            endif
        endif
        " for i in range(0,5)
        "     call getchar(0)
        " endfor
        echo
        " redraw
    endtry
endf


function! s:Init(world, cmd) "{{{3
    " TLogVAR a:cmd
    if a:cmd =~ '\<sticky\>'
        let a:world.sticky = 1
    endif
    if a:cmd =~ '^resume'
        call a:world.UseInputListScratch()
        let a:world.initial_index = line('.')
        if a:cmd =~ '\<pick\>'
            let a:world.state = 'pick'
            let a:world.prefidx = a:world.initial_index
        else
            call a:world.Retrieve(1)
        endif
    elseif !a:world.initialized
        " TLogVAR a:world.initialized, a:world.win_wnr, a:world.bufnr
        let a:world.initialized = 1
        call a:world.SetOrigin(1)
        call a:world.Reset(1)
    endif
    " TLogVAR a:world.state, a:world.sticky
endf


function! s:CheckAgentReturnValue(name, value) "{{{3
    if type(a:value) != 4 && !has_key(a:value, 'state')
        echoerr 'Malformed agent: '. a:name
    endif
    return a:value
endf


" Functions related to tlib#input#EditList(type, ...) "{{{2

" :def: function! tlib#input#EditList(query, list, ?timeout=0)
" Edit a list.
"
" EXAMPLES: >
"   echo tlib#input#EditList('Edit:', [100,200,300])
function! tlib#input#EditList(query, list, ...) "{{{3
    let handlers = a:0 >= 1 ? a:1 : g:tlib_handlers_EditList
    let rv       = a:0 >= 2 ? a:2 : ''
    let timeout  = a:0 >= 3 ? a:3 : 0
    " TLogVAR handlers
    let [success, list] = tlib#input#List('m', a:query, copy(a:list), handlers, rv, timeout)
    return success ? list : a:list
endf


function! tlib#input#Resume(name, pick) "{{{3
    echo
    if exists('b:tlib_suspend')
        for [m, pick] in items(b:tlib_suspend)
            exec 'unmap <buffer> '. m
        endfor
        unlet b:tlib_suspend
    endif
    let b:tlib_{a:name}.state = 'display'
    " call tlib#input#List('resume '. a:name)
    let cmd = 'resume '. a:name
    if a:pick >= 1
        let cmd .= ' pick'
        if a:pick >= 2
            let cmd .= ' sticky'
        end
    endif
    call tlib#input#ListW(b:tlib_{a:name}, cmd)
endf


" :def: function! tlib#input#CommandSelect(command, ?keyargs={})
" Take a command, view the output, and let the user select an item from 
" its output.
"
" EXAMPLE: >
"     command! TMarks exec 'norm! `'. matchstr(tlib#input#CommandSelect('marks'), '^ \+\zs.')
"     command! TAbbrevs exec 'norm i'. matchstr(tlib#input#CommandSelect('abbrev'), '^\S\+\s\+\zs\S\+')
function! tlib#input#CommandSelect(command, ...) "{{{3
    TVarArg ['args', {}]
    if has_key(args, 'retrieve')
        let list = call(args.retrieve)
    elseif has_key(args, 'list')
        let list = args.list
    else
        let list = tlib#cmd#OutputAsList(a:command)
    endif
    if has_key(args, 'filter')
        call map(list, args.filter)
    endif
    let type     = has_key(args, 'type') ? args.type : 's'
    let handlers = has_key(args, 'handlers') ? args.handlers : []
    let rv = tlib#input#List(type, 'Select', list, handlers)
    if !empty(rv)
        if has_key(args, 'process')
            let rv = call(args.process, [rv])
        endif
    endif
    return rv
endf


" :def: function! tlib#input#Edit(name, value, callback, ?cb_args=[])
"
" Edit a value (asynchronously) in a scratch buffer. Use name for 
" identification. Call callback when done (or on cancel).
" In the scratch buffer:
" Press <c-s> or <c-w><cr> to enter the new value, <c-w>c to cancel 
" editing.
" EXAMPLES: >
"   fun! FooContinue(success, text)
"       if a:success
"           let b:var = a:text
"       endif
"   endf
"   call tlib#input#Edit('foo', b:var, 'FooContinue')
function! tlib#input#Edit(name, value, callback, ...) "{{{3
    " TLogVAR a:value
    TVarArg ['args', []]
    let sargs = {'scratch': '__EDIT__'. a:name .'__'}
    let scr = tlib#scratch#UseScratch(sargs)

    " :nodoc:
    map <buffer> <c-w>c :call <SID>EditCallback(0)<cr>
    " :nodoc:
    imap <buffer> <c-w>c <c-o>call <SID>EditCallback(0)<cr>
    " :nodoc:
    map <buffer> <c-s> :call <SID>EditCallback(1)<cr>
    " :nodoc:
    imap <buffer> <c-s> <c-o>call <SID>EditCallback(1)<cr>
    " :nodoc:
    map <buffer> <c-w><cr> :call <SID>EditCallback(1)<cr>
    " :nodoc:
    imap <buffer> <c-w><cr> <c-o>call <SID>EditCallback(1)<cr>
    
    call tlib#normal#WithRegister('gg"tdG', 't')
    norm
    call append(1, split(a:value, "\<c-j>", 1))
    " let hrm = 'DON''T DELETE THIS HEADER'
    " let hr3 = repeat('"', (tlib#win#Width(0) - len(hrm)) / 2)
    let s:horizontal_line = repeat('`', tlib#win#Width(0))
    " hr3.hrm.hr3
    let hd  = ['Keys: <c-s>, <c-w><cr> ... save/accept; <c-w>c ... cancel', s:horizontal_line]
    call append(1, hd)
    call tlib#normal#WithRegister('gg"tdd', 't')
    syntax match TlibEditComment /^\%1l.*/
    syntax match TlibEditComment /^```.*/
    hi link TlibEditComment Comment
    exec len(hd) + 1
    if type(a:callback) == 4
        let b:tlib_scratch_edit_callback = get(a:callback, 'submit', '')
        call call(get(a:callback, 'init', ''), [])
    else
        let b:tlib_scratch_edit_callback = a:callback
    endif
    let b:tlib_scratch_edit_args     = args
    let b:tlib_scratch_edit_scratch  = sargs
    " exec 'autocmd BufDelete,BufHidden,BufUnload <buffer> call s:EditCallback('. string(a:name) .')'
    " echohl MoreMsg
    " echom 'Press <c-s> to enter, <c-w>c to cancel editing.'
    " echohl NONE
endf


function! s:EditCallback(...) "{{{3
    TVarArg ['ok', -1]
    " , ['bufnr', -1]
    " autocmd! BufDelete,BufHidden,BufUnload <buffer>
    if ok == -1
        let ok = confirm('Use value')
    endif
    let start = getline(2) == s:horizontal_line ? 3 : 1
    let text = ok ? join(getline(start, '$'), "\n") : ''
    let cb   = b:tlib_scratch_edit_callback
    let args = b:tlib_scratch_edit_args
    call tlib#scratch#CloseScratch(b:tlib_scratch_edit_scratch)
    call call(cb, args + [ok, text])
endf

autoload/tlib/list.vim	[[[1
168
" list.vim
" @Author:      Tom Link (micathom AT gmail com?subject=[vim])
" @Website:     http://www.vim.org/account/profile.php?user_id=4037
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Created:     2007-06-30.
" @Last Change: 2009-02-15.
" @Revision:    0.0.31

if &cp || exists("loaded_tlib_list_autoload")
    finish
endif
let loaded_tlib_list_autoload = 1


""" List related functions {{{1
" For the following functions please see ../../test/tlib.vim for examples.

" :def: function! tlib#list#Inject(list, initial_value, funcref)
" EXAMPLES: >
"   echo tlib#list#Inject([1,2,3], 0, function('Add')
"   => 6
function! tlib#list#Inject(list, value, Function) "{{{3
    if empty(a:list)
        return a:value
    else
        let item  = a:list[0]
        let rest  = a:list[1:-1]
        let value = call(a:Function, [a:value, item])
        return tlib#list#Inject(rest, value, a:Function)
    endif
endf


" EXAMPLES: >
"   tlib#list#Compact([0,1,2,3,[], {}, ""])
"   => [1,2,3]
function! tlib#list#Compact(list) "{{{3
    return filter(copy(a:list), '!empty(v:val)')
endf


" EXAMPLES: >
"   tlib#list#Flatten([0,[1,2,[3,""]]])
"   => [0,1,2,3,""]
function! tlib#list#Flatten(list) "{{{3
    let acc = []
    for e in a:list
        if type(e) == 3
            let acc += tlib#list#Flatten(e)
        else
            call add(acc, e)
        endif
        unlet e
    endfor
    return acc
endf


" :def: function! tlib#list#FindAll(list, filter, ?process_expr="")
" Basically the same as filter()
"
" EXAMPLES: >
"   tlib#list#FindAll([1,2,3], 'v:val >= 2')
"   => [2, 3]
function! tlib#list#FindAll(list, filter, ...) "{{{3
    let rv   = filter(copy(a:list), a:filter)
    if a:0 >= 1 && a:1 != ''
        let rv = map(rv, a:1)
    endif
    return rv
endf


" :def: function! tlib#list#Find(list, filter, ?default="", ?process_expr="")
"
" EXAMPLES: >
"   tlib#list#Find([1,2,3], 'v:val >= 2')
"   => 2
function! tlib#list#Find(list, filter, ...) "{{{3
    let default = a:0 >= 1 ? a:1 : ''
    let expr    = a:0 >= 2 ? a:2 : ''
    return get(tlib#list#FindAll(a:list, a:filter, expr), 0, default)
endf


" EXAMPLES: >
"   tlib#list#Any([1,2,3], 'v:val >= 2')
"   => 1
function! tlib#list#Any(list, expr) "{{{3
    return !empty(tlib#list#FindAll(a:list, a:expr))
endf


" EXAMPLES: >
"   tlib#list#All([1,2,3], 'v:val >= 2')
"   => 0
function! tlib#list#All(list, expr) "{{{3
    return len(tlib#list#FindAll(a:list, a:expr)) == len(a:list)
endf


" EXAMPLES: >
"   tlib#list#Remove([1,2,1,2], 2)
"   => [1,1,2]
function! tlib#list#Remove(list, element) "{{{3
    let idx = index(a:list, a:element)
    if idx != -1
        call remove(a:list, idx)
    endif
    return a:list
endf


" EXAMPLES: >
"   tlib#list#RemoveAll([1,2,1,2], 2)
"   => [1,1]
function! tlib#list#RemoveAll(list, element) "{{{3
    call filter(a:list, 'v:val != a:element')
    return a:list
endf


" :def: function! tlib#list#Zip(lists, ?default='')
" EXAMPLES: >
"   tlib#list#Zip([[1,2,3], [4,5,6]])
"   => [[1,4], [2,5], [3,6]]
function! tlib#list#Zip(lists, ...) "{{{3
    TVarArg 'default'
    let lists = copy(a:lists)
    let max   = 0
    for l in lists
        let ll = len(l)
        if ll > max
            let max = ll
        endif
    endfor
    " TLogVAR default, max
    return map(range(0, max - 1), 's:GetNthElement(v:val, lists, default)')
endf

function! s:GetNthElement(n, lists, default) "{{{3
    " TLogVAR a:n, a:lists, a:default
    return map(copy(a:lists), 'get(v:val, a:n, a:default)')
endf


function! tlib#list#Uniq(list, ...) "{{{3
    TVarArg ['get_value', '']
    let s:uniq_values = []
    if empty(get_value)
        call filter(a:list, 's:UniqValue(v:val)')
    else
        call filter(a:list, 's:UniqValue(eval(printf(get_value, string(v:val))))')
    endif
    return a:list
endf


function! s:UniqValue(value) "{{{3
    if index(s:uniq_values, a:value) == -1
        call add(s:uniq_values, a:value)
        return true
    else
        return false
    endif
endf


autoload/tlib/normal.vim	[[[1
26
" normal.vim
" @Author:      Tom Link (mailto:micathom AT gmail com?subject=[vim])
" @Website:     http://www.vim.org/account/profile.php?user_id=4037
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Created:     2008-10-06.
" @Last Change: 2009-02-15.
" @Revision:    10

let s:save_cpo = &cpo
set cpo&vim


function! tlib#normal#WithRegister(cmd, ...) "{{{3
    TVarArg ['register', 't'], ['norm_cmd', 'norm!']
    exec 'let reg = @'. register
    try
        exec norm_cmd .' '. a:cmd
        exec 'return @'. register
    finally
        exec 'let @'. register .' = reg'
    endtry
endf


let &cpo = s:save_cpo
unlet s:save_cpo
autoload/tlib/notify.vim	[[[1
103
" notify.vim
" @Author:      Tom Link (mailto:micathom AT gmail com?subject=[vim])
" @Website:     http://www.vim.org/account/profile.php?user_id=4037
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Created:     2008-09-19.
" @Last Change: 2009-02-15.
" @Revision:    0.0.14

let s:save_cpo = &cpo
set cpo&vim


" Print text in the echo area. Temporarily disable 'ruler' and 'showcmd' 
" in order to prevent |press-enter| messages.
function! tlib#notify#Echo(text, ...) "{{{3
    TVarArg 'style'
    let ruler = &ruler
    let showcmd = &showcmd
    try
        set noruler
        set noshowcmd
        if !empty(style)
            exec 'echohl '. style
        endif
        echo strpart(a:text, 0, &columns - 1)
    finally
        if !empty(style)
            echohl None
        endif
        let &ruler = ruler
        let &showcmd = showcmd
    endtry
endf


" Contributed by Erik Falor:
" If the line containing the message is too long, echoing it will cause 
" a 'Hit ENTER' prompt to appear.  This function cleans up the line so 
" that doesn't happen.
" The echoed line is too long if it is wider than the width of the 
" window, minus cmdline space taken up by the ruler and showcmd 
" features.
function! tlib#notify#TrimMessage(message) "{{{3
    let filler = '...'

    " If length of message with tabs converted into spaces + length of 
    " line number + 2 (for the ': ' that follows the line number) is 
    " greater than the width of the screen, truncate in the middle
    let to_fill = &columns
    " TLogVAR to_fill

    " Account for space used by elements in the command-line to avoid 
    " 'Hit ENTER' prompts.
    " If showcmd is on, it will take up 12 columns.
    " If the ruler is enabled, but not displayed in the statusline, it 
    " will in its default form take 17 columns.  If the user defines a 
    " custom &rulerformat, they will need to specify how wide it is.
    if has('cmdline_info')
        if &showcmd
            let to_fill -= 12
        else
            let to_fill -= 1
        endif
        " TLogVAR &showcmd, to_fill

        " TLogVAR &laststatus, &ruler, &rulerformat
        if &ruler
            if &laststatus == 0 || winnr('$') == 1
                if has('statusline')
                    if &rulerformat == ''
                        " default ruler is 17 chars wide
                        let to_fill -= 17
                    elseif exists('g:MP_rulerwidth')
                        let to_fill -= g:MP_rulerwidth
                    else
                        " tml: fallback: guess length
                        let to_fill -= strlen(&rulerformat)
                    endif
                else
                endif
            endif
        else
        endif
    else
        let to_fill -= 1
    endif

    " TLogVAR to_fill
    " TLogDBG strlen(a:message)
    if strlen(a:message) > to_fill
        let front = to_fill / 2 - 1
        let back  = front 
        if to_fill % 2 == 0 | let back -= 1 | endif
        return strpart(a:message, 0, front) . filler .
                    \strpart(a:message, strlen(a:message) - back)
    else
        return a:message
    endif
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
autoload/tlib/progressbar.vim	[[[1
73
" progressbar.vim
" @Author:      Tom Link (mailto:micathom AT gmail com?subject=[vim])
" @Website:     http://www.vim.org/account/profile.php?user_id=4037
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Created:     2007-09-30.
" @Last Change: 2009-02-15.
" @Revision:    0.0.34

if &cp || exists("loaded_tlib_progressbar_autoload")
    finish
endif
let loaded_tlib_progressbar_autoload = 1

let s:statusline = []
let s:laststatus = []
let s:max = []
let s:format = []
let s:width = []
let s:value = []
let s:timestamp = -1

" EXAMPLE: >
"     call tlib#progressbar#Init(20)
"     try
"         for i in range(20)
"             call tlib#progressbar#Display(i)
"             call DoSomethingThatTakesSomeTime(i)
"         endfor
"     finally
"         call tlib#progressbar#Restore()
"     endtry
function! tlib#progressbar#Init(max, ...) "{{{3
    TVarArg ['format', '%s'], ['width', 10]
    call insert(s:statusline, &statusline)
    call insert(s:laststatus, &laststatus)
    call insert(s:max, a:max)
    call insert(s:format, format)
    call insert(s:width, width)
    call insert(s:value, -1)
    let &laststatus = 2
    let s:timestamp = localtime()
endf


function! tlib#progressbar#Display(value, ...) "{{{3
    TVarArg 'extra'
    let ts = localtime()
    if ts == s:timestamp
        return
    else
        let s:timestamp = ts
    endif
    let val = a:value * s:width[0] / s:max[0]
    if val != s:value[0]
        let s:value[0] = val
        let pbl = repeat('#', val)
        let pbr = repeat('.', s:width[0] - val)
        let &statusline = printf(s:format[0], '['.pbl.pbr.']') . extra
        redrawstatus
    endif
endf


function! tlib#progressbar#Restore() "{{{3
    let &statusline = remove(s:statusline, 0)
    let &laststatus = remove(s:laststatus, 0)
    call remove(s:max, 0)
    call remove(s:format, 0)
    call remove(s:width, 0)
    call remove(s:value, 0)
endf


autoload/tlib/rx.vim	[[[1
63
" rx.vim
" @Author:      Tom Link (micathom AT gmail com?subject=[vim])
" @Website:     http://www.vim.org/account/profile.php?user_id=4037
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Created:     2007-07-20.
" @Last Change: 2009-02-15.
" @Revision:    0.0.26

if &cp || exists("loaded_tlib_rx_autoload")
    finish
endif
let loaded_tlib_rx_autoload = 1


" :def: function! tlib#rx#Escape(text, ?magic='m')
" magic can be one of: m, M, v, V
" See :help 'magic'
function! tlib#rx#Escape(text, ...) "{{{3
    TVarArg 'magic'
    if empty(magic)
        let magic = 'm'
    endif
    if magic =~# '^\\\?m$'
        return escape(a:text, '^$.*\[]~')
    elseif magic =~# '^\\\?M$'
        return escape(a:text, '^$\')
    elseif magic =~# '^\\\?V$'
        return escape(a:text, '\')
    elseif magic =~# '^\\\?v$'
        return substitute(a:text, '[^0-9a-zA-Z_]', '\\&', 'g')
    else
        echoerr 'tlib: Unsupported magic type'
        return a:text
    endif
endf

" :def: function! tlib#rx#EscapeReplace(text, ?magic='m')
" Escape return |sub-replace-special|.
function! tlib#rx#EscapeReplace(text, ...) "{{{3
    TVarArg ['magic', 'm']
    if magic ==# 'm' || magic ==# 'v'
        return escape(a:text, '&~')
    elseif magic ==# 'M' || magic ==# 'V'
        return a:text
    else
        echoerr 'magic must be one of: m, v, M, V'
    endif
endf


function! tlib#rx#Suffixes(...) "{{{3
    TVarArg ['magic', 'm']
    let sfx = split(&suffixes, ',')
    call map(sfx, 'tlib#rx#Escape(v:val, magic)')
    if magic ==# 'v'
        return '('. join(sfx, '|') .')$'
    elseif magic ==# 'V'
        return '\('. join(sfx, '\|') .'\)\$'
    else
        return '\('. join(sfx, '\|') .'\)$'
    endif
endf

autoload/tlib/scratch.vim	[[[1
102
" scratch.vim
" @Author:      Tom Link (micathom AT gmail com?subject=[vim])
" @Website:     http://www.vim.org/account/profile.php?user_id=4037
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Created:     2007-07-18.
" @Last Change: 2009-02-15.
" @Revision:    0.0.128

if &cp || exists("loaded_tlib_scratch_autoload")
    finish
endif
let loaded_tlib_scratch_autoload = 1


" :def: function! tlib#scratch#UseScratch(?keyargs={})
" Display a scratch buffer (a buffer with no file). See :TScratch for an 
" example.
" Return the scratch's buffer number.
function! tlib#scratch#UseScratch(...) "{{{3
    exec tlib#arg#Let([['keyargs', {}]])
    " TLogDBG string(keys(keyargs))
    let id = get(keyargs, 'scratch', '__Scratch__')
    " TLogVAR id
    " TLogDBG winnr()
    " TLogDBG bufnr(id)
    " TLogDBG bufwinnr(id)
    " TLogDBG bufnr('%')
    if id =~ '^\d\+$' && bufwinnr(id) != -1
        if bufnr('%') != id
            exec 'buffer! '. id
        endif
    else
        let bn = bufnr(id)
        let wpos = g:tlib_scratch_pos
        if get(keyargs, 'scratch_vertical')
            let wpos .= ' vertical'
        endif
        " TLogVAR wpos
        if bn != -1
            " TLogVAR bn
            let wn = bufwinnr(bn)
            if wn != -1
                " TLogVAR wn
                exec wn .'wincmd w'
            else
                let cmd = get(keyargs, 'scratch_split', 1) ? wpos.' sbuffer! ' : 'buffer! '
                " TLogVAR cmd
                silent exec cmd . bn
            endif
        else
            " TLogVAR id
            let cmd = get(keyargs, 'scratch_split', 1) ? wpos.' split ' : 'edit '
            " TLogVAR cmd
            silent exec cmd . escape(id, '%#\ ')
            " silent exec 'split '. id
        endif
        let ft = get(keyargs, 'scratch_filetype', '')
        " TLogVAR ft
        " if !empty(ft)
        let &ft=ft
        " end
    endif
    setlocal buftype=nofile
    setlocal bufhidden=hide
    setlocal noswapfile
    setlocal nobuflisted
    setlocal modifiable
    setlocal foldmethod=manual
    setlocal foldcolumn=0
    let keyargs.scratch = bufnr('%')
    return keyargs.scratch
endf


" Close a scratch buffer as defined in keyargs (usually a World).
function! tlib#scratch#CloseScratch(keyargs, ...) "{{{3
    TVarArg ['reset_scratch', 1]
    let scratch = get(a:keyargs, 'scratch', '')
    " TLogVAR scratch, reset_scratch
    " TLogDBG string(tlib#win#List())
    if !empty(scratch)
        let wn = bufwinnr(scratch)
        " TLogVAR wn
        try
            if wn != -1
                " TLogDBG winnr()
                let wb = tlib#win#Set(wn)
                wincmd c
                " exec wb 
                " redraw
                " TLogVAR winnr()
                return 1
            endif
        finally
            if reset_scratch
                let a:keyargs.scratch = ''
            endif
        endtry
    endif
    return 0
endf

autoload/tlib/string.vim	[[[1
156
" string.vim
" @Author:      Tom Link (micathom AT gmail com?subject=[vim])
" @Website:     http://www.vim.org/account/profile.php?user_id=4037
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Created:     2007-06-30.
" @Last Change: 2009-02-15.
" @Revision:    0.0.110

if &cp || exists("loaded_tlib_string_autoload")
    finish
endif
let loaded_tlib_string_autoload = 1


" :def: function! tlib#string#RemoveBackslashes(text, ?chars=' ')
" Remove backslashes from text (but only in front of the characters in 
" chars).
function! tlib#string#RemoveBackslashes(text, ...) "{{{3
    exec tlib#arg#Get(1, 'chars', ' ')
    " TLogVAR chars
    let rv = substitute(a:text, '\\\(['. chars .']\)', '\1', 'g')
    return rv
endf


function! tlib#string#Chomp(string) "{{{3
    return substitute(a:string, '[[:cntrl:][:space:]]*$', '', '')
endf


function! tlib#string#Format(template, dict) "{{{3
    let parts = split(a:template, '\ze%\({.\{-}}\|.\)')
    let out = []
    for part in parts
        let ml   = matchlist(part, '^%\({\(.\{-}\)}\|\(.\)\)\(.*\)$')
        if empty(ml)
            let rest = part
        else
            let var  = empty(ml[2]) ? ml[3] : ml[2]
            let rest = ml[4]
            if has_key(a:dict, var)
                call add(out, a:dict[var])
            elseif var == '%%'
                call add(out, '%')
            else
                call add(out, ml[1])
            endif
        endif
        call add(out, rest)
    endfor
    return join(out, '')
endf


" This function deviates from |printf()| in certain ways.
" Additional items:
"     %{rx}      ... insert escaped regexp
"     %{fuzzyrx} ... insert typo-tolerant regexp
function! tlib#string#Printf1(format, string) "{{{3
    let s = split(a:format, '%.\zs')
    " TLogVAR s
    return join(map(s, 's:PrintFormat(v:val, a:string)'), '')
endf

function! s:PrintFormat(format, string) "{{{3
    let cut = match(a:format, '%\({.\{-}}\|.\)$')
    if cut == -1
        return a:format
    else
        let head = cut > 0 ? a:format[0 : cut - 1] : ''
        let tail = a:format[cut : -1]
        " TLogVAR head, tail
        if tail == '%{fuzzyrx}'
            let frx = []
            for i in range(len(a:string))
                if i > 0
                    let pb = i - 1
                else
                    let pb = 0
                endif
                let slice = tlib#rx#Escape(a:string[pb : i + 1])
                call add(frx, '['. slice .']')
                call add(frx, '.\?')
            endfor
            let tail = join(frx, '')
        elseif tail == '%{rx}'
            let tail = tlib#rx#Escape(a:string)
        elseif tail == '%%'
            let tail = '%'
        elseif tail == '%s'
            let tail = a:string
        endif
        " TLogVAR tail
        return head . tail
    endif
endf
" function! tlib#string#Printf1(format, string) "{{{3
"     let n = len(split(a:format, '%\@<!%s', 1)) - 1
"     let f = a:format
"     if f =~ '%\@<!%{fuzzyrx}'
"         let frx = []
"         for i in range(len(a:string))
"             if i > 0
"                 let pb = i - 1
"             else
"                 let pb = 0
"             endif
"             let slice = tlib#rx#Escape(a:string[pb : i + 1])
"             call add(frx, '['. slice .']')
"             call add(frx, '.\?')
"         endfor
"         let f = s:RewriteFormatString(f, '%{fuzzyrx}', join(frx, ''))
"     endif
"     if f =~ '%\@<!%{rx}'
"         let f = s:RewriteFormatString(f, '%{rx}', tlib#rx#Escape(a:string))
"     endif
"     if n == 0
"         return substitute(f, '%%', '%', 'g')
"     else
"         let a = repeat([a:string], n)
"         return call('printf', insert(a, f))
"     endif
" endf


function! s:RewriteFormatString(format, pattern, string) "{{{3
    let string = substitute(a:string, '%', '%%', 'g')
    return substitute(a:format, tlib#rx#Escape(a:pattern), escape(string, '\'), 'g')
endf


function! tlib#string#TrimLeft(string) "{{{3
    return substitute(a:string, '^[[:space:][:cntrl:]]\+', '', '')
endf


function! tlib#string#TrimRight(string) "{{{3
    return substitute(a:string, '[[:space:][:cntrl:]]\+$', '', '')
endf


function! tlib#string#Strip(string) "{{{3
    return tlib#string#TrimRight(tlib#string#TrimLeft(a:string))
endf


function! tlib#string#Count(string, rx) "{{{3
    let s:count = 0
    call substitute(a:string, a:rx, '\=s:CountHelper()', 'g')
    return s:count
endf

function! s:CountHelper() "{{{3
    let s:count += 1
endf

autoload/tlib/syntax.vim	[[[1
51
" syntax.vim
" @Author:      Tom Link (mailto:micathom AT gmail com?subject=[vim])
" @Website:     http://www.vim.org/account/profile.php?user_id=4037
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Created:     2007-11-19.
" @Last Change: 2009-02-15.
" @Revision:    0.0.11

if &cp || exists("loaded_tlib_syntax_autoload")
    finish
endif
let loaded_tlib_syntax_autoload = 1
let s:save_cpo = &cpo
set cpo&vim


function! tlib#syntax#Collect() "{{{3
    let acc = {}
    let syn = ''
    for line in tlib#cmd#OutputAsList('syntax')
        if line =~ '^---'
            continue
        elseif line =~ '^\w'
            let ml = matchlist(line, '^\(\w\+\)\s\+\(xxx\s\+\(.*\)\|\(cluster.*\)\)$')
            if empty(ml)
                echoerr 'Internal error: '. string(line)
            else
                let [m_0, syn, m_1, m_def1, m_def2; m_rest] = ml
                let acc[syn] = [empty(m_def1) ? m_def2 : m_def1]
            endif
        else
            call add(acc[syn], matchstr(line, '^\s\+\zs.*$'))
        endif
    endfor
    return acc
endf


" :def: function! tlib#syntax#Names(?rx='')
function! tlib#syntax#Names(...) "{{{3
    TVarArg 'rx'
    let names = keys(tlib#syntax#Collect())
    if !empty(rx)
        call filter(names, 'v:val =~ rx')
    endif
    return names
endf


let &cpo = s:save_cpo
unlet s:save_cpo
autoload/tlib/tab.vim	[[[1
55
" tab.vim
" @Author:      Tom Link (micathom AT gmail com?subject=[vim])
" @Website:     http://www.vim.org/account/profile.php?user_id=4037
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Created:     2007-08-27.
" @Last Change: 2009-02-15.
" @Revision:    0.0.29

if &cp || exists("loaded_tlib_tab_autoload")
    finish
endif
let loaded_tlib_tab_autoload = 1


" Return a dictionary of bufnumbers => [[tabpage, winnr] ...]
function! tlib#tab#BufMap() "{{{3
    let acc = {}
    for t in range(tabpagenr('$'))
        let bb = tabpagebuflist(t + 1)
        for b in range(len(bb))
            let bn = bb[b]
            let bd = [t + 1, b + 1]
            if has_key(acc, bn)
                call add(acc[bn], bd)
            else
                let acc[bn] = [bd]
            endif
        endfor
    endfor
    return acc
endf


" Find a buffer's window at some tab page.
function! tlib#tab#TabWinNr(buffer) "{{{3
    let bn = bufnr(a:buffer)
    let bt = tlib#tab#BufMap()
    let tn = tabpagenr()
    let wn = winnr()
    let bc = get(bt, bn)
    if !empty(bc)
        for [t, w] in bc
            if t == tn
                return [t, w]
            endif
        endfor
        return bc[0]
    endif
endf


function! tlib#tab#Set(tabnr) "{{{3
    exec a:tabnr .'tabnext'
endf

autoload/tlib/tag.vim	[[[1
121
" tag.vim
" @Author:      Tom Link (mailto:micathom AT gmail com?subject=[vim])
" @Website:     http://www.vim.org/account/profile.php?user_id=4037
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Created:     2007-11-01.
" @Last Change: 2009-02-15.
" @Revision:    0.0.45

if &cp || exists("loaded_tlib_tag_autoload")
    finish
endif
let loaded_tlib_tag_autoload = 1


" :def: function! tlib#tag#Retrieve(rx, ?extra_tags=0)
" Get all tags matching rx. Basically, this function simply calls 
" |taglist()|, but when extra_tags is true, the list of the tag files 
" (see 'tags') is temporarily expanded with |g:tlib_tags_extra|.
"
" Example use:
" If want to include tags for, eg, JDK, normal tags use can become slow. 
" You could proceed as follows:
"     1. Create a tags file for the JDK sources. When creating the tags 
"     file, make sure to include inheritance information and the like 
"     (command-line options like --fields=+iaSm --extra=+q should be ok).
"     In this example, we want tags only for public methods (there are 
"     most likely better ways to do this): >
"          ctags -R --fields=+iaSm --extra=+q ${JAVA_HOME}/src
"          head -n 6 tags > tags0
"          grep access:public tags >> tags0
" <    2. Say 'tags' included project specific tags files. In 
"      ~/vimfiles/after/ftplugin/java.vim insert: >
"          let b:tlib_tags_extra = $JAVA_HOME .'/tags0'
" <    3. When this function is invoked as >
"          echo tlib#tag#Retrieve('print')
" <    It will return only project-local tags. If it is invoked as >
"          echo tlib#tag#Retrieve('print', 1)
" <    tags from the JDK will be included.
function! tlib#tag#Retrieve(rx, ...) "{{{3
    TVarArg ['extra_tags', 0]
    if extra_tags
        let tags_orig = &l:tags
        if empty(tags_orig)
            setlocal tags<
        endif
        try
            let more_tags = tlib#var#Get('tlib_tags_extra', 'bg')
            if !empty(more_tags)
                let &l:tags .= ','. more_tags
            endif
            let taglist = taglist(a:rx)
        finally
            let &l:tags = tags_orig
        endtry
    else
        let taglist = taglist(a:rx)
    endif
    return taglist
endf


" Retrieve tags that meet the the constraints (a dictionnary of fields and 
" regexp, with the exception of the kind field that is a list of chars). 
" For the use of the optional use_extra argument see 
" |tlib#tag#Retrieve()|.
" :def: function! tlib#tag#Collect(constraints, ?use_extra=1, ?match_front=1)
function! tlib#tag#Collect(constraints, ...) "{{{3
    TVarArg ['use_extra', 0], ['match_end', 1], ['match_front', 1]
    " TLogVAR a:constraints, use_extra
    let rx = get(a:constraints, 'name', '')
    if empty(rx) || rx == '*'
        let rx = '.'
    else
        let rxl = ['\C']
        if match_front
            call add(rxl, '^')
        endif
        " call add(rxl, tlib#rx#Escape(rx))
        call add(rxl, rx)
        if match_end
            call add(rxl, '$')
        endif
        let rx = join(rxl, '')
    endif
    " TLogVAR rx, use_extra
    let tags = tlib#tag#Retrieve(rx, use_extra)
    " TLogDBG len(tags)
    for [field, rx] in items(a:constraints)
        if !empty(rx) && rx != '*'
            " TLogVAR field, rx
            if field == 'kind'
                call filter(tags, 'v:val.kind =~ "['. rx .']"')
            elseif field != 'name'
                call filter(tags, '!empty(get(v:val, field)) && get(v:val, field) =~ rx')
            endif
        endif
    endfor
    return tags
endf


function! tlib#tag#Format(tag) "{{{3
    if has_key(a:tag, 'signature')
        let name = a:tag.name . a:tag.signature
    elseif a:tag.cmd[0] == '/'
        let name = a:tag.cmd
        let name = substitute(name, '^/\^\?\s*', '', '')
        let name = substitute(name, '\s*\$\?/$', '', '')
        let name = substitute(name, '\s\{2,}', ' ', 'g')
        let tsub = tlib#var#Get('tlib_tag_substitute', 'bg')
        if has_key(tsub, &filetype)
            for [rx, rplc, sub] in tsub[&filetype]
                let name = substitute(name, rx, rplc, sub)
            endfor
        endif
    else
        let name = a:tag.name
    endif
    return name
endf

autoload/tlib/time.vim	[[[1
60
" time.vim
" @Author:      Tom Link (mailto:micathom AT gmail com?subject=[vim])
" @Website:     http://www.vim.org/account/profile.php?user_id=4037
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Created:     2007-10-17.
" @Last Change: 2009-02-22.
" @Revision:    0.0.29

if &cp || exists("loaded_tlib_time_autoload")
    finish
endif
let loaded_tlib_time_autoload = 1


function! tlib#time#MSecs() "{{{3
    let rts = reltimestr(reltime())
    return substitute(rts, '\.', '', '')
endf


function! tlib#time#Now() "{{{3
    let rts = reltimestr(reltime())
    let rtl = split(rts, '\.')
    return rtl
endf


function! tlib#time#Diff(a, b, ...) "{{{3
    TVarArg ['resolution', 2]
    let [as, am] = a:a
    let [bs, bm] = a:b
    let rv = 0 + (as - bs)
    if resolution > 0
        let rv .= repeat('0', resolution)
        let am = am[0 : resolution - 1]
        let bm = bm[0 : resolution - 1]
        let rv += (am - bm)
    endif
    return rv
endf


function! tlib#time#DiffMSecs(a, b, ...) "{{{3
    TVarArg ['resolution', 2]
    if a:a == a:b
        return 0
    endif
    let a = printf('%30s', a:a[0 : -(7 - resolution)])
    let b = printf('%30s', a:b[0 : -(7 - resolution)])
    for i in range(0, 29)
        if a[i] != b[i]
            let a = a[i : -1]
            let b = b[i : -1]
            return a - b
        endif
    endfor
    return 0
endf


autoload/tlib/type.vim	[[[1
34
" type.vim
" @Author:      Tom Link (mailto:micathom AT gmail com?subject=[vim])
" @Website:     http://www.vim.org/account/profile.php?user_id=4037
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Created:     2007-09-30.
" @Last Change: 2009-02-15.
" @Revision:    0.0.3

if &cp || exists("loaded_tlib_type_autoload")
    finish
endif
let loaded_tlib_type_autoload = 1

function! tlib#type#IsNumber(expr)
    return type(a:expr) == 0
endf

function! tlib#type#IsString(expr)
    return type(a:expr) == 1
endf

function! tlib#type#IsFuncref(expr)
    return type(a:expr) == 2
endf

function! tlib#type#IsList(expr)
    return type(a:expr) == 3
endf

function! tlib#type#IsDictionary(expr)
    return type(a:expr) == 4
endf


autoload/tlib/url.vim	[[[1
57
" url.vim
" @Author:      Tom Link (micathom AT gmail com?subject=[vim])
" @Website:     http://www.vim.org/account/profile.php?user_id=4037
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Created:     2007-06-30.
" @Last Change: 2009-02-15.
" @Revision:    0.0.26

if &cp || exists("loaded_tlib_url_autoload")
    finish
endif
let loaded_tlib_url_autoload = 1


" TODO: These functions could use printf() now.

" Decode an encoded URL.
function! tlib#url#Decode(url) "{{{3
    return substitute(a:url, '\(+\|%\(%\|\x\x\)\)', '\=tlib#url#DecodeChar(submatch(1))', 'g')
endf


" Decode a single character.
function! tlib#url#DecodeChar(char) "{{{3
    if a:char == '%%'
        return '%'
    elseif a:char == '+'
        return ' '
    else
        return nr2char("0x".a:char[1 : -1])
    endif
endf


" Encode a single character.
function! tlib#url#EncodeChar(char) "{{{3
    if a:char == '%'
        return '%%'
    elseif a:char == ' '
        return '+'
    else
        return printf("%%%X", char2nr(a:char))
    endif
endf


" Encode an url.
function! tlib#url#Encode(url, ...) "{{{3
    TVarArg ['extrachars', '']
    let rx = '\([^a-zA-Z0-9_.'. extrachars .'-]\)'
    " TLogVAR a:url, rx
    let rv = substitute(a:url, rx, '\=tlib#url#EncodeChar(submatch(1))', 'g')
    " TLogVAR rv
    return rv
endf


autoload/tlib/var.vim	[[[1
85
" var.vim
" @Author:      Tom Link (micathom AT gmail com?subject=[vim])
" @Website:     http://www.vim.org/account/profile.php?user_id=4037
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Created:     2007-06-30.
" @Last Change: 2009-02-15.
" @Revision:    0.0.23

if &cp || exists("loaded_tlib_var_autoload")
    finish
endif
let loaded_tlib_var_autoload = 1


" Define a variable called NAME if yet undefined.
" You can also use the :TLLet command.
"
" EXAMPLES: >
"   exec tlib#var#Let('g:foo', 1)
"   TLet g:foo = 1
function! tlib#var#Let(name, val) "{{{3
    return printf('if !exists(%s) | let %s = %s | endif', string(a:name), a:name, string(a:val))
    " return printf('if !exists(%s) | let %s = %s | endif', string(a:name), a:name, a:val)
endf


" :def: function! tlib#var#EGet(var, namespace, ?default='')
" Retrieve a variable by searching several namespaces.
"
" EXAMPLES: >
"   let g:foo = 1
"   let b:foo = 2
"   let w:foo = 3
"   echo eval(tlib#var#EGet('foo', 'vg'))  => 1
"   echo eval(tlib#var#EGet('foo', 'bg'))  => 2
"   echo eval(tlib#var#EGet('foo', 'wbg')) => 3
function! tlib#var#EGet(var, namespace, ...) "{{{3
    let pre  = []
    let post = []
    for namespace in split(a:namespace, '\zs')
        let var = namespace .':'. a:var
        call add(pre,  printf('exists("%s") ? %s : (', var, var))
        call add(post, ')')
    endfor
    let default = a:0 >= 1 ? a:1 : ''
    return join(pre) . string(default) . join(post)
endf


" :def: function! tlib#var#Get(var, namespace, ?default='')
" Retrieve a variable by searching several namespaces.
"
" EXAMPLES: >
"   let g:foo = 1
"   let b:foo = 2
"   let w:foo = 3
"   echo tlib#var#Get('foo', 'bg')  => 1
"   echo tlib#var#Get('foo', 'bg')  => 2
"   echo tlib#var#Get('foo', 'wbg') => 3
function! tlib#var#Get(var, namespace, ...) "{{{3
    for namespace in split(a:namespace, '\zs')
        let var = namespace .':'. a:var
        if exists(var)
            return eval(var)
        endif
    endfor
    return a:0 >= 1 ? a:1 : ''
endf


" :def: function! tlib#var#List(rx, ?prefix='')
" Get a list of variables matching rx.
" EXAMPLE:
"   echo tlib#var#List('tlib_', 'g:')
function! tlib#var#List(rx, ...) "{{{3
    TVarArg ['prefix', '']
    redir => vars
    silent! exec 'let '. prefix
    redir END
    let varlist = split(vars, '\n')
    call map(varlist, 'matchstr(v:val, ''^\S\+'')')
    call filter(varlist, 'v:val =~ a:rx')
    return varlist
endf

autoload/tlib/win.vim	[[[1
127
" win.vim
" @Author:      Tom Link (micathom AT gmail com?subject=[vim])
" @Website:     http://www.vim.org/account/profile.php?user_id=4037
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Created:     2007-08-24.
" @Last Change: 2009-02-15.
" @Revision:    0.0.47

if &cp || exists("loaded_tlib_win_autoload")
    finish
endif
let loaded_tlib_win_autoload = 1


" Return vim code to jump back to the original window.
function! tlib#win#Set(winnr) "{{{3
    if a:winnr > 0
        " TLogVAR a:winnr
        " TLogDBG winnr()
        " TLogDBG string(tlib#win#List())
        if winnr() != a:winnr && winbufnr(a:winnr) != -1
            let rv = winnr().'wincmd w'
            exec a:winnr .'wincmd w'
            " TLogVAR rv
            " TLogDBG string(tlib#win#List())
            return rv
        endif
    endif
    return ''
endf
 

" :def: function! tlib#win#GetLayout(?save_view=0)
function! tlib#win#GetLayout(...) "{{{3
    TVarArg ['save_view', 0]
    let views = {}
    if save_view
        let winnr = winnr()
        for w in range(1, winnr('$'))
            call tlib#win#Set(w)
            let views[w] = winsaveview()
        endfor
        call tlib#win#Set(winnr)
    endif
    return {'winnr': winnr('$'), 'winrestcmd': winrestcmd(), 'views': views, 'cmdheight': &cmdheight}
endf


function! tlib#win#SetLayout(layout) "{{{3
    if a:layout.winnr == winnr('$')
        " TLogVAR a:layout.winrestcmd
        " TLogDBG string(tlib#win#List())
        exec a:layout.winrestcmd
        if !empty(a:layout.views)
            let winnr = winnr()
            " TLogVAR winnr
            for [w, v] in items(a:layout.views)
                call tlib#win#Set(w)
                call winrestview(v)
            endfor
            call tlib#win#Set(winnr)
        endif
        if a:layout.cmdheight != &cmdheight
            let &cmdheight = a:layout.cmdheight
        endif
        " TLogDBG string(tlib#win#List())
        return 1
    endif
    return 0
endf


function! tlib#win#List() "{{{3
    let wl = {}
    for wn in range(1, winnr('$'))
        let wl[wn] = bufname(winbufnr(wn))
    endfor
    return wl
endf


" " :def: function! tlib#win#GetLayout1(?save_view=0)
" " Contrary to |tlib#win#GetLayout|, this version doesn't use 
" " |winrestcmd()|. It can also save windows views.
" function! tlib#win#GetLayout1(...) "{{{3
"     TVarArg ['save_view', 0]
"     let winnr = winnr()
"     let acc = {}
"     for w in range(1, winnr('$'))
"         let def = {'h': winheight(w), 'w': winwidth(w)}
"         if save_view
"             call tlib#win#Set(w)
"             let def.view = winsaveview()
"         endif
"         let acc[w] = def
"     endfor
"     call tlib#win#Set(winnr)
"     return acc
" endf
" 
" 
" " Reset layout from the value of |tlib#win#GetLayout1|.
" function! tlib#win#SetLayout1(layout) "{{{3
"     if len(a:layout) != winnr('$')
"         return 0
"     endif
"     let winnr = winnr()
"     for [w, def] in items(a:layout)
"         if tlib#win#Set(w)
"             exec 'resize '. def.h
"             exec 'vertical resize '. def.w
"             if has_key(def, 'view')
"                 call winrestview(def.view)
"             endif
"         else
"             break
"         endif
"     endfor
"     call tlib#win#Set(winnr)
"     return 1
" endf


function! tlib#win#Width(wnr) "{{{3
    return winwidth(a:wnr) - &fdc
endf

autoload/tlib.vim	[[[1
15
" tlib.vim
" @Author:      Tom Link (micathom AT gmail com?subject=[vim])
" @Website:     http://www.vim.org/account/profile.php?user_id=4037
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Created:     2007-07-17.
" @Last Change: 2009-02-15.
" @Revision:    0.0.5

if &cp || exists("loaded_tlib_autoload")
    finish
endif
let loaded_tlib_autoload = 1

" Dummy file for backwards compatibility.

