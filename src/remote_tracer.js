var fs     = require('fs'),
    Tracer = require('./tracer');
class RemoteTracer extends Tracer {
  get name() { return  'chorreador'; }
  generateTraceDefinition(pageId, profileId, recOnStart) {
    return '\n(' + this.traceDefinition.toString() +
      ')(window, ' + pageId + ', ' + profileId + ', ' + recOnStart + ')\n';
  }
  traceDefinition(global, pageId, profileId, recOnStart) {
    var chorreador = {
      traceNumPerReport: 1000,
      reportInterval:    1000 * 2,
      isRecording:       recOnStart,
      isReporting:       false,
      pageId:            pageId,
      profileId:         profileId,
      count:             0,
      traces:            [],
      trace: function(param, args, return_value) {
        if (!this.isRecording) {
          return return_value;
        }
        param.time         = Date.now();
        param.count        = chorreador.count++;
        param.caller       = param.func_id;
        param.args         = Array.prototype.slice.call(args);
        param.return_value = return_value;
        this.traces.push(param);
        this.updateMessage();
        return return_value;
      },
      setupRecButton: function() {
        var button   = document.createElement('div');
        button.style.width           = 100;
        button.style.height          = 100;
        button.style.top             = 0;
        button.style.right           = 50;
        button.style.zIndex          = 10000;
        button.style.position        = 'fixed';
        button.style.backgroundColor = 'black';
        button.onclick = () => {
          this.isRecording = !this.isRecording;
          this.updateRecButton();
        };
        this.traceNum  = document.createElement('div');
        this.status    = document.createElement('div');
        this.recButton = button;
        this.updateRecButton();
        this.updateMessage();
        document.body.appendChild(button);
        button.appendChild(this.traceNum);
        button.appendChild(this.status);
      },
      setupReporter: function() {
        setInterval(() => {
          if (this.isReporting) {
            return;
          }
          this.reportTraces();
        }, this.reportInterval);
        window.addEventListener("keydown", (e) => {
          if (e.keyCode == 83) {
            if (this.isReporting) {
              return;
            }
            this.reportTraces();
          }
        });
      },
      updateRecButton: function() {
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
      updateMessage: function() {
        if (this.traceNum) {
          this.traceNum.innerHTML = profileId + ': ' +
            this.traces.length + ' traces';
        }
      },
      jsonStrOfTraces: function(traces) {
        var cache = [];
        return JSON.stringify(traces, (key, value) => {
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
      reportTraces: function() {
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
        xhr.onreadystatechange = () => {
          if (xhr.readyState == 4) {
            this.isReporting = false;
          }
          if (xhr.readyState == 4 && xhr.status == 200) {
            console.log('Successfully report traces');
          }
          this.updateRecButton();
        };
        var url = window.location.protocol + '//' + window.location.host +
              '/profiles/' + profileId + '/report';
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
    window.addEventListener('load', function() {
      chorreador.setupRecButton();
      chorreador.setupReporter();
    });
  }
}
module.exports = RemoteTracer;
