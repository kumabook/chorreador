window.logger = {
  count: 0,
  trace: function(param) {
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
    };
    param.time = Date.now();
    param.count = window.logger.count++;
    var url = window.location.protocol + '//' +
      window.location.host + '/htmls/' + param.html_id +
          '/sources/' + param.source_id +
          '/funcs/' + param.func_id +
          '/traces/' + param.id +
          '/calls/create';
    url += '?time=' + Date.now();
    url += '&caller=' + arguments.callee.caller.name;
    url += '&count=' + param.count;
//    console.log(param);
//  xhr.open('GET', url, true);
//  xhr.send(JSON.stringify(log));
//    xhr.send();
  }
}
