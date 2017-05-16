" binding to source this file
let g:jsr_map_leader = '<leader>r'
nnoremap <leader>j :source vim/ftplugin/javascript.vim<cr>
execute "nnoremap ".g:jsr_map_leader."v :ExtractVariableAtCursor<cr>"
execute "vnoremap ".g:jsr_map_leader."v :ExtractVariableInRange<cr>"

command! ExtractVariableAtCursor call s:ExtractVariableAtCursor()
command! ExtractVariableInRange call s:ExtractVariableInRange()

function! s:ApplyChange(change)
  let line_start = a:change.line[0]
  let line_end =  a:change.line[1]
  let column_start = a:change.column[0]
  let column_end = a:change.column[1]


  let first = getline(line_start)
  let last = getline(line_end)
  silent execute line_start.",".line_end."delete _"

  let rest = strpart(first, 0, column_start) . a:change.code . strpart(last, column_end)
  silent execute line_start."put! =rest"
endfunction

function! s:ExtractVariable(start, end)
  call inputsave()
  let var_name = input('Variable name: ')
  call inputrestore()

  if var_name ==# ''
    return
  endif


  let output = system("./bin/jsr.js ".a:start." ".a:end." ".var_name, bufnr('%'))
  let changes = json_decode(output)
  let pos = getcurpos()

  for change in changes
    call s:ApplyChange(change)
  endfor

  call setpos('.', pos)
endfunction

function! s:GetOffset(expr)
  " 0 offset (row - 1, col - 1)
  return line2byte(line(a:expr)) + col(a:expr) - 2
endfunction

function! s:ExtractVariableAtCursor()
  let start = s:GetOffset('.')
  let end = start
  call s:ExtractVariable(start, end)
endfunction

function! s:ExtractVariableInRange()
  " 0 offset (row - 1, col - 1)
  let start = s:GetOffset("'<")
  let end = s:GetOffset("'>")
  call s:ExtractVariable(start, end)
endfunction

echom "Sourced js-refactor."
