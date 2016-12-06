"use strict";

var _createClass = (function () { function defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } } return function (Constructor, protoProps, staticProps) { if (protoProps) defineProperties(Constructor.prototype, protoProps); if (staticProps) defineProperties(Constructor, staticProps); return Constructor; }; })();

function _classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }

var Func = (function () {
  function Func(name, loc, range, source) {
    _classCallCheck(this, Func);

    this.id = Func._id++;
    this.name = name;
    this.loc = loc;
    this.range = range;
    this.source = source;
  }

  _createClass(Func, [{
    key: "toJSON",
    value: function toJSON() {
      return {
        id: this.id,
        name: this.name,
        loc: this.loc,
        range: this.range
      };
    }
  }]);

  return Func;
})();

Func._id = 1;
module.exports = Func;