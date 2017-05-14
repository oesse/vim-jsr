" binding to source this file
let g:jsr_map_leader = '<leader>r'
nnoremap <leader>j :source vim/ftplugin/javascript.vim<cr>
" execute "nnoremap ".g:jsr_map_leader."v :call ExtractVariable()<cr>"
execute "vnoremap ".g:jsr_map_leader."v :call ExtractVariable()<cr>"

function! ApplyChange(change)
  let chars = a:change.column[1] - a:change.column[0]
  if chars > 0
    execute a:change.line[0]."normal! ".a:change.column[0]."lc".chars."l".a:change.code
  else
    execute a:change.line[0]."normal! ".a:change.column[0]."li".a:change.code
  endif
endfunction

function! ExtractVariable()
  " 0 offset (row - 1, col - 1)
  let start = line2byte(line("'<")) + col("'<") - 2
  let end = line2byte(line("'>")) + col("'>") - 2

  let output = system("./node_modules/.bin/babel-node ./bin/jsr.js ".start." ".end." foo", bufnr('%'))
  let changes = json_decode(output)
  let pos = getcurpos()

  " 0put =output
  call ApplyChange(changes[0])
  call ApplyChange(changes[1])

  call setpos('.', pos)
endfunction

echom "Sourced js-refactor."
