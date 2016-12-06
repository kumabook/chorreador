Editor         = require './editor-view'
Page           = require './page'
Profile        = require './components/profile.cjsx'
ProfileList    = require './components/profile-list.cjsx'
ProfileActions = require './profile-actions'
React          = require 'react'
ReactDOM       = require 'react-dom'
ReactRouter    = require 'react-router'
Router         = ReactRouter.Router
Route          = ReactRouter.Route
Link           = ReactRouter.Link
IndexRoute     = ReactRouter.IndexRoute

App = React.createClass(
  render: ->
    return (
      <div>
        <div className="pure-menu-horizontal pure-menu">
          <ul className="pure-menu-list">
            <li className="pure-menu-item">
              <Link to="/"
                className="pure-menu-heading pure-menu-link">Chorreador</Link>
            </li>
            <li className="pure-menu-item">
              <Link to="/profiles"
                className="pure-menu-heading pure-menu-link">Profiles</Link>
            </li>
          </ul>
        </div>
      </div>
    )
  )

routes = (
  <Router>
    <Route path="/" component={ProfileList}>
      <IndexRoute component={ProfileList}/>
    </Route>
    <Route path="/profiles/:pid" component={Profile}/>
  </Router>
  )


chorreador = {}
chorreador.run = (profiles) ->
  chorreador.profiles = profiles
#  ProfileActions.index()
#  ReactDOM.render(<div>test</div>, document.body)
#  ReactDOM.render(App, document.body)
  ReactDOM.render routes, document.getElementById 'chorreador-container'

chorreador.showProfileView = (profileId, pageId) ->
  pstyle  = 'border: 1px solid #dfdfdf; padding: 5px;'
  $('#reporter').w2layout
    name: 'reporter1'
    padding: 4
    panels: [
      type: 'top'
      size: 25
      resizable: false
      style: pstyle
      content: 'chorreador'
    ,
      type: 'left'
      size: 200
      resizable: true
      style: pstyle
      content: $('#sidebar')
    ,
      type: 'main'
      style: pstyle
      content: $('#editor')
    ]
  $.ajax("/pages/#{pageId}/").then (_page, dataType) ->
    $.ajax("/profiles/#{profileId}/calls").then (calls, dataType) ->
      page          = new Page(_page.uri,
                               _page.path,
                               _page.code,
                               _page.id,
                               _page.sources)
      profile       = new Profile(page)
      profile.calls = calls
      editor        = new Editor(profile)
      editor.showSourceList()
      editor.showSource(page.sources[0], null)
    , () ->
      alert 'Sorry, something wrong.'
  , () ->
    alert 'Sorry, something wrong.'

module.exports = chorreador
