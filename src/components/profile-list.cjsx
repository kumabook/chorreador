React        = require 'react'
Router       = require 'react-router'
Link         = Router.Link
ProfileStore = require '../profile-store'

ProfileList = React.createClass
  getInitialState: ->
    profiles: ProfileStore.getAll()
  componentDidMount: ->
    ProfileStore.addChangeListener(this._onChange)
  componentWillUnmount: ->
    ProfileStore.removeChangeListener(this._onChange)
  render: ->
    trs = this.state.profiles.map (profile) ->
      (
        <tr key={profile.id}>
          <td>{profile.id}</td>
          <td>{profile.fileName}</td>
          <td>{profile.sourceCount}</td>
          <td>{profile.funcCount}</td>
          <td>{profile.callCount}</td>
          <td><Link to={"/profiles/" + profile.id}>View</Link></td>
        </tr>
        )
    return (
      <div className="pure-g">
        <div className="pure-u-1-24" />
        <div className="pure-u-2-3">
          <h1>Profiles</h1>
          <table className="pure-table">
            <thead>
              <tr>
                <th>ID</th>
                <th>URL</th>
                <th>Source count</th>
                <th>Func count</th>
                <th>Call count</th>
                <th></th>
              </tr>
            </thead>
            <tbody>{trs}</tbody>
          </table>
        </div>
      </div>
    )
  _onChange: ->
    this.setState
      profiles: ProfileStore.getAll()
ProfileList.run = (profiles) ->
  React.render(
    <ProfileList profiles={profiles}/>,
    document.body
  )


module.exports = ProfileList
