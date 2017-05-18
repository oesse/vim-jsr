
let s:this_file = expand('<sfile>:p')
let s:plugin_path = resolve(expand('<sfile>:p:h:h'))
let s:jsr_path = s:plugin_path . '/bin/jsr.js'

function! jsr#ExtractVariableAtCursor(...)
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

function! jsr#ExtractVariableInRange(...)
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

  let output = system(s:jsr_path." ".a:start." ".a:end." ".a:variable_name, bufnr('%'))
  if matchstr(output, "Error: Cannot find module '../lib/cli'") != ""
    echoerr "You must initialize vim-jsr by running 'npm install'!"
    return
  endif

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
endfunction

function! s:CountLines(str)
  return len(split(a:str, "\n"))-1
endfunction

