if !exists('g:jsrf_map_leader')
  let g:jsrf_map_leader = '<leader>r'
endif

command! -buffer -nargs=? ExtractVariableAtCursor call jsrf#ExtractVariableAtCursor(<f-args>)
command! -buffer -nargs=? -range ExtractVariableInRange call jsrf#ExtractVariableInRange(<f-args>)

execute "nnoremap <buffer> ".g:jsrf_map_leader."v :ExtractVariableAtCursor<cr>"
execute "vnoremap <buffer> ".g:jsrf_map_leader."v :ExtractVariableInRange<cr>"

