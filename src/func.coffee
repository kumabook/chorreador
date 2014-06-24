class Func
  _id = 1
  constructor: (@name, @loc, @range, @source) ->
    @id = _id++
  toJSON: () ->
    id:    @id
    name:  @name
    loc:   @loc
    range: @range
module.exports = Func
