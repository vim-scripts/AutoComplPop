"=============================================================================
" Copyright (c) 2007-2009 Takeshi NISHIDA
"
" GetLatestVimScripts: 1879 1 :AutoInstall: AutoComplPop
"=============================================================================
" LOAD GUARD {{{1

if exists('g:loaded_acp') || v:version < 702
  finish
endif
let g:loaded_acp = 1

" }}}1
"=============================================================================
" FUNCTION: {{{1

"
function s:defineOption(name, default)
  if !exists(a:name)
    let {a:name} = a:default
  endif
endfunction

"
function s:makeDefaultBehavior()
  let behavs = {
        \   '*'      : [],
        \   'ruby'   : [],
        \   'python' : [],
        \   'html'   : [],
        \   'xhtml'  : [],
        \   'css'    : [],
        \ }
  "---------------------------------------------------------------------------
  if g:acp_behaviorKeywordLength >= 0
    for key in keys(behavs)
      call add(behavs[key], {
            \   'command'  : g:acp_behaviorKeywordCommand,
            \   'pattern'  : printf('\k\{%d,}$', g:acp_behaviorKeywordLength),
            \   'repeat'   : 0,
            \ })
    endfor
  endif
  "---------------------------------------------------------------------------
  if g:acp_behaviorFileLength >= 0
    for key in keys(behavs)
      call add(behavs[key], {
            \   'command'  : "\<C-x>\<C-f>",
            \   'pattern'  : printf('\f[%s]\f\{%d,}$', (has('win32') || has('win64') ? '/\\' : '/'),
            \                       g:acp_behaviorFileLength),
            \   'excluded' : '[*/\\][/\\]\f*$\|[^[:print:]]\f*$',
            \   'repeat'   : 1,
            \ })
    endfor
  endif
  "---------------------------------------------------------------------------
  if has('ruby') && g:acp_behaviorRubyOmniMethodLength >= 0
    call add(behavs.ruby, {
          \   'command'  : "\<C-x>\<C-o>",
          \   'pattern'  : printf('[^. \t]\(\.\|::\)\k\{%d,}$', g:acp_behaviorRubyOmniMethodLength),
          \   'repeat'   : 0,
          \ })
  endif
  "---------------------------------------------------------------------------
  if has('ruby') && g:acp_behaviorRubyOmniSymbolLength >= 0
    call add(behavs.ruby, {
          \   'command'  : "\<C-x>\<C-o>",
          \   'pattern'  : printf('\(^\|[^:]\):\k\{%d,}$', g:acp_behaviorRubyOmniSymbolLength),
          \   'repeat'   : 0,
          \ })
  endif
  "---------------------------------------------------------------------------
  if has('python') && g:acp_behaviorPythonOmniLength >= 0
    call add(behavs.python, {
          \   'command'  : "\<C-x>\<C-o>",
          \   'pattern'  : printf('\k\.\k\{%d,}$', g:acp_behaviorPythonOmniLength),
          \   'repeat'   : 0,
          \ })
  endif
  "---------------------------------------------------------------------------
  if g:acp_behaviorHtmlOmniLength >= 0
    let behav_html = {
          \   'command'  : "\<C-x>\<C-o>",
          \   'pattern'  : printf('\(<\|<\/\|<[^>]\+ \|<[^>]\+=\"\)\k\{%d,}$', g:acp_behaviorHtmlOmniLength),
          \   'repeat'   : 1,
          \ }
    call add(behavs.html , behav_html)
    call add(behavs.xhtml, behav_html)
  endif
  "---------------------------------------------------------------------------
  if g:acp_behaviorCssOmniPropertyLength >= 0
    call add(behavs.css, {
          \   'command'  : "\<C-x>\<C-o>",
          \   'pattern'  : printf('\(^\s\|[;{]\)\s*\k\{%d,}$', g:acp_behaviorCssOmniPropertyLength),
          \   'repeat'   : 0,
          \ })
  endif
  "---------------------------------------------------------------------------
  if g:acp_behaviorCssOmniValueLength >= 0
    call add(behavs.css, {
          \   'command'  : "\<C-x>\<C-o>",
          \   'pattern'  : printf('[:@!]\s*\k\{%d,}$', g:acp_behaviorCssOmniValueLength),
          \   'repeat'   : 0,
          \ })
  endif
  "---------------------------------------------------------------------------
  return behavs
endfunction

"
function s:enable()
  call s:disable()

  augroup AcpGlobalAutoCommand
    autocmd!
    autocmd InsertEnter * unlet! s:posLast
    autocmd InsertLeave * call s:finishPopup()
  augroup END

  if g:acp_mappingDriven
    call s:mapForMappingDriven()
  else
    autocmd AcpGlobalAutoCommand CursorMovedI * call s:feedPopup()
  endif

  nnoremap <silent> i i<C-r>=<SID>feedPopup()<CR>
  nnoremap <silent> a a<C-r>=<SID>feedPopup()<CR>
  nnoremap <silent> R R<C-r>=<SID>feedPopup()<CR>
endfunction

"
function s:disable()
  call s:unmapForMappingDriven()
  augroup AcpGlobalAutoCommand
    autocmd!
  augroup END
  nnoremap i <Nop> | nunmap i
  nnoremap a <Nop> | nunmap a
  nnoremap R <Nop> | nunmap R
endfunction

"
let s:lockCount = 0

"
function s:lock()
  let s:lockCount += 1
endfunction

"
function s:unlock()
  let s:lockCount -= 1
  if s:lockCount < 0
    let s:lockCount = 0
    throw "autocomplpop.vim: not locked"
  endif
endfunction

"
function s:mapForMappingDriven()
  call s:unmapForMappingDriven()
  let s:keysMappingDriven = [
        \ 'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm',
        \ 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z',
        \ 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M',
        \ 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z',
        \ '0', '1', '2', '3', '4', '5', '6', '7', '8', '9',
        \ '-', '_', '~', '^', '.', ',', ':', '!', '#', '=', '%', '$', '@', '<', '>', '/', '\',
        \ '<Space>', '<C-h>', '<BS>', ]
  for key in s:keysMappingDriven
    execute printf('inoremap <silent> %s %s<C-r>=<SID>feedPopup()<CR>',
          \        key, key)
  endfor
endfunction

"
function s:unmapForMappingDriven()
  if !exists('s:keysMappingDriven')
    return
  endif
  for key in s:keysMappingDriven
    execute 'iunmap ' . key
  endfor
  let s:keysMappingDriven = []
endfunction

"
let s:tempOptionSet = { }

"
function s:setTempOption(name, value)
  call extend(s:tempOptionSet, { a:name : eval('&' . a:name) }, 'keep')
  execute printf('let &%s = a:value', a:name)
endfunction

"
function s:restoreTempOptionAll()
  for [name, value] in items(s:tempOptionSet)
    execute printf('let &%s = value', name)
  endfor
  let s:tempOptionSet = {}
endfunction

"
function s:matchesBehavior(text, behav)
  return a:text =~ a:behav.pattern &&
        \ (!exists('a:behav.excluded') || a:text !~ a:behav.excluded)
endfunction

"
function s:isCursorMovedSinceLastCall()
  if exists('s:posLast')
    let posPrev = s:posLast
  endif
  let s:posLast = getpos('.')
  if !exists('posPrev')
    return 1
  elseif has('multi_byte_ime')
    return (posPrev[1] != s:posLast[1] || posPrev[2] + 1 == s:posLast[2] ||
          \ posPrev[2] > s:posLast[2])
  else
    return (posPrev != s:posLast)
  endif
endfunction

"
let s:behavsCurrent = []

"
function s:feedPopup()
  " NOTE: CursorMovedI is not triggered while the popup menu is visible. And
  "       it will be triggered when popup menu is disappeared.
  if s:lockCount > 0 || pumvisible() || &paste
    return ''
  endif
  let cursorMoved = s:isCursorMovedSinceLastCall()
  if exists('s:behavsCurrent[0].repeat') && s:behavsCurrent[0].repeat
    let s:behavsCurrent = [ s:behavsCurrent[0] ]
  elseif cursorMoved
    let s:behavsCurrent = copy(exists('g:acp_behavior[&filetype]')
          \                    ? g:acp_behavior[&filetype]
          \                    : g:acp_behavior['*'])
  else
    let s:behavsCurrent = []
  endif
  let text = strpart(getline('.'), 0, col('.') - 1)
  call filter(s:behavsCurrent, 's:matchesBehavior(text, v:val)')
  if empty(s:behavsCurrent)
    call s:finishPopup()
    return ''
  endif
  " In case of dividing words by symbols (e.g. "for(int", "ab==cd") while a
  " popup menu is visible, another popup is not available unless input <C-e>
  " or try popup once. So first completion is duplicated.
  call insert(s:behavsCurrent, s:behavsCurrent[0])
  call s:setTempOption('completeopt', 'menuone' . (g:acp_completeoptPreview ? ',preview' : ''))
  call s:setTempOption('complete', g:acp_completeOption)
  call s:setTempOption('ignorecase', g:acp_ignorecaseOption)
  " NOTE: With CursorMovedI driven, Set 'lazyredraw' to avoid flickering.
  "       With Mapping driven, set 'nolazyredraw' to make a popup menu visible.
  call s:setTempOption('lazyredraw', !g:acp_mappingDriven)
  call s:setCompletefunc()
  call feedkeys(s:behavsCurrent[0].command, 'n') " use <Plug> for silence instead of <C-r>=
  call feedkeys("\<Plug>AcpOnPopupPost", 'm')
  return '' " for <C-r>=
endfunction

"
function s:finishPopup()
  let s:behavsCurrent = []
  call s:restoreTempOptionAll()
endfunction

"
function s:setCompletefunc()
  if exists('s:behavsCurrent[0].completefunc')
    call s:setTempOption('completefunc', s:behavsCurrent[0].completefunc)
  endif
endfunction

"
function s:onPopupPost()
  if pumvisible()
    " a command to restore to original text and select the first match
    return (s:behavsCurrent[0].command =~# "\<C-p>" ? "\<C-n>\<Up>"
          \                                         : "\<C-p>\<Down>")
  elseif exists('s:behavsCurrent[1]')
    call remove(s:behavsCurrent, 0)
    call s:setCompletefunc()
    return printf("\<C-e>%s\<C-r>=%sonPopupPost()\<CR>",
          \       s:behavsCurrent[0].command, s:PREFIX_SID)
  else
    call s:finishPopup()
    return "\<C-e>"
  endif
endfunction

" }}}1
"=============================================================================
" INITIALIZATION {{{1

"-----------------------------------------------------------------------------
function s:getSidPrefix()
  return matchstr(expand('<sfile>'), '<SNR>\d\+_')
endfunction
let s:PREFIX_SID = s:getSidPrefix()
delfunction s:getSidPrefix
"-----------------------------------------------------------------------------
call s:defineOption('g:acp_enableAtStartup', 1)
call s:defineOption('g:acp_mappingDriven', 0)
call s:defineOption('g:acp_ignorecaseOption', 1)
call s:defineOption('g:acp_completeOption', '.,w,b,k')
call s:defineOption('g:acp_completeoptPreview', 0)
call s:defineOption('g:acp_behaviorKeywordCommand', "\<C-p>")
call s:defineOption('g:acp_behaviorKeywordLength', 2)
call s:defineOption('g:acp_behaviorFileLength', 0)
call s:defineOption('g:acp_behaviorRubyOmniMethodLength', 0)
call s:defineOption('g:acp_behaviorRubyOmniSymbolLength', 1)
call s:defineOption('g:acp_behaviorPythonOmniLength', 0)
call s:defineOption('g:acp_behaviorHtmlOmniLength', 0)
call s:defineOption('g:acp_behaviorCssOmniPropertyLength', 1)
call s:defineOption('g:acp_behaviorCssOmniValueLength', 0)
call s:defineOption('g:acp_behavior', {})
"-----------------------------------------------------------------------------
call extend(g:acp_behavior, s:makeDefaultBehavior(), 'keep')
"-----------------------------------------------------------------------------
command! -bar -narg=0 AcpEnable  call s:enable()
command! -bar -narg=0 AcpDisable call s:disable()
command! -bar -narg=0 AcpLock    call s:lock()
command! -bar -narg=0 AcpUnlock  call s:unlock()
"-----------------------------------------------------------------------------
" legacy commands
command! -bar -narg=0 AutoComplPopEnable  AcpEnable
command! -bar -narg=0 AutoComplPopDisable AcpDisable
command! -bar -narg=0 AutoComplPopLock    AcpLock
command! -bar -narg=0 AutoComplPopUnlock  AcpUnlock
"-----------------------------------------------------------------------------
inoremap <silent> <expr> <Plug>AcpOnPopupPost <SID>onPopupPost()
"-----------------------------------------------------------------------------
if g:acp_enableAtStartup
  AcpEnable
endif
"-----------------------------------------------------------------------------

" }}}1
"=============================================================================
" vim: set fdm=marker:
