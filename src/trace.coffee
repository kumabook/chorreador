esprima = require 'esprima'
class Trace
  _id = 1
  constructor: (@func, @loc, @range, @position, @tracer) ->
    @id = _id++
  toAST: ->
    (esprima.parse "#{@tracer.name}.trace(#{@toParam()})")
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

module.exports = Trace
