import * as walk from 'acorn/dist/walk'
import * as acorn from 'acorn'
import escodegen from 'escodegen'


function nodeStackOfExpression(ast, start, end) {
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

  const visitor = makeVisitor([ 'Expression' ], start, end)

  const found = {}
  walk.ancestor(ast, visitor, walk.base, found)

  found.ancestors.reverse()
  return found.ancestors
}

export function parse(sourceCode) {
  const ast = acorn.parse(sourceCode, { locations: true })
  return ast
}

function variableId(varName) {
  return { type: 'Identifier', name: varName }
}

function constDeclaration(varId, initNode) {
  const varDecl = {
    type: 'VariableDeclarator',
    id: varId,
    init: initNode
  }
  return { type: 'VariableDeclaration', kind: 'const', declarations: [varDecl] }
}

function replaceElements(array, index, ...newElements) {
  return [...array.slice(0, index), ...newElements, ...array.slice(index + 1)]
}

export function extractVariableFromRange(sourceCode, charRange, varName) {
  const [start, end] = charRange
  const ast = parse(sourceCode)
  const stack = nodeStackOfExpression(parse(sourceCode), start, end)

  const attachmentProperties = {
    CallExpression: 'arguments',
    ExpressionStatement: 'expression',
    Program: 'body',
  }

  let declarationAttached = false
  let changeLocation
  const varId = variableId(varName)

  const newAst = stack.slice(1).reduce((newNode, container, index) => {
    const attachmentProperty = attachmentProperties[container.type]

    if (Array.isArray(container[attachmentProperty])) {
      const body = container[attachmentProperty]
      const bodyIdx = body.findIndex((node) => node === stack[index])

      // attach varable declaration to closest scope just before usage
      if (!declarationAttached && attachmentProperty === 'body') {
        declarationAttached = true
        changeLocation = container.loc
        const constDecl = constDeclaration(varId, stack[0])

        return {
          ...container,
          [attachmentProperty]: replaceElements(body, bodyIdx, constDecl, newNode),
        }
      }

      return {
        ...container,
        [attachmentProperty]: replaceElements(body, bodyIdx, newNode),
      }
    }

    return { ...container, [attachmentProperty]: newNode }
  }, varId)

  return {
    lines: { start: changeLocation.start.line, end: changeLocation.end.line },
    refactoredCode: escodegen.generate(newAst)
  }
}

export function extractVariablePosition(ast, start, end) {
  const stack = nodeStackOfExpression(ast, start, end)
  const enclIdx = stack.findIndex((node) => !!node.body)

  return { extractedNode: stack[0], insertPosition: stack[enclIdx-1].start }
}

