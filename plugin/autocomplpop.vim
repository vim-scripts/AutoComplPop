
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" autocomplpop.vim - Automatically open popup menu for completion
" Last Change:  02-May-2007.
" Author:       Takeshi Nishida <isskr@is.skr.jp>
" Version:      0.1, for Vim 7.0
" Licence:      MIT Licence
"
" Description:  In insert mode, open popup menu for completion when input several 
"               charactors. This plugin works by mapping alphanumeric characters
"               and underscore.
"  
"
" Installation: Drop this file in your plugin directory.
"               Set as below:
"                   :set completeopt+=menuone " Needed
"                   :set complete-=i          " Recommended
"                   :set complete-=t          " Recommended
"
" Usage:        :AutoComplPopEnable
"                   Activate automatic popup menu
"               :AutoComplPopDisable
"                   Stop automatic popup menu
"
" Options:      See section setting global value below.
"
"
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

if exists("b:loaded_AutoComplPop")
    finish
endif
let b:loaded_AutoComplPop = 1


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Map lowercase letters as trigger to open popup menu
if !exists('g:AutoComplPop_MapLower') 
    let g:AutoComplPop_MapLower = 1
endif

" Map uppercase letters as trigger to open popup menu
if !exists('g:AutoComplPop_MapUpper') 
    let g:AutoComplPop_MapUpper = 1
endif

" Map digits as trigger to open popup menu
if !exists('g:AutoComplPop_MapDigit') 
    let g:AutoComplPop_MapDigit = 1
endif

" Map each string of this list as trigger to open popup menu
if !exists('g:AutoComplPop_MapMore') 
    let g:AutoComplPop_MapMore = ['_']
endif

" Do not open popup menu if length of inputting word is less than this
if !exists('g:AutoComplPop_MinLength') 
    let g:AutoComplPop_MinLength = 2
endif

" Do not open popup menu if length of inputting word is more than this
if !exists('g:AutoComplPop_MaxLength') 
    let g:AutoComplPop_MaxLength = 999
endif

" Insert this to open popup menu
if !exists('g:AutoComplPop_PopupCmd') 
    let g:AutoComplPop_PopupCmd = "\<C-N>"
endif

" Insert this next to g:AutoComplPop_PopupCmd
if !exists('g:AutoComplPop_AdditionalCmd') 
    let g:AutoComplPop_AdditionalCmd = "\<C-R>=pumvisible() ? \"\\<C-N>\\<C-P>\" : \"\"\<CR>"
endif


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

command! -narg=0 -bar AutoComplPopEnable call <SID>Enable()
command! -narg=0 -bar AutoComplPopDisable call <SID>Disable()


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

let s:MapList = []


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! <SID>InsertAndPopup(input)
    if pumvisible()
        echo 'pumvisible() == TRUE'
        return a:input
    endif

    let last_word = matchstr(strpart(getline('.'), 0, col('.') - 1) . a:input, '^.*\zs\<\k\{-}$')
    let last_word_len = len(last_word)
    if last_word_len < g:AutoComplPop_MinLength || last_word_len > g:AutoComplPop_MaxLength
        return a:input
    endif

    return a:input . g:AutoComplPop_PopupCmd . g:AutoComplPop_AdditionalCmd
endfunction


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! <SID>Enable()
    if !empty(s:MapList)
        call <SID>Disable()
    endif

    if g:AutoComplPop_MapLower
        let nr = char2nr('a')
        while nr <= char2nr('z')
            call add(s:MapList, nr2char(nr))
            let nr = nr + 1
        endwhile
    endif

    if g:AutoComplPop_MapUpper
        let nr = char2nr('A')
        while nr <= char2nr('Z')
            call add(s:MapList, nr2char(nr))
            let nr = nr + 1
        endwhile
    endif

    if g:AutoComplPop_MapDigit
        let nr = char2nr('0')
        while nr <= char2nr('9')
            call add(s:MapList, nr2char(nr))
            let nr = nr + 1
        endwhile
    endif

    call extend(s:MapList, g:AutoComplPop_MapMore)

    for item in s:MapList
        execute 'inoremap <expr> ' . item . ' <SID>InsertAndPopup("'. item . '")'
    endfor
endfunction


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! <SID>Disable()
    if !empty(s:MapList)
        for item in s:MapList
            execute 'iunmap ' . item
        endfor

        unlet s:MapList[0:]
    endif
endfunction


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

