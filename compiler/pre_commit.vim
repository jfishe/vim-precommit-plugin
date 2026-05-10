if exists('current_compiler')
  finish
endif
let current_compiler = 'pre_commit'

CompilerSet makeprg=pre-commit
CompilerSet errorformat=%f:%l:%c:\ %m,%f:%l:\ %m,%-G%.%#
