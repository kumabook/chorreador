fs     = require 'fs'
Tracer = require './tracer'
class RemoteTracer extends Tracer
  name: 'esprofiler',
  generateTraceDefinition: (id) ->
    "\n(#{@traceDefinition.toString()})(window, #{id})\n"
  traceDefinition: (global, id) ->
    window.onload = (e) ->
      esprofiler.summarize()
    esprofiler = {
      id: id,
      count: 0,
      traces: [],
      trace: (param) ->
        param.time   = Date.now()
        param.count  = esprofiler.count++
        param.caller = arguments.callee.caller.name
        @traces.push param
      summarize: ->
        xhr = new XMLHttpRequest()
        xhr.onreadystatechange = ->
          if xhr.readyState == 4 && xhr.status == 200
            console.log 'Successfully summarize trace'
        url = window.location.protocol + '//' +
          window.location.host + '/htmls/' + id +
            '/summarize';
        xhr.open 'POST', url, true
        xhr.setRequestHeader 'Content-type', 'application/json; charset=utf-8'
        xhr.send JSON.stringify @traces
    }
    global.esprofiler = esprofiler
module.exports = RemoteTracer
###
        xhr = new XMLHttpRequest()
        xhr.onreadystatechange = ->
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
###
