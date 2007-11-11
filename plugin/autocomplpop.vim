""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" autocomplpop.vim - Automatically open the popup menu for completion.
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"
" Last Change:  12-Nov-2007.
" Author:       Takeshi Nishida <ns9tks(at)ns9tks.net>
" Version:      1.1, for Vim 7.0
" Licence:      MIT Licence
"
"-----------------------------------------------------------------------------
" Description:
"   Install this plugin and your vim comes to automatically opens the popup
"   menu for completion when you input a few charactors in a insert mode. This
"   plugin works by mapping alphanumeric characters and underscore.
"
"-----------------------------------------------------------------------------
" Installation:
"   Drop this file in your plugin directory.
"
"-----------------------------------------------------------------------------
" Usage:
"   If this plugin has been installed, the auto-popup is enabled at startup by
"   default.
"
"   Commands:
"       :AutoComplPopEnable
"           It makes mappings for the auto-popup.
"       :AutoComplPopDisable
"           It removes mappings for the auto-popup.
"       :AutoComplPopLock
"           Suspend the auto-popup.
"       :AutoComplPopUnlock
"           Resume the auto-popup after :AutoComplPopLock.
"
"-----------------------------------------------------------------------------
" Options:
"   g:AutoComplPop_NotEnableAtStartup:
"       The auto-popup is not enabled at startup if non-zero is set.
"
"   g:AutoComplPop_MapList:
"       Map each string of this list as trigger to open the popup menu.
"
"   g:AutoComplPop_MinLength:
"       It does not open the popup menu if the length of inputting word is
"       less than this.
"
"   g:AutoComplPop_MaxLength:
"       It does not open the popup menu if the length of inputting word is
"       more than this.
"
"   g:AutoComplPop_IgnoreCaseOption
"       It set this to 'ignorecase' when opens the popup menu.
"
"   g:AutoComplPop_PopupCmd:
"       It inserts this to open the popup menu.
"
"   g:AutoComplPop_CompleteOption:
"       It set this to 'complete' when opens the popup menu.
"
"-----------------------------------------------------------------------------
" Thanks:
"   vimtip #1386
"
"-----------------------------------------------------------------------------
" ChangeLog:
"   1.2:
"       - Fixed bugs related to 'completeopt'.
"
"   1.1:
"       - Added g:AutoComplPop_IgnoreCaseOption option.
"       - Added g:AutoComplPop_NotEnableAtStartup option.
"       - Removed g:AutoComplPop_LoadAndEnable option.
"   1.0:
"       - g:AutoComplPop_LoadAndEnable option for a startup activation is
"         added.
"       - AutoComplPopLock command and AutoComplPopUnlock command are added to
"         suspend and resume.
"       - 'completeopt' and 'complete' options are changed temporarily while
"         completing by this script.
"
"   0.4:
"       - The first match are selected when the popup menu is Opened. You can
"         insert the first match with CTRL-Y.
"
"   0.3:
"       - Fixed the problem that the original text is not restored if
"         'longest' is not set in 'completeopt'. Now the plugin works whether
"         or not 'longest' is set in 'completeopt', and also 'menuone'.
"
"   0.2:
"       - When completion matches are not found, insert CTRL-E to stop
"         completion.
"       - Clear the echo area.
"       - Fixed the problem in case of dividing words by symbols, popup menu
"         is not opened.
"
"   0.1:
"       - First release.
"
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" INCLUDE GUARD:
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

if exists('loaded_autocomplpop') || v:version < 700
    finish
endif
let loaded_autocomplpop = 1


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" INITIALIZATION FUNCTION:
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! <SID>Initialize()
    "-------------------------------------------------------------------------
    " CONSTANTS
    let s:map_list = []
    let s:lock_count = 0

    "-------------------------------------------------------------------------
    " OPTIONS
    ".........................................................................
    if !exists('g:AutoComplPop_NotEnableAtStartup')
        let g:AutoComplPop_NotEnableAtStartup = 0
    endif
    ".........................................................................
    if !exists('g:AutoComplPop_MapList')
        let g:AutoComplPop_MapList = ['a','b','c','d','e','f','g','h','i','j','k','l','m',
                    \                 'n','o','p','q','r','s','t','u','v','w','x','y','z',
                    \                 'A','B','C','D','E','F','G','H','I','J','K','L','M',
                    \                 'N','O','P','Q','R','S','T','U','V','W','X','Y','Z',
                    \                 '0','1','2','3','4','5','6','7','8','9','_']
    endif
    ".........................................................................
    if !exists('g:AutoComplPop_MinLength')
        let g:AutoComplPop_MinLength = 2
    endif
    ".........................................................................
    if !exists('g:AutoComplPop_MaxLength')
        let g:AutoComplPop_MaxLength = 999
    endif
    ".........................................................................
    if !exists('g:AutoComplPop_IgnoreCaseOption')
        let g:AutoComplPop_IgnoreCaseOption = 0
    endif
    ".........................................................................
    if !exists('g:AutoComplPop_PopupCmd')
        let g:AutoComplPop_PopupCmd = "\<C-n>"
    endif
    ".........................................................................
    if !exists('g:AutoComplPop_CompleteOption')
        let g:AutoComplPop_CompleteOption = '.,w,b'
    endif

    "-------------------------------------------------------------------------
    " COMMANDS
    command! -bar -narg=0 AutoComplPopEnable  call <SID>Enable()
    command! -bar -narg=0 AutoComplPopDisable call <SID>Disable()
    command! -bar -narg=0 AutoComplPopLock    call <SID>Lock()
    command! -bar -narg=0 AutoComplPopUnlock  call <SID>Unlock()

    "-------------------------------------------------------------------------
    " AUTOCOMMANDS
        augroup AutoComplPop_GlobalAutoCommand
            autocmd!
            autocmd CursorMovedI * call <SID>OnCursorMovedI()
            autocmd InsertLeave  * call <SID>OnInsertLeave()
        augroup END

    "-------------------------------------------------------------------------
    " ETC
    if !g:AutoComplPop_NotEnableAtStartup
        AutoComplPopEnable
    endif

endfunction


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" FUNCTIONS:
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

"-----------------------------------------------------------------------------
function! <SID>Enable()
    if !empty(s:map_list)
        call <SID>Disable()
    endif

    let s:map_list = deepcopy(g:AutoComplPop_MapList)

    for item in s:map_list
        execute 'inoremap <silent> <expr> ' . item . ' <SID>FeedKeysAndPopup("' . item . '")'
    endfor
endfunction


"-----------------------------------------------------------------------------
function! <SID>Disable()
    if !empty(s:map_list)
        for item in s:map_list
            execute 'iunmap ' . item
        endfor

        unlet s:map_list[0:]
        let s:lock_count = 0
    endif
endfunction

"-----------------------------------------------------------------------------
function! <SID>Lock()
    let s:lock_count += 1
endfunction

"-----------------------------------------------------------------------------
function! <SID>Unlock()
    let s:lock_count -= 1
    if s:lock_count < 0
        let s:lock_count = 0
        throw "autocomplpop: not locked" 
    endif
endfunction


"-----------------------------------------------------------------------------
function! <SID>FeedKeysAndPopup(keys)
    let last_word_len = len(<SID>GetLastWord() . a:keys)
    if s:lock_count == 0 && !pumvisible() && last_word_len >= g:AutoComplPop_MinLength &&
                \                            last_word_len <= g:AutoComplPop_MaxLength
        call <SID>SetOrRestoreOption(1)

        let s:popup_fed = 1
    endif

    return a:keys
endfunction


"-----------------------------------------------------------------------------
function! g:AutoComplPop_HandlePopupMenu(retry)
    echo ""
    if pumvisible()
        " a command to restore to original text and select the first match
        return "\<C-p>\<Down>"
    elseif a:retry > 0
        " In case of dividing words by symbols while popup menu is visible,
        " popup is not available unless input <C-e> (e.g. "for(int", "a==b")
        return "\<C-e>" . g:AutoComplPop_PopupCmd . "\<C-r>=g:AutoComplPop_HandlePopupMenu(" . (a:retry - 1) . ")\<CR>"
    else
        return "\<C-e>"
    endif 
endfunction


"-----------------------------------------------------------------------------
function! <SID>GetLastWord()
    return matchstr(strpart(getline('.'), 0, col('.') - 1), '\k*$')
endfunction


"-----------------------------------------------------------------------------
function! <SID>SetOrRestoreOption(set_or_restore)
    if a:set_or_restore && !exists('s:_completeopt')
        let s:_completeopt = &completeopt
        let   &completeopt = 'menuone'
        let s:_complete = &complete
        let   &complete = g:AutoComplPop_CompleteOption
        let s:_ignorecase = &ignorecase
        let   &ignorecase = g:AutoComplPop_IgnoreCaseOption
    elseif !a:set_or_restore && exists('s:_completeopt')
        let     &completeopt = s:_completeopt
        unlet s:_completeopt
        let     &complete    = s:_complete
        unlet s:_complete
        let     &ignorecase  = s:_ignorecase
        unlet s:_ignorecase
    endif
endfunction

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" EVENT HANDLER:
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

"-----------------------------------------------------------------------------
function! <SID>OnCursorMovedI()
    if exists('s:popup_fed')
        unlet s:popup_fed
        let retry = (len(<SID>GetLastWord()) == g:AutoComplPop_MinLength ? 1 : 0)
        call feedkeys(g:AutoComplPop_PopupCmd . "\<C-r>=g:AutoComplPop_HandlePopupMenu(" . retry . ")\<CR>", 'n')
    elseif !pumvisible()
        call <SID>SetOrRestoreOption(0)
    endif
endfunction


"-----------------------------------------------------------------------------
function! <SID>OnInsertLeave()
    call <SID>SetOrRestoreOption(0)
endfunction


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" INITIALIZE:
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
call <SID>Initialize()

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

