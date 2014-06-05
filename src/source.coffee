class Source
  _id = 1
  constructor: (@path, @code, @html) ->
    @id = _id++
    @funcs = []

module.exports = Source
