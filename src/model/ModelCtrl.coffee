bus           = require('WeaverBus')
AclService    = require('AclService')
ModelService  = require('ModelService')
logger        = require('logger')

bus.provide('model').require('name', 'version').on((req, name, version) ->
  ModelService.get(name, version)
)

# TODO: Assert read access
bus.private('model.read').retrieve('user').retrieve('model').on((req, user, model) ->
  logger.usage.info "User #{user.username} retrieved model #{model.name}"
  model
)
