import * as walk from 'acorn/dist/walk'
import * as acorn from 'acorn'

function nodeStackOfExpression (ast, start, end) {
  const makeVisitor = (nodeTypes, start, end) => {
    let found = false

    const visitor = {}
    for (const type of nodeTypes) {
      visitor[type] = (node, state, ancestors) => {
        if (!found && node.start <= start && node.end >= end) {
          found = true
          state.node = node
          state.ancestors = [...ancestors]
        }
      }
    }
    return visitor
  }

  const visitor = makeVisitor(['Expression'], start, end)

  const found = {}
  walk.ancestor(ast, visitor, walk.base, found)

  found.ancestors.reverse()
  return found.ancestors
}

export function parse (sourceCode) {
  const ast = acorn.parse(sourceCode, { locations: true, sourceType: 'module' })
  return ast
}

export function extractVariableFromRange (sourceCode, charRange, varName) {
  const [start, end] = charRange
  const stack = nodeStackOfExpression(parse(sourceCode), start, end)
  const enclIdx = stack.findIndex(node => !!node.body)

  const exprLocation = stack[0].loc
  const enclLocation = stack[enclIdx].loc

  return [
    {
      line: [exprLocation.start.line, exprLocation.end.line],
      column: [exprLocation.start.column, exprLocation.end.column],
      code: varName
    },
    {
      line: [enclLocation.start.line, enclLocation.end.line],
      column: [0, 0],
      code: `const ${varName} = ${sourceCode.substring(stack[0].start, stack[0].end)}\n`
    }
  ]
}
