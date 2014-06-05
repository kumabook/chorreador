class HTML
  _id = 1
  constructor: (@uri, @path) ->
    @id = _id++
    @sources = []

module.exports = HTML
