
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" autocomplpop.vim - Automatically open popup menu for completion.
" Last Change:  09-May-2007.
" Author:       Takeshi Nishida <isskr@is.skr.jp>
" Version:      0.3, for Vim 7.0
" Licence:      MIT Licence
"
" Description:  In insert mode, open popup menu for completion when input several 
"               charactors. This plugin works by mapping alphanumeric characters
"               and underscore.
"
" Installation: Drop this file in your plugin directory.
"               Set as below:
"                   :set complete-=i " Recommended
"                   :set complete-=t " Recommended
"
" Usage:        :AutoComplPopEnable
"                   Activate automatic popup menu
"               :AutoComplPopDisable
"                   Stop automatic popup menu
"
" Options:      See section setting global value below.
"
" ChangeLog:    0.3: Fixed the problem that the original text is not restored if 
"                    'longest' is not set in 'completeopt'. Now the plugin works 
"                    whether or not 'longest' is set in 'completeopt', and also
"                    'menuone'.
"               0.2: When completion matches are not found, insert CTRL-E to stop
"                    completion.
"                    Clear the echo area.
"                    Fixed the problem in case of dividing words by symbols, popup
"                    menu is not opened.
"               0.1: First release.
"
"
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

if exists("loaded_AutoComplPop")
    finish
endif
let loaded_AutoComplPop = 1


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


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

command! -narg=0 -bar AutoComplPopEnable call <SID>Enable()
command! -narg=0 -bar AutoComplPopDisable call <SID>Disable()


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

let s:MapList = []


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! g:AutoComplPop_InsertPostProcessing(restore)
    echo ""

    if !a:restore
        let restore_cmd = ""
    elseif &completeopt =~ '\clongest'
        let restore_cmd = "\<C-N>\<C-P>" " restore to original text
    else
        let restore_cmd = "\<C-P>"       " restore to original text
    endif

    if pumvisible()
        return restore_cmd
    endif

    return restore_cmd . "\<Space>\<C-H>" " End completion

endfunction


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! <SID>InsertAndPopup(input)
    if pumvisible()
        return a:input . "\<C-R>=g:AutoComplPop_InsertPostProcessing(0)\<CR>"
    endif

    let last_word = matchstr(strpart(getline('.'), 0, col('.') - 1) . a:input, '^.*\zs\<\k\{-}$')
    let last_word_len = len(last_word)
    if last_word_len < g:AutoComplPop_MinLength || last_word_len > g:AutoComplPop_MaxLength
        " End Completion in case of dividing words by symbols. (e.g. 'for(int', 'value_a==value_b')
        return a:input . "\<C-R>=g:AutoComplPop_InsertPostProcessing(0)\<CR>"
    endif

    return a:input . g:AutoComplPop_PopupCmd . "\<C-R>=g:AutoComplPop_InsertPostProcessing(1)\<CR>"
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

