class Func
  _id = 1
  constructor: (@name, @loc, @range, @source) ->
    @id = _id++

module.exports = Func
