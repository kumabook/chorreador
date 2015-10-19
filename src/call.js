class Call {
  constructor (func, caller, startTime, args) {
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
  isFinished() { return this.traces.length == 2; }
  isStarted() { return  this.traces.length != 0; }
  duration() { return this.endTime - this.startTime; }
  toJSON() {
    return {
      id:           this.id,
      func:         this.func,
      traces:       this.traces,
      caller:       this.caller,
      startTime:    this.startTime,
      endTime:      this.endTime,
      duration:     this.duration()
    };
  }
//    args:         this.args
//      return_value: this.return_value
}

Call.instances = {};
Call._id = 1;
module.exports = Call;
