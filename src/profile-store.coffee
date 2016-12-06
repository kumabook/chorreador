AppDispatcher = require './app-dispatcher'
EventEmitter  = require('events').EventEmitter
Constants     = require './constants'
assign        = require 'object-assign'

CHANGE_EVENT = 'change'

_profiles = []
_profile = null

ProfileStore = assign {}, EventEmitter.prototype,
  getAll: ->
    _profiles = chorreador.profiles
    _profiles
  getById: (id) ->
    _profiles = chorreador.profiles
    items = _profiles.filter((p) -> p.id == parseInt(id))
    if items.length > 0 then items[0] else null
  getCurrent: ->
    _profile
  emitChange: ->
    this.emit CHANGE_EVENT
  addChangeListener: (callback) ->
    this.on CHANGE_EVENT, callback
  removeChangeListener: (callback) ->
    this.removeListener CHANGE_EVENT, callback
AppDispatcher.register (action) ->
  switch action.actionType
    when Constants.PROFILE_INDEX
      _profiles = action.profiles
      ProfileStore.emitChange()
    when Constants.PROFILE_SHOW
      _profile = action.profile
      ProfileStore.emitChange()

module.exports = ProfileStore
