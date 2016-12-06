'use strict';

var _createClass = (function () { function defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ('value' in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } } return function (Constructor, protoProps, staticProps) { if (protoProps) defineProperties(Constructor.prototype, protoProps); if (staticProps) defineProperties(Constructor, staticProps); return Constructor; }; })();

function _classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError('Cannot call a class as a function'); } }

var express = require('express'),
    bodyParser = require('body-parser'),
    path = require('path'),
    fs = require('fs'),
    serveIndex = require('serve-index'),
    redirect = require('express-redirect'),
    RemoteTracer = require('./remote_tracer'),
    Instrumentor = require('./instrumentor'),
    Page = require('./page'),
    Source = require('./source'),
    Func = require('./func'),
    Call = require('./call'),
    Profile = require('./profile'),
    preference = require('./preference');

var mimeTypes = {
  ".html": "text/html",
  ".css": "text/css",
  ".js": "application/javascript",
  ".json": "application/json",
  ".png": "image/png",
  ".jpg": "image/jpeg",
  ".gif": "image/gif",
  ".txt": "text/plain"
};

var Server = (function () {
  function Server(port, instrumentedDir) {
    _classCallCheck(this, Server);

    this.port = port;
    this.instrumentedDir = instrumentedDir;
    this.app = express();
    this.pageList = [];
    this.profileList = [];
    this.tracer = new RemoteTracer();
    redirect(this.app);
    this.app.set('views', path.join(__dirname, '../views'));
    this.app.set('view engine', 'jade');

    this.app.use(bodyParser.urlencoded({
      extended: true
    }));
    this.app.use(bodyParser.json({
      limit: 1024 * 1024 * 500
    }));

    this.app.use(require("connect-assets")({
      paths: ['assets', 'assets/js', 'assets/css', 'bower_components']
    }));
    this.app.use('/bower_components', express['static'](__dirname + '/../bower_components'));

    this.app.redirect('/', 'instrumented');
    this.app.get(/^\/instrumented\/(.+)/, this.handleTarget.bind(this));
    this.app.use('/instrumented', serveIndex('instrumented', {
      icons: true,
      template: this.handleServeIndex.bind(this)
    }));
    this.app.post('/profiles/:pid/report', this.handleReport.bind(this));

    // html pages
    this.app.get('/preference', this.showPreference.bind(this));
    this.app.post('/preference', this.updatePreference.bind(this));
    this.app.get('/profiles', this.indexProfiles.bind(this));

    // json api
    this.app.get('/api/pages', this.handleGetPages.bind(this));
    this.app.get('/api/pages/:pid', this.handleGetPage.bind(this));
    this.app.get('/api/sources/:src_id', this.handleGetSource.bind(this));
    this.app.get('/api/profiles/:pid', this.handleProfile.bind(this));
    this.app.get('/api/profiles/:pid/calls', this.handleGetCalls.bind(this));
    this.app.get('/api/calls/:c_id:', this.handleGetCall.bind(this));
  }

  _createClass(Server, [{
    key: 'run',
    value: function run() {
      var _this = this;

      this.server = this.app.listen(this.port, function () {
        console.log('Listening on port ' + _this.server.address().port);
      });
    }
  }, {
    key: 'handleServeIndex',
    value: function handleServeIndex(locals, callback) {
      var jade = require('jade');
      var templateFile = path.join(__dirname, '../views/index.jade');
      var fn = jade.compileFile(templateFile, {});
      locals.profileList = this.profileList;
      locals.fileList = locals.fileList.filter(function (f) {
        return path.extname(f.name) === '.html';
      });
      callback(null, fn(locals));
    }
  }, {
    key: 'showPreference',
    value: function showPreference(req, res) {
      res.render('preference', {
        preference: preference
      });
    }
  }, {
    key: 'updatePreference',
    value: function updatePreference(req, res) {
      console.log(req.body);
      preference.recOnStart = req.body.recOnStart == 'true';
      res.render('preference', {
        preference: preference
      });
    }
  }, {
    key: 'handleGetPages',
    value: function handleGetPages() {}
  }, {
    key: 'handleGetPage',
    value: function handleGetPage() {}
  }, {
    key: 'handleGetSource',
    value: function handleGetSource(req, res) {}
  }, {
    key: 'handleGetPage',
    value: function handleGetPage(req, res) {
      var page = this.pageList.filter(function (h) {
        return h.id == ~ ~req.params.pid;
      })[0];
      this.renderJSON(req, res, page);
    }
  }, {
    key: 'handleGetCall',
    value: function handleGetCall(req, res) {
      var call = Call.instances[~ ~req.params.cid];
      return this.renderJSON(req, res, call);
    }
  }, {
    key: 'handleGetCalls',
    value: function handleGetCalls(req, res) {
      var profile = this.profileList.filter(function (p) {
        return p.id == ~ ~req.params.pid;
      })[0];
      return this.renderJSON(req, res, profile.calls);
    }
  }, {
    key: 'indexProfiles',
    value: function indexProfiles(req, res) {
      res.render('profiles', {
        profiles: this.profileList
      });
    }
  }, {
    key: 'handleProfile',
    value: function handleProfile(req, res) {
      var profile = this.profileList.filter(function (p) {
        return p.id == ~ ~req.params.pid;
      })[0];
      var val = profile.toJSON();
      val.page = profile.page;
      val.calls = profile.calls;
      res.json(val);
    }
  }, {
    key: 'handleReport',
    value: function handleReport(req, res) {
      var profile = this.profileList.filter(function (p) {
        return p.id == ~ ~req.params.pid;
      })[0];
      var page = profile.page;
      var traces = req.body;
      traces.forEach(function (trace) {
        var source = page.sources.filter(function (s) {
          return s.id == ~ ~trace.source_id;
        })[0];
        var func = null;
        if (source) {
          func = source.funcs.filter(function (f) {
            return f.id == ~ ~trace.func_id;
          })[0];
        } else {}
        var pos = trace.position;
        var call;
        if (func) {
          switch (pos) {
            case 'start':
              call = new Call(func, trace.caller, trace.time, trace.args);
              call.traces.push(trace);
              profile.calls.push(call);
              break;
            case 'end':
            case 'return':
              call = profile.latestUnfinishedCall(func);
              if (call) {
                call.traces.push(trace);
                call.endTime = trace.time;
                call.return_value = trace.return_value;
              }
              break;
          }
        }
      });
      /*    page.sources.forEach((source) => {
            source.funcs.forEach((func) => {
              var count = profile.calls.filter((c) => c.func == func).length;
              if (count > 0) {
                console.log(source.path + ': ' + func.name +
                            ' is called ' + count + ' times');
              }
            });
          });*/
      res.contentType('text/plain');
      res.writeHead(200);
      res.write('Summarize completed.\n');
      res.end();
      console.log('Add ' + traces.length + ' traces to page ' + page.id + '. Total ' + profile.calls.length + '. function calls are in there.');
    }
  }, {
    key: 'handleTarget',
    value: function handleTarget(req, res) {
      var fileName = path.join(process.cwd() + '/' + this.instrumentedDir, req.params[0]);
      if (fs.existsSync(fileName) && fs.statSync(fileName).isDirectory()) {
        fileName += '/index.html';
      } else if (fs.existsSync(fileName)) {
        this.renderStaticFile(req, res, fileName);
      } else {
        this.renderNotFound(req, res);
      }
    }
  }, {
    key: 'renderNotFound',
    value: function renderNotFound(req, res) {
      res.contentType('text/plain');
      res.write('404 Not Found\n');
      res.end();
      res.writeHead(404);
    }
  }, {
    key: 'renderJSON',
    value: function renderJSON(req, res, obj) {
      res.contentType('application/json');
      res.writeHead(200);
      res.write(JSON.stringify(obj));
      res.end();
    }
  }, {
    key: 'renderStaticFile',
    value: function renderStaticFile(req, res, fileName) {
      var _this2 = this;

      var ext = path.extname(fileName);
      res.contentType(mimeTypes[ext]);
      fs.readFile(fileName, 'binary', function (error, file) {
        var uri = req.protocol + '://' + req.get('host') + req.url;
        var referer = req.headers.referer;
        switch (ext) {
          case ".html":
            var page = new Page(uri, fileName, file.toString());
            var profile = new Profile(page);
            _this2.pageList.push(page);
            _this2.profileList.push(profile);
            file = Instrumentor.instrumentFunctionTraceDefinition2Page(page, profile, _this2.tracer, preference);
            break;
          case ".js":
            var pages = _this2.pageList.filter(function (h) {
              return h.uri == referer;
            });
            var profiles = _this2.profileList.filter(function (h) {
              return h.uri == referer;
            });
            var page = pages[pages.length - 1];
            var profile = profiles[profiles.length - 1];
            if (page) {
              var beautify = require('js-beautify').js_beautify;
              var source = new Source(uri, beautify(file), page);
              page.sources[uri] = source;
              page.sources.push(source);
            }

            file = Instrumentor.instrumentFunctionTrace(source, _this2.tracer);
            break;
        }
        res.writeHead(200);
        res.write(file, 'binary');
        res.end();
      });
    }
  }]);

  return Server;
})();

module.exports = Server;