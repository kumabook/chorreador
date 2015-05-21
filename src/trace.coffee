esprima = require 'esprima'
class Trace
  _id = 1
  constructor: (@func, @loc, @range, @position, @tracer) ->
    @id = _id++
  toAST: ->
    esprima.parse "#{@tracer.name}.trace(#{@toParam()}, arguments)"
  toTraceReturnAST: (returnNode) ->
    node = @createTraceReturnNode()
    node.argument.arguments.push returnNode.argument if returnNode.argument
    node
  toParam: ->
    json =
      id:       @id
      loc:      @loc
      range:    @range
      position: @position
    if @func?
      json['func_id']   = @func.id
      json['source_id'] = @func.source.id
      json['page_id']   = @func.source.page.id if @func.source.page?
    JSON.stringify(json)
  createTraceReturnNode: () ->
    type: 'ReturnStatement'
    argument:
      type: 'CallExpression'
      callee:
        type: 'MemberExpression'
        computed: false,
        object:
          type: 'Identifier'
          name: 'chorreador'
        property:
          type: 'Identifier'
          name: 'trace'
      arguments: [
        (esprima.parse "param = #{@toParam()}").body[0].expression.right
        type: 'CallExpression'
        callee:
          type: 'MemberExpression'
          computed: false
          object:
            type: 'Identifier'
            name: 'arguments'
          property:
            type: 'Identifier'
            name: 'toString'
        arguments: []
      ]

module.exports = Trace
