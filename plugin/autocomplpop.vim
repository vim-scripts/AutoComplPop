""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" autocomplpop.vim - Automatically open the popup menu for completion.
" Last Change:  08-Aug-2007.
" Author:       Takeshi Nishida <ns9tks(at)ns9tks.net>
" Version:      1.0, for Vim 7.0
" Licence:      MIT Licence
"
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Description:
"     In insert mode, open the popup menu for completion when input several
"     charactors. This plugin works by mapping alphanumeric characters and
"     underscore.
"
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Installation:
"     Drop this file in your plugin directory.
"
"
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Usage:
"     :AutoComplPopEnable
"         Activate automatic popup menu
"     :AutoComplPopDisable
"         Stop automatic popup menu
"     :AutoComplPopLock
"         Suspend
"     :AutoComplPopUnlock
"         Resume after :AutoComplPopLock
"
"
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Options:
"     See a section setting global value below.
"
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" ChangeLog:
"     1.0:
"         g:AutoComplPop_LoadAndEnable option for a startup activation is
"         added.
"         AutoComplPopLock command and AutoComplPopUnlock command are added to
"         suspend and resume.
"         'completeopt' and 'complete' options are changed temporarily while
"         completing by this script.
"     0.4:
"         The first match are selected when the popup menu is Opened. You can
"         insert the first match with CTRL-Y.
"     0.3:
"         Fixed the problem that the original text is not restored if
"         'longest' is not set in 'completeopt'. Now the plugin works whether
"         or not 'longest' is set in 'completeopt', and also 'menuone'.
"     0.2:
"         When completion matches are not found, insert CTRL-E to stop
"         completion.
"         Clear the echo area.
"         Fixed the problem in case of dividing words by symbols, popup menu
"         is not opened.
"     0.1:
"         First release.
"
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Thanks:       vimtip #1386
"
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

if exists("loaded_AutoComplPop")
    finish
endif
let loaded_AutoComplPop = 1


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Activate automatic popup menu if this file is loaded
if !exists('g:AutoComplPop_LoadAndEnable')
    let g:AutoComplPop_LoadAndEnable = 0
endif

" Map each string of this list as trigger to open the popup menu.
if !exists('g:AutoComplPop_MapList')
    let g:AutoComplPop_MapList = ['a','b','c','d','e','f','g','h','i','j','k','l','m',
                \                 'n','o','p','q','r','s','t','u','v','w','x','y','z',
                \                 'A','B','C','D','E','F','G','H','I','J','K','L','M',
                \                 'N','O','P','Q','R','S','T','U','V','W','X','Y','Z',
                \                 '0','1','2','3','4','5','6','7','8','9','_']
endif

" Do not open the popup menu if length of inputting word is less than this.
if !exists('g:AutoComplPop_MinLength')
    let g:AutoComplPop_MinLength = 2
endif

" Do not open the popup menu if length of inputting word is more than this.
if !exists('g:AutoComplPop_MaxLength')
    let g:AutoComplPop_MaxLength = 999
endif

" Insert this to open the popup menu.
if !exists('g:AutoComplPop_PopupCmd')
    let g:AutoComplPop_PopupCmd = "\<C-N>"
endif

" Set this to 'complete' when open the popup menu
if !exists('g:AutoComplPop_CompleteOption')
    let g:AutoComplPop_CompleteOption = '.,w,b'
endif


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

command! -narg=0 -bar AutoComplPopEnable  call <SID>Enable()
command! -narg=0 -bar AutoComplPopDisable call <SID>Disable()
command! -narg=0 -bar AutoComplPopLock    call <SID>Lock()
command! -narg=0 -bar AutoComplPopUnlock  call <SID>Unlock()


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

let s:MapList = []
let s:lockCount = 0


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! g:AutoComplPop_OpenPopupMenu(nRetry)
    let s:_completeopt = &completeopt
    set completeopt=menuone

    let s:_complete = &complete
    let &complete = g:AutoComplPop_CompleteOption

    return g:AutoComplPop_PopupCmd . "\<C-R>=g:AutoComplPop_AfterOpenPopupMenu(" . a:nRetry . ")\<CR>"
endfunction


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! g:AutoComplPop_AfterOpenPopupMenu(nRetry)
    let &completeopt = s:_completeopt
    let &complete = s:_complete

    if pumvisible()
        " a command to restore to original text and select the first match
        return "\<C-P>\<Down>"
    elseif a:nRetry > 0
        " In case of dividing words by symbols while popup menu is visible,
        " popup is not available unless input <C-E> (e.g. 'for(int', 'a==b')
        return "\<C-E>\<C-R>=g:AutoComplPop_OpenPopupMenu(" . (a:nRetry - 1) . ")\<CR>"
    else
        return "\<C-E>"
    endif 
endfunction


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! <SID>InsertAndPopup(input)
    if s:lockCount > 0 || pumvisible()
        return a:input
    endif

    let last_word_len = len(matchstr(strpart(getline('.'), 0, col('.') - 1) . a:input,
                \                    '^.*\zs\<\k\{-}$'))
    if last_word_len < g:AutoComplPop_MinLength || last_word_len > g:AutoComplPop_MaxLength
        return a:input
    endif

    if last_word_len == g:AutoComplPop_MinLength
        let nRetry = 1
    else
        let nRetry = 0
    endif

    return a:input  . "\<C-R>=g:AutoComplPop_OpenPopupMenu(" . nRetry . ")\<CR>"
endfunction


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! <SID>Enable()
    if !empty(s:MapList)
        call <SID>Disable()
    endif

    let s:MapList = deepcopy(g:AutoComplPop_MapList)

    for item in s:MapList
        execute 'inoremap <silent> <expr> ' . item . ' <SID>InsertAndPopup("'. item . '")'
    endfor
endfunction


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! <SID>Disable()
    if !empty(s:MapList)
        for item in s:MapList
            execute 'iunmap ' . item
        endfor

        unlet s:MapList[0:]
        let s:lockCount = 0
    endif
endfunction


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! <SID>Lock()
    let s:lockCount += 1
endfunction


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! <SID>Unlock()
    let s:lockCount -= 1
    if s:lockCount < 0
        let s:lockCount = 0
        throw "autocomplpop: not locked" 
    endif
endfunction


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

if g:AutoComplPop_LoadAndEnable
    AutoComplPopEnable
endif


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

