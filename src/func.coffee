class Func
  _id = 1
  constructor: (@name, @range, @source) ->
    @id = _id++
    @traces = []
    @calls = []
  getUnfinishedCall: () ->
    @calls.filter((c) ->
      c.traces.length == 1 && c.traces[0].position == 'start'
  )[0]

module.exports = Func
