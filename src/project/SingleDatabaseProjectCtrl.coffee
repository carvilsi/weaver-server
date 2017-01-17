bus         = require('EventBus').get('weaver')
config      = require('config')
Error       = require('weaver-commons').Error
WeaverError = require('weaver-commons').WeaverError
Promise     = require('bluebird')

# NOTE: Functionality described here needs to match that in KubernetesProjectCtrl
# This file is intended for development environments without access to a k8s cluster

serviceDatabase = config.get('services.database.endpoint')

databases = []
startId = 0

bus.on('project', (req, res) ->
  Promise.resolve(databases)
)

bus.on('project.create', (req, res) ->
  if !req.payload.name?
    Promise.reject(Error(WeaverError.OTHER_CAUSE, "Missing parameter name"))

  prj = { name: req.payload.name, id: startId }
  databases.push prj
  startId = startId + 1
  prj
)

bus.on('project.delete', (req, res) ->
  if !req.payload.id?
    Promise.reject(Error(WeaverError.OTHER_CAUSE, "Missing parameter id"))

  index = j for i, j in databases when i.id = req.payload.id
)

bus.on('getDatabaseForProject', (project) ->
  Promise.resolve(serviceDatabase)
)
