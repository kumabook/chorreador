fs = require 'fs'

class Tracer
  constructor: (@tracerDefinitionFile, @name) ->
    fs.readFile @tracerDefinitionFile, 'binary', (error, file) =>
      if error?
        console.log "error"
      else
        @tracerDefinition = file.toString()
  traceGen: (fileName, fn, phase) ->
    console.log("#{fileName} #{fn.name}");
    logItem = {
      file: fileName
      func: fn.name
      line: fn.line
      range: fn.range
      phase: phase
      return: fn.return ? false
    }
    "#{@name}(" + JSON.stringify(logItem) + ' );'

module.exports = Tracer
