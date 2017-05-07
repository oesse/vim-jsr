import * as acorn from 'acorn'
import escodegen from 'escodegen'
import fs from 'fs'
import path from 'path'

import * as refactor from '../lib'

import { expect } from 'chai'

describe('extractVariable', () => {
  context('out of function argument', () => {
    const sourceCode = 'doImportantStuff(1, a + b)'

    it('returns range of lines and source code with extracted variable', () => {
      const charRange = [20, 25]
      const { lines, refactoredCode }
        = refactor.extractVariableFromRange(sourceCode, charRange, 'varName')
      expect(refactoredCode).to.equal('const varName = a + b;\ndoImportantStuff(1, varName);')
      expect(lines).to.eql({ start: 1, end: 1 })
    })
  })
})
