class Profile {
  constructor(page) {
    this.page          = page;
    this.id            = Profile._id++;
    this.calls         = [];
    this.finishedCalls = [];
  }
  latestUnfinishedCall(func) {
    var calls = this.calls.filter((c) => {
      return c.func == func && c.traces.length == 1 && c.traces[0].position == 'start';
    });
    return calls[calls.length - 1];
  }
  toJSON() {
    return {
      id:          this.id,
      fileName:    this.page.fileName,
      sourceCount: this.page.sources.length,
      funcCount:   this.page.funcCount(),
      callCount:   this.calls.length
    };
  }
}
Profile._id = 1;
module.exports = Profile;
