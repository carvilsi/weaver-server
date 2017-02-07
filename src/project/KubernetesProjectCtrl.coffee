bus         = require('WeaverBus')
expect      = require('util/bus').getExpect(bus)
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

bus.on('project', (res, req) ->
  doCall("list")
)

expect('id').bus('project.create').do((res, req, id) ->
  doCall("create/#{id}")
)

expect('id').bus('project.delete').do((res, req, id) ->
  doCall("delete/#{id}")
)

expect('id').bus('project.ready').do((res, req, id) ->
  doCall("status/#{id}").then((status) ->
    { ready: status.ready }
  )
)

bus.on('getDatabaseForProject', (id) ->
  doCall("status/#{id}").then((status) ->
    Promise.resolve(status.service)
  )
)

logger.info("K8s project controller loaded")
