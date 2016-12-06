'use strict';

var _createClass = (function () { function defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ('value' in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } } return function (Constructor, protoProps, staticProps) { if (protoProps) defineProperties(Constructor.prototype, protoProps); if (staticProps) defineProperties(Constructor, staticProps); return Constructor; }; })();

function _classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError('Cannot call a class as a function'); } }

var fs = require('fs');

var Tracer = (function () {
  function Tracer() {
    _classCallCheck(this, Tracer);
  }

  _createClass(Tracer, [{
    key: 'generateTraceDefinition',
    value: function generateTraceDefinition(pageId, profileId, recOnStart) {
      throw new Error('not implemented');
    }
  }, {
    key: 'traceDefinition',
    value: function traceDefinition(global) {
      throw new Error('not implemented');
    }
  }, {
    key: 'name',
    get: function get() {
      return 'chorreador';
    }
  }]);

  return Tracer;
})();

module.exports = Tracer;