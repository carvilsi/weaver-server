Promise     = require('bluebird')
config      = require('config')
bus         = require('WeaverBus')
DbService   = require('DatabaseService')
Weaver      = require('weaver-sdk')
Error       = Weaver.LegacyError
WeaverError = Weaver.Error
MinioClient = require('MinioClient')
logger         = require('logger')

ProjectService = require('ProjectService')
ProjectPool    = require('ProjectPool')
UserService    = require('UserService')


bus.private('project').on((req) ->
  ProjectService.all()
)

bus.private('project.create').retrieve('user').require('id', 'name').on((req, user, id, name) ->

  ProjectPool.create().then((project) ->

    # Create an ACL for this user to set on the project
    acl = UserService.createACL(id, user)
    ProjectService.create(id, name, project.database, acl.id)

    return
  )
)

bus.private('project.delete').retrieve('project', 'database').on((req, project, database) ->
  Promise.all([
    database.wipe()
    ProjectService.delete(project)
  ])
)

bus.private('project.ready').require('id').on((req, id) ->
  ProjectPool.isReady(id)
)

bus.internal('getMinioForProject').on((project) ->
  logger.debug "Getting minio for #{project}"
  Promise.resolve(MinioClient.create(config.get('services.fileSystem')))
)
