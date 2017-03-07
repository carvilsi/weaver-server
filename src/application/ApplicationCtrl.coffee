config         = require('config')
pjson          = require('../../package.json')
bus            = require('WeaverBus')
UserService    = require('UserService')
ProjectService = require('ProjectService')

# Version
bus.public('application.version').on(->
  pjson.version
)

# Complete system wipe of all data
bus.private('application.wipe').enable(config.get('application.wipe')).retrieve('user').on((req, user) ->
  UserService.clear()
  ProjectService.clear()
  return
)
