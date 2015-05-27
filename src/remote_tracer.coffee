fs     = require 'fs'
Tracer = require './tracer'
class RemoteTracer extends Tracer
  name: 'chorreador'
  generateTraceDefinition: (pageId, profileId) ->
    "\n(#{@traceDefinition.toString()})(window, #{pageId}, #{profileId})\n"
  traceDefinition: (global, pageId, profileId) ->
    chorreador =
      traceNumPerReport: 1000
      reportInterval:    1000 * 2
      isRecording:       true
      isReporting:       false
      pageId:            pageId
      profileId:         profileId
      count:             0
      traces:            []
      trace: (param, args, return_value) ->
        return return_value if !@isRecording
        param.time         = Date.now()
        param.count        = chorreador.count++
        param.caller       = param.func_id
        param.args         = Array.prototype.slice.call(args)
        param.return_value = return_value
        @traces.push param
        return_value
      setupRecButton: ->
        button = document.createElement 'div'
        button.style.width           = 100
        button.style.height          = 100
        button.style.top             = 0
        button.style.right           = 50
        button.style.zIndex          = 10000
        button.style.position        = 'fixed'
        button.style.backgroundColor = 'black'
        button.onclick = () =>
          @isRecording = !@isRecording
          @updateRecButton()
        @recButton = button
        @updateRecButton()
        document.body.appendChild button
      setupReporter: ->
        setInterval () =>
          return if @isReporting
          @reportTraces()
        , @reportInterval
        window.addEventListener "keydown", (e) =>
          if e.keyCode == 83
            return if @isReporting
            @reportTraces()
      updateRecButton: ->
        if @isRecording
          @recButton.style.backgroundColor = 'red'
          @recButton.innerHTML = 'recording'
        else if @isReporting
          @recButton.style.backgroundColor = 'blue'
          @recButton.innerHTML = 'reporting'
        else if @traces.length > 0
          @recButton.style.backgroundColor = 'green'
          @recButton.innerHTML = 'waiting for report'
        else
          @recButton.style.backgroundColor = 'gray'
          @recButton.innerHTML = 'empty'
      jsonStrOfTraces: (traces) ->
        cache = []
        JSON.stringify traces, (key, value) ->
          if typeof value == 'object'
            return null if cache.indexOf(value) != -1
            cache.push value
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
          value
      reportTraces: ->
        @isReporting = true
        console.log 'Start reporting'
        if @traces.length == 0
          console.log 'Nothing to report'
          @isReporting = false
          @updateRecButton()
          return
        xhr = new XMLHttpRequest()
        xhr.onreadystatechange = =>
          @isReporting = false if xhr.readyState == 4
          if xhr.readyState == 4 && xhr.status == 200
            console.log 'Successfully report traces'
          @updateRecButton()
        url = "#{window.location.protocol}//#{window.location.host}" +
          "/profiles/#{profileId}/report"
        xhr.open 'POST', url, true
        xhr.setRequestHeader 'Content-type', 'application/json; charset=utf-8'
        traces = @traces.splice 0, @traceNumPerReport
        @updateRecButton()
        xhr.send @jsonStrOfTraces traces
        xhr
    global.chorreador = chorreador
    window.addEventListener 'load', ->
      chorreador.setupRecButton()
      chorreador.setupReporter()
module.exports = RemoteTracer
