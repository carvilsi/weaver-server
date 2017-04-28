config          = require('config')
pjson           = require('../../package.json')
bus             = require('WeaverBus')
UserService     = require('UserService')
AclService      = require('AclService')
RoleService     = require('RoleService')
ProjectService  = require('ProjectService')
ProjectPool     = require('ProjectPool')
DatabaseService = require('DatabaseService')
Promise         = require('bluebird')
logger          = require('logger')
conf            = require('config')


# Version
bus.public('application.version').on(->
  pjson.version
)

# Server time
bus.public('application.time').on(->
  servertime = new Date().getTime()
  servertime
)

# Provide Weaver SKD
bus.provide("weaver").retrieve('project').on((req, project) ->

  Weaver = require('weaver-sdk')
  weaver = Weaver.getWeaver()

  adminUser = conf.get('admin.username')
  adminPass = conf.get('admin.password')

  weaver.signInWithUsername(adminUser, adminPass).then( =>
    weaverProject = new Weaver.Project(project.name, project.id)
    weaver.useProject(weaverProject)

    new Weaver.Query().hasRelationOut("type", Weaver.Node.get("SpaceType")).find().then((r) -> console.log(r))

    weaver
  ).catch((error)->
    logger.code.error(error)
  )
)


# Complete system wipe of all data
bus.public('application.wipe').enable(config.get('application.wipe')).on((req) ->

  logger.usage.info "Wiping all the data on the server"

  # Wipe all project data first
  projects = ProjectService.all()
  endpoints = (p.database for p in projects)
  databases = (new DatabaseService(endpoint) for endpoint in endpoints)

  Promise.map(databases, (database) ->
    logger.usage.info "Wiping database: #{database.uri}"
    database.wipe()
  ).then(->
    # Wipe all users and projects
    Promise.all([
      UserService.wipe()
      AclService.wipe()
      RoleService.wipe()
      ProjectService.wipe()
    ])
  ).then(->
    Promise.map(projects, (p) ->
      logger.usage.debug "Destroying project: #{p.id}"
      ProjectPool.clean(p.id)
    )
  )
)
