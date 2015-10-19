var esprima = require('esprima');
class Trace {
  constructor (func, loc, range, position, tracer) {
    this.func     = func;
    this.loc      = loc;
    this.range    = range;
    this.position = position;
    this.tracer   = tracer;
    this.id = Trace._id++;
  }
  toAST() {
    return esprima.parse(this.tracer.name +
                         '.trace(' + this.toParam() + ', arguments)');
  }
  toTraceReturnAST(returnNode) {
    var node = this.createTraceReturnNode();
    if (returnNode.argument) {
      node.argument.arguments.push(returnNode.argument);
    }
    return node;
  }
  toParam() {
    var json = {
      id:       this.id,
      loc:      this.loc,
      range:    this.range,
      position: this.position
    };
    if (this.func) {
      json['func_id']   = this.func.id;
      json['source_id'] = this.func.source.id;
      if (this.func.source.page) {
        json['page_id'] = this.func.source.page.id;
      }
    }
    return JSON.stringify(json);
  }
  createTraceReturnNode () {
    return {
      type: 'ReturnStatement',
      argument: {
        type: 'CallExpression',
        callee: {
          type: 'MemberExpression',
          computed: false,
          object: {
            type: 'Identifier',
            name: 'chorreador'
          },
          property: {
            type: 'Identifier',
            name: 'trace'
          }
        },
        arguments: [
          (esprima.parse('param = ' + this.toParam()).body[0].expression.right),
          {
            type: 'Identifier',
            name: 'arguments'
          }
        ]
      }
    };
  }
}
Trace._id = 0;
module.exports = Trace;
