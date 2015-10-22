var esprima    = require('esprima'),
    escodegen  = require('escodegen'),
    estraverse = require('estraverse'),
    jsdom      = require('jsdom'),
    Trace      = require('./trace'),
    Func       = require('./func'),
    S          = esprima.Syntax;

class Instrumentor {
  static findFuncName(node, parent, code) {
    if (node.type == S.FunctionDeclaration) {
      return node.id.name;
    } else if (node.type == S.FunctionExpression) {
      switch(parent.type){
      case  S.AssignmentExpression:
        if (typeof parent.left.range != 'undefined') {
            return code.slice(parent.left.range[0],
                              parent.left.range[1]).replace(/"/g, '\\"');
        }
      case S.VariableDeclarator:
        return parent.id.name;
      case S.CallExpression:
        if (parent.callee.id) {
          return parent.callee.id.name;
        } else {
          return  '[Anonymous]';
        }
      case S.ReturnStatement:
      case S.LogicalExpression:
      case S.ConditionalExpression:
        return '[Anonymous]';

        if (typeof parent.length == 'number') {
          if (parent.id) {
            return parent.id.name;
          } else {
            return '[Anonymous]';
          };
        } else if (typeof parent.key != 'undefined') {
          switch (parent.key.type) {
          case 'Identifier':
            if (parent.value == node && parent.key.name) {
              return parent.key.name;
            }
          case 'Literal':
            if (parent.value == node && parent.key.value) {
              return parent.key.value;
            }
          }
        }
        return '[Anonymous]';
      }
    }
  }
  static instrumentFunctionTraceDefinition2Page (page, profile, tracer, preference) {
    var doc                = jsdom.jsdom(page.code),
        window             = doc.defaultView,
        scriptEl           = window.document.createElement("script");
    scriptEl.innerHTML     = tracer.generateTraceDefinition(page.id, profile.id, preference.recOnStart);
    window.document.head.insertBefore(scriptEl, window.document.head.firstChild);
    return doc.documentElement.outerHTML;
  }
  static instrumentFunctionTraceDefinition(source, tracer) {
    return source.code = tracer.generateTraceDefinition() + source.code;
  }
  static instrumentFunctionTrace(source, tracer) {
    var funcList = source.funcs;
    var ast = esprima.parse(source.code, {
      loc: true,
      range: true
    });
    var funcStack = [];
    estraverse.traverse(ast, {
      enter: (node, parent) => {
        var funcName = Instrumentor.findFuncName(node, parent, source.code);
        if (funcName) {
          var func = new Func(funcName, node.loc, node.range, source);
          node.func = func;
          funcStack.push(func);
          funcList.push(func);
          var trace = new Trace(func, node.loc, node.range, 'start', tracer);
          node.body.body = trace.toAST().body.concat(node.body.body);
        }
        if (node.type == S.ReturnStatement) {
          func = funcStack[funcStack.length - 1];
          trace = new Trace(func, node.loc, node.range, 'return', tracer);
          this.instrumentBeforeReturnStatement(node, parent, trace);
        }
      },
      leave: (node, parent) => {
        if (node.func) {
          var func = funcStack.pop();
          var trace = new Trace(func, node.loc, node.range, 'end', tracer);
          node.body.body = node.body.body.concat(trace.toAST().body);
          console.assert(node.func == func);
        }
      }
    });
    return escodegen.generate(ast);
  }
  static instrumentBeforeReturnStatement(node, parent, trace) {
    var traceNode = trace.toTraceReturnAST(node);
    switch(parent.type) {
    case S.BlockStatement:
      var index = parent.body.indexOf(node);
      if (index != -1) {
        parent.body[index] = traceNode;
      }
      break;
    case S.SwitchCase:
      parent.consequent[parent.consequent.length-1] = traceNode;
      break;
    case S.IfStatement:
      if (parent.consequent == node) {
        parent.consequent = traceNode;
      } else if (parent.alternate == node) {
        parent.alternate = traceNode;
      } else {
        throw new Error('unexpected return statement');
      }
    case S.WhileStatement:
      parent.body = traceNode;
      break;
    case S.ForStatement:
      parent.body = traceNode;
      break;
    case S.ForInStatement:
      parent.body = traceNode;
      break;
    default:
      throw new Error('unexpected return statement:' + parent.type);
      break;
    }
  }
};
module.exports = Instrumentor;
