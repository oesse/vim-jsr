" binding to source this file
if !exists('g:jsr_map_leader')
  let g:jsr_map_leader = '<leader>r'
endif

execute "nnoremap ".g:jsr_map_leader."v :ExtractVariableAtCursor<cr>"
execute "vnoremap ".g:jsr_map_leader."v :ExtractVariableInRange<cr>"

command! ExtractVariableAtCursor call s:ExtractVariableAtCursor()
command! -range ExtractVariableInRange call s:ExtractVariableInRange()

let s:jsr_debug = 0
let s:this_file = expand('<sfile>:p')
let s:plugin_path = resolve(fnamemodify(s:this_file, ':h').'/../..')
let s:jsr_path = s:plugin_path . '/bin/jsr.js'

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

function! s:CountLines(str)
  return len(split(a:str, "\n"))-1
endfunction

function! s:ExtractVariable(start, end)
  call inputsave()
  let var_name = input('Variable name: ')
  call inputrestore()

  if var_name ==# ''
    return
  endif


  let output = system(s:jsr_path." ".a:start." ".a:end." ".var_name, bufnr('%'))
  let changes = json_decode(output)
  let pos = getcurpos()

  " Extract expression
  call s:ApplyChange(changes[0])
  let pos[1] = changes[0].line[0]
  let pos[4] = changes[0].line[0]
  let pos[2] = changes[0].column[0] + 1

  " Insert var declaration
  call s:ApplyChange(changes[1])
  let pos_offset = s:CountLines(changes[1].code)
  let pos[1] += pos_offset

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

if s:jsr_debug
  execute "nnoremap <leader>j :source ".s:this_file."<cr>"
  echom "Sourced ".s:this_file
endif
