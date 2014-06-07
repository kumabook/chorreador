class Func
  _id = 1
  constructor: (@name, @range, @source) ->
    @id = _id++

module.exports = Func
