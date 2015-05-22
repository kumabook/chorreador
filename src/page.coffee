url = require 'url'
class Page
  _id = 1
  constructor: (@uri, @path, @code) ->
    @id       = _id++
    @sources  = []
    @fileName = url.parse(@uri).path
  funcCount: ->
    (@sources.map (s) -> s.funcs.length).reduce (a, b) -> a + b
  toJSON: () ->
    id:       @id
    sources:  @sources
module.exports = Page
