esprima    = require 'esprima'
escodegen  = require 'escodegen'
estraverse = require 'estraverse'
jsdom      = require 'jsdom'
Trace      = require './trace'
Func       = require './func'
Syntax     = esprima.Syntax

class Injector
  @findFuncName: (node, parent, code) ->
    if node.type == Syntax.FunctionDeclaration
      return node.id.name;
    else if node.type == Syntax.FunctionExpression
      if parent.type == Syntax.AssignmentExpression
        if typeof parent.left.range != 'undefined'
          return code.slice(parent.left.range[0],
                            parent.left.range[1]).replace(/"/g, '\\"');
      else if parent.type == Syntax.VariableDeclarator
        return parent.id.name;
      else if parent.type == Syntax.CallExpression
        return if parent.callee.id then parent.callee.id.name else '[Anonymous]'
      else if parent.type == Syntax.ReturnStatement
        return '[Anonymous]'
      else if parent.type == Syntax.LogicalExpression
        return '[Anonymous]'
      else if parent.type == Syntax.ConditionalExpression
        return '[Anonymous]'

      else if typeof parent.length == 'number'
        return if parent.id then parent.id.name else '[Anonymous]';
      else if typeof parent.key != 'undefined'
        if parent.key.type == 'Identifier'
          if parent.value == node && parent.key.name
            return parent.key.name
        else if parent.key.type == 'Literal'
          if parent.value == node && parent.key.value?
            return parent.key.value
      return '[Anonymous]'
#      throw new Error('unexpected FunctionExpression')

  @injectFunctionTraceDefinition2HTML: (html, profile, tracer) ->
    window   = jsdom.jsdom(html.code).parentWindow
    doc      = window.document
    scriptEl = doc.createElement("script")
    scriptEl.innerHTML = tracer.generateTraceDefinition html.id, profile.id
    doc.head.insertBefore scriptEl, doc.head.firstChild
#    console.log doc.innerHTML
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
          func = new Func(funcName, node.loc, node.range, source)
          node.func = func
          funcStack.push(func)
          funcList.push(func)
          trace = new Trace(func, node.loc, node.range, 'start', tracer)
          node.body.body = trace.toAST().body.concat node.body.body
        if node.type == Syntax.ReturnStatement
          func = funcStack[funcStack.length - 1]
          trace = new Trace(func, node.loc, node.range, 'return', tracer)
          @injectBeforeReturnStatement node, parent, trace
      leave: (node, parent) ->
        if node.func?
          func = funcStack.pop()
          trace = new Trace(func, node.loc, node.range, 'end', tracer)
          node.body.body = node.body.body.concat trace.toAST().body
          console.assert node.func == func
    }
    source.code = escodegen.generate ast
  @injectBeforeReturnStatement: (node, parent, trace) ->
    traceNode = trace.toAST()
    switch parent.type
      when Syntax.BlockStatement
        index = parent.body.indexOf node
        parent.body.splice index, 0, traceNode if  index != -1
      when Syntax.SwitchCase
        parent.consequent.splice parent.consequent.length-1, 0, traceNode
      when Syntax.IfStatement
        if parent.consequent == node
          parent.consequent = {
            type: Syntax.BlockStatement,
            body: [traceNode, node]
          }
        else if parent.alternate == node
          parent.alternate = {
            type: Syntax.BlockStatement,
            body: [traceNode, node]
          }
        else
          throw new Error('unexpected return statement')
      when Syntax.WhileStatement
        parent.body = {
          type: Syntax.BlockStatement,
          body: [traceNode, node]
      }
      when Syntax.ForStatement
        parent.body = {
          type: Syntax.BlockStatement,
          body: [traceNode, node]
      }
      else
        throw new Error('unexpected return statement')
module.exports = Injector
