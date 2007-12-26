""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" autocomplpop.vim - Automatically open the popup menu for completion.
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"
" Last Change:  26-Dec-2007.
" Author:       Takeshi Nishida <ns9tks(at)gmail.com>
" Version:      1.5, for Vim 7.0
" Licence:      MIT Licence
" URL:          http://www.vim.org/scripts/script.php?script_id=1879
"
"-----------------------------------------------------------------------------
" Description:
"   Install this plugin and your vim comes to automatically opens the popup
"   menu for completion when you input a few charactors in a insert mode. This
"   plugin works by mapping alphanumeric characters and some symbols.
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
"   Which completion method is used depends on the text before the cursor. The
"   default behavior is as follows:
"
"     1. The keyword completion is attempted if there are more than one
"        keyword charactor before the cursor.
"     2. The filename completion is attempted if there is '/' or '\' before
"        the cursor.
"     3. The omni completion is attempted in ruby file if there is '.' or '::'
"        before the cursor. (Ruby interface is required.)
"
"   This behavior is customizable.
"
"   Commands:
"     :AutoComplPopEnable
"       - makes mappings for the auto-popup.
"     :AutoComplPopDisable
"       - removes mappings for the auto-popup.
"     :AutoComplPopLock
"       - suspends the auto-popup.
"     :AutoComplPopUnlock
"       - resumes the auto-popup after :AutoComplPopLock.
"
"-----------------------------------------------------------------------------
" Options:
"   g:AutoComplPop_NotEnableAtStartup:
"     The auto-popup is not enabled at startup if this is non-zero.
"
"   g:AutoComplPop_MapList:
"     This is a list. Each string of this list is mapped as trigger to open
"     the popup menu.
"
"   g:AutoComplPop_IgnoreCaseOption
"     This is set to 'ignorecase' when the popup menu is opened.
"
"   g:AutoComplPop_CompleteOption:
"     This is set to 'complete' when the popup menu is opened.
"
"   g:AutoComplPop_CompleteoptPreview:
"     If this is non-zero, 'preview' is added to 'completeopt' when the popup
"     menu is opened.
"
"   g:AutoComplPop_Behavior:
"     This is a dictionary. Each key corresponds to a filetype. '*' is
"     default. Each value is a list. These are attempted in sequence until
"     completion item is found. Each element is a list which has following
"     items:
"       [0]:
"         If this pattern matched a text before the cursor, a popup menu is
"         opened.
"       [1]:
"         This is a command to be fed to open a popup menu for completion.
"       [2]:
"         It automatically repeats a completion if non-zero is set.
"
"-----------------------------------------------------------------------------
" Thanks:
"   vimtip #1386
"
"-----------------------------------------------------------------------------
" ChangeLog:
"   1.5:
"     - Implemented continuous-completion for the filename completion. And
"       added new option to g:AutoComplPop_Behavior.
"   1.4:
"     - Fixed the bug that the auto-popup was not suspended in fuzzyfinder.
"     - Fixed the bug that an error has occurred with Ruby-omni-completion
"       unless Ruby interface.
"
"   1.3:
"     - Supported Ruby-omni-completion by default.
"     - Supported filename completion by default.
"     - Added g:AutoComplPop_Behavior option.
"     - Added g:AutoComplPop_CompleteoptPreview option.
"     - Removed g:AutoComplPop_MinLength option.
"     - Removed g:AutoComplPop_MaxLength option.
"     - Removed g:AutoComplPop_PopupCmd option.
"
"   1.2:
"     - Fixed bugs related to 'completeopt'.
"
"   1.1:
"     - Added g:AutoComplPop_IgnoreCaseOption option.
"     - Added g:AutoComplPop_NotEnableAtStartup option.
"     - Removed g:AutoComplPop_LoadAndEnable option.
"   1.0:
"     - g:AutoComplPop_LoadAndEnable option for a startup activation is added.
"     - AutoComplPopLock command and AutoComplPopUnlock command are added to
"       suspend and resume.
"     - 'completeopt' and 'complete' options are changed temporarily while
"       completing by this script.
"
"   0.4:
"     - The first match are selected when the popup menu is Opened. You can
"       insert the first match with CTRL-Y.
"
"   0.3:
"     - Fixed the problem that the original text is not restored if 'longest'
"       is not set in 'completeopt'. Now the plugin works whether or not
"       'longest' is set in 'completeopt', and also 'menuone'.
"
"   0.2:
"     - When completion matches are not found, insert CTRL-E to stop
"       completion.
"     - Clear the echo area.
"     - Fixed the problem in case of dividing words by symbols, popup menu is
"       not opened.
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
  let s:has_win = (has('win16') || has('win32') || has('win64'))

  "-------------------------------------------------------------------------
  " OPTIONS
  ".........................................................................
  if !exists('g:AutoComplPop_NotEnableAtStartup')
    let g:AutoComplPop_NotEnableAtStartup = 0
  endif
  ".........................................................................
  if !exists('g:AutoComplPop_MapList')
    let g:AutoComplPop_MapList = [
          \ 'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm',
          \ 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z',
          \ 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M',
          \ 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z',
          \ '0', '1', '2', '3', '4', '5', '6', '7', '8', '9',
          \ '_', '.', ':', '/', ]
    if s:has_win
      call add(g:AutoComplPop_MapList, '\')
    endif
  endif
  ".........................................................................
  if !exists('g:AutoComplPop_IgnoreCaseOption')
    let g:AutoComplPop_IgnoreCaseOption = 0
  endif
  ".........................................................................
  if !exists('g:AutoComplPop_CompleteOption')
    let g:AutoComplPop_CompleteOption = '.,w,b'
  endif

  ".........................................................................
  if !exists('g:AutoComplPop_CompleteoptPreview')
    let g:AutoComplPop_CompleteoptPreview = 0
  endif
  ".........................................................................
  if !exists('g:AutoComplPop_Behavior')
    let g:AutoComplPop_Behavior = {}
  endif
  call extend(g:AutoComplPop_Behavior,
        \ { '*'    : [ ['\k\{2,}$'                               , "\<C-n>"      , 0],
        \              [(s:has_win ? '\S[/\\]\f*$' : '\S[/]\f*$'), "\<C-x>\<C-f>", 1],
        \            ],
        \ } ,'keep')
  if has('ruby')
    call extend(g:AutoComplPop_Behavior,
          \ { 'ruby' : [ ['\k\{2,}$'                               , "\<C-n>"      , 0],
          \              [(s:has_win ? '\S[/\\]\f*$' : '\S[/]\f*$'), "\<C-x>\<C-f>", 1],
          \              ['\([^. \t]\.\|^:\|\W:\)$'                , "\<C-x>\<C-o>", 0],
          \            ],
          \ } ,'keep')
  endif
  ".........................................................................

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
  " MAPPING

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
    execute 'inoremap <silent> ' . item . ' ' . item . "\<C-r>=<SID>FeedPopup()\<CR>"
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
function! <SID>SetOrRestoreOption(set_or_restore)
  if a:set_or_restore && !exists('s:_completeopt')
    let s:_completeopt = &completeopt
    let   &completeopt = 'menuone' . (g:AutoComplPop_CompleteoptPreview ? ',preview' : '')
    let s:_complete    = &complete
    let   &complete    = g:AutoComplPop_CompleteOption
    let s:_ignorecase  = &ignorecase
    let   &ignorecase  = g:AutoComplPop_IgnoreCaseOption
    let s:_lazyredraw  = &lazyredraw
    let   &lazyredraw  = 0
  elseif !a:set_or_restore && exists('s:_completeopt')
    let     &completeopt = s:_completeopt
    unlet s:_completeopt
    let     &complete    = s:_complete
    unlet s:_complete
    let     &ignorecase  = s:_ignorecase
    unlet s:_ignorecase
    let     &lazyredraw  = s:_lazyredraw
    unlet s:_lazyredraw
  endif
endfunction


"-----------------------------------------------------------------------------
function! <SID>FeedPopup()
  if s:lock_count == 0 && !pumvisible()
    call <SID>SetOrRestoreOption(1)
    let s:req_popup = 1
    return ''
  else
    " The popup menu is hidden by "\<C-r>" for users who set 'lazyredraw'.
    " To show it, return "\<Down>\<Up>"
    return ''
  endif
endfunction

"-----------------------------------------------------------------------------
function! <SID>OnCursorMovedI()
  " NOTE: CursorMovedI is not triggered while the pupup menu is visible. And
  "       it is triggered when pupup menu disappeared.
  if pumvisible()
    " do nothing
  elseif exists('s:behav_last') && s:behav_last[2]
    if strpart(getline('.'), 0, col('.') - 1) =~ s:behav_last[0]
      let s:behav_rest = [s:behav_last]
      call feedkeys("\<C-r>=g:AutoComplPop_HandlePopupMenu(1)\<CR>", 'n')
    endif
    unlet s:behav_last
  elseif exists('s:req_popup')
    unlet s:req_popup
    let ftype = (has_key(g:AutoComplPop_Behavior, &filetype) ? &filetype : '*')
    let text = strpart(getline('.'), 0, col('.') - 1)
    let s:behav_rest = filter(copy(g:AutoComplPop_Behavior[ftype]), 'text =~ v:val[0]')
    call feedkeys("\<C-r>=g:AutoComplPop_HandlePopupMenu(1)\<CR>", 'n')
  else
    call <SID>SetOrRestoreOption(0)
  endif

endfunction

"-----------------------------------------------------------------------------
function! g:AutoComplPop_HandlePopupMenu(first)
  echo ""
  if pumvisible()
    " a command to restore to original text and select the first match
    return "\<C-p>\<Down>"
  elseif len(s:behav_rest)
    if a:first
      " In case of dividing words by symbols while popup menu is visible,
      " popup is not available unless input <C-e> or try popup once. (vim's bug?)
      " E.g. "for(int", "ab==cd"
      " So duplicate first completion.
      let s:behav_last = s:behav_rest[0]
      return s:behav_last[1] . "\<C-r>=g:AutoComplPop_HandlePopupMenu(0)\<CR>"
    else
      let s:behav_last = remove(s:behav_rest, 0)
      return  "\<C-e>" . s:behav_last[1] . "\<C-r>=g:AutoComplPop_HandlePopupMenu(0)\<CR>"
    endif
  else
    unlet! s:behav_last
    call <SID>SetOrRestoreOption(0)
    return (a:first ? "" : "\<C-e>")
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

