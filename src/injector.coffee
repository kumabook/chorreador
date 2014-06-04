esmorph = require 'esmorph'
jsdom   = require 'jsdom'

class Injector
  @injectFunctionTracerDefinition: (html, tracerDef) ->
    window = jsdom.jsdom(html).parentWindow
    scriptEl = window.document.createElement("script")
    scriptEl.innerHTML = tracerDef
    window.document.head.appendChild(scriptEl)
    console.log window.document.innerHTML
    window.document.innerHTML
  @injectFunctionTracer: (source, sourceName, tracer) ->
    entrance = (fn) -> tracer.traceGen(sourceName, fn, 'start')
    exit = (fn) -> tracer.traceGen(sourceName, fn, 'end')
    tracers = [
      (esmorph.Tracer.FunctionEntrance entrance),
      (esmorph.Tracer.FunctionExit exit)
    ]
    code = esmorph.modify(source, tracers)

module.exports = Injector
