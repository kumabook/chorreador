React            = require 'react'
LinkedStateMixin = require 'react-addons-linked-state-mixin'
Router           = require 'react-router'
ProfileActions   = require '../profile-actions'
ProfileStore     = require '../profile-store'

Profile = React.createClass
  mixins: [Router.State, LinkedStateMixin],
  getInitialState: ->
    profile: ProfileStore.getById(this.props.params.pid)
    type: 'ReturnValue'
    value: ''
  render: ->
    details = ''
    if this.state.profile.calls?
      details = this.state.profile.calls.map((c) ->
        return (
          <p key={c.id}>
            {c.id} {c.func.name}: return: {c.return_value}
          </p>
        )
      )
    else
      detils = <p></p>
    return (
      <div className="pure-g">
        <div className="pure-u-1-24" />
        <div className="pure-u-2-3">
          <h1>Profile of {this.state.profile.fileName}</h1>
          <h2> Summary </h2>
          <div>
            Source count: {this.state.profile.id} <br/>
            Func count: {this.state.profile.funcCount} <br/>
            Call count: {this.state.profile.callCount} <br/>
          </div>
          <h2> Details </h2>
          <div>
            <select valueLink={this.linkState('type')}>
              <option value="ReturnValue">return value</option>
              <option value="Params">parameter</option>
              <option value="Function">function</option>
              <option value="Source">source</option>
            </select>
            <input valueLink={this.linkState('value')}></input>
            <button onClick={this.onClickSearchValueButton}>Search</button>
          </div>
          <div>
            {details}
          </div>
        </div>
      </div>
    )
  componentDidMount: ->
    ProfileActions.show @state.profile.id
    ProfileStore.addChangeListener @_onChange
  onClickSearchValueButton: ->
    console.log "search #{this.state.type} #{this.state.value}"
    
  _onChange: ->
    this.setState
      profile: ProfileStore.getCurrent()

module.exports = Profile
