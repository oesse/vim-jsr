" binding to source this file
let g:jsr_map_leader = '<leader>r'
nnoremap <leader>j :source vim/ftplugin/javascript.vim<cr>
execute "nnoremap ".g:jsr_map_leader."v :call ExtractVariableAtCursor()<cr>"
execute "vnoremap ".g:jsr_map_leader."v :call ExtractVariableInRange()<cr>"

function! ApplyChange(change)
  let chars = a:change.column[1] - a:change.column[0]
  if chars > 0
    execute a:change.line[0]."normal! ".a:change.column[0]."lc".chars."l".a:change.code
  else
    execute a:change.line[0]."normal! ".a:change.column[0]."li".a:change.code
  endif
endfunction

function! ExtractVariable(start, end)
  call inputsave()
  let var_name = input('Variable name: ')
  call inputrestore()

  if var_name ==# ''
    return
  endif


  let output = system("./bin/jsr.js ".a:start." ".a:end." ".var_name, bufnr('%'))
  let changes = json_decode(output)
  let pos = getcurpos()

  " 0put =output
  call ApplyChange(changes[0])
  call ApplyChange(changes[1])

  call setpos('.', pos)
endfunction

function! GetOffset(expr)
  " 0 offset (row - 1, col - 1)
  return line2byte(line(a:expr)) + col(a:expr) - 2
endfunction

function! ExtractVariableAtCursor()
  let start = GetOffset('.')
  let end = start
  call ExtractVariable(start, end)
endfunction

function! ExtractVariableInRange()
  " 0 offset (row - 1, col - 1)
  let start = GetOffset("'<")
  let end = GetOffset("'>")
  call ExtractVariable(start, end)
endfunction

echom "Sourced js-refactor."
