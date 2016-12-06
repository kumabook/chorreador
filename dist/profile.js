'use strict';

var _createClass = (function () { function defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ('value' in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } } return function (Constructor, protoProps, staticProps) { if (protoProps) defineProperties(Constructor.prototype, protoProps); if (staticProps) defineProperties(Constructor, staticProps); return Constructor; }; })();

function _classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError('Cannot call a class as a function'); } }

var Profile = (function () {
  function Profile(page) {
    _classCallCheck(this, Profile);

    this.page = page;
    this.id = Profile._id++;
    this.calls = [];
    this.finishedCalls = [];
  }

  _createClass(Profile, [{
    key: 'latestUnfinishedCall',
    value: function latestUnfinishedCall(func) {
      var calls = this.calls.filter(function (c) {
        return c.func == func && c.traces.length == 1 && c.traces[0].position == 'start';
      });
      return calls[calls.length - 1];
    }
  }, {
    key: 'toJSON',
    value: function toJSON() {
      return {
        id: this.id,
        fileName: this.page.fileName,
        sourceCount: this.page.sources.length,
        funcCount: this.page.funcCount(),
        callCount: this.calls.length
      };
    }
  }]);

  return Profile;
})();

Profile._id = 1;
module.exports = Profile;