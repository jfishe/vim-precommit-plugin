if exists('g:loaded_precommit')
  finish
endif
let g:loaded_precommit = 1

let g:precommit_command = get(g:, 'precommit_command', 'pre-commit')
let g:precommit_open_qf = get(g:, 'precommit_open_qf', 1)

command! -nargs=* -complete=customlist,precommit#Complete PreCommit call precommit#Command(<q-args>)
command! -nargs=1 -complete=customlist,precommit#CompleteHooks PreCommitHook call precommit#RunHook(<q-args>)
command! -nargs=? -complete=customlist,precommit#CompleteHooks PreCommitAll call precommit#RunAll(<q-args>)
command! -nargs=? -complete=customlist,precommit#CompleteHooks PreCommitFile call precommit#RunCurrentFile(<q-args>)
command! -nargs=0 PreCommitInstall call precommit#Command('install')
command! -nargs=0 PreCommitUpdate call precommit#Command('autoupdate')
command! -nargs=0 PreCommitClean call precommit#Command('clean')
command! -nargs=0 PreCommitHooks call precommit#ShowHooks()
command! -nargs=0 PreCommitOpenConfig call precommit#OpenConfig()
