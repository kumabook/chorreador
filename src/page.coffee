url = require 'url'
class Page
  _id = 1
  constructor: (@uri, @path, @code, @id, @sources) ->
    @id       = _id++ if !@id?
    @sources  = [] if !@sources?
    @fileName = url.parse(@uri).path
  funcCount: ->
    (@sources.map (s) -> s.funcs.length).reduce (a, b) -> a + b
  toJSON: () ->
    id:      @id
    uri:     @uri
    path:    @path
    code:    @code
    sources: @sources
module.exports = Page
