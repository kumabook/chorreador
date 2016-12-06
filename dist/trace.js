'use strict';

var _createClass = (function () { function defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ('value' in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } } return function (Constructor, protoProps, staticProps) { if (protoProps) defineProperties(Constructor.prototype, protoProps); if (staticProps) defineProperties(Constructor, staticProps); return Constructor; }; })();

function _classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError('Cannot call a class as a function'); } }

var esprima = require('esprima');

var Trace = (function () {
  function Trace(func, loc, range, position, tracer) {
    _classCallCheck(this, Trace);

    this.func = func;
    this.loc = loc;
    this.range = range;
    this.position = position;
    this.tracer = tracer;
    this.id = Trace._id++;
  }

  _createClass(Trace, [{
    key: 'toAST',
    value: function toAST() {
      return esprima.parse(this.tracer.name + '.trace(' + this.toParam() + ', arguments)');
    }
  }, {
    key: 'toTraceReturnAST',
    value: function toTraceReturnAST(returnNode) {
      var node = this.createTraceReturnNode();
      if (returnNode.argument) {
        node.argument.arguments.push(returnNode.argument);
      }
      return node;
    }
  }, {
    key: 'toParam',
    value: function toParam() {
      var json = {
        id: this.id,
        loc: this.loc,
        range: this.range,
        position: this.position
      };
      if (this.func) {
        json['func_id'] = this.func.id;
        json['source_id'] = this.func.source.id;
        if (this.func.source.page) {
          json['page_id'] = this.func.source.page.id;
        }
      }
      return JSON.stringify(json);
    }
  }, {
    key: 'createTraceReturnNode',
    value: function createTraceReturnNode() {
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
          arguments: [esprima.parse('param = ' + this.toParam()).body[0].expression.right, {
            type: 'Identifier',
            name: 'arguments'
          }]
        }
      };
    }
  }]);

  return Trace;
})();

Trace._id = 0;
module.exports = Trace;