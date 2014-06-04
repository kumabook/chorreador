window.logger = {
  count: 0,
  trace: function(logItem) {
    var xhr = new XMLHttpRequest();
    xhr.onreadystatechange = function() {
      switch (xhr.readyState) {
        case 1: // open
        case 2: // sent
        case 3: // receiving
        break;
        case 4: // loaded
        var obj;
        if (xhr.status == 200) {
        }
        break;
      }
      return;
    }
    var url = window.location.protocol + '//' +
      window.location.host + '/logs/create';
//#    url += '?id=' + logItem.id;
    url += '?file=' + logItem.file;

    url += '&func=' + logItem.func;
    url += '&line=' + logItem.line;
    url += '&phase=' + logItem.phase;
    xhr.open('GET', url, true);
    logItem.count = window.logger.count++;
    //          xhr.send(JSON.stringify(log));
    xhr.send();
  }
}