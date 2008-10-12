"=============================================================================
" autocomplpop.vim - Automatically open the popup menu for completion.
"=============================================================================
"
" Author:  Takeshi NISHIDA <ns9tks@DELETE-ME.gmail.com>
" Version: 2.6, for Vim 7.1
" Licence: MIT Licence
" URL:     http://www.vim.org/scripts/script.php?script_id=1879
"
" GetLatestVimScripts: 1879 1 :AutoInstall: autocomplpop.vim
"
"=============================================================================
" DOCUMENT: {{{1
"   Japanese: http://vim.g.hatena.ne.jp/keyword/autocomplpop.vim
"
"-----------------------------------------------------------------------------
" Description:
"   Install this plugin and your vim comes to automatically opens the popup
"   menu for completion when you enter characters or move the cursor in Insert
"   mode.
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
"     1. The keyword completion is attempted if the text before the cursor
"        consists of two keyword character.
"     2. The filename completion is attempted if the text before the cursor
"        consists of a filename character + a path separator + 0 or more
"        filename characters.
"     3. The omni completion is attempted in Ruby file if the text before the
"        cursor consists of "." or "::". (Ruby interface is required.)
"     4. The omni completion is attempted in Python file if the text before
"        the cursor consists of ".". (Python interface is required.)
"     5. The omni completion is attempted in HTML/XHTML file if the text
"        before the cursor consists of "<" or "</".
"     6. The omni completion is attempted in CSS file if the text before the
"        cursor consists of ":", ";", "{", "@", "!", or in the start of line
"        with blank characters and keyword characters.
"
"   This behavior is customizable.
"
"   Commands:
"     :AutoComplPopEnable
"       - makes autocommands for the auto-popup.
"     :AutoComplPopDisable
"       - removes autocommands for the auto-popup.
"
"-----------------------------------------------------------------------------
" Options:
"   g:AutoComplPop_NotEnableAtStartup:
"     The auto-popup is not enabled at startup if non-zero is set.
"
"   g:AutoComplPop_MappingDriven:
"     The auto-popup is triggered by key mappings instead of CursorMovedI
"     event if non-zero is set. This is useful to avoid auto-popup by moving
"     cursor in Insert mode.
"
"   g:AutoComplPop_IgnoreCaseOption
"     This is set to 'ignorecase' when the popup menu is opened.
"
"   g:AutoComplPop_CompleteOption:
"     This is set to 'complete' when the popup menu is opened.
"
"   g:AutoComplPop_CompleteoptPreview:
"     If non-zero is set, 'preview' is added to 'completeopt' when the popup
"     menu is opened.
"
"   g:AutoComplPop_BehaviorKeywordLength:
"     This is the length of keyword characters before the cursor which are
"     needed to attempt the keyword completion. If negative value is set, it
"     will never attempt this completion.
"
"   g:AutoComplPop_BehaviorFileLength:
"     This is the length of filename characters before the cursor which are
"     needed to attempt the filename completion. If negative value is set, it
"     will never attempt this completion.
"
"   g:AutoComplPop_BehaviorRubyOmniMethodLength:
"     This is the length of keyword characters before the cursor which are
"     needed to attempt the ruby omni-completion for methods. If negative
"     value is set, it will never attempt this completion.
"
"   g:AutoComplPop_BehaviorRubyOmniSymbolLength:
"     This is the length of keyword characters before the cursor which are
"     needed to attempt the ruby omni-completion for symbols. If negative
"     value is set, it will never attempt this completion.
"
"   g:AutoComplPop_BehaviorPythonOmniLength:
"     This is the length of keyword characters before the cursor which are
"     needed to attempt the python omni-completion. If negative value is set,
"     it will never attempt this completion.
"
"   g:AutoComplPop_BehaviorHtmlOmniLength:
"     This is the length of keyword characters before the cursor which are
"     needed to attempt the HTML omni-completion. If negative value is set, it
"     will never attempt this completion.
"
"   g:AutoComplPop_BehaviorCssOmniPropertyLength:
"     This is the length of keyword characters before the cursor which are
"     needed to attempt the CSS omni-completion for properties. If negative
"     value is set, it will never attempt this completion.
"
"   g:AutoComplPop_BehaviorCssOmniValueLength:
"     This is the length of keyword characters before the cursor which are
"     needed to attempt the CSS omni-completion for values. If negative value
"     is set, it will never attempt this completion.
"
"   g:AutoComplPop_Behavior:
"     This option is for advanced users. This setting overrides other behavior
"     options. This is a dictionary. Each key corresponds to a filetype. '*'
"     is default. Each value is a list. These are attempted in sequence until
"     completion item is found. Each element is a dictionary which has
"     following items:
"       ['command']:
"         This is a command to be fed to open a popup menu for completion.
"       ['pattern'], ['excluded']:
"         If a text before the cursor matches ['pattern'] and not
"         ['excluded'], a popup menu is opened.
"       ['repeat']:
"         It automatically repeats a completion if non-zero is set.
"
"-----------------------------------------------------------------------------
" Special Thanks:
"   vimtip #1386
"   Daniel Schierbeck
"
"-----------------------------------------------------------------------------
" ChangeLog:
"   2.6:
"     - Improved the behavior of omni completion for HTML/XHTML.
"
"   2.5:
"     - Added some options to customize behavior easily:
"         g:AutoComplPop_BehaviorKeywordLength
"         g:AutoComplPop_BehaviorFileLength
"         g:AutoComplPop_BehaviorRubyOmniMethodLength
"         g:AutoComplPop_BehaviorRubyOmniSymbolLength
"         g:AutoComplPop_BehaviorPythonOmniLength
"         g:AutoComplPop_BehaviorHtmlOmniLength
"         g:AutoComplPop_BehaviorCssOmniPropertyLength
"         g:AutoComplPop_BehaviorCssOmniValueLength
"
"   2.4:
"     - Added g:AutoComplPop_MappingDriven option.
"
"   2.3.1:
"     - Changed to set 'lazyredraw' while a popup menu is visible to avoid
"       flickering.
"     - Changed a behavior for CSS.
"     - Added support for GetLatestVimScripts.
"
"   2.3:
"     - Added a behavior for Python to support omni completion.
"     - Added a behavior for CSS to support omni completion.
"
"   2.2:
"     - Changed not to work when 'paste' option is set.
"     - Fixed AutoComplPopEnable command and AutoComplPopDisable command to
"       map/unmap "i" and "R".
"
"   2.1:
"     - Fixed the problem caused by "." command in Normal mode.
"     - Changed to map "i" and "R" to feed completion command after starting
"       Insert mode.
"     - Avoided the problem caused by Windows IME.
"
"   2.0:
"     - Changed to use CursorMovedI event to feed a completion command instead
"       of key mapping. Now the auto-popup is triggered by moving the cursor.
"     - Changed to feed completion command after starting Insert mode.
"     - Removed g:AutoComplPop_MapList option.
"
"   1.7:
"     - Added behaviors for HTML/XHTML. Now supports the omni completion for
"       HTML/XHTML.
"     - Changed not to show expressions for CTRL-R =.
"     - Changed not to set 'nolazyredraw' while a popup menu is visible.
"
"   1.6.1:
"     - Changed not to trigger the filename completion by a text which has
"       multi-byte characters.
"
"   1.6:
"     - Redesigned g:AutoComplPop_Behavior option.
"     - Changed default value of g:AutoComplPop_CompleteOption option.
"     - Changed default value of g:AutoComplPop_MapList option.
"
"   1.5:
"     - Implemented continuous-completion for the filename completion. And
"       added new option to g:AutoComplPop_Behavior.
"
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
"     - First release.
"
" }}}1
"=============================================================================

" INCLUDE GUARD: ======================================================== {{{1
if exists('loaded_autocomplpop') || v:version < 701
  finish
endif
let loaded_autocomplpop = 1


" FUNCTION: ============================================================= {{{1

"-----------------------------------------------------------------------------
function! s:GetSidPrefix()
  return matchstr(expand('<sfile>'), '<SNR>\d\+_')
endfunction

"-----------------------------------------------------------------------------
function! s:GetPopupFeeder()
  return s:PopupFeeder
endfunction

"-----------------------------------------------------------------------------
function! s:Enable()
  call s:Disable()

  augroup AutoComplPopGlobalAutoCommand
    autocmd!
    autocmd InsertEnter * let s:PopupFeeder.last_pos = [] | unlet s:PopupFeeder.last_pos
    autocmd InsertLeave * call s:PopupFeeder.finish()
  augroup END

  if g:AutoComplPop_MappingDriven
    call s:FeedMapping.map()
  else
    autocmd AutoComplPopGlobalAutoCommand CursorMovedI * call s:PopupFeeder.feed()
  endif

  nnoremap <silent> i i<C-r>=<SID>GetPopupFeeder().feed()<CR>
  nnoremap <silent> a a<C-r>=<SID>GetPopupFeeder().feed()<CR>
  nnoremap <silent> R R<C-r>=<SID>GetPopupFeeder().feed()<CR>
endfunction

"-----------------------------------------------------------------------------
function! s:Disable()
  call s:FeedMapping.unmap()
  augroup AutoComplPopGlobalAutoCommand
    autocmd!
  augroup END
  nnoremap i <Nop> | nunmap i
  nnoremap a <Nop> | nunmap a
  nnoremap R <Nop> | nunmap R
endfunction

" FUNCTION: BEHAVIOR ==================================================== {{{1

"-----------------------------------------------------------------------------
function! s:MakeDefaultBehavior()
  let behavs = {
        \   '*'      : [],
        \   'ruby'   : [],
        \   'python' : [],
        \   'html'   : [],
        \   'xhtml'  : [],
        \   'css'    : [],
        \ }

  if g:AutoComplPop_BehaviorKeywordLength >= 0
    for key in keys(behavs)
      call add(behavs[key], {
            \   'command'  : "\<C-n>",
            \   'pattern'  : printf('\k\{%d,}$', g:AutoComplPop_BehaviorKeywordLength),
            \   'repeat'   : 0,
            \ })
    endfor
  endif

  if g:AutoComplPop_BehaviorFileLength >= 0
    for key in keys(behavs)
      call add(behavs[key], {
            \   'command'  : "\<C-x>\<C-f>",
            \   'pattern'  : printf('\f[%s]\f\{%d,}$', (has('win32') || has('win64') ? '/\\' : '/'),
            \                       g:AutoComplPop_BehaviorFileLength),
            \   'excluded' : '[*/\\][/\\]\f*$\|[^[:print:]]\f*$',
            \   'repeat'   : 1,
            \ })
    endfor
  endif

  if has('ruby') && g:AutoComplPop_BehaviorRubyOmniMethodLength >= 0
    call add(behavs.ruby, {
          \   'command'  : "\<C-x>\<C-o>",
          \   'pattern'  : printf('[^. \t]\(\.\|::\)\k\{%d,}$', g:AutoComplPop_BehaviorRubyOmniMethodLength),
          \   'repeat'   : 0,
          \ })
  endif

  if has('ruby') && g:AutoComplPop_BehaviorRubyOmniSymbolLength >= 0
    call add(behavs.ruby, {
          \   'command'  : "\<C-x>\<C-o>",
          \   'pattern'  : printf('\(^\|[^:]\):\k\{%d,}$', g:AutoComplPop_BehaviorRubyOmniSymbolLength),
          \   'repeat'   : 0,
          \ })
  endif

  if has('python') && g:AutoComplPop_BehaviorPythonOmniLength >= 0
    call add(behavs.python, {
          \   'command'  : "\<C-x>\<C-o>",
          \   'pattern'  : printf('\k\.\k\{%d,}$', g:AutoComplPop_BehaviorPythonOmniLength),
          \   'repeat'   : 0,
          \ })
  endif

  if g:AutoComplPop_BehaviorHtmlOmniLength >= 0
    let behav_html = {
          \   'command'  : "\<C-x>\<C-o>",
          \   'pattern'  : printf('\(<\|<\/\|<[^>]\+ \|<[^>]\+=\"\)\k\{%d,}$', g:AutoComplPop_BehaviorHtmlOmniLength),
          \   'repeat'   : 1,
          \ }
    call add(behavs.html , behav_html)
    call add(behavs.xhtml, behav_html)
  endif

  if g:AutoComplPop_BehaviorCssOmniPropertyLength >= 0
    call add(behavs.css, {
          \   'command'  : "\<C-x>\<C-o>",
          \   'pattern'  : printf('\(^\s\|[;{]\)\s*\k\{%d,}$', g:AutoComplPop_BehaviorCssOmniPropertyLength),
          \   'repeat'   : 0,
          \ })
  endif

  if g:AutoComplPop_BehaviorCssOmniValueLength >= 0
    call add(behavs.css, {
          \   'command'  : "\<C-x>\<C-o>",
          \   'pattern'  : printf('[:@!]\s*\k\{%d,}$', g:AutoComplPop_BehaviorCssOmniValueLength),
          \   'repeat'   : 0,
          \ })
  endif

  return behavs
endfunction

" OBJECT: PopupFeeder: ================================================== {{{1
let s:PopupFeeder = { 'behavs' : [], 'lock_count' : 0 }
"-----------------------------------------------------------------------------
function! s:PopupFeeder.feed()
  " NOTE: CursorMovedI is not triggered while the pupup menu is visible. And
  "       it will be triggered when pupup menu is disappeared.

  if self.lock_count > 0 || pumvisible() || &paste
    return ''
  endif

  let cursor_moved = self.check_cursor_and_update()
  if exists('self.behavs[0]') && self.behavs[0].repeat
    let self.behavs = (self.behavs[0].repeat ? [ self.behavs[0] ] : [])
  elseif cursor_moved 
    let self.behavs = copy(exists('g:AutoComplPop_Behavior[&filetype]') ? g:AutoComplPop_Behavior[&filetype]
          \                                                             : g:AutoComplPop_Behavior['*'])
  else
    let self.behavs = []
  endif

  let cur_text = strpart(getline('.'), 0, col('.') - 1)
  call filter(self.behavs, 'cur_text =~ v:val.pattern && (!exists(''v:val.excluded'') || cur_text !~ v:val.excluded)')

  if empty(self.behavs)
    call self.finish()
    return ''
  endif

  " In case of dividing words by symbols while a popup menu is visible,
  " popup is not available unless input <C-e> or try popup once.
  " (E.g. "for(int", "ab==cd") So duplicates first completion.
  call insert(self.behavs, self.behavs[0])

  call s:OptionManager.set('completeopt', 'menuone' . (g:AutoComplPop_CompleteoptPreview ? ',preview' : ''))
  call s:OptionManager.set('complete', g:AutoComplPop_CompleteOption)
  call s:OptionManager.set('ignorecase', g:AutoComplPop_IgnoreCaseOption)
  call s:OptionManager.set('lazyredraw', !g:AutoComplPop_MappingDriven)
  " NOTE: With CursorMovedI driven, Set 'lazyredraw' to avoid flickering.
  "       With Mapping driven, set 'nolazyredraw' to make a popup menu visible.

  " use <Plug> for silence instead of <C-r>=
  call feedkeys(self.behavs[0].command . "\<Plug>AutocomplpopOnPopupPost", 'm')
  return '' " for <C-r>=
endfunction

"-----------------------------------------------------------------------------
function! s:PopupFeeder.finish()
  let self.behavs = []
  call s:OptionManager.restore_all()
endfunction

"-----------------------------------------------------------------------------
function! s:PopupFeeder.lock()
  let self.lock_count += 1
endfunction

"-----------------------------------------------------------------------------
function! s:PopupFeeder.unlock()
  let self.lock_count -= 1
  if self.lock_count < 0
    let self.lock_count = 0
    throw "autocomplpop.vim: not locked"
  endif
endfunction

"-----------------------------------------------------------------------------
function! s:PopupFeeder.check_cursor_and_update()
  let prev_pos = (exists('self.last_pos') ? self.last_pos : [-1, -1, -1, -1])
  let self.last_pos = getpos('.')

  if has('multi_byte_ime')
    return (prev_pos[1] != self.last_pos[1] || prev_pos[2] + 1 == self.last_pos[2] ||
          \ prev_pos[2] > self.last_pos[2])
  else
    return (prev_pos != self.last_pos)
  endif
endfunction

"-----------------------------------------------------------------------------
function! s:PopupFeeder.on_popup_post()
  if pumvisible()
    " a command to restore to original text and select the first match
    return "\<C-p>\<Down>"
  elseif exists('self.behavs[1]')
    call remove(self.behavs, 0)
    return printf("\<C-e>%s\<C-r>=%sGetPopupFeeder().on_popup_post()\<CR>",
          \       self.behavs[0].command, s:GetSidPrefix())
  else
    call self.finish()
    return "\<C-e>"
  endif
endfunction

" OBJECT: OptionManager: sets or restores temporary options ============= {{{1
let s:OptionManager = { 'originals' : {} }
"-----------------------------------------------------------------------------
function! s:OptionManager.set(name, value)
  call extend(self.originals, { a:name : eval('&' . a:name) }, 'keep')
  execute printf('let &%s = a:value', a:name)
endfunction

"-----------------------------------------------------------------------------
function! s:OptionManager.restore_all()
  for [name, value] in items(self.originals)
    execute printf('let &%s = value', name)
  endfor
  let self.originals = {}
endfunction

" OBJECT: FeedMapping: manages global mappings ========================== {{{1
let s:FeedMapping = { 'keys' :  [] }
"-----------------------------------------------------------------------------
function! s:FeedMapping.map()
  call self.unmap()

  let self.keys = [
        \ 'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm',
        \ 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z',
        \ 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M',
        \ 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z',
        \ '0', '1', '2', '3', '4', '5', '6', '7', '8', '9',
        \ '-', '_', '~', '^', '.', ',', ':', '!', '#', '=', '%', '$', '@', '<', '>', '/', '\',
        \ '<Space>', '<C-h>', '<BS>', ]

  for key in self.keys
    execute printf('inoremap <silent> %s %s<C-r>=<SID>GetPopupFeeder().feed()<CR>',
          \        key, key)
  endfor
endfunction

"-----------------------------------------------------------------------------
function! s:FeedMapping.unmap()
  for key in self.keys
    execute 'iunmap ' . key
  endfor

  let self.keys = []
endfunction

" }}}1

" GLOBAL OPTIONS: ======================================================= {{{1
"...........................................................................
if !exists('g:AutoComplPop_NotEnableAtStartup')
  let g:AutoComplPop_NotEnableAtStartup = 0
endif
"...........................................................................
if !exists('g:AutoComplPop_MappingDriven')
  let g:AutoComplPop_MappingDriven = 0
endif
".........................................................................
if !exists('g:AutoComplPop_IgnoreCaseOption')
  let g:AutoComplPop_IgnoreCaseOption = 0
endif
".........................................................................
if !exists('g:AutoComplPop_CompleteOption')
  let g:AutoComplPop_CompleteOption = '.,w,b,k'
endif
".........................................................................
if !exists('g:AutoComplPop_CompleteoptPreview')
  let g:AutoComplPop_CompleteoptPreview = 0
endif
".........................................................................
if !exists('g:AutoComplPop_BehaviorKeywordLength')
  let g:AutoComplPop_BehaviorKeywordLength = 2
endif
".........................................................................
if !exists('g:AutoComplPop_BehaviorFileLength')
  let g:AutoComplPop_BehaviorFileLength = 0
endif
".........................................................................
if !exists('g:AutoComplPop_BehaviorRubyOmniMethodLength')
  let g:AutoComplPop_BehaviorRubyOmniMethodLength = 0
endif
".........................................................................
if !exists('g:AutoComplPop_BehaviorRubyOmniSymbolLength')
  let g:AutoComplPop_BehaviorRubyOmniSymbolLength = 1
endif
".........................................................................
if !exists('g:AutoComplPop_BehaviorPythonOmniLength')
  let g:AutoComplPop_BehaviorPythonOmniLength = 0
endif
".........................................................................
if !exists('g:AutoComplPop_BehaviorHtmlOmniLength')
  let g:AutoComplPop_BehaviorHtmlOmniLength = 0
endif
".........................................................................
if !exists('g:AutoComplPop_BehaviorCssOmniPropertyLength')
  let g:AutoComplPop_BehaviorCssOmniPropertyLength = 1
endif
".........................................................................
if !exists('g:AutoComplPop_BehaviorCssOmniValueLength')
  let g:AutoComplPop_BehaviorCssOmniValueLength = 0
endif
".........................................................................
if !exists('g:AutoComplPop_Behavior')
  let g:AutoComplPop_Behavior = {}
endif
call extend(g:AutoComplPop_Behavior, s:MakeDefaultBehavior(), 'keep')


" COMMANDS/AUTOCOMMANDS/MAPPINGS/ETC.: ================================== {{{1
command! -bar -narg=0 AutoComplPopEnable  call s:Enable()
command! -bar -narg=0 AutoComplPopDisable call s:Disable()
command! -bar -narg=0 AutoComplPopLock    call s:PopupFeeder.lock()
command! -bar -narg=0 AutoComplPopUnlock  call s:PopupFeeder.unlock()

inoremap <silent> <expr> <Plug>AutocomplpopOnPopupPost <SID>GetPopupFeeder().on_popup_post()

if !g:AutoComplPop_NotEnableAtStartup
  AutoComplPopEnable
endif

" }}}1
"=============================================================================
" vim: set fdm=marker:
