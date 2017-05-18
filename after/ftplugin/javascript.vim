if !exists('g:jsr_map_leader')
  let g:jsr_map_leader = '<leader>r'
endif

command! -buffer -nargs=? ExtractVariableAtCursor call jsr#ExtractVariableAtCursor(<f-args>)
command! -buffer -nargs=? -range ExtractVariableInRange call jsr#ExtractVariableInRange(<f-args>)

execute "nnoremap <buffer> ".g:jsr_map_leader."v :ExtractVariableAtCursor<cr>"
execute "vnoremap <buffer> ".g:jsr_map_leader."v :ExtractVariableInRange<cr>"

