"=============================================================================
" Copyright (c) 2007-2009 Takeshi NISHIDA
"
" GetLatestVimScripts: 1879 1 :AutoInstall: AutoComplPop
"=============================================================================
" LOAD GUARD {{{1

if exists('g:loaded_acp')
  finish
elseif v:version < 702
  echoerr 'AutoComplPop does not support this version of vim (' . v:version . ').'
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
        \   'xml'    : [],
        \   'html'   : [],
        \   'xhtml'  : [],
        \   'css'    : [],
        \ }
  "---------------------------------------------------------------------------
  if !empty(g:acp_behaviorUserDefinedFunction)
    for key in keys(behavs)
      call add(behavs[key], {
            \   'command'      : "\<C-x>\<C-u>",
            \   'completefunc' : g:acp_behaviorUserDefinedFunction,
            \   'pattern'      : g:acp_behaviorUserDefinedPattern,
            \   'repeat'       : 0,
            \ })
    endfor
  endif
  "---------------------------------------------------------------------------
  if g:acp_behaviorKeywordLength >= 0
    for key in keys(behavs)
      call add(behavs[key], {
            \   'command' : g:acp_behaviorKeywordCommand,
            \   'pattern' : printf('\k\{%d,}$', g:acp_behaviorKeywordLength),
            \   'repeat'  : 0,
            \ })
    endfor
  endif
  "---------------------------------------------------------------------------
  if g:acp_behaviorFileLength >= 0
    for key in keys(behavs)
      call add(behavs[key], {
            \   'command' : "\<C-x>\<C-f>",
            \   'pattern' : printf('\f[%s]\f\{%d,}$', (has('win32') || has('win64') ? '/\\' : '/'),
            \                      g:acp_behaviorFileLength),
            \   'exclude' : '[*/\\][/\\]\f*$\|[^[:print:]]\f*$',
            \   'repeat'  : 1,
            \ })
    endfor
  endif
  "---------------------------------------------------------------------------
  if has('ruby') && g:acp_behaviorRubyOmniMethodLength >= 0
    call add(behavs.ruby, {
          \   'command' : "\<C-x>\<C-o>",
          \   'pattern' : printf('[^. \t]\(\.\|::\)\k\{%d,}$',
          \                      g:acp_behaviorRubyOmniMethodLength),
          \   'repeat'  : 0,
          \ })
  endif
  "---------------------------------------------------------------------------
  if has('ruby') && g:acp_behaviorRubyOmniSymbolLength >= 0
    call add(behavs.ruby, {
          \   'command' : "\<C-x>\<C-o>",
          \   'pattern' : printf('\(^\|[^:]\):\k\{%d,}$',
          \                      g:acp_behaviorRubyOmniSymbolLength),
          \   'repeat'  : 0,
          \ })
  endif
  "---------------------------------------------------------------------------
  if has('python') && g:acp_behaviorPythonOmniLength >= 0
    call add(behavs.python, {
          \   'command' : "\<C-x>\<C-o>",
          \   'pattern' : printf('\k\.\k\{%d,}$',
          \                      g:acp_behaviorPythonOmniLength),
          \   'repeat'  : 0,
          \ })
  endif
  "---------------------------------------------------------------------------
  if g:acp_behaviorXmlOmniLength >= 0
    call add(behavs.xml, {
          \   'command' : "\<C-x>\<C-o>",
          \   'pattern' : printf('\(<\|<\/\|<[^>]\+ \|<[^>]\+=\"\)\k\{%d,}$',
          \                      g:acp_behaviorXmlOmniLength),
          \   'repeat'  : 0,
          \ })
  endif
  "---------------------------------------------------------------------------
  if g:acp_behaviorHtmlOmniLength >= 0
    let behavHtml = {
          \   'command' : "\<C-x>\<C-o>",
          \   'pattern' : printf('\(<\|<\/\|<[^>]\+ \|<[^>]\+=\"\)\k\{%d,}$',
          \                      g:acp_behaviorHtmlOmniLength),
          \   'repeat'  : 1,
          \ }
    call add(behavs.html , behavHtml)
    call add(behavs.xhtml, behavHtml)
  endif
  "---------------------------------------------------------------------------
  if g:acp_behaviorCssOmniPropertyLength >= 0
    call add(behavs.css, {
          \   'command' : "\<C-x>\<C-o>",
          \   'pattern' : printf('\(^\s\|[;{]\)\s*\k\{%d,}$',
          \                      g:acp_behaviorCssOmniPropertyLength),
          \   'repeat'  : 0,
          \ })
  endif
  "---------------------------------------------------------------------------
  if g:acp_behaviorCssOmniValueLength >= 0
    call add(behavs.css, {
          \   'command' : "\<C-x>\<C-o>",
          \   'pattern' : printf('[:@!]\s*\k\{%d,}$',
          \                      g:acp_behaviorCssOmniValueLength),
          \   'repeat'  : 0,
          \ })
  endif
  "---------------------------------------------------------------------------
  return behavs
endfunction

" }}}1
"=============================================================================
" INITIALIZATION {{{1

"-----------------------------------------------------------------------------
call s:defineOption('g:acp_enableAtStartup', 1)
call s:defineOption('g:acp_mappingDriven', 0)
call s:defineOption('g:acp_ignorecaseOption', 1)
call s:defineOption('g:acp_completeOption', '.,w,b,k')
call s:defineOption('g:acp_completeoptPreview', 0)
call s:defineOption('g:acp_behaviorUserDefinedFunction', '')
call s:defineOption('g:acp_behaviorUserDefinedPattern' , '\k$')
call s:defineOption('g:acp_behaviorKeywordCommand', "\<C-n>")
call s:defineOption('g:acp_behaviorKeywordLength', 2)
call s:defineOption('g:acp_behaviorFileLength', 0)
call s:defineOption('g:acp_behaviorRubyOmniMethodLength', 0)
call s:defineOption('g:acp_behaviorRubyOmniSymbolLength', 1)
call s:defineOption('g:acp_behaviorPythonOmniLength', 0)
call s:defineOption('g:acp_behaviorXmlOmniLength', 0)
call s:defineOption('g:acp_behaviorHtmlOmniLength', 0)
call s:defineOption('g:acp_behaviorCssOmniPropertyLength', 1)
call s:defineOption('g:acp_behaviorCssOmniValueLength', 0)
call s:defineOption('g:acp_behavior', {})
"-----------------------------------------------------------------------------
call extend(g:acp_behavior, s:makeDefaultBehavior(), 'keep')
"-----------------------------------------------------------------------------
command! -bar -narg=0 AcpEnable  call acp#enable()
command! -bar -narg=0 AcpDisable call acp#disable()
command! -bar -narg=0 AcpLock    call acp#lock()
command! -bar -narg=0 AcpUnlock  call acp#unlock()
"-----------------------------------------------------------------------------
" legacy commands
command! -bar -narg=0 AutoComplPopEnable  AcpEnable
command! -bar -narg=0 AutoComplPopDisable AcpDisable
command! -bar -narg=0 AutoComplPopLock    AcpLock
command! -bar -narg=0 AutoComplPopUnlock  AcpUnlock
"-----------------------------------------------------------------------------
if g:acp_enableAtStartup
  AcpEnable
endif
"-----------------------------------------------------------------------------

" }}}1
"=============================================================================
" vim: set fdm=marker:
