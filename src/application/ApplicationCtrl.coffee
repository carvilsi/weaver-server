config          = require('config')
pjson           = require('../../package.json')
bus             = require('WeaverBus')
UserService     = require('UserService')
AclService      = require('AclService')
RoleService     = require('RoleService')
ProjectService  = require('ProjectService')
DatabaseService = require('DatabaseService')
Promise         = require('bluebird')
logger          = require('logger')

# Version
bus.public('application.version').on(->
  pjson.version
)

# Server time
bus.public('application.time').on(->
  servertime = new Date().getTime()
  servertime
)

# Complete system wipe of all data
bus.public('application.wipe').enable(config.get('application.wipe')).on((req) ->

  logger.usage.info "Wiping all the data on the server"

  # Wipe all project data first
  projects = ProjectService.all()
  endpoints = (p.endpoint for p in projects)
  databases = (new DatabaseService(endpoint) for endpoint in endpoints)

  Promise.map(databases, (database) ->
    logger.usage.info "Wiping database: #{database.uri}"
    database.wipe()
  ).then(->
    # Wipe all users and projects
    logger.usage.debug "Wiping users"
    UserService.wipe()
    logger.usage.debug "Wiping acl"
    AclService.wipe()
    logger.usage.debug "Wiping roles"
    RoleService.wipe()
    logger.usage.debug "Wiping projects"
    ProjectService.wipe()
  ).then(->
    Promise.map(projects, (p) ->
      logger.usage.debug "Destroying project: #{p.id}"
      p.destroy()
    )
  )
)
