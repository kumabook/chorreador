express       = require 'express'
bodyParser    = require('body-parser')
path          = require 'path'
fs            = require 'fs'

RemoteTracer  = require './remote_tracer'
Injector      = require './injector'
HTML          = require './html'
Source        = require './source'
Func          = require './func'
Call          = require './call'
Profile       = require './profile'

mimeTypes   = {
  ".html": "text/html",
  ".css" : "text/css",
  ".js"  : "application/javascript",
  ".json": "application/json",
  ".png" : "image/png",
  ".jpg" : "image/jpeg",
  ".gif" : "image/gif",
  ".txt" : "text/plain"
}

class Server
  constructor: (@port, @targetDir) ->
    @app         = express()
    @htmlList    = []
    @profileList = []
    @tracer      = new RemoteTracer()

    @app.use bodyParser
      limit: 1024 * 1024 * 500
    callCreatePath = '/htmls/:hid/profiles/:pid/sources/:sid/' +
               'funcs/:fid/traces/:tid/calls/create'
    @app.get '/',                                    @handleTop
    @app.get  callCreatePath,                        @handleCallCreate
    @app.post '/htmls/:hid/profiles/:pid/summarize', @handleSummarize
    @app.get  /^\/target\/(.*)?/,                    @handleTarget
  run: () ->
    @server = @app.listen @port, =>
      console.log "Listening on port #{@server.address().port}"

  handleTop: (req, res) =>
    res.writeHead 200, {
      'Content-Type': mimeTypes['.txt']
    }
    res.send('This is esprofiler project.')
  handleCallCreate: (req, res) =>
    res.writeHead 200, {
      'Content-Type': mimeTypes['.txt']
    }
    html    = @htmlList.filter((h) -> h.id == ~~req.params.hid)[0]
    profile = @profileList.filter((p) -> p.id == ~~req.params.pid)[0]
    source  = html.sources.filter((s) -> s.id == ~~req.params.sid)[0] if html?
    func    = source.funcs.filter((f) -> f.id == ~~req.params.fid)[0] if source?
    trace   = func.traces.filter((t) -> t.id == ~~req.params.tid)[0] if trace?
    if func?
      switch  trace.position
        when 'start'
          call = new Call(func, trace.caller, trace.time)
          call.traces.push trace
          profile.calls.push call
        when 'end', 'return'
          call = profile.latestUnfinishedCall func
          if call?
            call.traces.push trace
            call.endTime = trace.time
          else
            console.log "warning: unexpected function trace #{func.name}"
    res.end()
  handleSummarize: (req, res) =>
    html    = @htmlList.filter((h) -> h.id == ~~req.params.hid)[0]
    profile = @profileList.filter((p) -> p.id == ~~req.params.pid)[0]
    traces  = req.body
    for trace in traces
      source = html.sources.filter((s) -> s.id == ~~trace.source_id)[0]
      func   = source.funcs.filter((f) -> f.id == ~~trace.func_id)[0] if source?
      if func?
        switch trace.position
          when 'start'
            call = new Call(func, trace.caller, trace.time)
            call.traces.push trace
            profile.calls.push call
          when 'end', 'return'
            call = profile.latestUnfinishedCall func
            if call?
              call.traces.push trace
              call.endTime = trace.time
            else
              console.log "warning: unexpected function trace " +
                "#{source.path} #{func.loc.start.line} " +
                "id:#{func.id} #{func.name} trace_id:#{trace.id} " +
                "#{trace.loc.start.line}"
    for source in html.sources
      for func in source.funcs
        count = profile.calls.filter((c) -> c.func == func).length
        if count > 0
          console.log "#{source.path}: #{func.name} is called #{count} times."
    res.contentType('text/plain')
    res.writeHead 200
    res.write 'Summarize completed.\n'
    res.end()
    console.log "Summarize completed: total #{traces.length} traces " +
                "and #{profile.calls.length} function calls."
  handleTarget: (req, res) =>
    fileName = path.join process.cwd() + "/#{@targetDir}/", req.params[0]
#  console.log fileName
    if fs.existsSync(fileName) && fs.statSync(fileName).isDirectory()
      fileName += '/index.html'
    else if fs.existsSync fileName
      @renderStaticFile req, res, fileName
    else
      @renderNotFound req, res

  renderNotFound: (req, res) =>
    res.contentType('text/plain')
    res.writeHead 404
    res.write '404 Not Found\n'
    res.end()

  renderStaticFile: (req, res, fileName) =>
    ext  = path.extname fileName
    res.contentType(mimeTypes[ext])
    res.writeHead 200

    fs.readFile fileName, 'binary', (error, file) =>
      uri = req.protocol + '://' + req.get('host') + req.url
      referer = req.headers.referer
      switch ext
        when ".html"
          html = @htmlList.filter((h) -> h.uri == uri)[0]
          if !html?
            html = new HTML(uri, fileName)
            @htmlList.push html
          html.code = file.toString()
          profile   = new Profile(html)
          @profileList.push profile
          file      = Injector.injectFunctionTraceDefinition2HTML(html,
                                                                profile,
                                                                @tracer)
        when ".js"
          code    = file.toString()
          html    = @htmlList.filter((h) -> h.uri == referer)[0]
          profile = @profileList.filter((h) -> h.uri == referer)[0]
          if html?
            source = new Source(uri, code, html)
            html.sources[uri] = source
            html.sources.push source

          file = Injector.injectFunctionTrace source, @tracer
      res.write(file, 'binary')
      res.end()
module.exports = Server
