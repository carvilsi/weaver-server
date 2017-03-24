config     = require('config')
bus        = require('WeaverBus')
tracker    = require('Tracker')



bus.private('write').enable(config.get('services.tracker.enabled')).retrieve('user', 'project').on((req, user, project) ->
  tracker.processWrites(req.payload.operations, user, project)
  return
)

bus.private('history').on((req) ->
  tracker.getHistoryFor(req)
)
