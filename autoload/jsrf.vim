let s:this_file = expand('<sfile>:p')
let s:plugin_path = resolve(expand('<sfile>:p:h:h'))
let s:jsrf_path = s:plugin_path . '/node_modules/.bin/jsrf'

function! jsrf#ExpandObjectAtCursor(...)
  let start = s:GetOffset('.')
  let end = start
  call s:ExpandObject(start, end)
endfunction

function! jsrf#ExpandObjectInRange(...)
  let start = s:GetOffset("'<")
  let end = s:GetOffset("'>")
  call s:ExpandObject(start, end)
endfunction

function! s:ExpandObject(start, end)
  let cmd = s:jsrf_path." expand-object ".a:start." ".a:end
  let output = system(cmd, getline(1, line("$")))
  if output =~ "Error: Cannot find module '../lib/cli'"
    echoerr "You must initialize vim-jsrf by running 'npm install'!"
    return
  endif

  try
    let changes = json_decode(output)
  catch /^Vim\%((\a\+)\)\=:E474/
    echoerr "Cannot extract variable from this point"
    return
  endtry

  let pos = getcurpos()

  call s:ApplyChange(changes[0])
  let pos[1] = changes[0].line[0]
  let pos[4] = changes[0].line[0]
  let pos[2] = changes[0].column[0] + 1

  call setpos('.', pos)
endfunction

function! jsrf#ExtractVariableAtCursor(...)
  let start = s:GetOffset('.')
  let end = start
  if a:0 == 1
    let variable_name = a:1
  else
    call inputsave()
    let variable_name = input('Variable name: ')
    call inputrestore()
  endif
  call s:ExtractVariable(start, end, variable_name)
endfunction

function! jsrf#ExtractVariableInRange(...)
  let start = s:GetOffset("'<")
  let end = s:GetOffset("'>")
  if a:0 == 1
    let variable_name = a:1
  else
    call inputsave()
    let variable_name = input('Variable name: ')
    call inputrestore()
  endif
  call s:ExtractVariable(start, end, variable_name)
endfunction

function! s:GetOffset(expr)
  " 0 offset (row - 1, col - 1)
  return line2byte(line(a:expr)) + col(a:expr) - 2
endfunction

function! s:ExtractVariable(start, end, variable_name)
  " Invalid/empty variable name provided.
  if a:variable_name ==# ''
    return
  endif

  let cmd = s:jsrf_path." extract-variable ".a:start." ".a:end." ".a:variable_name
  let output = system(cmd, getline(1, line("$")))
  if output =~ "Error: Cannot find module '../lib/cli'"
    echoerr "You must initialize vim-jsrf by running 'npm install'!"
    return
  endif

  try
    let changes = json_decode(output)
  catch /^Vim\%((\a\+)\)\=:E474/
    echoerr "Cannot extract variable from this point"
    return
  endtry

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

function! s:ApplyChange(change)
  let line_start = a:change.line[0]
  let line_end =  a:change.line[1]
  let column_start = a:change.column[0]
  let column_end = a:change.column[1]


  let first = getline(line_start)
  let last = getline(line_end)

  let is_last_in_buffer = line_end == line("$")

  silent execute line_start.",".line_end."delete _"

  let rest = strpart(first, 0, column_start) . a:change.code . strpart(last, column_end)
  let put_cmd = line_start."put! =rest"
  if is_last_in_buffer
    let put_cmd = "$put =rest"
  endif
  silent execute put_cmd

  " only one line, delete doesnt delete only line of buffer
  if is_last_in_buffer && line_start == 1
    " delete it afterwards
    silent! execute "1,1 delete _"
  endif
endfunction

function! s:CountLines(str)
  return len(split(a:str, "\n"))-1
endfunction


