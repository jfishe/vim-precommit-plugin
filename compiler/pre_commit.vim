if exists('current_compiler')
  finish
endif
let current_compiler = 'pre_commit'

execute 'CompilerSet makeprg=' .. escape(get(g:, 'precommit_command', 'pre-commit'), ' \|"')
CompilerSet errorformat=%f:%l:%c:\ %m,%f:%l:\ %m,%-G%.%#
