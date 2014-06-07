fs     = require 'fs'
Tracer = require './tracer'
class ConsoleTracer extends Tracer
  name: 'estracer',
  generateTraceDefinition: () ->
    "\n(#{@traceDefinition.toString()})(global)\n"
  traceDefinition: (global) ->
    estracer = {
      count: 0,
      trace: (param) ->
        param.time = Date.now()
        param.count = estracer.count++
        param.caller = arguments.callee.caller.name
        console.log param
    }
    global.estracer = estracer
module.exports = ConsoleTracer
