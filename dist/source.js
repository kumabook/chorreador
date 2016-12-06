"use strict";

var _createClass = (function () { function defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } } return function (Constructor, protoProps, staticProps) { if (protoProps) defineProperties(Constructor.prototype, protoProps); if (staticProps) defineProperties(Constructor, staticProps); return Constructor; }; })();

function _classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }

var Source = (function () {
  function Source(path, code, page) {
    _classCallCheck(this, Source);

    this.id = Source._id++;
    this.path = path;
    this.code = code;
    this.page = page;
    this.funcs = [];
  }

  _createClass(Source, [{
    key: "toJSON",
    value: function toJSON() {
      return {
        id: this.id,
        path: this.path,
        code: this.code,
        funcs: this.funcs
      };
    }
  }]);

  return Source;
})();

Source._id = 1;
module.exports = Source;