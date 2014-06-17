class HTML
  _id = 1
  constructor: (@uri, @path) ->
    @id      = _id++
    @sources = []
    @code    = null
  toJSON: () ->
    id:      @id
    sources: @sources
module.exports = HTML
