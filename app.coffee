express    = require 'express'
path       = require 'path'
fs         = require 'fs'
#esprofiler = require './index'

Tracer     = require './src/tracer'
Injector   = require './src/injector'

app = express()

tracer = new Tracer('./src/simple-logger-client.js', 'logger.trace')
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
  if req.method == 'GET'
    console.log req.query
  res.end()
)
logItems = {}
addLogItem = (logItem) ->
  logItems[logItem.id] ?= {}
  logItems[logItem.id][logItem.phase] = logItem
#  console.log logItem.phase
#  console.log("func(id=#{logItem.id},#{logItem.func},#{logItem.line})")
  if logItem.phase == 'end'
    funcItem = logItems[logItem.id]
    startTime = funcItem.start.timestamp if funcItem.start?
    endTime   = funcItem.end.timestamp
    funcItem.duration = endTime - startTime
    console.log("#{logItem.id},\"#{logItem.file}\",\"#{logItem.func}\",\"#{funcItem.start.line}-#{funcItem.end.line}\",#{funcItem.duration}")
#    console.log("time of id=#{logItem.id}) is #{funcItem.duration}")


app.get('/srcs/:src_id/logs/create', (req, res) ->
)

app.get('/srcs/:src_id/logs/summarize', (req, res) ->
)

app.get('/apps/:app_id/logs/create', (req, res) ->
)
app.use(express.static(__dirname + '/assets'))

app.get(/^\/target\/(.*)?/, (req, res) ->
  fileName = path.join process.cwd() + '/target/', req.params[0]
  console.log fileName

  if fs.existsSync(fileName) && fs.statSync(fileName).isDirectory()
    fileName += '/index.html'
  else if fs.existsSync fileName
    renderStaticFile req, res, fileName, req.originalUrl
  else
    renderNotFound req, res
)

server = app.listen(3000, ->
  console.log('Listening on port %d', server.address().port)
)

renderNotFound = (req, res) ->
  res.writeHead 404
  res.contentType('text/plain')
  res.write '404 Not Found\n'
  res.end()


renderStaticFile = (req, res, fileName, uri) ->
  ext  = path.extname fileName
  res.contentType(mimeTypes[ext])
  res.writeHead 200

  fs.readFile fileName, 'binary', (error, file) ->
#    if (injectedSources.filter (s) -> fileName.match s).length > 0
    if ext == ".js"
      file = Injector.injectFunctionTracer file.toString(),
                                           uri,
                                           tracer
    else if ext == ".html"
      file = Injector.injectFunctionTracerDefinition(
        file.toString(),
        tracer.tracerDefinition)
    res.write(file, 'binary')
    res.end()
