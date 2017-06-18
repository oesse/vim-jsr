let s:this_file = expand('<sfile>:p')
let s:plugin_path = resolve(expand('<sfile>:p:h:h'))
let s:jsrf_path = s:plugin_path . '/node_modules/.bin/jsrf'

function! jsrf#ExpandObjectAtCursor(...)
  let start = s:GetOffset('.')
  let end = start
  call s:Jsrf("expand", start, end, '')
endfunction

function! jsrf#ExpandObjectInRange(...)
  let start = s:GetOffset("'<")
  let end = s:GetOffset("'>")
  call s:Jsrf("expand", start, end, '')
endfunction

function! jsrf#CollapseObjectAtCursor(...)
  let start = s:GetOffset('.')
  let end = start
  call s:Jsrf("collapse", start, end, '')
endfunction

function! jsrf#CollapseObjectInRange(...)
  let start = s:GetOffset("'<")
  let end = s:GetOffset("'>")
  call s:Jsrf("collapse", start, end, '')
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

  if variable_name ==# ''
    return
  endif

  call s:Jsrf("extract-variable", start, end, variable_name)
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

  if variable_name ==# ''
    return
  endif

  call s:Jsrf("extract-variable", start, end, variable_name)
endfunction

function! s:Jsrf(action, start, end, params)
  let cmd = s:jsrf_path." ".a:action." ".a:start." ".a:end." ".a:params
  let output = system(cmd, getline(1, line("$")))
  if output =~ "Error: Cannot find module '../lib/cli'"
    echoerr "You must initialize vim-jsrf by running 'npm install'!"
    return
  endif

  try
    let changes = json_decode(output)
  catch /^Vim\%((\a\+)\)\=:E474/
    if a:action ==# "extract-variable"
      echoerr "Cannot extract variable from this point"
    elseif a:action ==# "expand"
      echoerr "Cannot expand object from this point"
    elseif a:action ==# "collapse"
      echoerr "Cannot collapse object from this point"
    else
      echoerr "Error while performing action: ".a:action
    endif
    return
  endtry

  let pos = getcurpos()
  let new_pos = pos

  for change in changes
    call s:ApplyChange(change)
    call s:AdjustedCursorPosition(pos, change, new_pos)
  endfor

  call setpos('.', new_pos)
endfunction

function! s:GetOffset(expr)
  " 0 offset (row - 1, col - 1)
  return line2byte(line(a:expr)) + col(a:expr) - 2
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

function! s:AdjustedCursorPosition(pos, change, new_pos)
  let [line_start, line_end] = a:change.line
  let [col_start, col_end] = a:change.column

  if line_end < a:pos[1]
    let change_lines = s:CountLines(a:change.code)
    let line_difference = change_lines - (line_end - line_start)
    let a:new_pos[1] += line_difference
    return
  elseif line_start <= a:pos[1] && a:pos[1] <= line_end
    let new_line = a:pos[1] - line_start + 1
    let new_column = col_start - a:pos[2] + 1
    let a:new_pos[1] += new_line
    let a:new_pos[2] += new_column
    let a:new_pos[4] += new_column
    return
  endif

  " Do nothing, when change is after cursor position
endfunction

function! s:CountLines(str)
  return len(split(a:str, "\n"))-1
endfunction

