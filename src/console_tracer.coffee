fs     = require 'fs'
Tracer = require './tracer'
class ConsoleTracer extends Tracer
  name: 'chorreador',
  generateTraceDefinition: () ->
    "\n(#{@traceDefinition.toString()})(global)\n"
  traceDefinition: (global) ->
    chorreador =
      count: 0,
      trace: (param) ->
        param.time = Date.now()
        param.count = chorreador.count++
        param.caller = arguments.callee.caller.name
        console.log param
    global.chorreador = chorreador
module.exports = ConsoleTracer
