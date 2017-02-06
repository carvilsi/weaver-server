Promise         = require('bluebird')
config          = require('config')
DatabaseService = require('DatabaseService')
bus             = require('WeaverBus')
expect          = require('util/bus').getExpect(bus)

systemDatabase  = new DatabaseService(config.get('services.systemDatabase.endpoint'))

# Helper function to get the designated database based on target
getDb = (target) ->
  if target is '$SYSTEM'
    Promise.resolve(systemDatabase)
  else
    bus.get("internal").emit('getDatabaseForProject', target).then((endpoint) ->
      new DatabaseService(endpoint)
    )


bus.private('read').require('target').on((req, target) ->
  getDb(target).then((db) ->
    db.read(req.payload.nodeId)
  )
)

bus.private('write').require('target').on((req, target) ->
  getDb(target).then((db) ->
    db.write(req.payload.operations)
  )
)

bus.private('wipe').require('target').on((req, target) ->
  getDb(target).then((db) ->
    db.wipe()
  )
)

