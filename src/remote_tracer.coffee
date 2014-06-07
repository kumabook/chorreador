fs     = require 'fs'
Tracer = require './tracer'
class RemoteTracer extends Tracer
  name: 'esprofiler',
  generateTraceDefinition: () ->
    "\n(#{@traceDefinition.toString()})(window)\n"
  traceDefinition: (global) ->
    esprofiler = {
      count: 0,
      trace: (param) ->
        xhr = new XMLHttpRequest()
        xhr.onreadystatechange = ->
        param.time   = Date.now()
        param.count  = esprofiler.count++
        param.caller = arguments.callee.caller.name
        url = window.location.protocol + '//' +
          window.location.host + '/htmls/' + param.html_id +
            '/sources/' + param.source_id +
            '/funcs/' + param.func_id +
            '/traces/' + param.id +
            '/calls/create'
        url += '?time=' + param.time
        url += '&caller=' + param.caller
        url += '&count=' + param.count
        xhr.open 'GET', url, true
        xhr.send()
    }
    global.esprofiler = esprofiler
module.exports = RemoteTracer
