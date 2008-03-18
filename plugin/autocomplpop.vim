""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" autocomplpop.vim - Automatically open the popup menu for completion.
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"
" Author:       Takeshi Nishida <ns9tks(at)gmail.com>
" Version:      2.0, for Vim 7.1
" Licence:      MIT Licence
" URL:          http://www.vim.org/scripts/script.php?script_id=1879
"
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" DOCUMENT: (Japanese: http://vim.g.hatena.ne.jp/keyword/autocomplpop.vim)
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Description: {{{1
"   Install this plugin and your vim comes to automatically opens the popup
"   menu for completion when you enter characters or move the cursor in Insert
"   mode.
"
"-----------------------------------------------------------------------------
" Installation: {{{1
"   Drop this file in your plugin directory.
"
"-----------------------------------------------------------------------------
" Usage: {{{1
"   If this plugin has been installed, the auto-popup is enabled at startup by
"   default.
"
"   Which completion method is used depends on the text before the cursor. The
"   default behavior is as follows:
"
"     1. The keyword completion is attempted if the text before the cursor
"        consists of two keyword character.
"     2. The keyword completion is attempted in Scheme file if the text before
"        the cursor consists of '(' + a keyword character.
"     3. The filename completion is attempted if the text before the cursor
"        consists of a filename character + a path separator + 0 or more
"        filename characters.
"     4. The omni completion is attempted in Ruby file if the text before the
"        cursor consists of '.' or '::'. (Ruby interface is required.)
"     5. The omni completion is attempted in HTML/XHTML file if the text
"        before the cursor consists of '<' or '</'.
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
" Options: {{{1
"   g:AutoComplPop_NotEnableAtStartup:
"     The auto-popup is not enabled at startup if this is non-zero.
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
" Thanks: {{{1
"   vimtip #1386
"
"-----------------------------------------------------------------------------
" ChangeLog: {{{1
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
"       - First release.
"
"-----------------------------------------------------------------------------
" }}}1

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" INCLUDE GUARD: {{{1
if exists('loaded_autocomplpop') || v:version < 701
  finish
endif
let loaded_autocomplpop = 1


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" FUNCTION: {{{1
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
  " NOTE: CursorMovedI is not triggered while the pupup menu is visible. And
  "       it will be triggered when pupup menu is disappeared.

  augroup AutoComplPopGlobalAutoCommand
    autocmd InsertEnter  * call s:PopupFeeder.initialize()
    autocmd InsertLeave  * call s:PopupFeeder.finish()
    autocmd CursorMovedI * call s:PopupFeeder.feed()
  augroup END
endfunction

"-----------------------------------------------------------------------------
function! s:Disable()
  autocmd! AutoComplPopGlobalAutoCommand
endfunction


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" OBJECT: PopupFeeder:  {{{1
let s:PopupFeeder = { 'behavs' : [], 'lock_count' : 0 }
"-----------------------------------------------------------------------------
function! s:PopupFeeder.initialize()
  let self.last_pos = []
  call self.feed()
endfunction

"-----------------------------------------------------------------------------
function! s:PopupFeeder.feed()
  if exists('self.behavs[0]') && self.behavs[0].repeat
    let self.behavs = (self.behavs[0].repeat ? [ self.behavs[0] ] : [])
  elseif self.lock_count == 0 && !pumvisible() && self.last_pos != getpos('.')
    let self.behavs = copy(exists('g:AutoComplPop_Behavior[&filetype]') ? g:AutoComplPop_Behavior[&filetype]
          \                                                             : g:AutoComplPop_Behavior['*'])
  else
    let self.behavs = []
  endif

  let self.last_pos = getpos('.')

  let cur_text = strpart(getline('.'), 0, col('.') - 1)
  call filter(self.behavs, 'cur_text =~ v:val.pattern && cur_text !~ v:val.excluded')

  if empty(self.behavs)
    call self.finish()
    return
  endif

  " In case of dividing words by symbols while popup menu is visible,
  " popup is not available unless input <C-e> or try popup once.
  " (E.g. "for(int", "ab==cd") So duplicates first completion.
  call insert(self.behavs, self.behavs[0])

  call s:OptionManager.set('completeopt', 'menuone' . (g:AutoComplPop_CompleteoptPreview ? ',preview' : ''))
  call s:OptionManager.set('complete', g:AutoComplPop_CompleteOption)
  call s:OptionManager.set('ignorecase', g:AutoComplPop_IgnoreCaseOption)
  "call s:OptionManager.set('lazyredraw', 0)

  " use <Plug> for silence instead of <C-r>
  inoremap <silent> <expr> <Plug>AutocomplpopOnPopupPost <SID>GetPopupFeeder().on_popup_post()
  call feedkeys(self.behavs[0].command . "\<Plug>AutocomplpopOnPopupPost", 'm')
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


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" OBJECT: OptionManager: sets or restores temporary options {{{1
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


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" INITIALIZATION: GLOBAL OPTIONS: {{{1
"...........................................................................
if !exists('g:AutoComplPop_NotEnableAtStartup')
  let g:AutoComplPop_NotEnableAtStartup = 0
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
if !exists('g:AutoComplPop_Behavior')
  let g:AutoComplPop_Behavior = {}
endif
call extend(g:AutoComplPop_Behavior, {
      \   '*' : [
      \     {
      \       'command'  : "\<C-n>",
      \       'pattern'  : '\k\k$',
      \       'excluded' : '^$',
      \       'repeat'   : 0,
      \     },
      \     {
      \       'command'  : "\<C-x>\<C-f>",
      \       'pattern'  : (has('win32') || has('win64') ? '\f[/\\]\f*$' : '\f[/]\f*$'),
      \       'excluded' : '[*/\\][/\\]\f*$\|[^[:print:]]\f*$',
      \       'repeat'   : 1,
      \     },
      \   ],
      \   'ruby' : [
      \     {
      \       'command'  : "\<C-n>",
      \       'pattern'  : '\k\k$',
      \       'excluded' : '^$',
      \       'repeat'   : 0,
      \     },
      \     {
      \       'command'  : "\<C-x>\<C-f>",
      \       'pattern'  : (has('win32') || has('win64') ? '\f[/\\]\f*$' : '\f[/]\f*$'),
      \       'excluded' : '[*/\\][/\\]\f*$\|[^[:print:]]\f*$',
      \       'repeat'   : 1,
      \     },
      \     {
      \       'command'  : "\<C-x>\<C-o>",
      \       'pattern'  : '\([^. \t]\.\|^:\|\W:\)$',
      \       'excluded' : (has('ruby') ? '^$' : '.*'),
      \       'repeat'   : 0,
      \     },
      \   ],
      \   'scheme' : [
      \     {
      \       'command'  : "\<C-n>",
      \       'pattern'  : '\k\k$',
      \       'excluded' : '^$',
      \       'repeat'   : 0,
      \     },
      \     {
      \       'command'  : "\<C-n>",
      \       'pattern'  : '(\k$',
      \       'excluded' : '^$',
      \       'repeat'   : 0,
      \     },
      \     {
      \       'command'  : "\<C-x>\<C-f>",
      \       'pattern'  : (has('win32') || has('win64') ? '\f[/\\]\f*$' : '\f[/]\f*$'),
      \       'excluded' : '[*/\\][/\\]\f*$\|[^[:print:]]\f*$',
      \       'repeat'   : 1,
      \     },
      \   ],
      \   'html' : [
      \     {
      \       'command'  : "\<C-n>",
      \       'pattern'  : '\k\k$',
      \       'excluded' : '^$',
      \       'repeat'   : 0,
      \     },
      \     {
      \       'command'  : "\<C-x>\<C-f>",
      \       'pattern'  : (has('win32') || has('win64') ? '\f[/\\]\f*$' : '\f[/]\f*$'),
      \       'excluded' : '[*/\\][/\\]\f*$\|[^[:print:]]\f*$',
      \       'repeat'   : 1,
      \     },
      \     {
      \       'command'  : "\<C-x>\<C-o>",
      \       'pattern'  : '\(<\k*\|<\/\k*\|<[^>]* \)$',
      \       'excluded' : '^$',
      \       'repeat'   : 1,
      \     },
      \   ],
      \   'xhtml' : [
      \     {
      \       'command'  : "\<C-n>",
      \       'pattern'  : '\k\k$',
      \       'excluded' : '^$',
      \       'repeat'   : 0,
      \     },
      \     {
      \       'command'  : "\<C-x>\<C-f>",
      \       'pattern'  : (has('win32') || has('win64') ? '\f[/\\]\f*$' : '\f[/]\f*$'),
      \       'excluded' : '[*/\\][/\\]\f*$\|[^[:print:]]\f*$',
      \       'repeat'   : 1,
      \     },
      \     {
      \       'command'  : "\<C-x>\<C-o>",
      \       'pattern'  : '\(<\k*\|<\/\k*\|<[^>]* \)$',
      \       'excluded' : '^$',
      \       'repeat'   : 1,
      \     },
      \   ],
      \ } ,'keep')

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" INITIALIZATION: COMMANDS, AUTOCOMMANDS, MAPPINGS, ETC.: {{{1
command! -bar -narg=0 AutoComplPopEnable  call s:Enable()
command! -bar -narg=0 AutoComplPopDisable call s:Disable()
command! -bar -narg=0 AutoComplPopLock    call s:PopupFeeder.lock()
command! -bar -narg=0 AutoComplPopUnlock  call s:PopupFeeder.unlock()

if !g:AutoComplPop_NotEnableAtStartup
  AutoComplPopEnable
endif

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" }}}1
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" vim: set fdm=marker:

