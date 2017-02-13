bus         = require('WeaverBus')
config      = require('config')
rp          = require('request-promise')
Weaver      = require('weaver-sdk')
Error       = Weaver.LegacyError
WeaverError = Weaver.Error
Promise     = require('bluebird')
logger      = require('logger')

# NOTE: The functionality in this file needs to be equivalent to that in SingleDatabaseProjectCtrl, this is
# leading for production systems and other installs which have a k8s cluster available.

serviceProject  = config.get('services.projectController.endpoint')

createUri = (suffix) ->
  "#{serviceProject}/#{suffix}"

doCall = (suffix) ->
  uri = createUri(suffix)
  rp({
    uri: uri
    json: true
  })

bus.private('project').on( ->
  doCall("list")
)

bus.private('project.create').require('id').on((req, id) ->
  doCall("create/#{id}")
)

bus.private('project.delete').require('id').on((req, id) ->
  doCall("delete/#{id}")
)

bus.private('project.ready').require('id').on((req, id) ->
  doCall("status/#{id}").then((status) ->
    { ready: status.ready }
  )
)

bus.internal('getDatabaseForProject').on((project) ->
  doCall("status/#{project}").then((status) ->
    status.services.service
  )
)

bus.internal('getMinioForProject').on((project) ->
  doCall("status/#{project}").then((status) ->
    MinioClient.create({
      endpoint: status.services.minio
      region: 'us-east-1' 
      accessKey: status.minio.MINIO_ACCESS_KEY
      secretKey: status.minio.MINIO_SECRET_KEY
      secure: false
    })
  )
)

logger.info("K8s project controller loaded")
