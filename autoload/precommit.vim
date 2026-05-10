let s:subcommands = [
      \ 'install',
      \ 'run',
      \ 'clean',
      \ 'autoupdate',
      \ 'gc',
      \ 'validate-config',
      \ 'validate-manifest',
      \ 'sample-config',
      \ 'migrate-config',
      \ ]

function! precommit#Executable() abort
  return get(g:, 'precommit_command', 'pre-commit')
endfunction

function! precommit#ConfigPath() abort
  let l:start = expand('%:p:h')
  if empty(l:start)
    let l:start = getcwd()
  endif

  for l:name in ['.pre-commit-config.yaml', '.pre-commit-config.yml']
    let l:path = findfile(l:name, l:start . ';')
    if !empty(l:path)
      return fnamemodify(l:path, ':p')
    endif
  endfor

  return ''
endfunction

function! precommit#Root() abort
  let l:config = precommit#ConfigPath()
  if !empty(l:config)
    return fnamemodify(l:config, ':h')
  endif

  let l:start = expand('%:p:h')
  if empty(l:start)
    let l:start = getcwd()
  endif

  let l:gitdir = finddir('.git', l:start . ';')
  if !empty(l:gitdir)
    return fnamemodify(l:gitdir, ':h')
  endif

  return getcwd()
endfunction

function! precommit#HookIds() abort
  let l:path = precommit#ConfigPath()
  if empty(l:path) || !filereadable(l:path)
    return []
  endif

  let l:hooks = []
  let l:seen = {}
  for l:line in readfile(l:path)
    if l:line =~# '^\s*-\s*id:\s*'
      let l:hook = trim(matchstr(l:line, '^\s*-\s*id:\s*\zs.*$'))
      let l:hook = substitute(l:hook, '\s\+#.*$', '', '')
      if l:hook =~# '^".*"$' || l:hook =~# "^'.*'$"
        let l:hook = l:hook[1 : strlen(l:hook) - 2]
      endif
      if !empty(l:hook) && !has_key(l:seen, l:hook)
        let l:seen[l:hook] = 1
        call add(l:hooks, l:hook)
      endif
    endif
  endfor

  return l:hooks
endfunction

function! precommit#Complete(arglead, cmdline, cursorpos) abort
  let l:before = strpart(a:cmdline, 0, a:cursorpos)
  let l:parts = split(l:before)
  if len(l:parts) <= 1
    return s:FilterByPrefix(copy(s:subcommands), a:arglead)
  endif

  if len(l:parts) == 2 && get(l:parts, 1, '') !=# 'run'
    return s:FilterByPrefix(copy(s:subcommands), a:arglead)
  endif

  if get(l:parts, 1, '') ==# 'run'
    if len(l:parts) == 2 && l:before !~# '\s$'
      return s:FilterByPrefix(copy(s:subcommands), a:arglead)
    endif
    return precommit#CompleteHooks(a:arglead, a:cmdline, a:cursorpos)
  endif

  return []
endfunction

function! precommit#CompleteHooks(arglead, cmdline, cursorpos) abort
  return s:FilterByPrefix(precommit#HookIds(), a:arglead)
endfunction

function! precommit#Command(qargs) abort
  let l:title = empty(a:qargs) ? 'pre-commit' : 'pre-commit ' . a:qargs
  let l:command = shellescape(precommit#Executable())
  if !empty(a:qargs)
    let l:command .= ' ' . a:qargs
  endif
  return s:Execute(l:command, l:title)
endfunction

function! precommit#RunHook(hook) abort
  let l:hook = trim(a:hook)
  if empty(l:hook)
    echoerr 'precommit.vim: hook id is required'
    return 1
  endif

  let l:title = 'pre-commit run ' . l:hook
  let l:command = shellescape(precommit#Executable()) . ' run ' . shellescape(l:hook)
  return s:Execute(l:command, l:title)
endfunction

function! precommit#RunAll(hook) abort
  let l:hook = trim(a:hook)
  let l:title = 'pre-commit run --all-files'
  let l:command = shellescape(precommit#Executable()) . ' run --all-files'

  if !empty(l:hook)
    let l:title = 'pre-commit run ' . l:hook . ' --all-files'
    let l:command = shellescape(precommit#Executable()) . ' run ' . shellescape(l:hook) . ' --all-files'
  endif

  return s:Execute(l:command, l:title)
endfunction

function! precommit#RunCurrentFile(hook) abort
  let l:file = expand('%:p')
  if empty(l:file)
    echoerr 'precommit.vim: current buffer has no file path'
    return 1
  endif

  let l:hook = trim(a:hook)
  let l:title = 'pre-commit run --files ' . expand('%:t')
  let l:command = shellescape(precommit#Executable()) . ' run --files ' . shellescape(l:file)

  if !empty(l:hook)
    let l:title = 'pre-commit run ' . l:hook . ' --files ' . expand('%:t')
    let l:command = shellescape(precommit#Executable()) . ' run ' . shellescape(l:hook) . ' --files ' . shellescape(l:file)
  endif

  return s:Execute(l:command, l:title)
endfunction

function! precommit#OpenConfig() abort
  let l:path = precommit#ConfigPath()
  if empty(l:path)
    echoerr 'precommit.vim: no .pre-commit-config.yaml or .yml found'
    return
  endif

  execute 'edit' fnameescape(l:path)
endfunction

function! precommit#ShowHooks() abort
  let l:hooks = precommit#HookIds()
  if empty(l:hooks)
    echom 'precommit.vim: no hooks found'
    return
  endif

  echom join(l:hooks, "\n")
endfunction

function! s:Execute(command, title) abort
  let l:binary = matchstr(precommit#Executable(), '^\S\+')
  if empty(l:binary) || !executable(l:binary)
    echoerr 'precommit.vim: executable not found: ' . precommit#Executable()
    return 127
  endif

  let l:root = precommit#Root()
  let l:save_cwd = getcwd()
  try
    execute 'lcd' fnameescape(l:root)
    let l:lines = systemlist(a:command)
    let l:code = v:shell_error
  finally
    execute 'lcd' fnameescape(l:save_cwd)
  endtry

  return s:PopulateQuickfix(a:title, l:lines, l:code)
endfunction

function! s:PopulateQuickfix(title, lines, code) abort
  let l:items = []
  if empty(a:lines)
    call add(l:items, {'text': a:code == 0 ? 'pre-commit completed successfully.' : 'pre-commit exited with code ' . a:code})
  else
    for l:line in a:lines
      call add(l:items, s:QuickfixItem(l:line))
    endfor
  endif

  call setqflist([], 'r', {'title': a:title, 'items': l:items})
  if get(g:, 'precommit_open_qf', 1)
    botright copen
  endif

  if a:code == 0
    echohl ModeMsg
    echom a:title . ' succeeded'
  else
    echohl ErrorMsg
    echom a:title . ' failed (' . a:code . ')'
  endif
  echohl None

  return a:code
endfunction

function! s:QuickfixItem(line) abort
  let l:match = matchlist(a:line, '^\(.\{-}\):\(\d\+\):\(\d\+\):\s*\(.*\)$')
  if !empty(l:match)
    return {
          \ 'filename': l:match[1],
          \ 'lnum': str2nr(l:match[2]),
          \ 'col': str2nr(l:match[3]),
          \ 'text': l:match[4],
          \ }
  endif

  let l:match = matchlist(a:line, '^\(.\{-}\):\(\d\+\):\s*\(.*\)$')
  if !empty(l:match)
    return {
          \ 'filename': l:match[1],
          \ 'lnum': str2nr(l:match[2]),
          \ 'text': l:match[3],
          \ }
  endif

  return {'text': a:line}
endfunction

function! s:FilterByPrefix(values, prefix) abort
  if empty(a:prefix)
    return a:values
  endif

  let l:pattern = '^' . escape(a:prefix, '\.^$~[]')
  return filter(a:values, {_, item -> item =~? l:pattern})
endfunction
