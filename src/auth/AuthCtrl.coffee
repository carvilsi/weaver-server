bus    = require('EventBus').get('weaver')
rp     = require('request-promise')
config = require('config')
Error        = require('weaver-commons').Error
WeaverError  = require('weaver-commons').WeaverError
Promise      = require('bluebird')


createUri = (suffix) ->
  "#{config.get('services.flock.prot')}://#{config.get('services.flock.host')}:#{config.get('services.flock.port')}#{config.get('services.flock.endPoint')}/#{suffix}"

doLogInCall = (res, suffix, usr, pass) ->
  auth = 'Basic ' + new Buffer(usr + ':' + pass).toString('base64')
  rp({
    method:'GET',
    uri: createUri(suffix),
    headers:{'Authorization':auth},
    json: true
  })

doPermissionCall = (res, suffix, token) ->
  rp({
    method:'GET',
    uri: createUri(suffix),
    headers:{'Authorization':token},
    json: true
  })
  
  
###
 Basic auth, the usr and pass (TODO: implement the login @weaver-sdk)
 http://localhost:9487/logIn?user=phoenix&password=Schaap
###


bus.on('logIn', (req, res) ->
  if !req.query.user?
    Promise.reject(Error WeaverError.USERNAME_MISSING, 'USERNAME_MISSING')
  else if !req.query.password?
    Promise.reject(Error WeaverError.PASSWORD_MISSING, 'PASSWORD_MISSING')
  else
    doLogInCall(res, 'token',req.query.user,req.query.password)
)

###
 Adding the filters, by now just for reading
 http://localhost:9487/read?user=phoenix&access_token=eyJhbGciOiJSUzI1NiJ9.eyIkaW50X3Blcm1zIjpbXSwic3ViIjoib3JnLnBhYzRqLm1vbmdvLnByb2ZpbGUuTW9uZ29Qcm9maWxlI3Bob2VuaXgiLCIkaW50X3JvbGVzIjpbIlJPTEVfUEhPRU5JWCJdLCJfaWQiOiI1ODZjYjc5OTQxMGRmODAwMDE4M2M3NjAiLCJleHAiOjE0ODM3MTg1ODAsImlhdCI6MTQ4MzYzMjE4MH0.xxbH5-Xhpiz99Gpyfg_ArWdUd1cqMcprpzPL-em4l_Nbx0X7jAYiLfGFmdgOFkb8dPHwqewR9HKS_OFYm14bwV96CdL3u_sWQfFREe5k6ejEDGQnAmAb6DSAEM-Q1oM_BQB2ItvklxON5DbSFDSRoSv4a_kCnQ5uWZ_NgXbvAPfhzJTLb-ASXJHo3XxP42t9R63D6R6_Grw3GnBvXelzAARdAqZFoHo4V5CedKHDi6Gu72r1ZmVq2PISpRlRiBVVdFaiKNdBmoY9t_B0IfOtHTfFf0Bb7NnoSAJGfYQvkKVeEDKAOMJmY5tdWG2miT8HkbAWkAUXTSK7j-QDKEbW8g
###

bus.filter('read', (req, res) ->
  if !req.query.user?
    Promise.reject(Error WeaverError.USERNAME_MISSING, 'USERNAME_MISSING')
  else if !req.query.access_token?
    Promise.reject(Error WeaverError.SESSION_MISSING, 'SESSION_MISSING')
  else
    doPermissionCall(res,"users/permissions/#{req.query.user}",req.query.access_token)
)

