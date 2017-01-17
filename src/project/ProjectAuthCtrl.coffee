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

validateJSONSchema = (jsonReq, jsonSch) ->
  v = new Validator()
  v.validate(jsonReq,jsonSch).valid
  
validateAuthRequest = (req) ->
  if !req.payload.accessToken?
    Promise.reject(Error WeaverError.SESSION_MISSING, 'A valid session token is missing.')
  else if !validateJSONSchema(req.payload,authSchemas.newApplication)
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

bus.on('application', (req, res) ->
  validateAuthRequest(req)
  .then((req) ->
    doCreateApplicationCall(res,'applications',req.payload.accessToken,{application:"#{req.payload.projectName}_#{req.payload.applicationName}"})
  ).then((re) ->
    Promise.resolve()
  ).catch((err) ->
    errorCodeParserFlock(err)
  )
)