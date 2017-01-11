bus          = require('EventBus').get('weaver')
rp           = require('request-promise')
config       = require('config')
Error        = require('weaver-commons').Error
WeaverError  = require('weaver-commons').WeaverError
Promise      = require('bluebird')
Validator    = require('jsonschema').Validator
authSchemas  = require('authSchemas')

createUri = (suffix) ->
  "#{config.get('services.flock.endpoint')}/#{suffix}"

doLogInCall = (res, suffix, usr, pass) ->
  auth = 'Basic ' + new Buffer(usr + ':' + pass).toString('base64')
  rp({
    method: 'GET',
    uri: createUri(suffix),
    headers: {'Authorization':auth},
    json: true
  })

doPermissionCall = (res, suffix, token) ->
  rp({
    method: 'GET',
    uri: createUri(suffix),
    headers: {'Authorization':token},
    json: true
  })
  
doSignUpCall = (res, suffix, token, newUserCredentials) ->
  rp({
    method: 'POST',
    uri: createUri(suffix),
    headers: {'Authorization':token},
    body: newUserCredentials,
    json: true
  })
  

validateJSONSchema = (jsonReq, jsonSch) ->
  v = new Validator()
  v.validate(jsonReq,jsonSch).valid
  
  
###
 Basic auth, the usr and pass
 http://localhost:9487/logIn?payload={"user":"phoenix","password":"Schaap"}
###


bus.on('logIn', (req, res) ->
  if !req.payload.user?
    Promise.reject(Error WeaverError.USERNAME_MISSING, 'USERNAME_MISSING')
  else if !req.payload.password?
    Promise.reject(Error WeaverError.PASSWORD_MISSING, 'PASSWORD_MISSING')
  else if !validateJSONSchema(req.payload,authSchemas.userCredentials)
    Promise.reject(Error WeaverError.DATATYPE_INVALID, 'DATATYPE_INVALID')
  else
    doLogInCall(res, 'token',req.payload.user,req.payload.password)
)

###
 Basic sign up action.
 Only an authentifyed user (with valid token) can performs this action (creates a user)
 http://localhost:9487/signUp
 {"newUserCredentials":{"userName": "aquarius","userEmail": "aqua@universe.uni","userPassword": "aquarius","directoryName":"SYSUNITE"},"access_token":"eyJhbGciOiJSUzI1NiJ9.eyIkaW50X3Blcm1zIjpbImRlbGV0ZV9hcHBsaWNhdGlvbiIsInJlYWRfYXBwbGljYXRpb24iLCJjcmVhdGVfcm9sZSIsImRlbGV0ZV9yb2xlIiwiY3JlYXRlX3Blcm1pc3Npb24iLCJjcmVhdGVfYXBwbGljYXRpb24iLCJkZWxldGVfZGlyZWN0b3J5IiwiZGVsZXRlX3Blcm1pc3Npb24iLCJjcmVhdGVfZGlyZWN0b3J5IiwicmVhZF91c2VyIiwiY3JlYXRlX3VzZXIiLCJyZWFkX3Blcm1pc3Npb24iLCJkZWxldGVfdXNlciIsInJlYWRfcm9sZSIsInJlYWRfZGlyZWN0b3J5Il0sInN1YiI6Im9yZy5wYWM0ai5tb25nby5wcm9maWxlLk1vbmdvUHJvZmlsZSNwaG9lbml4IiwiJGludF9yb2xlcyI6WyJwaG9lbml4Il0sIl9pZCI6IjU4NmY1OGNiYTFkMTQ3MTk0OTM2YTI2YSIsImV4cCI6MTQ4NDE1MDM1MCwiaWF0IjoxNDg0MDYzOTUwfQ.pfuWfiD3G6ZwLcAXaR_Ry4uWidOEpEVM1FHLQ9Bfs6RD0tpLxGtEtWnTX3h5F3AHqUkLP-D_e8k_cJhgLqxOu9Fh8AWcjllUEPcm2r8YshgeOuiGRNOCxMbRHHpl1_15sniXf6G4bLoUtAO402SDqdcwRy2flPLOunYbXCUz_kuMaSaMTJcKVGcmTdL5OM6GxwiNxzT6UXW7hzRkC5etUtDFVHSYmQBj9bBhatkPjOnuliXr6hOjvHjCOHKPFmb8W9Zy429mXMcc40AqeyUnDEN9Y7IXd-FEZaKNbf3BPf17p6dHtD7RrXj40XsMrIeO-zeVx6WKJElc3W7dHvg5_g"}
###

bus.on('signUp', (req,res) ->
  if !req.payload.access_token?
    Promise.reject(Error WeaverError.SESSION_MISSING, 'SESSION_MISSING')
  else if !req.payload.newUserCredentials?
    Promise.reject(Error WeaverError.DATATYPE_INVALID, 'DATATYPE_INVALID')
  else if !validateJSONSchema(req.payload.newUserCredentials,authSchemas.newUserCredentials)
    Promise.reject(Error WeaverError.DATATYPE_INVALID, 'DATATYPE_INVALID')
  else
    doSignUpCall(res,'users',req.payload.access_token,req.payload.newUserCredentials)
)


###
 Adding the filters, by now just for reading
 http://localhost:9487/read?payload={"user":"phoenix","access_token":"eyJhbGciOiJSUzI1NiJ9.eyIkaW50X3Blcm1zIjpbImRlbGV0ZV9hcHBsaWNhdGlvbiIsInJlYWRfYXBwbGljYXRpb24iLCJjcmVhdGVfcm9sZSIsImRlbGV0ZV9yb2xlIiwiY3JlYXRlX3Blcm1pc3Npb24iLCJjcmVhdGVfYXBwbGljYXRpb24iLCJkZWxldGVfZGlyZWN0b3J5IiwiZGVsZXRlX3Blcm1pc3Npb24iLCJjcmVhdGVfZGlyZWN0b3J5IiwicmVhZF91c2VyIiwiY3JlYXRlX3VzZXIiLCJyZWFkX3Blcm1pc3Npb24iLCJkZWxldGVfdXNlciIsInJlYWRfcm9sZSIsInJlYWRfZGlyZWN0b3J5Il0sInN1YiI6Im9yZy5wYWM0ai5tb25nby5wcm9maWxlLk1vbmdvUHJvZmlsZSNwaG9lbml4IiwiJGludF9yb2xlcyI6WyJwaG9lbml4Il0sIl9pZCI6IjU4NmY1OGNiYTFkMTQ3MTk0OTM2YTI2YSIsImV4cCI6MTQ4NDA0MDQwMSwiaWF0IjoxNDgzOTU0MDAxfQ.H7CEIbc_9157SHrU7VO0aBV9a40AAavPY4HEPm6Qw1AS0mrXWW5Ae4Sv-4lm0PwxvG1LhTsp9ZFW-faeNWhmJN0Aj37ZLLV5MEpFyVIpl91FnA_g0jKHWedRdzX8NvPcNMGqempWc49hgzLyFsm71Zcqp1ah2IaZ_oIHOGahz-DyUzkFI3hEF67iZeYrAfQp42a-Gi40QYUKOUPxbNBfAMQe5QcbyB1Qs75RwXg5AwJknGfyrfz4gNkkIEkAV5kvvoSoLFBsvi-v_NzkgQjh1DQbjim4X8dXIDEq7GX5b8OxEg6zrwKcdEQazdyYm1g8HgerivcdYOBB8Z9HKy3vAQ"}
###

bus.filter('read', (req, res) ->
  if !req.payload.user?
    Promise.reject(Error WeaverError.USERNAME_MISSING, 'USERNAME_MISSING')
  else if !req.payload.access_token?
    Promise.reject(Error WeaverError.SESSION_MISSING, 'SESSION_MISSING')
  else
    doPermissionCall(res,"users/permissions/#{req.payload.user}",req.payload.access_token)
)

