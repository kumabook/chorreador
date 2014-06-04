class Analyze
  constructor: (@html) ->
    @calls = []
  addCall: (call) ->
    @calls.push(call)
module.exports = Analyze
