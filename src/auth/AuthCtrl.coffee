bus          = require('EventBus').get('weaver')
rp           = require('request-promise')
config       = require('config')
Error        = require('weaver-commons').Error
WeaverError  = require('weaver-commons').WeaverError
Promise      = require('bluebird')
Validator    = require('jsonschema').Validator
authSchemas  = require('authSchemas')
logger       = require('logger')
_            = require('lodash')
_            = require('lodash/core')
pick         = require('lodash/pick')

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

doGETCall = (res, suffix, token) ->
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
  
doSignOffCall = (res, suffix, token, user) ->
  rp({
    method: 'DELETE',
    uri: createUri(suffix),
    headers: {'Authorization':token},
    json: true
  })

validateJSONSchema = (jsonReq, jsonSch) ->
  v = new Validator()
  v.validate(jsonReq,jsonSch).valid
  
errorCodeParserFlock = (res) ->
  # For signUp error cases
  if res.statusCode is 409
    Promise.reject(Error WeaverError.DUPLICATE_VALUE, 'Duplication error, username or email is already taken.')
  # For logIn error cases
  else if res.statusCode is 401
    if !!~ res.error.Error.message.indexOf "account"
      Promise.reject(Error WeaverError.USERNAME_NOT_FOUND, res.error.Error.message)
    else if !!~ res.error.Error.message.indexOf "credentials"
      Promise.reject(Error WeaverError.PASSWORD_INCORRECT, 'The password is incorrect.')
    else
      Promise.reject(Error WeaverError.OTHER_CAUSE, 'There was an unexpected error.')
  else
    Promise.reject(Error WeaverError.OTHER_CAUSE, 'There was an unexpected error.')
  
###
 Basic auth, the usr and pass
 http://localhost:9487/logIn?payload={"user":"phoenix","password":"Schaap"}
###


bus.on('logIn', (req, res) ->
  if !req.payload.user?
    Promise.reject(Error WeaverError.USERNAME_MISSING, 'The username is missing.')
  else if !req.payload.password?
    Promise.reject(Error WeaverError.PASSWORD_MISSING, 'The password is missing.')
  else if !validateJSONSchema(req.payload,authSchemas.userCredentials)
    Promise.reject(Error WeaverError.DATATYPE_INVALID, 'The provided data is not valid.')
  else
    doLogInCall(res, 'token',req.payload.user,req.payload.password)
    .then((re) ->
      Promise.resolve(re)
    ).catch((err) ->
      errorCodeParserFlock(err)
    )
)



###
 Basic sign up action.
 Only an authentifyed user (with valid token) can performs this action (creates a user)
 http://localhost:9487/signUp
 {"newUserCredentials":{"userName": "aquarius","userEmail": "aqua@universe.uni","userPassword": "aquarius","directoryName":"SYSUNITE"},"accessToken":"eyJhbGciOiJSUzI1NiJ9.eyIkaW50X3Blcm1zIjpbImRlbGV0ZV9hcHBsaWNhdGlvbiIsInJlYWRfYXBwbGljYXRpb24iLCJjcmVhdGVfcm9sZSIsImRlbGV0ZV9yb2xlIiwiY3JlYXRlX3Blcm1pc3Npb24iLCJjcmVhdGVfYXBwbGljYXRpb24iLCJkZWxldGVfZGlyZWN0b3J5IiwiZGVsZXRlX3Blcm1pc3Npb24iLCJjcmVhdGVfZGlyZWN0b3J5IiwicmVhZF91c2VyIiwiY3JlYXRlX3VzZXIiLCJyZWFkX3Blcm1pc3Npb24iLCJkZWxldGVfdXNlciIsInJlYWRfcm9sZSIsInJlYWRfZGlyZWN0b3J5Il0sInN1YiI6Im9yZy5wYWM0ai5tb25nby5wcm9maWxlLk1vbmdvUHJvZmlsZSNwaG9lbml4IiwiJGludF9yb2xlcyI6WyJwaG9lbml4Il0sIl9pZCI6IjU4NmY1OGNiYTFkMTQ3MTk0OTM2YTI2YSIsImV4cCI6MTQ4NDE1MDM1MCwiaWF0IjoxNDg0MDYzOTUwfQ.pfuWfiD3G6ZwLcAXaR_Ry4uWidOEpEVM1FHLQ9Bfs6RD0tpLxGtEtWnTX3h5F3AHqUkLP-D_e8k_cJhgLqxOu9Fh8AWcjllUEPcm2r8YshgeOuiGRNOCxMbRHHpl1_15sniXf6G4bLoUtAO402SDqdcwRy2flPLOunYbXCUz_kuMaSaMTJcKVGcmTdL5OM6GxwiNxzT6UXW7hzRkC5etUtDFVHSYmQBj9bBhatkPjOnuliXr6hOjvHjCOHKPFmb8W9Zy429mXMcc40AqeyUnDEN9Y7IXd-FEZaKNbf3BPf17p6dHtD7RrXj40XsMrIeO-zeVx6WKJElc3W7dHvg5_g"}
###

bus.on('signUp', (req,res) ->
  if !req.payload.accessToken?
    Promise.reject(Error WeaverError.SESSION_MISSING, 'A valid session token is missing.')
  else if !req.payload.newUserCredentials?
    Promise.reject(Error WeaverError.DATATYPE_INVALID, 'The provided data is not valid.')
  else if !validateJSONSchema(req.payload.newUserCredentials,authSchemas.newUserCredentials)
    Promise.reject(Error WeaverError.DATATYPE_INVALID, 'The provided data is not valid.')
  else
    doSignUpCall(res,'users',req.payload.accessToken,req.payload.newUserCredentials)
    .then((re) ->
      Promise.resolve()
    ).catch((err) ->
      errorCodeParserFlock(err)
    )
)

###
  Deletes a user from weaver-flock
  http://localhost:9487/signOff
  {"user":"aquarius","accessToken":"eyJhbGciOiJSUzI1NiJ9.eyIkaW50X3Blcm1zIjpbImRlbGV0ZV9hcHBsaWNhdGlvbiIsInJlYWRfYXBwbGljYXRpb24iLCJjcmVhdGVfcm9sZSIsImRlbGV0ZV9yb2xlIiwiY3JlYXRlX3Blcm1pc3Npb24iLCJjcmVhdGVfYXBwbGljYXRpb24iLCJkZWxldGVfZGlyZWN0b3J5IiwiZGVsZXRlX3Blcm1pc3Npb24iLCJjcmVhdGVfZGlyZWN0b3J5IiwicmVhZF91c2VyIiwiY3JlYXRlX3VzZXIiLCJyZWFkX3Blcm1pc3Npb24iLCJkZWxldGVfdXNlciIsInJlYWRfcm9sZSIsInJlYWRfZGlyZWN0b3J5Il0sInN1YiI6Im9yZy5wYWM0ai5tb25nby5wcm9maWxlLk1vbmdvUHJvZmlsZSNwaG9lbml4IiwiJGludF9yb2xlcyI6WyJwaG9lbml4Il0sIl9pZCI6IjU4NzYwMTRjNDEwZGY4MDAwMWQ3NWNiYyIsImV4cCI6MTQ4NDIyMzYxNywiaWF0IjoxNDg0MTM3MjE3fQ.bKt1nsTm5srgdZKJb-PUvZDkkTlZ1xCLSuffzimmE6xui27C5QuTr1-yjzqwxE97WwiNxETvLE3_AnAF9nXjnXy9815CxHkjb6wVC2T6NB6tMdosRn7i8xNPWpdlUwGDJIjiwtp9OUE7k3CCZj9SWAfavOvNzlclEtSC2a8jaKJWqQba7_pgOHPXeAAvjXsyI7UYUiSKNXMKQN1UITCxI7CONKYNFpDiZT5MfyXkH4ShX5poZmElO4FNGelManIDmdsUMFsjD7qxXpcL0-vXbbVgPzX04hqNwOSvHKMP2cRTqe2IDJ5wNpgipX6wsVqHNe0xP56kqXlZLd2U5rxXiQ"}
###

bus.on('signOff', (req, res) ->
  if !req.payload.accessToken?
    Promise.reject(Error WeaverError.SESSION_MISSING, 'A valid session token is missing.')
  else if !req.payload.user?
    Promise.reject(Error WeaverError.USERNAME_MISSING, 'The username is missing.')
  else
    doSignOffCall(res,"users/#{req.payload.user}",req.payload.accessToken)
  
)

bus.on('permissions', (req, res) ->
  if !req.payload.accessToken?
    Promise.reject(Error WeaverError.SESSION_MISSING, 'A valid session token is missing.')
  else if !req.payload.user?
    Promise.reject(Error WeaverError.USERNAME_MISSING, 'The username is missing.')
  else
    doGETCall(res,"users/permissions/#{req.payload.user}",req.payload.accessToken)
)

bus.on('usersList', (req, res) ->
  if !req.payload.accessToken?
    Promise.reject(Error WeaverError.SESSION_MISSING, 'A valid session token is missing.')
  else if !validateJSONSchema(req.payload,authSchemas.listUsers)
    Promise.reject(Error WeaverError.DATATYPE_INVALID, 'The provided data is not valid.')
  else
    doGETCall(res,"users?directory=#{req.payload.directory}",req.payload.accessToken)
    .then((res) ->
      users = []
      for user in res
        users.push(_.pick(user,['userName','userEmail']))
      Promise.resolve(users)
    ).catch((err) ->
      errorCodeParserFlock(err)
    )
)

###
 Filters TODO: move to other file?
###

###
 Adding the filters, by now just for reading
 http://localhost:9487/read?payload={"user":"phoenix","accessToken":"eyJhbGciOiJSUzI1NiJ9.eyIkaW50X3Blcm1zIjpbImRlbGV0ZV9hcHBsaWNhdGlvbiIsInJlYWRfYXBwbGljYXRpb24iLCJjcmVhdGVfcm9sZSIsImRlbGV0ZV9yb2xlIiwiY3JlYXRlX3Blcm1pc3Npb24iLCJjcmVhdGVfYXBwbGljYXRpb24iLCJkZWxldGVfZGlyZWN0b3J5IiwiZGVsZXRlX3Blcm1pc3Npb24iLCJjcmVhdGVfZGlyZWN0b3J5IiwicmVhZF91c2VyIiwiY3JlYXRlX3VzZXIiLCJyZWFkX3Blcm1pc3Npb24iLCJkZWxldGVfdXNlciIsInJlYWRfcm9sZSIsInJlYWRfZGlyZWN0b3J5Il0sInN1YiI6Im9yZy5wYWM0ai5tb25nby5wcm9maWxlLk1vbmdvUHJvZmlsZSNwaG9lbml4IiwiJGludF9yb2xlcyI6WyJwaG9lbml4Il0sIl9pZCI6IjU4NmY1OGNiYTFkMTQ3MTk0OTM2YTI2YSIsImV4cCI6MTQ4NDA0MDQwMSwiaWF0IjoxNDgzOTU0MDAxfQ.H7CEIbc_9157SHrU7VO0aBV9a40AAavPY4HEPm6Qw1AS0mrXWW5Ae4Sv-4lm0PwxvG1LhTsp9ZFW-faeNWhmJN0Aj37ZLLV5MEpFyVIpl91FnA_g0jKHWedRdzX8NvPcNMGqempWc49hgzLyFsm71Zcqp1ah2IaZ_oIHOGahz-DyUzkFI3hEF67iZeYrAfQp42a-Gi40QYUKOUPxbNBfAMQe5QcbyB1Qs75RwXg5AwJknGfyrfz4gNkkIEkAV5kvvoSoLFBsvi-v_NzkgQjh1DQbjim4X8dXIDEq7GX5b8OxEg6zrwKcdEQazdyYm1g8HgerivcdYOBB8Z9HKy3vAQ"}
###

bus.filter('read', (req, res) ->
  if !req.payload.user?
    Promise.reject(Error WeaverError.USERNAME_MISSING, 'The username is missing.')
  else if !req.payload.accessToken?
    Promise.reject(Error WeaverError.SESSION_MISSING, 'A valid session token is missing.')
  else
    doGETCall(res,"users/permissions/#{req.payload.user}",req.payload.accessToken).then((res)->
      if 'read_role' in res
        Promise.resolve()
      else
        Promise.reject(Error WeaverError.OPERATION_FORBIDDEN,'You do not have rights to perform this operation.')
    ).catch((err) ->
      if err.code is WeaverError.OPERATION_FORBIDDEN
        Promise.reject(Error WeaverError.OPERATION_FORBIDDEN,'You do not have rights to perform this operation.')
      else
        Promise.reject(Error WeaverError.INVALID_SESSION_TOKEN,'A valid session token is missing.')
    )
)
