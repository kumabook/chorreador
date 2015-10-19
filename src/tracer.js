var fs = require('fs');
class Tracer {
  get name() { return  'chorreador'; }
  generateTraceDefinition(pageId, profileId) {
    throw new Error('not implemented');
  }
  traceDefinition(global) {
    throw new Error('not implemented');
  }
}
module.exports = Tracer;
