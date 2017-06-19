Promise         = require('bluebird')
config          = require('config')
bus             = require('WeaverBus')
MinioClient     = require('MinioClient')
ProjectService  = require('ProjectService')
ProjectPool     = require('ProjectPool')
AclService      = require('AclService')
DatabaseService = require('DatabaseService')
logger          = require('logger')



bus.provide("project").require('target').on((req, target) ->
  ProjectService.get(target)
)

bus.provide("database").retrieve('user', 'project').on((req, user, project) ->
  AclService.assertACLReadPermission(user, project.acl)
  new DatabaseService(project.database)
)

# Move to FileController
bus.provide('minio').retrieve('project').on((req, project) ->
  MinioClient.create(project.fileServer)
)

bus.private('project').on((req) ->
  ProjectService.all()
)

bus.private('project.create').retrieve('user').require('id', 'name').on((req, user, id, name) ->
  AclService.assertACLWritePermission(user, 'create-projects')

  ProjectPool.create(id).then((project) ->

    # Create an ACL for this user to set on the project
    acl = AclService.createACL(id, user)
    ProjectService.create(id, name, project.database, acl.id, project.fileServer, project.tracker)

    return
  )
)

bus.private('project.delete').retrieve('project', 'database', 'minio', 'tracker').on((req, project, database, minio, tracker) ->
  logger.usage.info "Deleting project with id #{project.id}"
  Promise.all([
    tracker.wipe()
    database.wipe()
    ProjectPool.clean(project.id)
    ProjectService.delete(project)
  ])
)

bus.private('project.ready').require('id').on((req, id) ->
  ProjectPool.isReady(id)
)

bus.internal('getMinioForProject').on((project) ->
  Promise.resolve(MinioClient.create(ProjectService.get(project).fileServer))
)

# Create a snapshot with write operations for the project
bus.private('snapshot').retrieve('project').on((req, project) ->
  logger.usage.info "Generating snapshot for project with id #{project.id}"
  database = new DatabaseService(project.database)
  database.snapshot()
)

# Wipe single project
bus.public('project.wipe').retrieve('project').on((req, project) ->
  logger.usage.info "Wiping project with id #{project.id}"
  database = new DatabaseService(project.database)
  database.wipe()
)


# Wipe all projects
bus.public('projects.wipe').enable(config.get('application.wipe')).on((req) ->
  logger.usage.info "Wiping all projects"

  endpoints = (p.database for p in ProjectService.all())
  databases = (new DatabaseService(endpoint) for endpoint in endpoints)

  Promise.map(databases, (database) ->
    logger.usage.info "Wiping database: #{database.uri}"
    database.wipe()
  )
)


# Destroy all projects
bus.public('projects.destroy').enable(config.get('application.wipe')).on((req) ->

  logger.usage.info "Destroying all projects"

  Promise.map(ProjectService.all(), (p) ->
    logger.usage.debug "Destroying project: #{p.id}"
    ProjectPool.clean(p.id).catch((err) ->
      logger.usage.warn "Error cleaning project id #{p.id}"
      Promise.resolve()
    )
  ).then(->
    logger.code.debug "Calling wipe on the project service"
    ProjectService.wipe().then( ->
      logger.code.debug "ProjectService promise completed"
    )
  )
)
