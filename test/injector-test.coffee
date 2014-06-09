assert      = require "assert"
esprima     = require "esprima"
estraverse  = require "estraverse"
fs          = require "fs"
Injector    = require "../src/injector"
Source      = require "../src/source"
Tracer      = require "../src/tracer"

fixtures = "./test/fixtures"
describe 'Injector', ->
  describe '#findFuncName', ->
    it 'return function name from function expression node', (done) ->
      fs.readFile "#{fixtures}/expression.js", 'binary', (error, file) ->
        tracer   = new Tracer("#{fixtures}/tracer.js", "logger.trace")
        source   = new Source('expression.js', file.toString())
        ast = esprima.parse source.code
        estraverse.traverse ast, {
          enter: (node, parent) ->
            if node.type == esprima.Syntax.FunctionExpression
              assert.equal(Injector.findFuncName(node, parent), "test")
        }
        done()
