# TODO: Change this to use ProjectService
# TODO: Add project object to route req

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
UserService    = require('UserService')


# NOTE: Functionality described here needs to match that in KubernetesProjectCtrl
# This file is intended for development environments without access to a k8s cluster
serviceDatabase = new DbService(config.get('services.projectDatabase.endpoint'))
databases = {}


bus.private('project').on((req) ->
  ProjectService.list()
)

# TODO: Add name from the SDK
bus.private('project.create').retrieve('user').require('id').on((req, user, id, name) ->
  name = 'unnamed'
  ProjectService.create(id, name)
  acl = UserService.createACL(id, user)
  return
)

bus.private('project.delete').require('id').on((req, id) ->
  ProjectService.delete(id)
  return
)

bus.private('project.ready').require('id').on((req, id) ->
  {ready: true}
)


# PUT these in req object
bus.internal('getDatabaseForProject').on((project) ->
  Promise.resolve(serviceDatabase.uri)
)

bus.internal('getMinioForProject').on((project) ->
  logger.debug "Getting minio for #{project}"
  Promise.resolve(MinioClient.create(config.get('services.fileSystem')))
)

logger.info("Single database project controller loaded")
