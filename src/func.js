class Func {
  constructor (name, loc, range, source) {
    this.id     = Func._id++;
    this.name   = name;
    this.loc    = loc;
    this.range  = range;
    this.source = source;
  }
  toJSON () {
    return {
      id:    this.id,
      name:  this.name,
      loc:   this.loc,
      range: this.range
    };
  }
}
Func._id = 1;
module.exports = Func;
