bus          = require('WeaverBus')
rp           = require('request-promise')
config       = require('config')
Weaver       = require('weaver-sdk')
Error        = Weaver.LegacyError
WeaverError  = Weaver.Error
Promise      = require('bluebird')
Validator    = require('jsonschema').Validator
authSchemas  = require('authSchemas')
logger       = require('logger')

# Let all authentication go through here, and have a similar service for Projects
UserService = require('UserService')

bus.private('users.create').on((req,res) ->
  console.log(req.payload.id)
  Promise.resolve()
)
