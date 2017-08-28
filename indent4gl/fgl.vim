" Description: Informix 4GL/4Js 4GL indent script  
" Author:      Omar VP
" Update:      28/08/2017

if exists("b:did_indent")
    finish
endif
let b:did_indent = 1

setlocal indentexpr=GetFglIndent(v:lnum)
setlocal indentkeys&
setlocal indentkeys+==~MAIN,=~ELSE,=~END,=~WHEN,=~OTHERWISE,=~ON,=~COMMAND,=~BEFORE,=~AFTER,=~INPUT,=~CONSTRUCT,=~MENU,=~CASE,=~GLOBALS,=~ORDER,=~FORMAT,=~PAGE,=~FIRST,=~FUNCTION,=~REPORT,=~FIELD,=~EXECUTE,=~CALL,=~PREPARE,=~DECLARE,=~LET,=~DEFINE,=~OPEN,=~IF,=~RETURNING

" Only define the function once.
if exists("*GetFglIndent")
    finish
endif

function GetFglIndent(lnum)
    let this_line = getline(a:lnum)
    let lnum = prevnonblank(a:lnum - 1)
    let previous_line = getline(lnum)

    " Hit the start of the file
    " Let function/report/reprot sub-blocks starts on the first column always
    if lnum == 0 || 
       \ this_line =~# '^\s*\<\(MAIN\|FORMAT\|OUTPUT\)\>\s*$' ||
       \ this_line =~# '^\s*\<\(BEFORE\|AFTER\)\>\s*GROUP\s*OF.*$' ||
       \ this_line =~# '^\s*\<\(FUNCTION\|REPORT\|FIRST\|PAGE\)\>' || 
       \ this_line =~# '^\s*--#\<\(END FUNCTION\)\>' ||
       \ this_line =~# '^\s*--@\<\(END FUNCTION\)\>' ||
       \ this_line =~# '^\s*\<\(END FUNCTION\)\>'
       return 0
    endif

    let ind = indent(lnum)

    if b:mult_line_end == 1
       let ind = ind - &sw
       let b:mult_line_end = 0
    endif   

    if b:mult_line == 1 && this_line !~# '^.*,\s*$'
       let b:mult_line = 0
       let b:mult_line_end = 1
    endif   

    " Add
    if  previous_line =~# '^\s*CALL .*,\s*$' ||
        \ previous_line =~# '^\s*DEFINE .*,\s*$' ||
        \ previous_line =~# '^\s*OPEN .*USING\s*$' ||
        \ previous_line =~# '^\s*PUT .*FROM\s*$' ||
        \ previous_line =~# '^\s*LET .*,\s*$' ||
        \ previous_line =~# '^\s*LET .*=\s*$' ||
        \ previous_line =~# '^\s*PRINT COLUMN .*,\s*$' ||
        \ previous_line =~# '^\s*EXECUTE .*USING\s*$' ||
        \ previous_line =~# '^\s*OUTPUT\s*$' 
      let ind = ind + &sw
      let b:mult_line = 1

    elseif previous_line =~# '^\s*\<\(MAIN\|FUNCTION\|REPORT\|CASE\|IF\|ELSE\|DO\|FOR\|WHILE\|OTHERWISE\|COMMAND\|BEFORE\|AFTER\|WHEN\|ON\|FORMAT\|PAGE\s\+HEADER\|FIRST\|FOREACH\|MENU\|INPUT\|CONSTRUCT\|OPTIONS\|GLOBALS\)\>' || 
        \ previous_line =~# '^\s*--#\<\(FUNCTION\|IF\|ELSE\)\>'
      let ind = ind + &sw

      if previous_line =~# '^\s*\<\(MENU\|CASE\|INPUT\|CONSTRUCT\)\>\s*.*$'
         let b:no_indent=1 
      endif
      if previous_line =~# '^.*END IF\s*$'
         let ind = ind - &sw
      endif
    elseif previous_line =~# '^.*RECORD\s*$' && previous_line !~# '^\s*#'
          "================================================
          "variable record
          "   field like table.column
          "end record
          "================================================
         let ind = ind + &sw
    endif

    " Subtract
    if this_line =~# '^\s*\<END\>\s\+\<\(CASE\|MENU\|INPUT\|CONSTRUCT\|GLOBALS\)\>'
       if previous_line !~# '^\s*\<\(CASE\|MENU\|INPUT\|CONSTRUCT\|GLOBALS\)>'
          let ind = ind - 2 * &sw
       else
          let ind = ind - &sw
       endif
    elseif this_line =~# '^\s*\<\(ELSE\|END\)\>\s*.*$' ||
        \ this_line =~# '^\s*--#\<\(ELSE\|END\)\>\s*.*$'
          let ind = ind - &sw

    elseif this_line =~# '^\s*\<\(WHEN\|OTHERWISE\|COMMAND\|ON\|BEFORE\s\+\<\(INPUT\|MENU\|CONSTRUCT\|FIELD\)\>\|AFTER\s\+\<\(INPUT\|CONSTRUCT\|FIELD\)\>\)\>\s*.*$'
       "================================================
       "unindent for sub command blocks
       "================================================
       if b:no_indent==1 
          let b:no_indent=0
       else
          let ind = ind - &sw
       endif
    elseif this_line =~# '^\s*\<THEN\>\s*.*$'
       "================================================
       "if expression
       "then
       "   statement ...
       "================================================
       if previous_line =~# '^\s*\<IF\>\s\+.*$'
          let ind = ind - &sw
       endif
    elseif previous_line =~# '^\s*END RECORD\s*$'
       let ind = ind - &sw
    endif

    return ind
endfunction

