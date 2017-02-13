Promise     = require('bluebird')
config      = require('config')
bus         = require('WeaverBus')
DbService   = require('DatabaseService')
Weaver      = require('weaver-sdk')
Error       = Weaver.LegacyError
WeaverError = Weaver.Error
MinioClient = require('MinioClient')
logger      = require('logger')


# NOTE: Functionality described here needs to match that in KubernetesProjectCtrl
# This file is intended for development environments without access to a k8s cluster
serviceDatabase = new DbService(config.get('services.projectDatabase.endpoint'))
databases = {}


bus.private('project.create').require('id').on((req, id) ->
  if databases[id]?
    Promise.reject(Error(WeaverError.OTHER_CAUSE, "Project with #{id} already exists."))
  else
    databases[id] = {ready: 0}  # Keep track of ready calls to simulate delay
)

bus.private('project.delete').require('id').on((req, id) ->
  delete databases[id]
)

# Tests whether given project is created and ready
bus.private('project.ready').require('id').on((req, id) ->
  new Promise((resolve, reject) ->

    if not databases[id]?
      reject(Error(WeaverError.OTHER_CAUSE, "Project with #{id} does not exists."))

    # Ready after 3 tries
    ready = databases[id].ready > 3

    if not ready
      databases[id].ready++
    else
      databases[id].ready = 0  # Reset

    resolve({ready})
  )
)

bus.internal('getDatabaseForProject').on((project) ->
  Promise.resolve(serviceDatabase.uri)
)

bus.internal('getMinioForProject').on((project) ->
  logger.debug "Getting minio for #{project}"
  Promise.resolve(MinioClient.create(config.get('services.fileSystem')))
)

logger.info("Single database project controller loaded")
