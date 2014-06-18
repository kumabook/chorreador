fs     = require 'fs'
Tracer = require './tracer'
class RemoteTracer extends Tracer
  name: 'esprofiler',
  generateTraceDefinition: (htmlID, profileID) ->
    "\n(#{@traceDefinition.toString()})(window, #{htmlID}, #{profileID})\n"
  traceDefinition: (global, htmlID, profileID) ->
    window.onload = (e) ->
      esprofiler.summarize()
    esprofiler = {
      htmlID: htmlID,
      profileID: profileID,
      count: 0,
      traces: [],
      trace: (param) ->
        arguments.callee.id = param.func_id
        console.log(arguments.callee.caller.id)
        param.time   = Date.now()
        param.count  = esprofiler.count++
        param.caller = param.func_id#arguments.callee.caller
        @traces.push param
      summarize: ->
        xhr = new XMLHttpRequest()
        xhr.onreadystatechange = ->
          if xhr.readyState == 4 && xhr.status == 200
            console.log 'Successfully summarize trace'
        url = "#{window.location.protocol}//#{window.location.host}" +
          "/htmls/#{htmlID}/profiles/#{profileID}/summarize";
        xhr.open 'POST', url, true
        xhr.setRequestHeader 'Content-type', 'application/json; charset=utf-8'
        xhr.send JSON.stringify @traces
    }
    global.esprofiler = esprofiler
module.exports = RemoteTracer
