class Call
  _id = 1
  constructor: (@func, @caller, @startTime, @args) ->
    @id = _id++
    @traces = []
    @endTime
    @return_value
  isFinished: () -> @traces.length == 2
  isStarted: () -> @traces.length != 0
  duration: () -> @endTime - @startTime
  toJSON: ->
    id:           @id
    func:         @func
    traces:       @traces
    caller:       @caller
    args:         @args
    return_value: @return_value
    startTime:    @startTime
    endTime:      @endTime
    duration:     @duration()
module.exports = Call
