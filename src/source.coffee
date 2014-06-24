class Source
  _id = 1
  constructor: (@path, @code, @page) ->
    @id = _id++
    @funcs = []
  toJSON: () ->
    id:    @id
    path:  @path
    code:  @code
    funcs: @funcs
module.exports = Source
