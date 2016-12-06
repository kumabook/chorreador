'use strict';

var Editor = require('./editor-view'),
    Page = require('./page'),
    Profile = require('./profile'),
    ProfileList = require('./components/profile-list.cjsx');

var chorreador = {
  run: function run(profiles) {
    ProfileList.run(profiles);
  },
  showProfileView: function showProfileView(profileId, pageId) {
    var pstyle = 'border: 1px solid #dfdfdf; padding: 5px;';
    $('#reporter').w2layout({
      name: 'reporter1',
      padding: 4,
      panels: [{
        type: 'top',
        size: 25,
        resizable: false,
        style: pstyle,
        content: 'chorreador'
      }],
      type: 'left',
      size: 200,
      resizable: true,
      style: pstyle,
      content: $('#sidebar')
    }, {
      type: 'main',
      style: pstyle,
      content: $('#editor')
    });
    $.ajax('/pages/' + pageId + '/').then(function (_page, dataType) {
      $.ajax('/profiles/' + profileId + '/calls').then(function (calls, dataType) {
        var page = new Page(_page.uri, _page.path, _page.code, _page.id, _page.sources);
        var profile = new Profile(page);
        profile.calls = calls;
        var editor = new Editor(profile);
        editor.showSourceList();
        editor.showSource(page.sources[0], null);
      }, function () {
        alert('Sorry, something wrong.');
      });
    }, function () {
      alert('Sorry, something wrong.');
    });
  }
};
module.exports = chorreador;