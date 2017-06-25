config        = require('config')
bus           = require('WeaverBus')
Tracker       = require('Tracker')
Promise       = require('bluebird')
logger        = require('logger')
operationSort = require('operationSort')
AclService    = require('AclService')

trackers = {}

bus.private('write').retrieve('tracker', 'user', 'project').on((req, tracker, user, project) ->
  if tracker?
    req.payload.operations.sort(operationSort)
    tracker.processWrites(req.payload.operations, user, project)
  return
)

bus.private('history').retrieve('tracker', 'user', 'project').on((req, tracker, user, project) ->
  AclService.assertProjectFunctionPermission(user, project, 'history')
  logger.usage.info "History requested for project #{project.projectId} by user #{user.username}"
  tracker.getHistoryFor(req)

bus.provide('tracker').retrieve('project').on((req, project) ->
  if not trackers[project.id]?
    trackers[project.id] = new Tracker(project.tracker)
  trackers[project.id]
))
