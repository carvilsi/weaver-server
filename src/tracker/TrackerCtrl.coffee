config        = require('config')
bus           = require('WeaverBus')
Tracker       = require('Tracker')
Promise       = require('bluebird')
logger        = require('logger')
AclService    = require('AclService')

trackers = {}

bus.private('history').retrieve('tracker', 'user', 'project').on((req, tracker, user, project) ->
  AclService.assertProjectFunctionPermission(user, project, 'history')
  logger.usage.info "History requested for project #{project.projectId} by user #{user.username}"
  tracker.getHistoryFor(req)
)

bus.provide('tracker').retrieve('project','database').on((req, project, database) ->
  if not trackers[project.id]?
    trackers[project.id] = new Tracker(database)
  trackers[project.id]
)
