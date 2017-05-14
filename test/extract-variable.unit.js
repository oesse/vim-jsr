import * as acorn from 'acorn'
import escodegen from 'escodegen'
import fs from 'fs'
import path from 'path'

import { extractVariableFromRange } from '../src'

import { expect } from 'chai'

describe('extractVariableFromRange', () => {
  context('with range inside function parameter', () => {
    const sourceCode = 'doImportantStuff(1, a + b)'
    const charRange = [20, 25]

    it('returns change sets defining const variable with expression from range', () => {
      const [ diff1, diff2 ] = extractVariableFromRange(sourceCode, charRange, 'varName')

      expect(diff1).to.eql({ line: [1, 1], column: [20, 25], code: 'varName' })
      expect(diff2).to.eql({ line: [1, 1], column: [0, 0], code: 'const varName = a + b\n' })
    })
  })
})
