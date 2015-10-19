var fs     = require('fs'),
    Tracer = require('./tracer');
class ConsoleTracer extends Tracer {
  get name() { return  'chorreador'; }
  generateTraceDefinition () {
    return "\n(#{@traceDefinition.toString()})(global)\n";
  }
  traceDefinition(global) {
    var chorreador = {
      count: 0,
      trace: (param) => {
        param.time         = Date.now();
        param.count        = chorreador.count++;
        param.caller       = arguments.callee.caller.name;
        param.args         = arguments.toString();
        param.return_value = null;
        console.log(param);
      }
    };
    global.chorreador = chorreador;
  }
}
module.exports = ConsoleTracer;

