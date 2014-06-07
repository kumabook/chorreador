esprima    = require 'esprima'
escodegen  = require 'escodegen'
estraverse = require 'estraverse'
jsdom      = require 'jsdom'
Trace      = require './trace'
Func       = require './func'

class Injector
  @findFuncName: (node, parent, code) ->
    if node.type == esprima.Syntax.FunctionDeclaration
      return node.id.name;
    else if node.type == esprima.Syntax.FunctionExpression
      if parent.type == esprima.Syntax.AssignmentExpression
        if typeof parent.left.range != 'undefined'
          return code.slice(parent.left.range[0],
                            parent.left.range[1]).replace(/"/g, '\\"');
      else if parent.type == esprima.Syntax.VariableDeclarator
        return parent.id.name;
      else if parent.type == esprima.Syntax.CallExpression
        return if parent.callee.id then parent.callee.id.name else '[Anonymous]';
      else if typeof parent.length == 'number'
        return if parent.id then parent.id.name else '[Anonymous]';
      else if typeof parent.key != 'undefined'
        if parent.key.type == 'Identifier'
          if parent.value == node && parent.key.name
            return parent.key.name

  @injectFunctionTraceDefinition2HTML: (html, htmlID, tracer) ->
    window = jsdom.jsdom(html).parentWindow
    scriptEl = window.document.createElement("script")
    scriptEl.innerHTML = tracer.generateTraceDefinition htmlID
    window.document.head.appendChild(scriptEl)
    console.log window.document.innerHTML
    window.document.innerHTML
  @injectFunctionTraceDefinition: (source, tracer) ->
    source.code = tracer.generateTraceDefinition() + source.code
  @injectFunctionTrace: (source, tracer) ->
    funcList = source.funcs
    ast = esprima.parse source.code, {
      loc: true,
      range: true
    }
    funcStack = []
    estraverse.traverse ast, {
      enter: (node, parent) =>
        funcName = Injector.findFuncName node, parent, source.code
        if funcName?
          func = new Func(funcName, node.range, source)
          node.func = func
          funcStack.push(func)
          funcList.push(func)
          trace = new Trace(node.func, node.range, 'start', tracer)
          node.body.body = trace.toAST().body.concat node.body.body
        if node.type == esprima.Syntax.ReturnStatement
          func = funcStack[funcStack.length - 1]
          trace = new Trace(func, node.range, 'return', tracer)
          @injectBeforeReturnStatement node, parent, trace
      leave: (node, parent) ->
        if node.func?
          func = funcStack.pop()
          trace = new Trace(func, node.range, 'end', tracer)
          node.body.body = node.body.body.concat trace.toAST().body
          console.assert node.func == func
    }
    source.code = escodegen.generate ast
  @injectBeforeReturnStatement: (node, parent, trace) ->
    traceNode = trace.toAST()
    switch parent.type
      when esprima.Syntax.BlockStatement
        parent.body = traceNode.body.concat parent.body
      when esprima.Syntax.SwitchCase
        parent.consequent.splice parent.consequent.length-1, 0, traceNode
      when esprima.Syntax.IfStatement
        if parent.consequent == node
          parent.consequent = {
            type: esprima.Syntax.BlockStatement,
            body: [traceNode, node]
          }
        else if parent.alternate == node
          console.log 'alternate'
          parent.alternate = {
            type: esprima.Syntax.BlockStatement,
            body: [traceNode, node]
          }
        else
          throw new Error('unexpected return statement')
      when esprima.Syntax.WhileStatement
        parent.body = {
          type: esprima.Syntax.BlockStatement,
          body: [traceNode, node]
      }
      when esprima.Syntax.ForStatement
        parent.body = {
          type: esprima.Syntax.BlockStatement,
          body: [traceNode, node]
      }
      else
        console.log parent
        throw new Error('unexpected return statement')
module.exports = Injector
