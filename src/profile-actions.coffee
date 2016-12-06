request       = require 'superagent'
AppDispatcher = require './app-dispatcher'
Constants     = require './constants'

ProfileActions =
  index: ->
    request
      .get '/api/profiles'
      .set 'Accept', 'application/json'
      .end (err, res) ->
        AppDispatcher.dispatch
          actionType: Constants.PROFILE_INDEX
          profiles:   res.body
  show: (profileId) ->
    request
      .get "/api/profiles/#{profileId}"
      .end (err, res) ->
        console.log(res);
        AppDispatcher.dispatch
          actionType: Constants.PROFILE_SHOW
          profile:    res.body
  index_calls: (params) ->
    request
      .get '/api/profiles/#{profileId}/calls'
      .query(params)
      .end (err, res) ->
        AppDispatcher.dispatch
          actionType: Constants.CALLS_INDEX
          profile:    res.body

module.exports = ProfileActions
