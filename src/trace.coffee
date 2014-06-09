esprima = require 'esprima'
class Trace
  _id = 1
  constructor: (@func, @loc, @range, @position, @tracer) ->
    @id = _id++
  toAST: ->
    (esprima.parse "#{@tracer.name}.trace(#{@toParam()})")
  toParam: ->
    json = {
      id: @id,
      loc: @loc,
      range: @range,
      position: @position
    }
    if @func?
      json['func_id'] = @func.id
      json['source_id'] = @func.source.id
      json['html_id'] = @func.source.html.id if @func.source.html?
    JSON.stringify(json)

module.exports = Trace
