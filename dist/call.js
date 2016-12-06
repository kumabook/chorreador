"use strict";

var _createClass = (function () { function defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } } return function (Constructor, protoProps, staticProps) { if (protoProps) defineProperties(Constructor.prototype, protoProps); if (staticProps) defineProperties(Constructor, staticProps); return Constructor; }; })();

function _classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }

var Call = (function () {
  function Call(func, caller, startTime, args) {
    _classCallCheck(this, Call);

    this.id = Call._id++;
    this.func = func;
    this.caller = caller;
    this.startTime = startTime;
    this.args = args;
    this.traces = [];
    this.endTime = null;
    this.return_value = null;
    Call.instances[this.id] = this;
  }

  _createClass(Call, [{
    key: "isFinished",
    value: function isFinished() {
      return this.traces.length == 2;
    }
  }, {
    key: "isStarted",
    value: function isStarted() {
      return this.traces.length != 0;
    }
  }, {
    key: "duration",
    value: function duration() {
      return this.endTime - this.startTime;
    }
  }, {
    key: "toJSON",
    value: function toJSON() {
      return {
        id: this.id,
        func: this.func,
        traces: this.traces,
        caller: this.caller,
        startTime: this.startTime,
        endTime: this.endTime,
        duration: this.duration()
      };
    }

    //    args:         this.args
    //      return_value: this.return_value
  }]);

  return Call;
})();

Call.instances = {};
Call._id = 1;
module.exports = Call;