bus          = require('EventBus').get('weaver')
rp           = require('request-promise')
config       = require('config')
Error        = require('weaver-commons').Error
WeaverError  = require('weaver-commons').WeaverError
Promise      = require('bluebird')
Validator    = require('jsonschema').Validator
authSchemas  = require('authSchemas')
logger       = require('logger')

createUri = (suffix) ->
  "#{config.get('services.flock.endpoint')}/#{suffix}"
  
doCreateApplicationCall = (res, suffix, token, newApplication) ->
  rp({
    method: 'POST',
    uri: createUri(suffix),
    headers: {'Authorization':token},
    body: newApplication,
    json: true
  })
  
doGetCall = (res, suffix, token, application) ->
  rp({
    method: 'GET',
    uri: createUri(suffix),
    headers: {'Authorization':token},
    json: true
  })

validateJSONSchema = (jsonReq, jsonSch) ->
  v = new Validator()
  v.validate(jsonReq,jsonSch).valid
  
validateAuthRequest = (req, schema) ->
  if !req.payload.accessToken?
    Promise.reject(Error WeaverError.SESSION_MISSING, 'A valid session token is missing.')
  else if !validateJSONSchema(req.payload,schema)
    Promise.reject(Error WeaverError.DATATYPE_INVALID, 'The provided data is not valid. Try something like: {\"applicationName\":\"fooApp\",\"projectName\":\"barProj\",\"accessToken\":\"Whatever\"}')
  else
    Promise.resolve(req)
  
errorCodeParserFlock = (res) ->
  if res.statusCode is 400
    Promise.reject(Error WeaverError.DATATYPE_INVALID, 'The provided data is not valid.')
  else if res.statusCode is 403
    Promise.reject(Error WeaverError.OPERATION_FORBIDDEN, 'You do not have rights to perform this operation.')
  else
    Promise.reject(Error WeaverError.OTHER_CAUSE, 'There was an unexpected error.')

###
 Creates an application by now known as project
###

bus.on('createApplication', (req, res) ->
  validateAuthRequest(req, authSchemas.newApplication)
  .then((req) ->
    doCreateApplicationCall(res,'applications',req.payload.accessToken,{applicationName:"#{req.payload.projectName}_#{req.payload.applicationName}"})
  ).then((re) ->
    Promise.resolve(re)
  ).catch((err) ->
    if err.code?
      Promise.reject(err)
    else
      errorCodeParserFlock(err)
  )
)

###
 Return an application
###

bus.on('getApplication', (req, res) ->
  validateAuthRequest(req, authSchemas.getApplication)
  .then((req) ->
    doGetCall(res,"applications/#{req.payload.applicationName}",req.payload.accessToken)
  ).then((re) ->
    Promise.resolve(re)
  ).catch((err) ->
    if err.code?
      Promise.reject(err)
    else
      errorCodeParserFlock(err)
  )
)

###
 Retrieving all the applications
###
bus.on('listApplication', (req, res) ->
  if !req.payload.accessToken?
    Promise.reject(Error WeaverError.SESSION_MISSING, 'A valid session token is missing.')
  else
    doGetCall(res,'applications',req.payload.accessToken)
    .then((re) ->
      Promise.resolve(re)
    ).catch((err) ->
      errorCodeParserFlock(err)
    )
)

###
 Return permissions from an application
###
bus.on('permissionApplication', (req, res) ->
  if !req.payload.accessToken?
    Promise.reject(Error WeaverError.SESSION_MISSING, 'A valid session token is missing.')
  else
    doGetCall(res,'applications',req.payload.accessToken)
    .then((re) ->
      Promise.resolve(re)
    ).catch((err) ->
      errorCodeParserFlock(err)
    )
)

