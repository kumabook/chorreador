esmorph    = require 'esmorph'

class Injector
  @inject: (source, sourceName, logger) ->
    tracers = [
      (esmorph.Tracer.FunctionEntrance (fn) -> logger(sourceName, fn, 'start')),
      (esmorph.Tracer.FunctionExit (fn) -> logger(sourceName, fn, 'end'))
    ]
    code = esmorph.modify(source, tracers)

module.exports = Injector
