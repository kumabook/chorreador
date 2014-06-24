fs     = require 'fs'
Tracer = require './tracer'
class RemoteTracer extends Tracer
  name: 'chorreador',
  generateTraceDefinition: (pageId, profileId) ->
    "\n(#{@traceDefinition.toString()})(window, #{pageId}, #{profileId})\n"
  traceDefinition: (global, pageId, profileId) ->
    window.onload = (e) ->
      chorreador.summarize()
    chorreador =
      pageId:    pageId
      profileId: profileId
      count:     0
      traces:    []
      trace: (param) ->
        arguments.callee.id = param.func_id
        console.log(arguments.callee.caller.id)
        param.time   = Date.now()
        param.count  = chorreador.count++
        param.caller = param.func_id#arguments.callee.caller
        @traces.push param
      summarize: ->
        xhr = new XMLHttpRequest()
        xhr.onreadystatechange = ->
          if xhr.readyState == 4 && xhr.status == 200
            console.log 'Successfully summarize trace'
        url = "#{window.location.protocol}//#{window.location.host}" +
          "/pages/#{pageId}/profiles/#{profileId}/summarize";
        xhr.open 'POST', url, true
        xhr.setRequestHeader 'Content-type', 'application/json; charset=utf-8'
        xhr.send JSON.stringify @traces
    global.chorreador = chorreador
module.exports = RemoteTracer
