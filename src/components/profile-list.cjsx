React  = require 'react'
Router = require 'react-router'
Link   = Router.Link

ProfileList = React.createClass
  render: ->
    trs = this.props.profiles.map (profile) ->
      to = "/profiles/#{profile.id}"
      (
        <tr>
          <td>{profile.id}</td>
          <td>{profile.fileName}</td>
          <td>{profile.sourceCount}</td>
          <td>{profile.funcCount}</td>
          <td>{profile.callCount}</td>
            <td><Link to={to}>View</Link></td>
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
  componentDidMount: ->


ProfileList.run = (profiles) ->
  React.render(
    <ProfileList profiles={profiles}/>,
    document.body
  )


module.exports = ProfileList
