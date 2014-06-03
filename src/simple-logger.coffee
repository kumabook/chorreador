SimpleLogger = (fileName, fn, phase) ->
  logItem = {
    file: fileName
    func: fn.name
    line: fn.line
    range: fn.range
    phase: phase
    return: fn.return ? false
  }
  'logger.trace(' + JSON.stringify(logItem) + ' );'
module.exports = SimpleLogger
