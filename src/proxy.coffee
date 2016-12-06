express   = require 'express'
httpProxy = require 'http-proxy'
app       = express()

console.log httpProxy.RoutingProxy
proxy     = new httpProxy.RoutingProxy()

apiProxy = (host, port) ->
 (req, res, next) ->
  if req.url.match new RegExp "^\/api\/ "
    proxy.proxyRequest req, res,
      host: host
       port: port
  else
    next()

app.configure () ->
  app.use express.static(process.cwd() + "/generated")
  app.use apiProxy('localhost', 3000)
  app.use express.bodyParser()
  app.use express.errorHandler()

module.exports = app;
