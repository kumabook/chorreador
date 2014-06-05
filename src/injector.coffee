esmorph = require 'esmorph'
jsdom   = require 'jsdom'
Trace   = require './trace'
Func    = require './func'

class Injector
  @injectFunctionTracerDefinition: (html, tracerDef) ->
    window = jsdom.jsdom(html).parentWindow
    scriptEl = window.document.createElement("script")
    scriptEl.innerHTML = tracerDef
    window.document.head.appendChild(scriptEl)
#    console.log window.document.innerHTML
    window.document.innerHTML
  @injectFunctionTracer: (source, tracer) ->
    funcList = source.funcs
    entrance = (fn) ->
#      console.log ("entrance #{source.path} #{fn.name} #{fn.line}")
      func = new Func(fn.name, fn.range, source)
      funcList.push func
      trace = new Trace(func, fn.range, 'start')
      func.traces.push(trace)
      "#{tracer.name}(" + trace.toParam() + ' );'
    exit = (fn) ->
#      console.log ("exit #{source.path} #{fn.name} #{fn.range}")
      func = funcList.filter((f) ->
         f.range[0] == fn.range[0] && f.range[1] == fn.range[1])[0]
      trace = new Trace(func,
                        fn.ranage,
                        if fn.return? then 'return' else 'end')
      if func?
        func.traces.push(trace)
      "#{tracer.name}(" + trace.toParam() + ' );'
    tracers = [
      (esmorph.Tracer.FunctionEntrance entrance),
      (esmorph.Tracer.FunctionExit exit)
    ]
    code = esmorph.modify(source.code, tracers)

module.exports = Injector
