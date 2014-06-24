class Page
  _id = 1
  constructor: (@uri, @path, @code) ->
    @id      = _id++
    @sources = []
  toJSON: () ->
    id:      @id
    sources: @sources
module.exports = Page
