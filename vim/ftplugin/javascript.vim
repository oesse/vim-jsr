" binding to source this file
let g:jsr_map_leader = '<leader>r'
nnoremap <leader>j :source vim/ftplugin/javascript.vim<cr>
" execute "nnoremap ".g:jsr_map_leader."v :call ExtractVariable()<cr>"
execute "vnoremap ".g:jsr_map_leader."v :call ExtractVariable()<cr>"

function! ExtractVariable()
  " 0 offset (row - 1, col - 1)
  let start = line2byte(line("'<")) + col("'<") - 2
  let end = line2byte(line("'>")) + col("'>") - 2

  let output = system("./node_modules/.bin/babel-node ./bin/jsr.js ".start." ".end." foo", bufnr('%'))
  let changes = json_decode(output)
  0put =output
  " let newStart = changes.lines.start
  " let newEnd = changes.lines.end
  " execute newStart.",".newEnd."delete _"
  " execute newStart."put =changes.code"

  " %delete _
  " put =output
  " let @c

  " let @c = changes[1]
  " execute changes[0]."delete _"
  " execute (changes[0]-1)."put c"
  " " echom l:start . ":" . l:end

endfunction

echom "Sourced js-refactor."
