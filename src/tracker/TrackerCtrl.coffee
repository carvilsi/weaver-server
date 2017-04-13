config     = require('config')
bus        = require('WeaverBus')

bus.private('write').retrieve('tracker', 'user', 'project').on((req, tracker, user, project) ->
  if tracker?
    tracker.processWrites(req.payload.operations, user, project)
  return
)

bus.private('history').retrieve('tracker').on((req, tracker) ->
  tracker.getHistoryFor(req)

bus.provide('tracker').retrieve('project').on((req, project) ->
))
