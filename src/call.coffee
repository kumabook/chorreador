class Call
  _id = 1
  constructor: (@func, @caller, @startTime) ->
    @id = _id++
    @traces = []
    @endTime
  isFinished: () -> @traces.length == 2
  isStarted: () -> @traces.length != 0
  duration: () -> @endTime - @startTime
module.exports = Call
