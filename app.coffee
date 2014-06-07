express       = require 'express'
path          = require 'path'
fs            = require 'fs'

RemoteTracer  = require './src/remote_tracer'
Injector      = require './src/injector'
HTML          = require './src/html'
Source        = require './src/source'
Func          = require './src/func'
Call          = require './src/call'

app = express()

port      = process.argv[2] || 3000
targetDir = process.argv[3] || 'target'

htmlList = []

tracer = new RemoteTracer()
mimeTypes =
  ".html": "text/html",
  ".css" : "text/css",
  ".js"  : "application/javascript",
  ".json": "application/json",
  ".png" : "image/png",
  ".jpg" : "image/jpeg",
  ".gif" : "image/gif",
  ".txt" : "text/plain"


app.get('/hello.txt', (req, res) ->
  res.send('Hello World')
)

app.get('/logs/create', (req, res) ->
  res.writeHead 200,
    'Content-Type': mimeTypes['.txt']
  html   = htmlList[req.headers.referer]
  source = html.sources[req.query.file] if html?
  func   = source.funcs[req.query.func] if source?
  func.calls.push(new Call(func, new Date(), new Date(), '')) if func?
  console.log "#{func.name} #{func.calls.length}"
  res.end()
)

app.get('/htmls/:hid/sources/:sid/funcs/:fid/traces/:tid/calls/create', (req, res) ->
  res.writeHead 200, {
    'Content-Type': mimeTypes['.txt']
  }
  html   = htmlList.filter((h) -> h.id == ~~req.params.hid)[0]
  source = html.sources.filter((s) -> s.id == ~~req.params.sid)[0] if html?
  func   = source.funcs.filter((f) -> f.id == ~~req.params.fid)[0] if source?
  trace  = func.traces.filter((t) -> t.id == ~~req.params.tid)[0] if trace?
  if func?
    unfinishedCall = func.getUnfinishedCall()
    if unifinishedCall?
      unfinishedCall.traces.push trace
      unfinishedCall.endTime = req.query.time
    else
      func.calls.push(new Call(func, req.query.caller, req.query.time))
    console.log "#{func.name} #{func.calls.length}"
  res.end()
)

app.post('/htmls/summarize', (req, res) ->
  html = htmlList[req.headers.refer]
)

app.get('/srcs/:src_id/logs/create', (req, res) ->
)

app.get('/srcs/:src_id/logs/summarize', (req, res) ->
)

app.get('/apps/:app_id/logs/create', (req, res) ->
)
app.get(/^\/target\/(.*)?/, (req, res) ->
  fileName = path.join process.cwd() + "/#{targetDir}/", req.params[0]
#  console.log fileName

  if fs.existsSync(fileName) && fs.statSync(fileName).isDirectory()
    fileName += '/index.html'
  else if fs.existsSync fileName
    renderStaticFile req, res, fileName
  else
    renderNotFound req, res
)

server = app.listen(port, ->
  console.log('Listening on port %d', server.address().port)
)

renderNotFound = (req, res) ->
  res.contentType('text/plain')
  res.writeHead 404
  res.write '404 Not Found\n'
  res.end()

renderStaticFile = (req, res, fileName) ->
  ext  = path.extname fileName
  res.contentType(mimeTypes[ext])
  res.writeHead 200

  fs.readFile fileName, 'binary', (error, file) ->
    uri = req.protocol + '://' + req.get('host') + req.url
    referer = req.headers.referer

    if ext == ".html"
      html = new HTML(uri, fileName)
      htmlList[uri] = html
      htmlList.push html
      file = Injector.injectFunctionTraceDefinition2HTML(
        file.toString(),
        tracer)
    else if ext == ".js"
      code = file.toString()
      html = htmlList[referer]
      if html?
#        console.log " #{uri} from #{referer}"
        source = new Source(uri, code, html)
        html.sources[uri] = source
        html.sources.push source

      file = Injector.injectFunctionTrace source, tracer
    res.write(file, 'binary')
    res.end()
