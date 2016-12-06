'use strict';

var _createClass = (function () { function defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ('value' in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } } return function (Constructor, protoProps, staticProps) { if (protoProps) defineProperties(Constructor.prototype, protoProps); if (staticProps) defineProperties(Constructor, staticProps); return Constructor; }; })();

function _classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError('Cannot call a class as a function'); } }

var url = require('url');

var Page = (function () {
  function Page(uri, path, code, id, sources) {
    _classCallCheck(this, Page);

    if (!this.id) {
      this.id = Page._id++;
    }
    this.uri = uri;
    this.path = path;
    this.code = code;
    this.sources = sources ? sources : [];
    this.fileName = url.parse(this.uri).path;
  }

  _createClass(Page, [{
    key: 'funcCount',
    value: function funcCount() {
      return this.sources.map(function (s) {
        return s.funcs.length;
      }).reduce(function (a, b) {
        return a + b;
      });
    }
  }, {
    key: 'toJSON',
    value: function toJSON() {
      return {
        id: this.id,
        uri: this.uri,
        path: this.path,
        code: this.code,
        sources: this.sources
      };
    }
  }]);

  return Page;
})();

Page._id = 1;
module.exports = Page;