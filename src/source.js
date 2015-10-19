class Source {
  constructor (path, code, page) {
    this.id    = Source._id++;
    this.path  = path;
    this.code  = code;
    this.page  = page;
    this.funcs = [];
  }
  toJSON() {
    return {
    id:    this.id,
    path:  this.path,
    code:  this.code,
      funcs: this.funcs
    };
  }
}
Source._id = 1;
module.exports = Source;
