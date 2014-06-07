fs = require 'fs'
class Tracer
  name: 'esprofiler',
  generateTraceDefinition: () ->
    throw new Error 'not implemented'
  traceDefinition: (global) ->
    throw new Error 'not implemented'
module.exports = Tracer
