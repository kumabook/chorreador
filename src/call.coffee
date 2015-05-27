class Call
  @instances = {}
  _id = 1
  constructor: (@func, @caller, @startTime, @args) ->
    @id = _id++
    @traces = []
    @endTime
    @return_value
    Call.instances[@id] = this
  isFinished: () -> @traces.length == 2
  isStarted: () -> @traces.length != 0
  duration: () -> @endTime - @startTime
  toJSON: ->
    id:           @id
    func:         @func
    traces:       @traces
    caller:       @caller
    startTime:    @startTime
    endTime:      @endTime
    duration:     @duration()
#    args:         @args
#    return_value: @return_value
module.exports = Call
