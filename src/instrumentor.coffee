esprima    = require 'esprima'
escodegen  = require 'escodegen'
estraverse = require 'estraverse'
jsdom      = require 'jsdom'
Trace      = require './trace'
Func       = require './func'
S          = esprima.Syntax

class Instrumentor
  @findFuncName: (node, parent, code) ->
    if node.type == S.FunctionDeclaration
      return node.id.name;
    else if node.type == S.FunctionExpression
      switch parent.type
        when S.AssignmentExpression
          if typeof parent.left.range != 'undefined'
            return code.slice(parent.left.range[0],
                              parent.left.range[1]).replace(/"/g, '\\"');
        when S.VariableDeclarator
          return parent.id.name;
        when S.CallExpression
          if parent.callee.id
            return parent.callee.id.name
          else
            return  '[Anonymous]'
        when S.ReturnStatement, S.LogicalExpression, S.ConditionalExpression
          return '[Anonymous]'

      if typeof parent.length == 'number'
        return if parent.id then parent.id.name else '[Anonymous]';
      else if typeof parent.key != 'undefined'
        switch parent.key.type
          when 'Identifier'
            if parent.value == node && parent.key.name
              return parent.key.name
          when 'Literal'
            if parent.value == node && parent.key.value?
              return parent.key.value
      return '[Anonymous]'

  @instrumentFunctionTraceDefinition2Page: (page, profile, tracer) ->
    doc                = jsdom.jsdom(page.code)
    window             = doc.defaultView
    scriptEl           = window.document.createElement("script")
    scriptEl.innerHTML = tracer.generateTraceDefinition page.id, profile.id
    window.document.head.insertBefore scriptEl, window.document.head.firstChild
    doc.documentElement.outerHTML
  @instrumentFunctionTraceDefinition: (source, tracer) ->
    source.code = tracer.generateTraceDefinition() + source.code
  @instrumentFunctionTrace: (source, tracer) ->
    funcList = source.funcs
    ast = esprima.parse source.code, {
      loc: true,
      range: true
    }
    funcStack = []
    estraverse.traverse ast, {
      enter: (node, parent) =>
        funcName = Instrumentor.findFuncName node, parent, source.code
        if funcName?
          func = new Func(funcName, node.loc, node.range, source)
          node.func = func
          funcStack.push(func)
          funcList.push(func)
          trace = new Trace(func, node.loc, node.range, 'start', tracer)
          node.body.body = trace.toAST().body.concat node.body.body
        if node.type == S.ReturnStatement
          func = funcStack[funcStack.length - 1]
          trace = new Trace(func, node.loc, node.range, 'return', tracer)
          @instrumentBeforeReturnStatement node, parent, trace
      leave: (node, parent) ->
        if node.func?
          func = funcStack.pop()
          trace = new Trace(func, node.loc, node.range, 'end', tracer)
          node.body.body = node.body.body.concat trace.toAST().body
          console.assert node.func == func
    }
    escodegen.generate ast
  @instrumentBeforeReturnStatement: (node, parent, trace) ->
    traceNode = trace.toTraceReturnAST node
    switch parent.type
      when S.BlockStatement
        index = parent.body.indexOf node
        parent.body[index] = traceNode if index != -1
      when S.SwitchCase
        parent.consequent[parent.consequent.length-1] = traceNode
      when S.IfStatement
        if parent.consequent == node
          parent.consequent = traceNode
        else if parent.alternate == node
          parent.alternate = traceNode
        else
          throw new Error('unexpected return statement')
      when S.WhileStatement
        parent.body = traceNode
      when S.ForStatement
        parent.body = traceNode
      when S.ForInStatement
        parent.body = traceNode
      else
        throw new Error('unexpected return statement:' + parent.type)
module.exports = Instrumentor
