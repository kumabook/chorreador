class Trace
  _id = 1
  constructor: (@func, @range, @position) ->
    @id = _id++
  toParam: () ->
    json = {
      id: @id,
      range: @range,
      position: @position
    }
    if @func?
      json['func_id'] = @func.id
      json['source_id'] = @func.source.id
      json['html_id'] = @func.source.html.id
    JSON.stringify(json)

module.exports = Trace
