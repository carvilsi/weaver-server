bus         = require('EventBus').get('weaver')
expect      = require('util/bus').getExpect(bus)
config      = require('config')
rp          = require('request-promise')
Error       = require('weaver-commons').Error
WeaverError = require('weaver-commons').WeaverError
Promise     = require('bluebird')
logger      = require('logger')

# NOTE: The functionality in this file needs to be equivalent to that in SingleDatabaseProjectCtrl, this is 
# leading for production systems and other installs which have a k8s cluster available.

serviceProject  = config.get('services.project.endpoint')
  
createUri = (suffix) ->
  "#{serviceProject}/#{suffix}"

doCall = (suffix) ->
  uri = createUri(suffix)
  logger.debug "Going to GET request \"#{uri}\""
  rp({
    uri: uri
    json: true
  }).then((res) ->
    logger.debug "Call result"
    logger.debug res
    res
  )

bus.on('project', (res, req) ->
  Promise.resolve(doCall("list"))
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

bus.on('getDatabaseForProject', (project) ->
  doCall("status/#{id}").then((status) ->
    Promise.resolve(status.service)
  )
)
