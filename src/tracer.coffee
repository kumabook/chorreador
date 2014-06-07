fs = require 'fs'
class Tracer
  name: 'esprofiler',
  generateTraceDefinition: (htmlID, profileID) ->
    throw new Error 'not implemented'
  traceDefinition: (global) ->
    throw new Error 'not implemented'
module.exports = Tracer
