class Profile
  _id = 1
  constructor: (@page) ->
    @id = _id++
    @calls = []
    @finishedCalls = []
  latestUnfinishedCall: (func) ->
    calls = @calls.filter (c) ->
      c.func == func && c.traces.length == 1 && c.traces[0].position == 'start'
    calls[calls.length - 1]
  toJSON: ->
    id:          @id
    fileName:    @page.fileName
    sourceCount: @page.sources.length
    funcCount:   @page.funcCount()
    callCount:   @calls.length
module.exports = Profile
