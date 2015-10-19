var url = require('url');
class Page {
  constructor(uri, path, code, id, sources) {
    if (!this.id) {
      this.id     = Page._id++;
    }
    this.uri      = uri;
    this.path     = path;
    this.code     = code;
    this.sources  = sources ? sources : [];
    this.fileName = url.parse(this.uri).path;
  }
  funcCount() {
    return (this.sources.map (s => s.funcs.length).reduce((a, b) => a + b));
  }
  toJSON() {
    return {
      id:      this.id,
      uri:     this.uri,
      path:    this.path,
      code:    this.code,
      sources: this.sources
    };
  }
}
Page._id = 1;
module.exports = Page;
