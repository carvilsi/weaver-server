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
  ProjectService.all()
)

# TODO: Add name from the SDK
bus.private('project.create').retrieve('user').require('id', 'name').on((req, user, id, name) ->

# Get an unused database endpoint
  allEndpoints       = config.get('databasePool')
  usedEndpoints      = (p.endpoint for p in ProjectService.all())
  availableEndpoints = allEndpoints.filter((endpoint) -> usedEndpoints.indexOf(endpoint) is -1)

  # TODO: Test this in WeaverProject.test
  if availableEndpoints.length is 0
    throw {code: -1, message: "No more available endpoints to use for new project #{name}"}

  endpoint = availableEndpoints[0]

  # Create an ACL for this user to set on the project
  acl = UserService.createACL(id, user)
  ProjectService.create(id, name, endpoint, acl.id)
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
