class Call
  _id = 1
  constructor: (@func, @caller, @startTime) ->
    @id = _id++
    @traces = []
    @endTime
module.exports = Call
