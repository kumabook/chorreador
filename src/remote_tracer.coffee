fs     = require 'fs'
Tracer = require './tracer'
class RemoteTracer extends Tracer
  name: 'chorreador'
  generateTraceDefinition: (pageId, profileId) ->
    "\n(#{@traceDefinition.toString()})(window, #{pageId}, #{profileId})\n"
  traceDefinition: (global, pageId, profileId) ->
    window.addEventListener "keydown", (e) ->
      if e.keyCode == 83
        alert('summarize')
        chorreador.summarize()
    chorreador =
      pageId:    pageId
      profileId: profileId
      count:     0
      traces:    []
      trace: (param, args, return_value) ->
        param.time         = Date.now()
        param.count        = chorreador.count++
        param.caller       = param.func_id
        param.args         = Array.prototype.slice.call(args)
        param.return_value = return_value
        @traces.push param
        return_value
      summarize: ->
        xhr = new XMLHttpRequest()
        xhr.onreadystatechange = ->
          if xhr.readyState == 4 && xhr.status == 200
            console.log 'Successfully summarize trace'
        url = "#{window.location.protocol}//#{window.location.host}" +
          "/pages/#{pageId}/profiles/#{profileId}/summarize"
        xhr.open 'POST', url, true
        xhr.setRequestHeader 'Content-type', 'application/json; charset=utf-8'
        cache = []
        json_str = JSON.stringify @traces, (key, value) ->
          if typeof value == 'object'
            str = Object.prototype.toString.call(value)
            switch str
              when '[object Object]'
                return value
              when '[object Array]'
                return value
              when '[object Number]'
                return value
              when '[object String]'
                return value
              when '[object Event]'
                return 'Event'
              when '[object global]'
                return 'global'
              else
                return
          return value
        xhr.send json_str
    global.chorreador = chorreador
module.exports = RemoteTracer
