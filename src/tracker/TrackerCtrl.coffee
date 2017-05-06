config        = require('config')
bus           = require('WeaverBus')
Tracker       = require('Tracker')
Promise       = require('bluebird')
logger        = require('logger')
operationSort = require('operationSort')

trackers = {}

bus.private('write').retrieve('tracker', 'user', 'project').on((req, tracker, user, project) ->
  if tracker?
    req.payload.operations.sort(operationSort)
    tracker.processWrites(req.payload.operations, user, project)
  return
)

bus.private('history').retrieve('tracker').on((req, tracker) ->
  tracker.getHistoryFor(req)

bus.provide('tracker').retrieve('project').on((req, project) ->
  if not trackers[project.id]?
    trackers[project.id] = new Tracker(project.tracker)
  trackers[project.id]
))
