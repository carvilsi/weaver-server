Promise     = require('bluebird')
config      = require('config')
bus         = require('EventBus').get('weaver')
expect      = require('util/bus').getExpect(bus)
DbService   = require('DatabaseService')
Error       = require('weaver-commons').Error
WeaverError = require('weaver-commons').WeaverError


# NOTE: Functionality described here needs to match that in KubernetesProjectCtrl
# This file is intended for development environments without access to a k8s cluster

serviceDatabase = new DbService(config.get('services.database.endpoint'))
databases = {}


# For each project, fetch the name in the database.
# It will return an {id, name} pair
bus.on('project', (req, res) ->  
  Promise.map((id for id of databases), (id) ->
    serviceDatabase.read(id)
  ).then((projects) ->
    ({id: p.id, name: p.name} for p in projects)
  )  
)

expect('id').bus('project.create').do((req, res, id) ->
  if databases[id]?
    Promise.reject(Error(WeaverError.OTHER_CAUSE, "Project with #{id} already exists."))
  else
    databases[id] = {ready: 0}  # Keep track of ready calls to simulate delay
)

expect('id').bus('project.delete').do((req, res, id) ->
  delete databases[id]
)

# Tests whether given project is created and ready
expect('id').bus('project.ready').do((req, res, id) ->
  new Promise((resolve, reject) ->

    if not databases[id]?
      reject(Error(WeaverError.OTHER_CAUSE, "Project with #{id} does not exists."))

    # Ready after 3 tries
    ready = databases[id].ready > 3
    
    if not ready
      databases[id].ready++
    else
      databases[id].ready = 0  # Reset
    
    resolve({ready})
  )
)

bus.on('getDatabaseForProject', (project) ->
  Promise.resolve(serviceDatabase.uri)
)