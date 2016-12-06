'use strict';

var _createClass = (function () { function defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ('value' in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } } return function (Constructor, protoProps, staticProps) { if (protoProps) defineProperties(Constructor.prototype, protoProps); if (staticProps) defineProperties(Constructor, staticProps); return Constructor; }; })();

var _get = function get(_x, _x2, _x3) { var _again = true; _function: while (_again) { var object = _x, property = _x2, receiver = _x3; desc = parent = getter = undefined; _again = false; if (object === null) object = Function.prototype; var desc = Object.getOwnPropertyDescriptor(object, property); if (desc === undefined) { var parent = Object.getPrototypeOf(object); if (parent === null) { return undefined; } else { _x = parent; _x2 = property; _x3 = receiver; _again = true; continue _function; } } else if ('value' in desc) { return desc.value; } else { var getter = desc.get; if (getter === undefined) { return undefined; } return getter.call(receiver); } } };

function _classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError('Cannot call a class as a function'); } }

function _inherits(subClass, superClass) { if (typeof superClass !== 'function' && superClass !== null) { throw new TypeError('Super expression must either be null or a function, not ' + typeof superClass); } subClass.prototype = Object.create(superClass && superClass.prototype, { constructor: { value: subClass, enumerable: false, writable: true, configurable: true } }); if (superClass) Object.setPrototypeOf ? Object.setPrototypeOf(subClass, superClass) : subClass.__proto__ = superClass; }

var fs = require('fs'),
    Tracer = require('./tracer');

var RemoteTracer = (function (_Tracer) {
  _inherits(RemoteTracer, _Tracer);

  function RemoteTracer() {
    _classCallCheck(this, RemoteTracer);

    _get(Object.getPrototypeOf(RemoteTracer.prototype), 'constructor', this).apply(this, arguments);
  }

  _createClass(RemoteTracer, [{
    key: 'generateTraceDefinition',
    value: function generateTraceDefinition(pageId, profileId, recOnStart) {
      return '\n(' + this.traceDefinition.toString() + ')(window, ' + pageId + ', ' + profileId + ', ' + recOnStart + ')\n';
    }
  }, {
    key: 'traceDefinition',
    value: function traceDefinition(global, pageId, profileId, recOnStart) {
      var chorreador = {
        traceNumPerReport: 1000,
        reportInterval: 1000 * 2,
        isRecording: recOnStart,
        isReporting: false,
        pageId: pageId,
        profileId: profileId,
        count: 0,
        traces: [],
        trace: function trace(param, args, return_value) {
          if (!this.isRecording) {
            return return_value;
          }
          param.time = Date.now();
          param.count = chorreador.count++;
          param.caller = param.func_id;
          param.args = Array.prototype.slice.call(args);
          param.return_value = return_value;
          this.traces.push(param);
          this.updateMessage();
          return return_value;
        },
        setupRecButton: function setupRecButton() {
          var _this = this;

          var button = document.createElement('div');
          button.style.width = 100;
          button.style.height = 100;
          button.style.top = 0;
          button.style.right = 50;
          button.style.zIndex = 10000;
          button.style.position = 'fixed';
          button.style.backgroundColor = 'black';
          button.onclick = function () {
            _this.isRecording = !_this.isRecording;
            _this.updateRecButton();
          };
          this.traceNum = document.createElement('div');
          this.status = document.createElement('div');
          this.recButton = button;
          this.updateRecButton();
          this.updateMessage();
          document.body.appendChild(button);
          button.appendChild(this.traceNum);
          button.appendChild(this.status);
        },
        setupReporter: function setupReporter() {
          var _this2 = this;

          setInterval(function () {
            if (_this2.isReporting) {
              return;
            }
            _this2.reportTraces();
          }, this.reportInterval);
          window.addEventListener("keydown", function (e) {
            if (e.keyCode == 83) {
              if (_this2.isReporting) {
                return;
              }
              _this2.reportTraces();
            }
          });
        },
        updateRecButton: function updateRecButton() {
          if (this.isRecording) {
            this.recButton.style.backgroundColor = 'red';
            this.status.innerHTML = 'recording';
          } else if (this.isReporting) {
            this.recButton.style.backgroundColor = 'blue';
            this.status.innerHTML = 'reporting';
          } else if (this.traces.length > 0) {
            this.recButton.style.backgroundColor = 'green';
            this.status.innerHTML = 'waiting for report';
          } else {
            this.recButton.style.backgroundColor = 'gray';
            this.status.innerHTML = 'empty';
          }
        },
        updateMessage: function updateMessage() {
          if (this.traceNum) {
            this.traceNum.innerHTML = profileId + ': ' + this.traces.length + ' traces';
          }
        },
        jsonStrOfTraces: function jsonStrOfTraces(traces) {
          var cache = [];
          return JSON.stringify(traces, function (key, value) {
            if (typeof value == 'object') {
              if (cache.indexOf(value) != -1) {
                return null;
              }
              cache.push(value);
              var str = Object.prototype.toString.call(value);
              switch (str) {
                case '[object Object]':
                  return value;
                case '[object Array]':
                  return value;
                case '[object Number]':
                  return value;
                case '[object String]':
                  return value;
                case '[object Event]':
                  return 'Event';
                case '[object global]':
                  return 'global';
                default:
                  return;
              }
            }
            return value;
          });
        },
        reportTraces: function reportTraces() {
          var _this3 = this;

          this.isReporting = true;
          console.log('Start reporting');
          if (this.traces.length == 0) {
            console.log('Nothing to report');
            this.isReporting = false;
            this.updateRecButton();
            this.updateMessage();
            return;
          }
          var xhr = new XMLHttpRequest();
          xhr.onreadystatechange = function () {
            if (xhr.readyState == 4) {
              _this3.isReporting = false;
            }
            if (xhr.readyState == 4 && xhr.status == 200) {
              console.log('Successfully report traces');
            }
            _this3.updateRecButton();
          };
          var url = window.location.protocol + '//' + window.location.host + '/profiles/' + profileId + '/report';
          xhr.open('POST', url, true);
          xhr.setRequestHeader('Content-type', 'application/json; charset=utf-8');
          var traces = this.traces.splice(0, this.traceNumPerReport);
          this.updateRecButton();
          this.updateMessage();
          xhr.send(this.jsonStrOfTraces(traces));
          return xhr;
        }
      };
      global.chorreador = chorreador;
      window.addEventListener('load', function () {
        chorreador.setupRecButton();
        chorreador.setupReporter();
      });
    }
  }, {
    key: 'name',
    get: function get() {
      return 'chorreador';
    }
  }]);

  return RemoteTracer;
})(Tracer);

module.exports = RemoteTracer;