let g:tex_flavor='latex'

let g:Tex_Debug = 1
let g:Tex_UseMakefile = 0
setlocal noguipty
" TCTarget dvi
"
" this is mostly a matter of taste. but LaTeX looks good with just a bit
" of indentation.
set sw=2
" TIP: if you write your \label's as \label{fig:something}, then if you
" type in \ref{fig: and press <C-n> you will automatically cycle through
" all the figure labels. Very useful!
set iskeyword+=:

" A comma seperated list of formats which need multiple compilations to be
" correctly compiled.
let g:Tex_DefaultTargetFormat = 'tex'
let g:Tex_MultipleCompileFormats = 'pdf'

" let g:Tex_EscapeChars = '{}¥'
let g:Tex_CompileRule_dvi = ':'
" let g:Tex_CompileRule_dvi = 'texi2dvi $* && bibtex $* && texi2dvi $*'
" let g:Tex_CompileRule_dvi = 'latex -interaction=nonstopmode $*'
" let g:Tex_CompileRule_dvi = 'latex -src-specials -interaction=nonstopmode $*'
" let g:Tex_CompileRule_dvi = 'latex $*'
" let g:Tex_CompileRule_ps = 'dvips -Ppdf -o $*.ps $*.dvi'

" ways to generate pdf files. there are soo many...
" NOTE: pdflatex generates the same output as latex. therefore quickfix is
"       possible.
" let g:Tex_CompileRule_pdf = 'pdflatex -interaction=nonstopmode $*'
" let g:Tex_CompileRule_pdf = 'ps2pdf $*.ps'
let g:Tex_CompileRule_pdf = ':'
" let g:Tex_CompileRule_pdf = 'dvipdfmx $*.dvi'
let g:Tex_FormatDependency_pdf = ''
" let g:Tex_FormatDependency_pdf = 'dvi'
" let g:Tex_CompileRule_pdf = 'dvipdf $*.dvi'
" let g:Tex_CompileRule_pdfmx = 'dvipdfmx $*.dvi'

" let g:Tex_CompileRule_html = 'latex2html $*.tex'
let g:Tex_ViewRule_dvi = 'xdvi'
" let g:Tex_ViewRule_ps = 'ghostview'
let g:Tex_ViewRule_pdf = 'xpdf'
" let g:Tex_ViewRule_pdfmx = 'foxit'
" the option below specifies an editor for the dvi viewer while starting
" up the dvi viewer according to Dimitri Antoniou's tip on vim.sf.net (tip
" #225)
let g:Tex_UseEditorSettingInDVIViewer = 0
set nu
