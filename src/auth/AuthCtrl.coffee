bus    = require('EventBus').get('weaver')
rp     = require('request-promise')
config = require('config')

createUri = (suffix) ->
  console.log "#{config.get('services.flock.prot')}://#{config.get('services.flock.host')}:#{config.get('services.flock.port')}#{config.get('services.flock.endPoint')}/#{suffix}"
  "#{config.get('services.flock.prot')}://#{config.get('services.flock.host')}:#{config.get('services.flock.port')}#{config.get('services.flock.endPoint')}/#{suffix}"

doCall = (res, suffix) ->
  auth = 'Basic ' + new Buffer('phoenix' + ':' + 'Schaap').toString('base64') # hardcoded by now
  res.promise(
    rp({
      method:'GET',
      uri: createUri(suffix),
      headers:{
        'Authorization':auth
      },
      json: true
    })
  )

bus.on('logIn', (req, res) ->
  console.log '=^^=|_'
  doCall(res, 'token')
)

###
 
 This bus filter response is answering with false, so it will reject the other on.read
 
+bus.filter('read', (event, req, res) ->
+  res.error("Filter says no")
+  false
+)
+
 bus.on('write', (req, res)->
   res.promise(handler.write(req.payload))
-)

###


