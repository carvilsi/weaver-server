Promise         = require('bluebird')
config          = require('config')
DatabaseService = require('DatabaseService')
bus             = require('EventBus').get('weaver')
expect          = require('util/bus').getExpect(bus)

systemDatabase  = new DatabaseService(config.get('services.systemDatabase.endpoint'))

# Helper function to get the designated database based on target
getDb = (target) ->
  console.log
  if target is '$SYSTEM'
    Promise.resolve(systemDatabase)
  else
    bus.emit('getDatabaseForProject', target).then((endpoint) ->
      new DatabaseService(endpoint)
    )


expect('target').bus('read').do((req, res, target) ->
  getDb(target).then((db) ->
    db.read(req.payload.nodeId)
  )
)

expect('target').bus('write').do((req, res, target) ->
  getDb(target).then((db) ->
    db.write(req.payload.operations)
  )
)

expect('target').bus('wipe').do((req, res, target) ->
  getDb(target).then((db) ->
    db.wipe()
  )
)

