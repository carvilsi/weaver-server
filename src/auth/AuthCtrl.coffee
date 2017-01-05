bus    = require('EventBus').get('weaver')
rp     = require('request-promise')
config = require('config')
Error        = require('weaver-commons').Error
WeaverError  = require('weaver-commons').WeaverError
Promise      = require('bluebird')


createUri = (suffix) ->
  console.log "#{config.get('services.flock.prot')}://#{config.get('services.flock.host')}:#{config.get('services.flock.port')}#{config.get('services.flock.endPoint')}/#{suffix}"
  "#{config.get('services.flock.prot')}://#{config.get('services.flock.host')}:#{config.get('services.flock.port')}#{config.get('services.flock.endPoint')}/#{suffix}"

doLogInCall = (res, suffix, usr, pass) ->
  auth = 'Basic ' + new Buffer(usr + ':' + pass).toString('base64')
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

doPermissionCall = (res, suffix, token) ->
  res.promise(
    rp({
      method:'GET',
      uri: createUri(suffix),
      headers:{
        'Authorization':token
      },
      json: true
    })
  )

###
 Basic auth, the usr and pass (TODO: implement the login @weaver-sdk)
###


bus.on('logIn', (req, res) ->
  doLogInCall(res, 'token',req.query.user,req.query.password)
  .then( (res) ->
    console.log res
  )
  .catch( (res) ->
    
  )
)

###
 Adding the filters, by now just for reading
###

bus.filter('read', (event, req, res) ->
  #
  if !req.query.user?
    res.error(Promise.reject(Error WeaverError.USERNAME_MISSING, 'USERNAME_MISSING'))
    false
  
  if !req.query.access_token?
    res.error(Promise.reject(Error WeaverError.SESSION_MISSING, 'SESSION_MISSING'))
    false
  #
  promise = doPermissionCall(res,"users/permissions/#{req.query.user}",req.query.access_token)
  
  console.log promise
  
  # console.log  res
  # console.log promise
  
  # res.then(
  #   console.log 'ok'
  # )
  #
  # res.catch(
  #   console.log 'nok'
  # )
  # .then(
  #   console.log 'ok'
  # )
  # .catch(
  #   console.log 'nok'
  # )
  
  
  # false
)

