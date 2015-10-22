var express      = require('express'),
    bodyParser   = require('body-parser'),
    path         = require('path'),
    fs           = require('fs'),
    serveIndex   = require('serve-index'),
    redirect     = require('express-redirect'),

    RemoteTracer = require('./remote_tracer'),
    Instrumentor = require('./instrumentor'),
    Page         = require('./page'),
    Source       = require('./source'),
    Func         = require('./func'),
    Call         = require('./call'),
    Profile      = require('./profile');

var mimeTypes   = {
  ".html": "text/html",
  ".css" : "text/css",
  ".js"  : "application/javascript",
  ".json": "application/json",
  ".png" : "image/png",
  ".jpg" : "image/jpeg",
  ".gif" : "image/gif",
  ".txt" : "text/plain"
}


class Server {
  constructor (port, instrumentedDir) {
    this.port            = port;
    this.instrumentedDir = instrumentedDir;
    this.app             = express();
    this.pageList        = [];
    this.profileList     = [];
    this.tracer          = new RemoteTracer();
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
      paths: [
        'assets',
        'assets/js',
        'assets/css',
        'bower_components']
    }));
    this.app.use('/bower_components',
                 express.static(__dirname + '/../bower_components'));

    this.app.redirect('/', 'instrumented');
    this.app.get(/^\/instrumented\/(.+)/,      this.handleTarget.bind(this));
    this.app.use('/instrumented', serveIndex('instrumented', {
      icons: true,
      template: this.handleServeIndex.bind(this)
    }));

    this.app.get('/preference',                this.handlePreference.bind(this));
    this.app.get('/pages',                     this.handleGetPages.bind(this));
    this.app.get('/pages/:pid',                this.handleGetPage.bind(this));
    this.app.get('/sources/:src_id',           this.handleGetSource.bind(this));

    this.app.get('/profiles',                  this.handleProfiles.bind(this));
    this.app.get('/profiles/:prof_id',         this.handleProfile.bind(this));
    this.app.get('/profiles/:prof_id/calls',   this.handleGetCalls.bind(this));
    this.app.get('/calls/:c_id:',              this.handleGetCall.bind(this));

    this.app.post('/profiles/:prof_id',        this.handleUpdateProfile.bind(this));
    this.app.post('/profiles/:prof_id/report', this.handleReport.bind(this));
  }
  run() {
    this.server = this.app.listen(this.port, () => {
      console.log('Listening on port ' + this.server.address().port);
    });
  }
  handleServeIndex(locals, callback) {
    var jade = require('jade');
    var templateFile = path.join(__dirname, '../views/index.jade');
    var fn = jade.compileFile(templateFile, {});
    locals.profileList = this.profileList;
    locals.fileList    = locals.fileList.filter(
      f => path.extname(f.name) === '.html');
    callback(null, fn(locals));
  }
  handlePreference (req, res) {
    res.render('preference', {
      preference:  null//preference
    });
  }
  handleGetPages() {}
  handleGetPage() {}
  handleGetSource() {}
  handleUpdateProfile() {}
  handleGetSource (req, res) {}
  handleGetPage (req, res) {
    var page    = this.pageList.filter(h => h.id == ~~req.params.pid)[0];
    this.renderJSON(req, res, page);
  }
  handleGetCall (req, res) {
    var call = Call.instances[~~req.params.cid];
    return this.renderJSON(req, res, call);
  }
  handleGetCalls (req, res) {
    var profile = this.profileList.filter(p => p.id == ~~req.params.prof_id)[0];
    return this.renderJSON(req, res, profile.calls);
  }
  handleProfiles (req, res) {
    res.render('profiles', {
      profiles: this.profileList
    });
  }
  handleProfile (req, res) {
    var profile = this.profileList.filter(p => p.id == ~~req.params.prof_id)[0];
    res.render('profile', {
      profile: profile
    });
  }
  handleReport (req, res) {
    var profile = this.profileList.filter(p => p.id == ~~req.params.prof_id)[0];
    var page    = profile.page;
    var traces  = req.body;
    traces.forEach((trace) => {
      var source = page.sources.filter(s => s.id == ~~trace.source_id)[0];
      var func = null;
      if (source) {
        func = source.funcs.filter(f => f.id == ~~trace.func_id)[0];
      } else {
      }
      var pos = trace.position;
      var call;
      if (func) {
        switch(pos) {
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
            call.endTime      = trace.time;
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
    console.log('Add ' + traces.length + ' traces to page ' + page.id +
                '. Total ' + profile.calls.length +
                '. function calls are in there.');
  }
  handleTarget(req, res) {
    var fileName = path.join(process.cwd() + '/' + this.instrumentedDir,
                             req.params[0]);
    if (fs.existsSync(fileName) && fs.statSync(fileName).isDirectory()) {
      fileName += '/index.html';
    } else if (fs.existsSync(fileName)) {
      this.renderStaticFile(req, res, fileName);
    } else {
      this.renderNotFound(req, res);
    }
  }
  renderNotFound(req, res) {
    res.contentType('text/plain');
    res.write('404 Not Found\n');
    res.end();
    res.writeHead(404);
  }
  renderJSON(req, res, obj) {
    res.contentType('application/json');
    res.writeHead(200);
    res.write(JSON.stringify(obj));
    res.end();
  }
  renderStaticFile(req, res, fileName) {
    var ext  = path.extname(fileName);
    res.contentType(mimeTypes[ext]);
    fs.readFile(fileName, 'binary', (error, file) => {
      var uri = req.protocol + '://' + req.get('host') + req.url;
      var referer = req.headers.referer;
      switch(ext) {
      case ".html":
        var page    = new Page(uri, fileName, file.toString());
        var profile = new Profile(page);
        this.pageList.push(page);
        this.profileList.push(profile);
        file = Instrumentor.instrumentFunctionTraceDefinition2Page(page,
                                                                   profile,
                                                                   this.tracer,
                                                                   preference);
        break;
      case ".js":
        var pages    = this.pageList.filter( h => h.uri == referer);
        var profiles = this.profileList.filter( h => h.uri == referer);
        var page     = pages[pages.length - 1];
        var profile  = profiles[profiles.length - 1];
        if (page) {
          var beautify = require('js-beautify').js_beautify;
          var source = new Source(uri, beautify(file), page);
          page.sources[uri] = source;
          page.sources.push(source);
        }

        file = Instrumentor.instrumentFunctionTrace(source, this.tracer);
        break;
      }
      res.writeHead(200);
      res.write(file, 'binary');
      res.end();
    });
  }
}
module.exports = Server;
