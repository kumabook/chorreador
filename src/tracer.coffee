fs = require 'fs'
class Tracer
  constructor: (@tracerDefinitionFile, @name) ->
    fs.readFile @tracerDefinitionFile, 'binary', (error, file) =>
      if error?
        console.log "error"
      else
        @tracerDefinition = file.toString()
module.exports = Tracer
