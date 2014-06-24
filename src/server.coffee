express      = require 'express'
bodyParser   = require('body-parser')
path         = require 'path'
fs           = require 'fs'

RemoteTracer = require './remote_tracer'
Instrumentor = require './instrumentor'
Page         = require './page'
Source       = require './source'
Func         = require './func'
Call         = require './call'
Profile      = require './profile'

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
  constructor: (@port, @instrumentedDir) ->
    @app         = express()
    @pageList    = []
    @profileList = []
    @tracer      = new RemoteTracer()
    @app.set 'views', path.join(__dirname, '../views')
    @app.set 'view engine', 'jade'

    @app.use(bodyParser.urlencoded extended: true)
    @app.use(bodyParser.json(),
      limit: 1024 * 1024 * 500)
    @app.use require("connect-assets")()
    @app.use '/bower_components',
             express.static __dirname + '/../bower_components'
    callCreatePath = '/pages/:pid/profiles/:prof_id/sources/:sid/' +
               'funcs/:fid/traces/:tid/calls/create'
    @app.get '/',                                        @handleTop
    @app.get  callCreatePath,                            @handleCallCreate
    @app.post '/pages/:pid/profiles/:prof_id/summarize', @handleSummarize
    @app.get  /^\/instrumented\/(.*)?/,                  @handleTarget
    @app.get '/pages/:pid/profiles/:prof_id',            @handleProfile

  run: () ->
    @server = @app.listen @port, =>
      console.log "Listening on port #{@server.address().port}"
  handleProfile: (req, res) =>
    console.log 'handle profile'
    page    = @pageList.filter((h) -> h.id == ~~req.params.pid)[0]
    profile = @profileList.filter((p) -> p.id == ~~req.params.prof_id)[0]
    res.render 'profile',
      title: 'test'
      page: page
      profile: profile
  handleTop: (req, res) =>
    res.writeHead 200, {
      'Content-Type': mimeTypes['.txt']
    }
    res.send('This is chorreador project.')
  handleCallCreate: (req, res) =>
    res.writeHead 200, {
      'Content-Type': mimeTypes['.txt']
    }
    page    = @pageList.filter((h) -> h.id == ~~req.params.pid)[0]
    profile = @profileList.filter((p) -> p.id == ~~req.params.prof_id)[0]
    source  = page.sources.filter((s) -> s.id == ~~req.params.sid)[0] if html?
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
    page    = @pageList.filter((h) -> h.id == ~~req.params.pid)[0]
    profile = @profileList.filter((p) -> p.id == ~~req.params.prof_id)[0]
    traces  = req.body
    for trace in traces
      source = page.sources.filter((s) -> s.id == ~~trace.source_id)[0]
      func   = source.funcs.filter((f) -> f.id == ~~trace.func_id)[0] if source?
      if func?
        console.log trace.caller
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
    for source in page.sources
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
    fileName = path.join process.cwd() + "/#{@instrumentedDir}/", req.params[0]
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
          page = @pageList.filter((h) -> h.uri == uri)[0]
          if !page?
            page = new Page(uri, fileName, file.toString())
            @pageList.push page
          profile   = new Profile(page)
          @profileList.push profile
          file      = Instrumentor.instrumentFunctionTraceDefinition2Page(page,
                                                                profile,
                                                                @tracer)
        when ".js"
          page    = @pageList.filter((h) -> h.uri == referer)[0]
          profile = @profileList.filter((h) -> h.uri == referer)[0]
          if page?
            source = new Source(uri, file.toString(), page)
            page.sources[uri] = source
            page.sources.push source

          file = Instrumentor.instrumentFunctionTrace source, @tracer
      res.write(file, 'binary')
      res.end()

module.exports = Server
