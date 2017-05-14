const refactor = require('../lib')

let data = ''
process.stdin.setEncoding('utf-8')

process.stdin.on('readable', function() {
  let chunk
  while (chunk = process.stdin.read()) {
    data += chunk
  }
})

process.stdin.on('end', function () {
  const [,, start, end, varName] = process.argv
  const { lines, changeLocation } = refactor.extractVariableFromRange(data, [start, end], varName)
  console.log(JSON.stringify({ lines, code: changeLocation }))
  // console.log(lines.start, lines.end)
  // console.log(changeLocation)
})

