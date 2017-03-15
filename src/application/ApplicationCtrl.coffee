config          = require('config')
pjson           = require('../../package.json')
bus             = require('WeaverBus')
UserService     = require('UserService')
AclService      = require('AclService')
RoleService     = require('RoleService')
ProjectService  = require('ProjectService')
DatabaseService = require('DatabaseService')
Promise         = require('bluebird')

# Version
bus.public('application.version').on(->
  pjson.version
)

# Complete system wipe of all data
bus.public('application.wipe').enable(config.get('application.wipe')).on((req) ->

  # Wipe all project data first
  endpoints = (p.endpoint for p in ProjectService.all())
  databases = (new DatabaseService(endpoint) for endpoint in endpoints)

  Promise.map(databases, (database) ->
    database.wipe()
  ).then(->

    # Wipe all users and projects
    UserService.wipe()
    AclService.wipe()
    RoleService.wipe()
    ProjectService.wipe()
  )
)
