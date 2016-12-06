React            = require 'react'
LinkedStateMixin = require 'react-addons-linked-state-mixin'
Router           = require 'react-router'

CallGraph = React.createClass
  mixins: [Router.State, LinkedStateMixin],
  getInitialState: ->
    type: ''
    value: ''
  render: ->
    return (
      <div className="call-graph">
      </div>
    )

module.exports = CallGraph
