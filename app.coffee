express    = require 'express'
path       = require 'path'
fs         = require 'fs'
esprofiler = require './index'

app = express()

mimeTypes =
  ".html": "text/html",
  ".css" : "text/css",
  ".js"  : "application/javascript",
  ".png" : "image/png",
  ".jpg" : "image/jpeg",
  ".gif" : "image/gif",
  ".txt" : "text/plain"


app.get('/hello.txt', (req, res) ->
  res.send('Hello World')
)

app.get('/srcs/:src_id/logs/create', (req, res) ->
  
)

app.get('/srcs/:src_id/logs/summarize', (req, res) ->
  
)

app.get('/apps/:app_id/logs/create', (req, res) ->
  
)

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
      file = esprofiler.Injector.inject file.toString(),
                                        uri,
                                        esprofiler.SimpleLogger
    console.log "request to #{uri}" if ext == ".html"
    res.write(file, 'binary')
    res.end()
